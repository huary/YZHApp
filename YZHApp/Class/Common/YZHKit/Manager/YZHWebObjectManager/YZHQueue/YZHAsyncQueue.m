//
//  YZHAsyncQueue.m
//  YZHApp
//
//  Created by yuan on 2019/1/11.
//  Copyright © 2019年 yuanzh. All rights reserved.
//

#import "YZHAsyncQueue.h"
#import "YZHKitType.h"

@interface YZHAsyncQueue ()
@property (nonatomic, assign) void *asyncTaskQueueSpecificKey;

@property (nonatomic, assign) BOOL isDefaultQueue;

@end

@implementation YZHAsyncQueue

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefault];
    }
    return self;
}

-(void)_setupDefault
{
    self.asyncTaskQueueSpecificKey = (__bridge void *)self;
}

-(dispatch_queue_t)_taskQueue
{
    if (_asyncTaskQueue == nil) {
        NSString *queueLabel = NEW_STRING_WITH_FORMAT(@"com.YZHAsyncTaskQueue.%@",@([self hash]));
        _asyncTaskQueue = dispatch_queue_create([queueLabel UTF8String], DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_asyncTaskQueue, self.asyncTaskQueueSpecificKey, (__bridge void *)self, NULL);
        self.isDefaultQueue = YES;
    }
    
    if (!self.isDefaultQueue) {
        dispatch_queue_set_specific(_asyncTaskQueue, self.asyncTaskQueueSpecificKey, (__bridge void *)self, NULL);
        self.isDefaultQueue = YES;
    }
    
    return _asyncTaskQueue;
}

-(void)_addExecute:(YZHAsyncQueueExecuteBlock)executeBlock inQueue:(dispatch_queue_t)queue asyncCompletion:(BOOL)asyncCompletionn completionBlock:(YZHAsyncQueueExecuteCompletionBlock)completionBlock
{
    dispatch_async(queue, ^{
        id retObj = nil;
        if (executeBlock) {
            retObj = executeBlock(self);
        }
        if (completionBlock) {
            if (asyncCompletionn) {
                dispatch_async_in_main_queue(^{
                    completionBlock(self,retObj);
                });
            }
            else {
                completionBlock(self,retObj);
            }
        }
    });    
}

-(void)addAsyncExecute:(YZHAsyncQueueExecuteBlock)executeBlock completionBlock:(YZHAsyncQueueExecuteCompletionBlock)completionBlock
{
    [self _addExecute:executeBlock inQueue:[self _taskQueue] asyncCompletion:YES completionBlock:completionBlock];
}

-(void)addAsyncExecute:(YZHAsyncQueueExecuteBlock)executeBlock asyncCompletion:(BOOL)asyncCompletion completionBlock:(YZHAsyncQueueExecuteCompletionBlock)completionBlock
{
    [self _addExecute:executeBlock inQueue:[self _taskQueue] asyncCompletion:asyncCompletion completionBlock:completionBlock];
}

-(BOOL)isInAsyncQueue
{
    return (dispatch_get_specific(self.asyncTaskQueueSpecificKey) == (__bridge void *)self);
}

-(dispatch_queue_t)asyncTaskQueue
{
    return _asyncTaskQueue;
}

@end
