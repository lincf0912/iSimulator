//
//  AboutWindownContorller.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/25.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindownContorller : NSWindowController
// Properties are used by bindings
@property (copy) NSString *appName;
@property (copy) NSString *version;
@property (copy) NSString *desc;
@end
