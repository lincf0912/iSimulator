//
//  Shell.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/7.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "Shell.h"

NSString * shell(NSString *launchPath ,NSArray<NSString *> *arguments)
{
    if (launchPath.length > 0) {
        FILE* fp = NULL;
        char cmd[512];
        NSString *resultStr = @"";
        sprintf(cmd, "%s %s ; echo $?", [launchPath UTF8String], [(arguments ? [arguments componentsJoinedByString:@" "]  : @"") UTF8String]);
        NSString *cmdStr = nil;
        if ((fp = popen(cmd, "r")) != NULL)
        {
            while (fgets(cmd, sizeof(cmd), fp) != NULL) {
                if (cmd[strlen(cmd) - 1] == '\n') {
                    cmd[strlen(cmd) - 1] = '\0'; //去除换行符
                }
                cmdStr = [NSString stringWithUTF8String:cmd];
                if (![@"0" isEqualToString:cmdStr]) {
                    resultStr = [resultStr stringByAppendingString:cmdStr];
                }
            }
            //            fgets(cmd, sizeof(cmd), fp);
            pclose(fp);
        }
        
        //0 成功， 1 失败
        printf("resultStr is %s\n", [resultStr UTF8String]);
        return resultStr;
    }
    return @"";
}

@implementation Shell


@end
