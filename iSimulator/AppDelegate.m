//
//  AppDelegate.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "AppDelegate.h"
#import "MainMenu.h"
#import "NSAlert+Block.h"

@interface AppDelegate () <MainMenuDelegate>

@property (nonatomic, strong) MainMenu *menu;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.menu = [MainMenu new];
    self.menu.itemDelegate = self;
    [self.menu start];
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - MainMenuDelegate
- (void)mainMenuAboutApp:(MainMenu *)mainMenu
{
    NSAlert *alert = [[NSAlert alloc] initWithInfoTitle:@"关于" message:@"感谢你的使用。" cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert beginSheetModalForWindow:[[NSApplication sharedApplication] windows].firstObject completionHandler:nil];
}

- (void)mainMenuPreferencesApp:(MainMenu *)mainMenu
{
    
}

- (void)mainMenuQuitApp:(MainMenu *)mainMenu
{
    [NSApp terminate:self];
}

@end
