//
//  AppDelegate.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "AppDelegate.h"
#import "MainMenu.h"

#import <Sparkle/Sparkle.h>

#import "AboutWindownContorller.h"

#import "NSUserDefaults+KeyPath.h"

@interface AppDelegate () <MainMenuDelegate, SUUpdaterDelegate>

@property (nonatomic, strong) MainMenu *menu;

@property (nonatomic, strong) AboutWindownContorller *aboutWindowController;

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
    if (_aboutWindowController == nil) {
        _aboutWindowController = [[AboutWindownContorller alloc] initWithWindowNibName:@"AboutWindownContorller"];
    }
    [_aboutWindowController.window center];
    
    [_aboutWindowController.window orderFrontRegardless];
}

- (void)mainMenuPreferencesApp:(MainMenu *)mainMenu
{
    if(_preferencesWindowController == nil)
    {
        _preferencesWindowController = [[NSStoryboard storyboardWithName:@"PreferencesStoryboard" bundle:nil] instantiateInitialController];
    }
    [_preferencesWindowController.window orderFrontRegardless];
}

- (void)mainMenuQuitApp:(MainMenu *)mainMenu
{
    [NSApp terminate:self];
}

#pragma mark - Updater Delegate

- (NSString *)feedURLStringForUpdater:(SUUpdater *)updater
{
    NSString *feedURLString = [NSBundle mainBundle].infoDictionary[@"SUFeedURL"];
    NSAssert(feedURLString != nil, @"A feed URL should be set in Info.plist");
    
    if([NSUserDefaults isReleaseUpdatesEnabled])
    {
        NSString *lastComponent = feedURLString.lastPathComponent;
        NSString *baseURLString = feedURLString.stringByDeletingLastPathComponent;
        return [NSString stringWithFormat:@"%@/prerelease-%@", baseURLString, lastComponent];
    }
    
    return feedURLString;
}

@end
