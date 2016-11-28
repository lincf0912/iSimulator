//
//  UpdateOption.h
//  iSimulator
//
//  Created by LamTsanFeng on 2016/11/28.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, updateOperationType) {
    updateOperationType_everyDay,
    updateOperationType_everyWeek,
    updateOperationType_everyMonth,
};

@interface UpdateOption : NSObject

@property (nonatomic, readonly) NSString *localizedTitle;

@property (nonatomic, readonly) updateOperationType type;

- (instancetype)initWithOperation:(updateOperationType)type;

UpdateOption * UpdateOptionForOperation(updateOperationType type);
@end
