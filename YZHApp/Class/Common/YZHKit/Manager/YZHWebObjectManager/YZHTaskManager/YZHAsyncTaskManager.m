//
//  YZHAsyncTaskManager.m
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/8.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHAsyncTaskManager.h"

@interface YZHAsyncTaskManager ()

@end

@implementation YZHAsyncTaskManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupAsyncDefault];
    }
    return self;
}

-(void)_setupAsyncDefault
{
    self.maxConcurrentRunningTaskCnt = 5;
    _sync = NO;
    _operationManager = [[YZHOperationManager alloc] initWithExecutionOrder:YZHOperationExecutionOrderFIFO];
    _operationManager.maxConcurrentOperationCount = 1;
}


@end
