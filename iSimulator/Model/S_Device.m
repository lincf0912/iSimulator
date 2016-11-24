//
//  S_Device.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "S_Device.h"
#import "S_AppInfo.h"
#import "URLContent.h"

@interface S_Device ()

@property (nonatomic, strong) NSMutableArray<S_AppInfo *> *appInfoList;

@end

@implementation S_Device

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        _appInfoList = [NSMutableArray array];
        
        NSString *state = dictionary[@"state"];
        if ([state isEqualToString:@"Booting"]) {
            _state = DeviceState_Booting;
        } else if ([state isEqualToString:@"Booted"]) {
            _state = DeviceState_Booted;
        } else {
            _state = DeviceState_Shutdown;
        }
        
        _isUnavailable = [dictionary[@"availability"] containsString:@"unavailable"];
        _name = dictionary[@"name"];
        _UDID = dictionary[@"udid"];
        
        /** 获取设备下的应用列表 */
        NSURL *applicationForDevicePath = applicationForDeviceURL(self.UDID);
        NSArray *dirEnumerator = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:applicationForDevicePath includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLContentModificationDateKey] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsHiddenFiles error:nil];
        for (NSURL *fileURL in dirEnumerator) {
            id isDirectoryObj;
            if ([fileURL getResourceValue:&isDirectoryObj
                                   forKey:NSURLIsDirectoryKey
                                    error:NULL])
            {
                if ([isDirectoryObj boolValue]) {
                    S_AppInfo *app = [[S_AppInfo alloc] initWithURL:fileURL UDID:self.UDID deviceName:self.name];
                    if (app) {
                        [_appInfoList addObject:app];
                    }
                }
            }
        }
        
    }
    
    return self;
}

- (NSImage *)deviceIcon
{
    NSString *imageName = @"";
    switch (_state) {
        case DeviceState_Booting:
            imageName = [self.name containsString:@"iPad"] ? @"iPad-booting" : @"iPhone-booting";
            break;
        case DeviceState_Booted:
            imageName = [self.name containsString:@"iPad"] ? @"iPad-booted" : @"iPhone-booted";
            break;
        default:
            imageName = [self.name containsString:@"iPad"] ? @"iPad" : @"iPhone";
            break;
    }
    return [NSImage imageNamed:imageName];
}

- (NSArray<S_AppInfo *> *)appList
{
    return [self.appInfoList copy];
}

@end
