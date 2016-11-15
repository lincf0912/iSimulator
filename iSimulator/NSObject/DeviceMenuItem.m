//
//  DeviceMenuItem.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/10.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "DeviceMenuItem.h"
#import "S_Device.h"

@interface DeviceMenuItem ()

@property (nonatomic, strong) S_Device *device;

@end

@implementation DeviceMenuItem

- (instancetype)initWithDevice:(S_Device *)device
{
    self = [super initWithTitle:@"" action:Nil keyEquivalent:@""];
    if (self) {
        _device = device;
        
        [self buildUI];
    }
    return self;
}

- (void)buildUI
{
    NSFont *font = [NSFont systemFontOfSize:14.f];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:self.device.name attributes:@{NSFontAttributeName:font}];
    font = [NSFont systemFontOfSize:11.f];
    NSAttributedString *detail = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%ld apps installed", self.device.appList.count] attributes:@{NSFontAttributeName:font}];
    NSMutableAttributedString *mutableAttribStr = [[NSMutableAttributedString alloc] init];
    [mutableAttribStr appendAttributedString:title];
    [mutableAttribStr appendAttributedString:detail];
    self.attributedTitle = [mutableAttribStr copy];
    
    self.image = self.device.deviceIcon;
}
@end
