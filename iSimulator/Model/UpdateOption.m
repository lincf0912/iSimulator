//
//  UpdateOption.m
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/28.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "UpdateOption.h"

@implementation UpdateOption

- (instancetype)initWithOperation:(updateOperationType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (NSString *)localizedTitle
{
    
    NSString *name = @"Indefinitely";
    switch (self.type) {
        case updateOperationType_everyDay:
            name = @"每天";
            break;
        case updateOperationType_everyWeek:
            name = @"每周";
            break;
        case updateOperationType_everyMonth:
            name = @"每月";
            break;
    }
    
    return name;
}

- (NSString *)description
{
    return self.localizedTitle;
}

UpdateOption * UpdateOptionForOperation(updateOperationType type)
{
    return [[UpdateOption alloc] initWithOperation:type];
}
@end
