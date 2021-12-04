//
//  YZHOperationManager.h
//  YZHApp
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHOperation.h"

typedef NS_ENUM(NSInteger, YZHOperationExecutionOrder)
{
    YZHOperationExecutionOrderNone  = -1,
    YZHOperationExecutionOrderFIFO  = 0,
    YZHOperationExecutionOrderFILO  = 1,
};

@class YZHOperationManager;

typedef void(^YZHTaskOperationBlock)(YZHOperationManager *manager, YZHOperation *operation);
typedef void(^YZHTaskOperationCompletionBlock)(YZHOperationManager *manager, YZHOperation *operation);


@interface YZHOperationManager : NSObject

-(instancetype)initWithExecutionOrder:(YZHOperationExecutionOrder)executionOrder;

/* <#name#> */
@property (nonatomic, assign, readonly) YZHOperationExecutionOrder executionOrder;


@property (nonatomic, assign) NSInteger maxConcurrentOperationCount;

/// 最大可加入到Queue中的operation的个数，默认为0，无限制
@property (nonatomic, assign) NSInteger maxAddIntoQueueCount;

//这个是默认添加到queue中
-(YZHOperation*)addTaskOperation:(YZHTaskOperationBlock)taskBlock completion:(YZHTaskOperationCompletionBlock)completion forKey:(id)key;

-(YZHOperation*)addTaskOperation:(YZHTaskOperationBlock)taskBlock completion:(YZHTaskOperationCompletionBlock)completion forKey:(id)key addToQueue:(BOOL)addToQueue;

-(void)startAllTaskOperationInQueue;

-(void)startTaskOperationForKey:(id)key;

-(YZHOperation*)taskOperationForKey:(id)key;

-(void)addTaskOperationIntoQueue:(YZHOperation*)taskOperation forKey:(id)key;

-(void)cancelTaskOperationForKey:(id)key;

@end
