//
//  MainMenu.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainMenu;

@protocol MainMenuDelegate <NSObject>

@optional
/** 关于 */
- (void)mainMenuAboutApp:( MainMenu * _Nonnull )mainMenu;
/** 偏好设置 */
- (void)mainMenuPreferencesApp:(MainMenu * _Nonnull )mainMenu;
/** 退出 */
- (void)mainMenuQuitApp:(MainMenu * _Nonnull )mainMenu;

@end

@interface MainMenu : NSObject

@property (nonatomic, readonly)  NSStatusItem * _Nonnull statusItem;

@property (nullable, weak) id<MainMenuDelegate> itemDelegate;

- (void)start;
@end
