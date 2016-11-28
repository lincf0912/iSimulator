//
//  NSUserDefaults+KeyPath.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/28.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (KeyPath)

+ (BOOL)isReleaseUpdatesEnabled;
+ (void)setIsReleaseUpdatesEnabled:(BOOL)isReleaseUpdatesEnabled;
@end
