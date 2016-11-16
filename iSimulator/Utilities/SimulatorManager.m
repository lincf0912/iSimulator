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

- (void)loadData:(void (^)())complete
{
    if (self.resultBlock == nil) return;
    dispatch_async(self.seialQueue, ^{
        NSString *jsonString = shell(@"/usr/bin/xcrun", @[@"simctl", @"list", @"-j", @"devices"]);
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        /** 数据源容器 */
        NSMutableArray *container = [NSMutableArray arrayWithCapacity:5];
        NSMutableArray *appList = [NSMutableArray arrayWithCapacity:5];
        /** 获取设备 */
        NSDictionary *devices = json[@"devices"];
        /** 设备版本 */
        for (NSString *version in devices) {
            /** 筛选iOS模拟器 */
            if ([version containsString:@"iOS"]) {
                /** 筛选可利用的模拟器 */
                NSMutableArray *data = [NSMutableArray array];
                NSArray *simulators = devices[version];
                for (NSDictionary *sim in simulators) {
                    S_Device *d = [[S_Device alloc] initWithDictionary:sim];
                    if (d.isUnavailable) {
                        continue;
                    }
                    [data addObject:d];
                    [appList addObjectsFromArray:d.appList];
                }
                if (data.count) {
                    /** 过滤历史模拟器 */
                    NSString *key = version;
                    NSString *oldVersion = @"com.apple.CoreSimulator.SimRuntime.";
                    if ([key containsString:oldVersion]) {
                        key = [[key substringToIndex:oldVersion.length] stringByReplacingOccurrencesOfString:@"-" withString:@","];
                    }
                    [container addObject:@{key:data}];
                }
            }
        }
        /** 筛选最近使用应用 */
        [appList sortUsingComparator:^NSComparisonResult(S_AppInfo *  _Nonnull obj1, S_AppInfo *  _Nonnull obj2) {
            return obj1.accessDateTime < obj2.accessDateTime;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.container = [container copy];
            self.resultBlock(self.container, [appList copy]);
            /** 开启监视 */
            if (self.monitor == nil) {
                [self startMointor];
            }
            if (complete) complete();
        });
    });
}

- (void)startMointor
{
    __weak typeof(self) weakSelf = self;
    /** 开启监视 */
    if (self.monitor == nil) {
        self.monitor = [[SimulatorMonitor alloc] init];
        
        void (^monitorUrl)() = ^{
            /** 监听设备URL */
            [self.monitor addMonitor:devicePathURL()];
            for (NSDictionary *dict in self.container) {
                for (NSString *key in dict) {
                    NSArray *devices = dict[key];
                    for (S_Device *device in devices) {
                        /** 只监听可用模拟器 */
                        if (device.isUnavailable == NO) {
                            /** 监听设备状态URL */
                            [self.monitor addMonitor:deviceURL(device.UDID)];
                            NSURL *applicationUrl = applicationForDeviceURL(device.UDID);
                            if ([[NSFileManager defaultManager] fileExistsAtPath:applicationUrl.path]) {
                                [self.monitor addMonitor:applicationUrl];
                            }
                        }
                    }
                }
            }
        };
        
        monitorUrl();
        [self.monitor start];
        
        [self.monitor setCompleteBlock:^(NSURL *url) {
            /** 如果非应用目录变化，则需要刷新监听列表 */
            BOOL isNotAPPUrl = ![url.path containsString:applicationForDevice];
            if (isNotAPPUrl) {
                [weakSelf.monitor cancelWithUrl:url];
            }
            [weakSelf loadData:^{
                if (isNotAPPUrl) {
                    [weakSelf.monitor cancel];
                    /** 重置监听 */
                    monitorUrl();
                }
            }];
        }];
    }
}

- (void)cancelMointor
{
    if (self.monitor) {
        [self.monitor setCompleteBlock:nil];
        [self.monitor cancel];
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
    /** 需要先shutdown 但shutdown会导致模拟器卡死 */
    shell(@"xcrun simctl erase ", @[device.UDID]);
}

- (void)addPhotoToDevice:(S_Device *)device
{
    [OpenFinder multipleSelectFile:@[@"png", @"jpg", @"jpeg"] complete:^(NSArray<NSURL *> *urls) {
        //xcrun simctl addphoto <device> <path> [... <path>]
        NSMutableString *urlStr = [NSMutableString stringWithString:@""];
        for (NSURL *url in urls) {
            [urlStr appendFormat:@"\"%@\"", [url path]];
            [urlStr appendString:@" "];
        }
        if (urlStr.length) {
            shell(@"xcrun simctl addphoto ", @[device.UDID, urlStr]);
        }
    }];
}

- (void)addVideoToDevice:(S_Device *)device
{
    [OpenFinder multipleSelectFile:@[@"mp4"] complete:^(NSArray<NSURL *> *urls) {
        //xcrun simctl addvideo <device> <path> [... <path>]
        NSMutableString *urlStr = [NSMutableString stringWithString:@""];
        for (NSURL *url in urls) {
            [urlStr appendFormat:@"\"%@\"", [url path]];
            [urlStr appendString:@" "];
        }
        if (urlStr.length) {
            shell(@"xcrun simctl addvideo ", @[device.UDID, urlStr]);
        }
    }];
}

- (void)installAppInSimulator:(S_Device *)device
{
    [OpenFinder selectFile:@[@"app"] complete:^(NSURL *url) {
        //xcrun simctl install booted <path>
        shell(@"xcrun simctl install booted ", @[[NSString stringWithFormat:@"\"%@\"", url.path]]);
    }];
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
    NSURL *appUrl = [self getAppDocumentUrl:appInfo];
    if (appUrl) {
        shell(@"rm -rf ", @[[appUrl.path stringByAppendingPathComponent:@"Documents/*"]]);
        shell(@"rm -rf ", @[[appUrl.path stringByAppendingPathComponent:@"Library/*"]]);
        shell(@"rm -rf ", @[[appUrl.path stringByAppendingPathComponent:@"tmp/*"]]);
    }
}
- (void)launchAppInSimulator:(S_AppInfo *)appInfo
{
    shell(@"open -a \"Simulator.app\" --args -CurrentDeviceUDID ", @[appInfo.UDID]);
    shell(@"xcrun simctl launch booted ", @[appInfo.bundleId]);
}

- (void)uninstallAppInSimulator:(S_AppInfo *)appInfo
{
    shell(@"xcrun simctl uninstall booted ", @[appInfo.bundleId]);
}

@end
