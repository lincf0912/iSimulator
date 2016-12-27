//
//  NSUserDefaults+KeyPath.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/28.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "NSUserDefaults+KeyPath.h"
#import "UpdateOption.h"

NSString *const UpdateOptionName = @"UpdateOption";

@implementation NSUserDefaults (KeyPath)

+ (UpdateOption *)updateOption
{
    NSInteger updateCheckInterval = [self updateOptionDesc];
    updateOperationType type = updateOperationType_everyDay;
    if (updateCheckInterval == 1) {
        type = updateOperationType_everyDay;
    } else if (updateCheckInterval == 7) {
        type = updateOperationType_everyWeek;
    } else if (updateCheckInterval == 30) {
        type = updateOperationType_everyMonth;
    }
    return UpdateOptionForOperation(type);
}

+ (NSInteger)updateOptionDesc
{
    NSInteger updateCheckInterval = [[NSUserDefaults standardUserDefaults] integerForKey:UpdateOptionName];
    return updateCheckInterval == 0 ? 1 : updateCheckInterval;
}

+ (void)setUpdateOption:(UpdateOption *)updateOption
{
    NSInteger updateCheckInterval = 1;
    switch (updateOption.type) {
        case updateOperationType_everyDay:
            updateCheckInterval = 1;
            break;
        case updateOperationType_everyWeek:
            updateCheckInterval = 7;
            break;
        case updateOperationType_everyMonth:
            updateCheckInterval = 30;
            break;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:updateCheckInterval forKey:UpdateOptionName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// =======================================================================================================
// =======================================================================================================
// =======================================================================================================

NSString *const SimulatorDisplayName = @"SimulatorDisplay";

+ (NSInteger)simulatorDisplay
{
    NSInteger display = [[NSUserDefaults standardUserDefaults] integerForKey:SimulatorDisplayName];
    return display;
}

+ (void)setSimulatorDisplay:(NSInteger)display
{
    [[NSUserDefaults standardUserDefaults] setInteger:display forKey:SimulatorDisplayName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
