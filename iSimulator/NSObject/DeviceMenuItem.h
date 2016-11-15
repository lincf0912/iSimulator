//
//  DeviceMenuItem.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/10.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class S_Device;
@interface DeviceMenuItem : NSMenuItem

- (instancetype)initWithDevice:(S_Device *)device;
@end
