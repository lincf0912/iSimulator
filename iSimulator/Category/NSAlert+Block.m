//
//  NSAlert+Block.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/15.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "NSAlert+Block.h"

@implementation NSAlert (Block)

+ (instancetype)alertWithInfoTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray <NSString *>*)otherButtonTitles
{
    return [[self alloc] initWithStyle:NSAlertStyleInformational title:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
}

+ (instancetype)alertWithWarningTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray <NSString *>*)otherButtonTitles
{
    return [[self alloc] initWithStyle:NSAlertStyleWarning title:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
}

- (instancetype)initWithStyle:(NSAlertStyle)style title:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray <NSString *>*)otherButtonTitles
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = style;
    alert.messageText = title;
    alert.informativeText = message;
    
    NSString *cancelTitle = cancelButtonTitle.length ? cancelButtonTitle : @"Cancel";
    [alert addButtonWithTitle:cancelTitle];
    
    if (otherButtonTitles.count) {
        for (NSString *otherButtonTitle in otherButtonTitles) {
            [alert addButtonWithTitle:otherButtonTitle];
        }
    }
    
    return alert;
}



- (void)showSheetModalForWindow:(NSWindow *)sheetWindow completionHandler:(void (^)(NSModalResponse returnCode))handler
{
    [self beginSheetModalForWindow:sheetWindow completionHandler:handler];
    [[NSApp windows].lastObject becomeKeyWindow];
}
@end
