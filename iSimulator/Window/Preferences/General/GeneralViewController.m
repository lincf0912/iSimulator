//
//  GeneralViewController.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/25.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "GeneralViewController.h"
#import "LoginItemsRegistry.h"
#import "NSUserDefaults+KeyPath.h"

#import "SimulatorManager.h"

NSString *const startAtLoginName = @"iSimulator_startLogin";

@interface GeneralViewController ()
@property (weak) IBOutlet NSButton *startAtLoginButton;

@property (nonatomic, assign) BOOL iSimulator_startLogin;

@end

@implementation GeneralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.startAtLoginButton bind:@"value"
                         toObject:self
                      withKeyPath:startAtLoginName
                          options:@{
                                    NSRaisesForNotApplicableKeysBindingOption: @YES,
                                    NSConditionallySetsEnabledBindingOption: @YES
                                    }
     ];
}

- (void)setISimulator_startLogin:(BOOL)iSimulator_startLogin
{
    [self willChangeValueForKey:startAtLoginName];
    if(iSimulator_startLogin)
    {
        [self addToLoginItems];
    }
    else
    {
        [self removeFromLoginItems];
    }
    [self didChangeValueForKey:startAtLoginName];
}

- (BOOL)iSimulator_startLogin
{
    return [self isStartAtLogin];
}

- (void)addToLoginItems
{
    [LoginItemsRegistry installLoginRegistry];
}

- (void)removeFromLoginItems
{
    [LoginItemsRegistry unInstallLoginRegistry];
}

- (BOOL)isStartAtLogin
{
    return [LoginItemsRegistry isLoginRegistry];
}

- (IBAction)iSimulator_simulatorDisplay_action:(id)sender {
    [NSUserDefaults setSimulatorDisplay:[(NSButton *)sender integerValue]];
    [[SimulatorManager shareSimulatorManager] reloadSimulators];
}
@end
