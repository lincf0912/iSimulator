//
//  LoginItemsRegistry.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/28.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginItemsRegistry : NSObject

// 是否默认启动
+(BOOL)isLoginRegistry;
// 配置开机默认启动
+(void)installLoginRegistry;
// 取消配置开机默认启动
+(void)unInstallLoginRegistry;
@end
