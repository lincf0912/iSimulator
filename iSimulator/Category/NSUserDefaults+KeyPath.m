//
//  NSUserDefaults+KeyPath.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/28.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "NSUserDefaults+KeyPath.h"

NSString *const isReleaseUpdatesEnabledName = @"isReleaseUpdatesEnabled";

@implementation NSUserDefaults (KeyPath)

+ (BOOL)isReleaseUpdatesEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:isReleaseUpdatesEnabledName];
}

+ (void)setIsReleaseUpdatesEnabled:(BOOL)isReleaseUpdatesEnabled
{
    [[NSUserDefaults standardUserDefaults] setBool:isReleaseUpdatesEnabled forKey:isReleaseUpdatesEnabledName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
