//
//  YZHQueue.h
//  YZHApp
//
//  Created by yuan on 2020/4/17.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YZHQueue;
typedef void(^YZHQueueBlock)(YZHQueue *queue);


@interface YZHQueue : NSObject

@property (nonatomic, strong, readonly) dispatch_queue_t queue;

- (instancetype)initWithQueue:(dispatch_queue_t)queue;

- (BOOL)isExecuteInQueue;

//如果在queue的线程中执行则同步执行，否则异步执行
- (void)dispatchQueueBlock:(YZHQueueBlock)block;

//同步执行queue中的任务
- (void)dispatchSyncQueueBlock:(YZHQueueBlock)block;


@end

NS_ASSUME_NONNULL_END
