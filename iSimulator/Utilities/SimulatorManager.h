//
//  SimulatorManager.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Foundation/Foundation.h>
@class S_Device, S_AppInfo;

typedef void (^resultBlock)(NSArray<NSDictionary <NSString *, NSArray <S_Device *>*>*> *deviceList, NSArray <S_AppInfo *>*recentList);

@interface SimulatorManager : NSObject
/** 初始化 */
+ (instancetype)shareSimulatorManager;
/** 异步加载设备列表 */
- (void)loadSimulators:(resultBlock)complete;
/* 重新加载设备列表 */
- (void)reloadSimulators;

/** 异步获取沙盒大小 */
- (void)getSandboxSize:(S_AppInfo *)app complete:(void (^)(long long sandboxSize))complete;

/** 获取设备地址 */
- (NSURL *)getDeviceUrl:(S_Device *)device;
/** 打开设备目录 */
- (void)openDevicePath:(S_Device *)device;
/** 重置设备 */
- (void)resetDeviceData:(S_Device *)device;
/** 添加图片到设备 */
- (void)addPhotoToDevice:(S_Device *)device DEPRECATED_ATTRIBUTE;
/** 添加视频到设备 */
- (void)addVideoToDevice:(S_Device *)device DEPRECATED_ATTRIBUTE;
/** 添加媒体文件到设备[You can also specify multiple live photos by providing the photo and video files. They will automatically be discovered and imported correctly.] */
- (void)addMediaToDevice:(S_Device *)device;
/** 安装模拟器应用 */
- (void)installAppInDevice:(S_Device *)device;
/** 删除模拟器 */
- (void)deleteDevice:(S_Device *)device;
/** 同步粘贴板 */
- (void)pbsyncDevice:(S_Device *)device ToHost:(BOOL)toHost;

//========================分割线====================


/** 获取应用目录地址 */
- (NSURL *)getAppDocumentUrl:(S_AppInfo *)appInfo;
/** 打开应用目录 */
- (void)openAppDocument:(S_AppInfo *)appInfo;

/** 重置app数据 */
- (void)resetAppDataInSimulator:(S_AppInfo *)appInfo;
/** 启动模拟器应用 */
- (void)launchAppInSimulator:(S_AppInfo *)appInfo;
/** 卸载模拟器应用 */
- (void)uninstallAppInSimulator:(S_AppInfo *)appInfo;
@end
