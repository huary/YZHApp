//
//  YZHTaskOperationManager.h
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHTaskOperation.h"


typedef NS_ENUM(NSInteger, YZHTaskOperationExecutionOrder)
{
    YZHTaskOperationExecutionOrderNone  = -1,
    YZHTaskOperationExecutionOrderFIFO  = 0,
    YZHTaskOperationExecutionOrderFILO  = 1,
};

@class YZHTaskOperationManager;

typedef void(^YZHTaskOperationBlock)(YZHTaskOperationManager *manager, YZHTaskOperation *taskOperation);
typedef void(^YZHTaskOperationCompletionBlock)(YZHTaskOperationManager *manager, YZHTaskOperation *taskOperation);


@interface YZHTaskOperationManager : NSObject

-(instancetype)initWithExecutionOrder:(YZHTaskOperationExecutionOrder)executionOrder;

/* <#name#> */
@property (nonatomic, assign, readonly) YZHTaskOperationExecutionOrder executionOrder;


@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;

//这个是默认添加到queue中
-(YZHTaskOperation*)addTaskOperation:(YZHTaskOperationBlock)taskBlock completion:(YZHTaskOperationCompletionBlock)completion forKey:(id)key;

-(YZHTaskOperation*)addTaskOperation:(YZHTaskOperationBlock)taskBlock completion:(YZHTaskOperationCompletionBlock)completion forKey:(id)key addToQueue:(BOOL)addToQueue;

-(void)startAllTaskOperationInQueue;

-(void)startTaskOperationForKey:(id)key;

-(YZHTaskOperation*)taskOperationForKey:(id)key;

-(void)addTaskOperationIntoQueue:(YZHTaskOperation*)taskOperation forKey:(id)key;

-(void)cancelTaskOperationForKey:(id)key;

@end
