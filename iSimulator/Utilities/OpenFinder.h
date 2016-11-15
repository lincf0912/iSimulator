//
//  OpenFinder.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/15.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OpenFinder : NSObject

/** 选择文件 */
+ (void)selectFile:(NSArray <NSString *>*)suffixs complete:(void (^)(NSURL *url))complete;
/** 选择文件（多选） */
+ (void)multipleSelectFile:(NSArray <NSString *>*)suffixs complete:(void (^)(NSArray <NSURL *>*urls))complete;
@end
