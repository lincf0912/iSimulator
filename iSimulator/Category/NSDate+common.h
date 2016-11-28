//
//  NSDate+common.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/28.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (common)

/** 返回某天到当前相差的天数 */
- (NSUInteger)daysDifferentFromOtherDate:(NSDate *)otherDate;
@end
