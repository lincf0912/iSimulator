//
//  BaseSettingViewController.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/12/28.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "BaseSettingViewController.h"

@interface BaseSettingViewController ()

@end

@implementation BaseSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear
{
    [super viewWillAppear];

    self.preferredContentSize = self.view.fittingSize;
    
//    NSWindow *window = [NSApp windows].lastObject;
//    NSRect newWindowFrame = [window frameRectForContentRect:[self.view frame]];
//    newWindowFrame.origin = [window frame].origin;
//    newWindowFrame.origin.x -= newWindowFrame.size.width - [window frame].size.width;
//    newWindowFrame.origin.y -= newWindowFrame.size.height - [window frame].size.height;
//    [window setFrame:newWindowFrame display:YES animate:YES];
}

@end
