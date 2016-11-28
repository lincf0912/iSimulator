//
//  NSDate+common.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/28.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "NSDate+common.h"

@implementation NSDate (common)

/** 返回某天到当前相差的天数 */
- (NSUInteger)daysDifferentFromOtherDate:(NSDate *)otherDate
{
    int D_DAY = 60*60*24;
    NSTimeInterval interval = [self timeIntervalSinceDate:otherDate];
    NSUInteger days = @(interval).intValue / D_DAY;
    return days;
}
@end
