//
//  NSImage+Addition.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/9.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "NSImage+Addition.h"

@implementation NSImage (Addition)

- (NSImage *)imageWithCornerRadius:(CGFloat)cornerRadius size:(NSSize)size
{
    if (self.isValid == NO) return nil;
    NSImage *newImage = [[NSImage alloc] initWithSize:size];
    [newImage lockFocus];
    self.size = size;
    [NSGraphicsContext currentContext].imageInterpolation = NSImageInterpolationHigh;
    [NSGraphicsContext saveGraphicsState];
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:(NSRect){NSZeroPoint, size} xRadius:cornerRadius yRadius:cornerRadius];
    [bezierPath addClip];
    [self drawAtPoint:NSZeroPoint fromRect:(NSRect){NSZeroPoint, size} operation:NSCompositingOperationCopy fraction:1.f];
    [NSGraphicsContext restoreGraphicsState];
    
    [newImage unlockFocus];
    
    return newImage;
}

@end
