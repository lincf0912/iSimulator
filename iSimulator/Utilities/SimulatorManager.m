//
//  SimulatorManager.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "SimulatorManager.h"
#import "SimulatorMonitor.h"
#import "URLContent.h"
#import "Shell.h"

#import "NSAlert+Block.h"

#import "OpenFinder.h"

#import "S_AppInfo.h"
#import "S_Device.h"

@interface SimulatorManager ()

@property (nonatomic, strong) dispatch_queue_t seialQueue;
@property (nonatomic, copy) resultBlock resultBlock;

@property (nonatomic, strong) SimulatorMonitor *monitor;
@property (nonatomic, strong) NSArray<NSDictionary <NSString *, NSArray <S_Device *>*>*> *container;

@end

@implementation SimulatorManager

/** 初始化 */
+ (instancetype)shareSimulatorManager
{
    static SimulatorManager *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [SimulatorManager new];
        share.seialQueue = dispatch_queue_create("SimulatorManagerQueue", DISPATCH_QUEUE_SERIAL);
    });
    return share;
}

/** 异步加载数据 */
- (void)loadSimulators:(resultBlock)complete
{
    if (complete == nil) return;
    self.resultBlock = [complete copy];
    [self loadData:nil];
}

/* 重新加载设备列表 */
- (void)reloadSimulators
{
    [self loadData:nil];
}

- (void)loadData:(void (^)(void))complete
{
    if (self.resultBlock == nil) return;
    
    [self loadDevicesJson_async:^(NSDictionary *json) {
        if ([json isKindOfClass:[NSDictionary class]] == NO) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultBlock(@[], @[]);
                if (complete) complete();
            });
            return;
        }
        /** 数据源容器 */
        NSMutableArray *container = [NSMutableArray arrayWithCapacity:5];
        NSMutableArray *appList = [NSMutableArray arrayWithCapacity:5];
        /** 获取设备 */
        NSDictionary *devices = json[@"devices"];
        /** 设备版本 */
        for (NSString *version in devices) {
            /** 筛选可利用的模拟器 */
            NSMutableArray *dataList = [NSMutableArray array];
            NSArray *simulators = devices[version];
            for (NSDictionary *sim in simulators) {
                S_Device *d = [[S_Device alloc] initWithDictionary:sim];
                [dataList addObject:d];
                if (!d.isUnavailable) {
                    /** 可用模拟器才添加到最近列表 */
                    [appList addObjectsFromArray:d.appList];
                }
            }
            if (dataList.count) {
                /** 过滤历史模拟器 */
                NSString *key = version;
                NSString *oldVersion = @"com.apple.CoreSimulator.SimRuntime.";
                if ([key containsString:oldVersion]) {
                    key = [[key stringByReplacingOccurrencesOfString:oldVersion withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@"."];
                    key = [key stringByReplacingCharactersInRange:[key rangeOfString:@"."] withString:@" "];
                }
                [container addObject:@{key:dataList}];
            }
        }
        /** 筛选最近使用应用 */
        [appList sortUsingComparator:^NSComparisonResult(S_AppInfo *  _Nonnull obj1, S_AppInfo *  _Nonnull obj2) {
            return obj1.sortDateTime < obj2.sortDateTime;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.container = [container copy];
            self.resultBlock(self.container, [appList copy]);
            /** 开启监视 */
            [self startMointor];
            if (complete) complete();
        });
    }];
}


- (void)loadDevicesJson_async:(void (^)(NSDictionary *json))complete
{
    dispatch_async(self.seialQueue, ^{
        NSString *jsonString = shell(@"/usr/bin/xcrun", @[@"simctl", @"list", @"-j", @"devices"]);
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([json isKindOfClass:[NSDictionary class]] == NO) {
            if (complete) complete(nil);
        } else {
            if (complete) complete(json);
        }
    });
}

