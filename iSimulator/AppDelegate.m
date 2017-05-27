//
//  AppDelegate.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "AppDelegate.h"
#import "MainMenu.h"

#import "NSUserDefaults+KeyPath.h"
#import "NSDate+common.h"

#import "AboutWindowController.h"

@interface AppDelegate () <MainMenuDelegate>

@property (nonatomic, strong) MainMenu *menu;

@property (nonatomic, strong) AboutWindowController *aboutWindowController;

@property (nonatomic, nullable) NSWindowController *preferencesWindowController;

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
    [NSApp activateIgnoringOtherApps:YES];
    if (_aboutWindowController == nil) {
        _aboutWindowController = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindowController"];
    }
    [_aboutWindowController.window center];
    [_aboutWindowController.window orderFrontRegardless];
    
    [_aboutWindowController showWindow:self];
}

- (void)mainMenuPreferencesApp:(MainMenu *)mainMenu
{
    [NSApp activateIgnoringOtherApps:YES];
    if(_preferencesWindowController == nil)
    {
        _preferencesWindowController = [[NSStoryboard storyboardWithName:@"PreferencesStoryboard" bundle:nil] instantiateInitialController];
    }
    [_preferencesWindowController.window center];
    [_preferencesWindowController.window orderFrontRegardless];
    
    [_preferencesWindowController showWindow:self];
}

- (void)mainMenuQuitApp:(MainMenu *)mainMenu
{
    [NSApp terminate:self]; 
}

@end
