//
//  GeneralViewController.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/25.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "GeneralViewController.h"

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

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    self.preferredContentSize = self.view.fittingSize;
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
    
}

- (void)removeFromLoginItems
{
    
}

- (BOOL)isStartAtLogin
{
    return NO;
}

@end
