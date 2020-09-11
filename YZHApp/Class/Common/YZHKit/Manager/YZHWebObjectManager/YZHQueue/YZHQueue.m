//
//  YZHQueue.m
//  YZHApp
//
//  Created by yuan on 2020/4/17.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "YZHQueue.h"
#import <pthread.h>

@implementation YZHQueue

- (instancetype)initWithQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self) {
        [self _setupWithQueue:queue];
    }
    return self;
}

- (void)_setupWithQueue:(dispatch_queue_t)queue
{
    _queue = queue;
    if (queue && queue != dispatch_get_main_queue()) {
        dispatch_queue_set_specific(_queue, (__bridge void *)self, (__bridge void *)self, NULL);
    }
}

- (BOOL)isExecuteInQueue
{
    if (_queue == dispatch_get_main_queue()) {
        if (pthread_main_np()) {
            return YES;
        }
    }
    else {
        void *ptr = dispatch_get_specific((__bridge void *)self);
        return (ptr == (__bridge void *)self);
    }
    return NO;
}

- (void)dispatchQueueBlock:(YZHQueueBlock)block
{
    if (block == nil) {
        return;
    }
    if (_queue == nil || [self isExecuteInQueue]) {
        block(self);
    }
    else {
        dispatch_async(self.queue, ^{
            block(self);
        });
    }
}


- (void)dispatchSyncQueueBlock:(YZHQueueBlock)block
{
    if (block == nil) {
        return;
    }
    if (_queue == nil || [self isExecuteInQueue]) {
        block(self);
    }
    else {
        dispatch_sync(self.queue, ^{
            block(self);
        });
    }
}
@end