/* 删除所有不可用的模拟器 */
- (void)removeUnsimulators:(void (^)(void))complete
{
    dispatch_async(self.seialQueue, ^{
        NSArray *container = self.container;
        for (NSDictionary *dict in container) {
            for (NSString *key in dict) {
                NSArray *devices = dict[key];
                for (S_Device *device in devices) {
                    if (device.isUnavailable) {
                        shell(@"xcrun simctl delete ", @[device.UDID]);
                        NSURL *deviceURL = [self getDeviceUrl:device];
                        [[NSFileManager defaultManager] removeItemAtURL:deviceURL error:nil];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete();
            }
        });
    });
}

/** 获取最新的设备版本 */
- (NSString *)latestDeviceVersion
{
    NSArray *container = self.container;
    NSMutableArray <NSString *>*versions = [NSMutableArray array];
    for (NSDictionary *dict in container) {
        [versions addObjectsFromArray:dict.allKeys];
    }
    [versions sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch|NSNumericSearch];
    }];
    return versions.lastObject;
}

/** 删除旧的模拟器 */
- (void)removeOldSimulators:(void (^)(void))complete
{
    dispatch_async(self.seialQueue, ^{
        NSString *latestVersion = [self latestDeviceVersion];
        NSArray *container = self.container;
        for (NSDictionary *dict in container) {
            for (NSString *key in dict) {
                if ([key isEqualToString:latestVersion]) {
                    continue;
                }
                NSArray *devices = dict[key];
                for (S_Device *device in devices) {
                    shell(@"xcrun simctl delete ", @[device.UDID]);
                    NSURL *deviceURL = [self getDeviceUrl:device];
                    [[NSFileManager defaultManager] removeItemAtURL:deviceURL error:nil];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete();
            }
        });
    });
}

- (void)startMointor
{
    /** 开启监视 */
    if (self.monitor == nil) {
        self.monitor = [[SimulatorMonitor alloc] init];
        
        __weak typeof(self) weakSelf = self;

        void (^monitorUrl)(SimulatorMonitor *) = ^(SimulatorMonitor *monitor){
            /** 监听设备URL */
            [monitor addMonitor:devicePathURL()];
            NSArray *container = weakSelf.container;
            for (NSDictionary *dict in container) {
                for (NSString *key in dict) {
                    NSArray *devices = dict[key];
                    for (S_Device *device in devices) {
                        /** 监听设备状态URL */
                        NSURL *deviceUrl = deviceURL(device.UDID);
                        if ([[NSFileManager defaultManager] fileExistsAtPath:deviceUrl.path]) {
                            [monitor addMonitor:deviceUrl];
                        }
                        /** 监听设备数据URL */
                        NSURL *deviceDataUrl = deviceDataURL(device.UDID);
                        if ([[NSFileManager defaultManager] fileExistsAtPath:deviceDataUrl.path]) {
                            [monitor addMonitor:deviceDataUrl];
                        }
                        /** 监听应用变化 */
                        NSURL *applicationUrl = applicationForDeviceURL(device.UDID);
                        if ([[NSFileManager defaultManager] fileExistsAtPath:applicationUrl.path]) {
                            [monitor addMonitor:applicationUrl];
                        }
                    }
                }
            }
        };
        
        /* 监听URL */
        monitorUrl(self.monitor);
        [self.monitor start];
        
        [self.monitor setCompleteBlock:^(NSURL *url) {
            /* 因为loadData的命令会触发目录变化，所以在loadData之前需要取消对目录的监听 */
            [weakSelf.monitor cancelWithUrl:url];
            [weakSelf loadData:^{
                [weakSelf.monitor cancel];
                /** 重置监听 */
                monitorUrl(weakSelf.monitor);
                [weakSelf.monitor start];
            }];
        }];
    }
}

/** 异步获取沙盒大小 */
- (void)getSandboxSize:(S_AppInfo *)app complete:(void (^)(long long sandboxSize))complete
{
    if (complete == nil) return;
    dispatch_async(self.seialQueue, ^{
        long long sandBoxSize = 0;
        NSURL *fileUrl = nil;
        /** 沙盒大小 */
        NSURL *sandboxUrl = [self getAppDocumentUrl:app];
        if (sandboxUrl) {
            NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:sandboxUrl includingPropertiesForKeys:nil options:0 errorHandler:nil];
            while (fileUrl = [dirEnumerator nextObject]) {
                NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileUrl.path error:nil];
                sandBoxSize += attributes.fileSize;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            complete(sandBoxSize);
        });
    });
}

