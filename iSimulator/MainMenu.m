//
//  MainMenu.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "MainMenu.h"
#import "iActivityIndicatorView.h"

#import "DeviceMenuItem.h"
#import "ApplicationMenuItem.h"

#import "SimulatorManager.h"

#import "S_Device.h"
#import "S_AppInfo.h"

NSString *const mainMenuTitle = @"Main Menu";
NSInteger const recent_max = 5;

NSInteger const about_Tag = 990;


@interface MainMenu () <NSMenuDelegate, ApplicationMenuItemDelegate>

@property (nonatomic, strong) NSMenu *menu_main;

@end
@implementation MainMenu

- (instancetype)init
{
    self = [super init];
    if (self) {
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        [_statusItem setImage:[NSImage imageNamed:@"MenuIcon"]];
        [_statusItem setHighlightMode:YES];
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    if (self.menu_main == nil) {
        NSMenu *menu = [[NSMenu alloc] initWithTitle:mainMenuTitle];
        
        /** 菊花加载 */
        NSMenuItem * recentLoaded = [MainMenu createTipsItemWithTitle:@""];
        iActivityIndicatorView *indicator = [[iActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, menu.size.width, 20)];
        recentLoaded.view = indicator;
        [menu addItem:recentLoaded];
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        /** 第三标题 */
        NSMenuItem *aboutItem  = [[NSMenuItem alloc] initWithTitle:@"About iSimulators" action:@selector(appAbout:) keyEquivalent:@""];
        aboutItem.tag = about_Tag;
        aboutItem.target = self;
        [menu addItem:aboutItem];
        
        NSMenuItem *prefeItem  = [[NSMenuItem alloc] initWithTitle:@"Preferences..." action:@selector(appPreferences:) keyEquivalent:@","];
        prefeItem.target = self;
        [menu addItem:prefeItem];
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        /** 第四标题 */
        NSMenuItem *quitItem  = [[NSMenuItem alloc] initWithTitle:@"Quit iSimulators" action:@selector(appQuit:) keyEquivalent:@"q"];
        quitItem.target = self;
        [menu addItem:quitItem];
        
        self.statusItem.menu = menu;
        menu.delegate = self;
        self.menu_main = menu;
    }
}

- (void)start
{
    /** 加载app数据 */
    [[SimulatorManager shareSimulatorManager] loadSimulators:^(NSArray<NSDictionary<NSString *,NSArray<S_Device *> *> *> *deviceList, NSArray<S_AppInfo *> *recentList) {
        
        NSMenu *menu = self.menu_main;
        
        /** 删除旧数据 直到about_Tag */
        for (NSMenuItem *item in menu.itemArray) {
            if (item.tag == about_Tag) {
                break;
            }
            if (item.menu) {
                [menu removeItem:item];
            }
        }
        
        NSInteger nextIndex = 0;
        
        if (deviceList.count && recentList.count) {
            /** 第一标题 */
            NSMenuItem *recentApps = [MainMenu createTipsItemWithTitle:@"Recent Apps"];
            [menu insertItem:recentApps atIndex:nextIndex++];
            /** 数据 */
            for (NSInteger i=0; i<recentList.count; i++) {
                if (i == recent_max) {
                    break;
                }
                S_AppInfo *app = recentList[i];
                ApplicationMenuItem *appItem = [[ApplicationMenuItem alloc] initWithApp:app withDetailText:app.deviceName];
                appItem.action = @selector(appOnClickInMenu:);
                appItem.target = self;
                appItem.representedObject = app;
                appItem.delegate = self;
                [menu insertItem:appItem atIndex:nextIndex++];
            }
            
            [menu insertItem:[NSMenuItem separatorItem] atIndex:nextIndex++];
            
            /** 第二标题 */
            for (NSDictionary *allDevice in deviceList) {
                for (NSString *version in allDevice) {
                    
                    NSMenuItem *simulators = [MainMenu createTipsItemWithTitle:[NSString stringWithFormat:@"%@ Simulators", version]];
                    [menu insertItem:simulators atIndex:nextIndex++];
                    
                    BOOL isExistsDevice = NO;
                    /** 设备 */
                    NSArray *devics = allDevice[version];
                    for (S_Device *device in devics) {
                        if (device.appList.count) {
                            NSMenuItem *deviceItem = [[DeviceMenuItem alloc] initWithDevice:device];
                            deviceItem.action = @selector(revealInFileViewer:);
                            deviceItem.target = self;
                            deviceItem.representedObject = device;
                            
                            [menu insertItem:deviceItem atIndex:nextIndex++];
                            
                            NSMenu *subMenu = [NSMenu new];
                            subMenu.delegate = self;
                            NSMenuItem *titleItem = [MainMenu createTipsItemWithTitle:@"Applications"];
                            [subMenu addItem:titleItem];
                            for (S_AppInfo *app in device.appList) {
                                ApplicationMenuItem *appItem = [[ApplicationMenuItem alloc] initWithApp:app];
                                appItem.action = @selector(appOnClickInMenu:);
                                appItem.target = self;
                                appItem.representedObject = app;
                                appItem.delegate = self;
                                /** app菜单 */
                                [subMenu addItem:appItem];
                            }
                            [subMenu addItem:[NSMenuItem separatorItem]];
                            /** Device Action */
                            [self createDeviceActionsInMenu:subMenu device:device];
                            
                            [deviceItem setSubmenu:subMenu];
                            
                            isExistsDevice = YES;
                        }
                    }
                    
                    if (!isExistsDevice) {
                        [menu removeItemAtIndex:--nextIndex];
                    }
                }
            }
            /** 数据 */
            [menu insertItem:[NSMenuItem separatorItem] atIndex:nextIndex++];
            
        } else {
            /** 第一标题 */
            NSMenuItem *recentApps = [MainMenu createTipsItemWithTitle:@"NO Simulators"];
            [menu insertItem:recentApps atIndex:nextIndex++];
            [menu insertItem:[NSMenuItem separatorItem] atIndex:nextIndex++];
        }
        
        [menu update];
    }];
}

#pragma mark - app点击事件
- (void)appOnClickInMenu:(NSMenuItem *)item
{
    [[SimulatorManager shareSimulatorManager] openAppDocument:item.representedObject];
}

#pragma mark - ApplicationMenuItemDelegate
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem revealSandboxInFileViewer:(S_AppInfo *)app
{
    [[SimulatorManager shareSimulatorManager] openAppDocument:app];
}
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem launchInSimulator:(S_AppInfo *)app
{
    [[SimulatorManager shareSimulatorManager] launchAppInSimulator:app];
}
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem copySandboxPathToPasteboard:(S_AppInfo *)app
{
    NSURL *appDocumentURL = [[SimulatorManager shareSimulatorManager] getAppDocumentUrl:app];
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType]
               owner:self];
    [pb setString:appDocumentURL.path forType:NSStringPboardType];
}
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem resetData:(S_AppInfo *)app
{
    [[SimulatorManager shareSimulatorManager] resetAppDataInSimulator:app];
}
- (void)applicationMenuItem:(ApplicationMenuItem *)appMenuItem uninstall:(S_AppInfo *)app
{
    [[SimulatorManager shareSimulatorManager] uninstallAppInSimulator:app];
}

