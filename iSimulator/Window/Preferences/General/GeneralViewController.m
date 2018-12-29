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
#import "iActivityIndicatorView.h"
#import "NSAlert+Block.h"

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

- (IBAction)iSimulator_deleteUnsimulator_action:(NSButton *)sender {
    
    NSAlert *alert = [NSAlert alertWithInfoTitle:@"Are you sure you want to delete all unavailable Simulator?" message:@"Permanent and unrecoverable，it cannot turn back into its previous stage." cancelButtonTitle:@"Delete" otherButtonTitles:@[@"Don't Delete"]];
    [alert showSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            sender.enabled = NO;
            iActivityIndicatorView *indicator = [[iActivityIndicatorView alloc] initWithFrame:sender.frame];
            [sender.superview addSubview:indicator];
            [[SimulatorManager shareSimulatorManager] removeUnsimulators:^{
                [indicator removeFromSuperview];
                sender.enabled = YES;
            }];
        }
    }];
    
    
}

@end
