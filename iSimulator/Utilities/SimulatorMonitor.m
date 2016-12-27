//
//  SimulatorMonitor.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/11.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "SimulatorMonitor.h"

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

typedef void(^dispatch_cancelable_block_t)(BOOL cancel);

dispatch_cancelable_block_t _dispatch_block_t(NSTimeInterval delay, void(^block)())
{
    __block dispatch_cancelable_block_t cancelBlock = nil;
    dispatch_cancelable_block_t delayBlcok = ^(BOOL cancel){
        if (!cancel) {
            dispatch_main_async_safe(block);
        }
        cancelBlock = nil;
    };
    cancelBlock = delayBlcok;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (cancelBlock) {
            cancelBlock(NO);
        }
    });
    return delayBlcok;
}

void _dispatch_cancel(dispatch_cancelable_block_t block)
{
    if (block) {
        block(YES);
    }
}

@interface SimulatorMonitor ()

@property (nonatomic, strong) NSMutableDictionary <NSURL *, dispatch_source_t>*myMonitors;
@property (nonatomic, assign) BOOL isStartMonitor;

@property (nonatomic, copy) dispatch_cancelable_block_t monitorBlock;

@end

@implementation SimulatorMonitor

- (instancetype)init
{
    self = [super init];
    if (self) {
        _myMonitors = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addMonitor:(NSURL *)url
{
    if (url == nil) return;
    NSString *path = url.path;
    
    /** 跳过存在的监听 */
    if ([self.myMonitors objectForKey:url]) {
        return;
    }
    
    int fd = open(path.fileSystemRepresentation, O_EVTONLY);
    if (fd == -1)
    {
        @throw [NSException exceptionWithName:@"IOError"
                                       reason:@"cannotOpenPath"
                                     userInfo:nil];
        return;
    }
    
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_WRITE, DISPATCH_TARGET_QUEUE_DEFAULT);
    
    if (!source)
    {
        close(fd);
        @throw [NSException exceptionWithName:@"dispatchError"
                                       reason:@"dispatch_source_create_fail"
                                     userInfo:nil];
        return;
    }
    
    dispatch_source_set_event_handler(source, ^{
        [self waitForDirectoryToFinishChanging:url];
    });
    
    dispatch_source_set_cancel_handler(source, ^{
        close(fd);
    });
    
    [self.myMonitors setObject:source forKey:url];
    
    if (_isStartMonitor) {
        dispatch_resume(source);
    }
}

- (void)start
{
    if (!_isStartMonitor) {
        for (NSURL *url in self.myMonitors) {
            dispatch_source_t source = self.myMonitors[url];
            dispatch_resume(source);
        }
        _isStartMonitor = YES;
    }
}
- (void)cancel
{
    for (NSURL *url in self.myMonitors) {
        dispatch_source_t source = self.myMonitors[url];
        dispatch_source_cancel(source);
    }
    [self.myMonitors removeAllObjects];
    _isStartMonitor = NO;
}

- (void)cancelWithUrl:(NSURL *)url
{
    dispatch_source_t source = self.myMonitors[url];
    dispatch_source_cancel(source);
}

- (BOOL)isExistUrl:(NSURL *)url
{
    return self.myMonitors[url] != nil;
}

- (void)waitForDirectoryToFinishChanging:(NSURL *)url
{
    __weak typeof(self) weakSelf = self;
    /** 避免频繁刷新 */
    _dispatch_cancel(self.monitorBlock);
    self.monitorBlock = _dispatch_block_t(1.f, ^{
        [weakSelf checkDirectoryInfo:url];
    });
}

- (void)checkDirectoryInfo:(NSURL *)url
{
    NSLog(@"监听目录发生变化 - url:%@ ", url);
    if (self.completeBlock) {
        self.completeBlock(url);
    }
}

- (NSArray<dispatch_source_t> *)monitors
{
    return [self.myMonitors copy];
}
@end