#pragma mark - MainMenuDelegate
- (void)appAbout:(NSMenuItem *)item
{
    if ([self.itemDelegate respondsToSelector:@selector(mainMenuAboutApp:)]) {
        [self.itemDelegate mainMenuAboutApp:self];
    }
}

- (void)appPreferences:(NSMenuItem *)item
{
    if ([self.itemDelegate respondsToSelector:@selector(mainMenuPreferencesApp:)]) {
        [self.itemDelegate mainMenuPreferencesApp:self];
    }
}

- (void)appQuit:(NSMenuItem *)item
{
    if ([self.itemDelegate respondsToSelector:@selector(mainMenuQuitApp:)]) {
        [self.itemDelegate mainMenuQuitApp:self];
    }
}

#pragma mark - 设备点击事件
- (void)revealInFileViewer:(NSMenuItem *)item
{
    [[SimulatorManager shareSimulatorManager] openDevicePath:item.representedObject];
}
- (void)addPhotos:(NSMenuItem *)item
{
    [[SimulatorManager shareSimulatorManager] addPhotoToDevice:item.representedObject];
}
- (void)addVideos:(NSMenuItem *)item
{
    [[SimulatorManager shareSimulatorManager] addVideoToDevice:item.representedObject];
}
- (void)installApplication:(NSMenuItem *)item
{
    [[SimulatorManager shareSimulatorManager] installAppInSimulator:item.representedObject];
}
- (void)resetContentAndSettings:(NSMenuItem *)item
{
    [[SimulatorManager shareSimulatorManager] resetDeviceData:item.representedObject];
}
- (void)copyPathToPasteboard:(NSMenuItem *)item
{
    NSURL *deviceURL = [[SimulatorManager shareSimulatorManager] getDeviceUrl:item.representedObject];
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType]
               owner:self];
    [pb setString:deviceURL.path forType:NSStringPboardType];
}
- (void)uninstall:(NSMenuItem *)item
{
    NSURL *deviceURL = [[SimulatorManager shareSimulatorManager] getDeviceUrl:item.representedObject];
    [[NSFileManager defaultManager] removeItemAtURL:deviceURL error:nil];
}

