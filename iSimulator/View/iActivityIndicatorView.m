//
//  iActivityIndicatorView.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/8.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "iActivityIndicatorView.h"

@interface iActivityIndicatorView ()

@property (nonatomic, strong) NSProgressIndicator *indicator;
@end

@implementation iActivityIndicatorView


- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _indicator = [[NSProgressIndicator alloc] init];
        _indicator.style = NSProgressIndicatorSpinningStyle;
        _indicator.controlSize = NSControlSizeSmall;
        _indicator.displayedWhenStopped = YES;
        _indicator.indeterminate = YES;
        [_indicator sizeToFit];
        [_indicator setFrameOrigin:NSMakePoint((frameRect.size.width-_indicator.frame.size.width)/2, (frameRect.size.height-_indicator.frame.size.height)/2)];
        _indicator.autoresizingMask = NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin;
        [self addSubview:_indicator];
        self.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    }
    return self;
}

- (void)layout
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startAnimation];
    });
}

- (void)startAnimation
{
    [_indicator startAnimation:self];
}

- (void)stopAnimation
{
    [_indicator stopAnimation:self];
}

@end