#pragma mark - 设备
- (NSURL *)getDeviceUrl:(S_Device *)device
{
    if (device) {
        return deviceURL(device.UDID);
    }
    return nil;
}

- (void)openDevicePath:(S_Device *)device
{
    NSURL *deviceUrl = [self getDeviceUrl:device];
    if (deviceUrl) {
        [[NSWorkspace sharedWorkspace] openURL:deviceUrl];
    }
}

- (void)resetDeviceData:(S_Device *)device
{
    NSAlert *alert = [NSAlert alertWithInfoTitle:@"Are you sure you want to reset the Simulator content and settings?" message:@"All installed applications, content, and settings will be moved to the trash. This process may take a few moment, please be patient." cancelButtonTitle:@"Reset" otherButtonTitles:@[@"Don't Reset"]];
    [alert showSheetModalForWindow:[NSApp windows].firstObject completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            /** 需要先shutdown 但shutdown会导致模拟器卡死 */
            shell(@"xcrun simctl shutdown ", @[device.UDID]);
            sleep(0.5);
            shell(@"xcrun simctl erase ", @[device.UDID]);
            sleep(0.5);
            shell(@"killAll Simulator", nil);
            sleep(0.5);
//            shell(@"open -a \"Simulator.app\" --args -CurrentDeviceUDID ", @[device.UDID]);
            shell(@"xcrun instruments -w ", @[device.UDID]);
//            shell(@"xcrun simctl boot ", @[device.UDID]);
        }
    }];
}

- (void)addPhotoToDevice:(S_Device *)device DEPRECATED_ATTRIBUTE
{
    [OpenFinder multipleSelectFile:@[@"png", @"jpg", @"jpeg"] complete:^(NSArray<NSURL *> *urls) {
        //xcrun simctl addphoto <device> <path> [... <path>]
        for (NSURL *url in urls) {
            NSString *urlPath = [NSString stringWithFormat:@"\"%@\"", [url path]];
            if (urlPath.length) {
                shell(@"xcrun simctl addphoto ", @[device.UDID, urlPath]);
            }
        }
    }];
}

- (void)addVideoToDevice:(S_Device *)device DEPRECATED_ATTRIBUTE
{
    [OpenFinder multipleSelectFile:@[@"mp4"] complete:^(NSArray<NSURL *> *urls) {
        //xcrun simctl addvideo <device> <path> [... <path>]
        for (NSURL *url in urls) {
            NSString *urlPath = [NSString stringWithFormat:@"\"%@\"", [url path]];
            if (urlPath.length) {
                shell(@"xcrun simctl addvideo ", @[device.UDID, urlPath]);
            }
        }
    }];
}

- (void)addMediaToDevice:(S_Device *)device
{
    [OpenFinder multipleSelectFile:@[@"png", @"jpg", @"jpeg", @"HEIC", @"gif", @"mp4", @"mov"] complete:^(NSArray<NSURL *> *urls) {
        //xcrun simctl addmedia <device> <path> [... <path>]
        for (NSURL *url in urls) {
            NSString *urlPath = [NSString stringWithFormat:@"\"%@\"", [url path]];
            if (urlPath.length) {
                shell(@"xcrun simctl addmedia ", @[device.UDID, urlPath]);
            }
        }
    }];
}

- (void)installAppInDevice:(S_Device *)device
{
    [OpenFinder selectFile:@[@"app"] complete:^(NSURL *url) {
        //xcrun simctl install booted <path>
        if (url) {
            shell(@"xcrun instruments -w ", @[device.UDID]);
            shell(@"xcrun simctl install booted ", @[[NSString stringWithFormat:@"\"%@\"", url.path]]);
        }
    }];
}

