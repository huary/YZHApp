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
        //不能用self设置当前queue所在线程的tls的key为self、且值为self，而是应该queue所在线程的tls的key设置为queue、且值为queue，
        //就实现了queue->thread->queue 弱循环引用，否则在以下场景会出现问题，如：
        //将dispatch_queue_t 类型简化为DQ，GGL类型简化为GQ
        //GQA->DQA
        //GQA->DQB
        //如果同一个GQ用两个不（及以上）一样的DQ初始化（initWithQueue，虽然不是设计之初的本意，但也没有规避不能这么做），
        //因此在DQA的所在线程根据GQA来为Key取值的话，取到的Value是GQA，同理在DQB...用GQA为Key取值Value还是GQA，
        //因此DQA、DQB...等没有进行线程切换,不是设计本意，导致线程紊乱，出现线程安全的错误。
        dispatch_queue_set_specific(_queue, (__bridge void *)_queue, (__bridge void *)_queue, NULL);
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
        if (_queue == nil) {
            return NO;
        }
        void *ptr = dispatch_get_specific((__bridge void *)_queue);
        return (ptr == (__bridge void *)_queue);
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
