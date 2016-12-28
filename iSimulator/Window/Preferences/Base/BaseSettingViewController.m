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
}

@end
