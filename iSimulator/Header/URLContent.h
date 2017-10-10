//
//  header.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//
#import <Foundation/Foundation.h>

/** 设备路径 */
extern NSString *const devicesPath;
/** 应用路径 */
extern NSString *const applicationPath;
/** 应用状态文件 */
extern NSString *const applicationStatesPlist;
/** 设备所属应用路径 */
extern NSString *const applicationForDevice;
/** 设备文件 */
extern NSString *const deviceSetPlist;
extern NSString *const devicePlist;

/** 打开应用路径匹配文件 */
//extern NSString *const mobileContainerManagerPlist;
extern NSString *const mobileContainerManagerPlist_Identifier;

/** 首路径 */
OBJC_EXTERN NSURL * devicePathURL(void);
/** 设备路径 */
OBJC_EXTERN NSURL * deviceURL(NSString *UDID);
/** 设备数据路径 */
OBJC_EXTERN NSURL * deviceDataURL(NSString *UDID);
/** 应用路径 */
OBJC_EXTERN NSURL * applicationPathURL(NSString *UDID);
/** 设备所属应用路径 */
OBJC_EXTERN NSURL * applicationForDeviceURL(NSString *UDID);
/** 设备文件 */
OBJC_EXTERN NSURL * deviceSetPlistURL(void);
OBJC_EXTERN NSURL * devicePlistURL(void);
/** 应用路径匹配文件 */
OBJC_EXTERN NSURL * mobileContainerManagerPlistURL(NSURL *url);
