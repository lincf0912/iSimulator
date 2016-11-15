//
//  ApplicationMenuItem.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/10.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class S_AppInfo, ApplicationMenuItem;

@protocol ApplicationMenuItemDelegate <NSObject>

/** 子菜单点击事件回调 */
@optional

- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem revealSandboxInFileViewer:(S_AppInfo *)app;
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem launchInSimulator:(S_AppInfo *)app;
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem copySandboxPathToPasteboard:(S_AppInfo *)app;
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem resetData:(S_AppInfo *)app;
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem uninstall:(S_AppInfo *)app;

@end

@interface ApplicationMenuItem : NSMenuItem

- (instancetype)initWithApp:(S_AppInfo *)app;
- (instancetype)initWithApp:(S_AppInfo *)app withDetailText:(NSString *)detailText;


@property (nonatomic, weak) id<ApplicationMenuItemDelegate> delegate;

@end
