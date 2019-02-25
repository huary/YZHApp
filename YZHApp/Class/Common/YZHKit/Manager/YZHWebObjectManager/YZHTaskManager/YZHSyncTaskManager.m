//
//  YZHSyncTaskManager.m
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/8.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHSyncTaskManager.h"

@implementation YZHSyncTaskManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setSyncDefault];
    }
    return self;
}

-(void)_setSyncDefault
{
    _sync = YES;
    self.maxConcurrentRunningTaskCnt = 5;
    _operationManager = [[YZHTaskOperationManager alloc] initWithExecutionOrder:YZHTaskOperationExecutionOrderNone];
    _operationManager.maxConcurrentOperationCount = self.maxConcurrentRunningTaskCnt;
}

@end
