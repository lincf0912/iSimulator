//
//  S_Device.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseModel.h"

typedef NS_ENUM(NSUInteger, DeviceState) {
    DeviceState_Shutdown,
    DeviceState_Booted,
    DeviceState_Booting,
};

@class S_AppInfo;
@interface S_Device : BaseModel

/** 应用列表 */
@property (nonatomic, readonly) NSArray<S_AppInfo *> *appList;
/** 是否正在使用 */
@property (nonatomic, readonly) DeviceState state;
/** 是否不可使用 */
@property (nonatomic, readonly) BOOL isUnavailable;
/** 设备名称 */
@property (nonatomic, copy, readonly) NSString *name;
/** 图标 */
@property (nonatomic, getter=deviceIcon) NSImage *deviceIcon;
/** 设备标识 */
@property (nonatomic, copy, readonly) NSString *UDID;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
