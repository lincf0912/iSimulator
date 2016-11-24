//
//  header.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "URLContent.h"

NSString *const devicesPath = @"Developer/CoreSimulator/Devices/";
NSString *const deviceSetPlist = @"device_set.plist";
NSString *const devicePlist = @"device.plist";

NSString *const applicationPath = @"data/Containers/Data/Application";
NSString *const applicationForDevice = @"data/Containers/Bundle/Application";

NSString *const mobileContainerManagerPlist = @".com.apple.mobile_container_manager.metadata.plist";
NSString *const mobileContainerManagerPlist_Identifier = @"MCMMetadataIdentifier";

NSURL * devicePathURL()
{
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    return [NSURL fileURLWithPath:[libraryPath stringByAppendingPathComponent:devicesPath]];
}

NSURL * deviceURL(NSString *UDID)
{
    if (UDID.length == 0) return nil;
    return [devicePathURL() URLByAppendingPathComponent:UDID];
}

NSURL * deviceDataURL(NSString *UDID)
{
    if (UDID.length == 0) return nil;
    return [deviceURL(UDID) URLByAppendingPathComponent:@"data"];
}

NSURL * applicationPathURL(NSString *UDID)
{
    return [deviceURL(UDID) URLByAppendingPathComponent:applicationPath];
}

NSURL * applicationForDeviceURL(NSString *UDID)
{
    return [deviceURL(UDID) URLByAppendingPathComponent:applicationForDevice];
}

NSURL * deviceSetPlistURL()
{
    return [devicePathURL() URLByAppendingPathComponent:deviceSetPlist];
}

NSURL * devicePlistURL()
{
    return [devicePathURL() URLByAppendingPathComponent:devicePlist];
}

NSURL * mobileContainerManagerPlistURL(NSURL *url)
{
    return [url URLByAppendingPathComponent:mobileContainerManagerPlist];
}