#pragma mark - 私有
- (void)createDeviceActionsInMenu:(NSMenu *)menu device:(S_Device *)device
{
    NSMenuItem *title = [MainMenu createTipsItemWithTitle:@"Device Actions"];
    [menu addItem:title];
    
    NSMenuItem *reveal = [menu addItemWithTitle:@"Reveal in File Viewer" action:@selector(revealInFileViewer:) keyEquivalent:@""];
    reveal.target = self;
    reveal.representedObject = device;
    reveal.image = [NSImage imageNamed:@"reveal"];
    NSMenuItem *photos = [menu addItemWithTitle:@"Add Photos..." action:@selector(addPhotos:) keyEquivalent:@""];
    photos.target = self;
    photos.representedObject = device;
    photos.image = [NSImage imageNamed:@"photo"];
    NSMenuItem *videos = [menu addItemWithTitle:@"Add Videos..." action:@selector(addVideos:) keyEquivalent:@""];
    videos.target = self;
    videos.representedObject = device;
    videos.image = [NSImage imageNamed:@"video"];
    NSMenuItem *install = [menu addItemWithTitle:@"Install Application..." action:@selector(installApplication:) keyEquivalent:@""];
    install.target = self;
    install.representedObject = device;
    install.image = [NSImage imageNamed:@"install"];
    NSMenuItem *reset = [menu addItemWithTitle:@"Reset Content and Settings..." action:@selector(resetContentAndSettings:) keyEquivalent:@""];
    reset.target = self;
    reset.representedObject = device;
    reset.image = [NSImage imageNamed:@"reset"];
    NSMenuItem *copy = [menu addItemWithTitle:@"Copy Path to Pasteboard" action:@selector(copyPathToPasteboard:) keyEquivalent:@""];
    copy.target = self;
    copy.representedObject = device;
    copy.image = [NSImage imageNamed:@"copy"];
    
    if (device.isUnavailable) {
        NSMenuItem *uninstall = [menu addItemWithTitle:@"Uninstall..." action:@selector(uninstall:) keyEquivalent:@""];
        uninstall.target = self;
        uninstall.representedObject = device;
        uninstall.image = [NSImage imageNamed:@"uninstall"];
    }
}

+ (NSMenuItem *)createTipsItemWithTitle:(NSString *)title
{
    NSMenuItem * tips = [[NSMenuItem alloc] initWithTitle:title action:Nil keyEquivalent:@""];
    tips.enabled = NO;
    return tips;
}
@end
