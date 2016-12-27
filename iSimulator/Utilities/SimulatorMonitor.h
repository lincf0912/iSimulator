//
//  SimulatorMonitor.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/11.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimulatorMonitor : NSObject

@property (nonatomic, copy) void (^completeBlock)(NSURL *url);
//@property (nonatomic, readonly) NSDictionary <NSString *, dispatch_source_t>*monitors;

- (void)addMonitor:(NSURL *)url;

- (void)start;
- (void)cancel;
- (void)cancelWithUrl:(NSURL *)url;

- (BOOL)isExistUrl:(NSURL *)url;

@end
