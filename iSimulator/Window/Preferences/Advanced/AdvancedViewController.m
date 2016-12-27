//
//  AdvancedViewController.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/25.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "AdvancedViewController.h"
#import "UpdateOption.h"
#import "NSUserDefaults+KeyPath.h"

@interface AdvancedViewController ()

@property (nonatomic) NSArray<UpdateOption *> *updateOptions;
@property (nonatomic) UpdateOption *selectedUpdateOption;
@end

@implementation AdvancedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.updateOptions = @[UpdateOptionForOperation(updateOperationType_everyDay),
                           UpdateOptionForOperation(updateOperationType_everyWeek),
                           UpdateOptionForOperation(updateOperationType_everyMonth)];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    self.preferredContentSize = self.view.fittingSize;
}

- (UpdateOption *)selectedUpdateOption
{
    return [NSUserDefaults updateOption];
}

- (void)setSelectedUpdateOption:(UpdateOption *)selectedUpdateOption
{
    [self willChangeValueForKey:@"selectedUpdateOption"];
    [NSUserDefaults setUpdateOption:selectedUpdateOption];
    [self didChangeValueForKey:@"selectedUpdateOption"];
}
@end
