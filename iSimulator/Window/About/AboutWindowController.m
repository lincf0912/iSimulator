//
//  AboutWindowController.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/25.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "AboutWindowController.h"

@interface AboutWindowController ()

@end

@implementation AboutWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
//    [self.window setFrameOrigin:NSMakePoint(0, [NSScreen mainScreen].frame.size.height)];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(id)kCFBundleNameKey];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:(id)kCFBundleVersionKey];
    self.appName = appName;
    self.version = [NSString stringWithFormat:@"%@ (%@)", version, build];
    
    
    self.desc = @"Simple & Strong";
}
- (IBAction)linAction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://lincf0912.github.io/iSimulator/"]];
}

@end
