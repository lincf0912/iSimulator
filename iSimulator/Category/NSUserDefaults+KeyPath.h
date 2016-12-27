//
//  NSUserDefaults+KeyPath.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/28.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UpdateOption;

@interface NSUserDefaults (KeyPath)
/** 版本更新间隔 */
+ (NSInteger)updateOptionDesc;
+ (UpdateOption *)updateOption;
+ (void)setUpdateOption:(UpdateOption *)updateOption;

// =======================================================================================================
// =======================================================================================================
// =======================================================================================================
/* 是否显示模拟器 */
+ (NSInteger)simulatorDisplay;
+ (void)setSimulatorDisplay:(NSInteger)display;
@end
