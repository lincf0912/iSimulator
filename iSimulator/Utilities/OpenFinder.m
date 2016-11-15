//
//  OpenFinder.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/15.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "OpenFinder.h"

@implementation OpenFinder

+ (void)selectFile:(NSArray <NSString *>*)suffixs complete:(void (^)(NSURL *url))complete
{
    if (complete == nil) return;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    //允许打开目录
    [oPanel setCanChooseDirectories:NO];
    //不允许打开多个文件
    [oPanel setAllowsMultipleSelection:NO];
    //限制打开文件后缀名
    [oPanel setAllowedFileTypes:suffixs];
    //可以打开文件
    [oPanel setCanChooseFiles:YES];
    //点击ok返回文件路径
    [oPanel beginSheetModalForWindow:[[NSApplication sharedApplication] windows].firstObject completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK)
        {
            complete([[oPanel URLs] firstObject]);
        }else {
            complete(nil);
        }
    }];
}

+ (void)multipleSelectFile:(NSArray <NSString *>*)suffixs complete:(void (^)(NSArray <NSURL *>*urls))complete
{
    if (complete == nil) return;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    //允许打开目录
    [oPanel setCanChooseDirectories:NO];
    //允许打开多个文件
    [oPanel setAllowsMultipleSelection:YES];
    //限制打开文件后缀名
    [oPanel setAllowedFileTypes:suffixs];
    //可以打开文件
    [oPanel setCanChooseFiles:YES];
    //点击ok返回文件路径
    [oPanel beginSheetModalForWindow:[[NSApplication sharedApplication] windows].firstObject completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK)
        {
            complete([oPanel URLs]);
        }else {
            complete(nil);
        }
    }];
}
@end