- (void)deleteDevice:(S_Device *)device
{
    NSAlert *alert = [NSAlert alertWithInfoTitle:@"Are you sure you want to delete the Simulator?" message:@"Permanent and unrecoverable，it cannot turn back into its previous stage." cancelButtonTitle:@"Delete" otherButtonTitles:@[@"Don't Delete"]];
    [alert showSheetModalForWindow:[NSApp windows].firstObject completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            shell(@"xcrun simctl delete ", @[device.UDID]);
            NSURL *deviceURL = [self getDeviceUrl:device];
            [[NSFileManager defaultManager] removeItemAtURL:deviceURL error:nil];
        }
    }];
}

- (void)pbsyncDevice:(S_Device *)device ToHost:(BOOL)toHost
{
    if (toHost) {
        shell(@"xcrun simctl pbsync ", @[device.UDID, @"host"]);
    } else {
        shell(@"xcrun simctl pbsync ", @[@"host", device.UDID]);
    }
}

#pragma mark - 应用

- (NSURL *)getAppDocumentUrl:(S_AppInfo *)appInfo
{
    if (appInfo == nil) return nil;
    NSURL *url = applicationPathURL(appInfo.UDID);
    NSArray *dirEnumerator = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
    
    NSURL *appUrl = nil;
    for (NSURL *dirUrl in dirEnumerator) {
        NSDictionary *mobileContainerManager = [NSDictionary dictionaryWithContentsOfURL:mobileContainerManagerPlistURL(dirUrl)];
        if ([mobileContainerManager[mobileContainerManagerPlist_Identifier] isEqualToString:appInfo.bundleId]) {
            appUrl = dirUrl;
            break;
        }
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:appUrl.path])
    {
        return appUrl;
    }
    return nil;
}

- (void)openAppDocument:(S_AppInfo *)appInfo
{
    NSURL *appUrl = [self getAppDocumentUrl:appInfo];
    if (appUrl) {
        [[NSWorkspace sharedWorkspace] openURL:appUrl];
    }
}

- (void)resetAppDataInSimulator:(S_AppInfo *)appInfo
{
    NSAlert *alert = [NSAlert alertWithInfoTitle:@"Are you sure you want to reset the Application Data?" message:@"Documents, Library, and tmp will be moved to the trash. This process may take a few moment, please be patient." cancelButtonTitle:@"ResetApp" otherButtonTitles:@[@"Don't ResetApp"]];
    [alert showSheetModalForWindow:[NSApp windows].firstObject completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSURL *appUrl = [self getAppDocumentUrl:appInfo];
            if (appUrl) {
                NSArray *dirEnumerator = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:appUrl includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsHiddenFiles error:nil];
                for (NSURL *dirUrl in dirEnumerator) {
                    shell(@"rm -rf ", @[[dirUrl.path stringByAppendingPathComponent:@"*"]]);
                }
            }
        }
    }];
}
- (void)launchAppInSimulator:(S_AppInfo *)appInfo
{
    shell(@"xcrun instruments -w ", @[appInfo.UDID]);

    shell(@"xcrun simctl launch booted ", @[appInfo.bundleId]);
}

- (void)uninstallAppInSimulator:(S_AppInfo *)appInfo
{
    NSAlert *alert = [NSAlert alertWithInfoTitle:@"Are you sure you want to uninstall the Application?" message:[NSString stringWithFormat:@"the %@ application will be uninstall from the device.", appInfo.bundleDisplayName] cancelButtonTitle:@"Uninstall" otherButtonTitles:@[@"Don't Uninstall"]];
    [alert showSheetModalForWindow:[NSApp windows].firstObject completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            shell(@"xcrun instruments -w ", @[appInfo.UDID]);
            shell(@"xcrun simctl terminate ", @[appInfo.UDID, appInfo.bundleId]);
            sleep(1);
            shell(@"xcrun simctl uninstall booted ", @[appInfo.bundleId]);
        }
    }];
}

@end
