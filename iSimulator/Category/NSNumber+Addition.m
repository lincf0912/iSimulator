//
//  NSNumber+Addition.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/11.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "NSNumber+Addition.h"

@implementation NSNumber (Addition)

- (NSString *)sizeToStr
{
    CGFloat aSize = [self floatValue];
    NSArray *unitText = @[@"B",@"K",@"M",@"G",@"T"];
    NSInteger index = 0;
    while (aSize > 999) {
        index++;
        aSize /= 1024;
    }
    NSNumberFormatter *nFormat = [[NSNumberFormatter alloc] init];
    [nFormat setNumberStyle:NSNumberFormatterDecimalStyle];
    [nFormat setMaximumFractionDigits:1];
    return [NSString stringWithFormat:@"%@%@",[nFormat stringFromNumber:[NSNumber numberWithFloat:aSize]],[unitText objectAtIndex:index]];
}
@end
