//
//  NSAlert+Block.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/15.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "NSAlert+Block.h"

@implementation NSAlert (Block)

- (instancetype)initWithInfoTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleInformational;
    alert.messageText = title;
    alert.informativeText = message;
    
    NSString *cancelTitle = cancelButtonTitle.length ? cancelButtonTitle : @"Cancel";
    [alert addButtonWithTitle:cancelTitle];
    
    if (otherButtonTitles.length) {
        [alert addButtonWithTitle:otherButtonTitles];
    }
    
    return alert;
}

@end
