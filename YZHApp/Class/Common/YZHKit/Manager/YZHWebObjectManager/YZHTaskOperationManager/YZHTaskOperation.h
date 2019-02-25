//
//  YZHTaskOperation.h
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSNotificationName const YZHTaskOperationStartNotification;
UIKIT_EXTERN NSNotificationName const YZHTaskOperationWillFinishNotification;
UIKIT_EXTERN NSNotificationName const YZHTaskOperationDidFinishNotification;


@class YZHTaskOperation;
typedef void(^YZHTaskOperationStartBlock)(YZHTaskOperation *taskOperation);
typedef void(^YZHTaskOperationWillFinishBlock)(YZHTaskOperation *taskOperation);
typedef void(^YZHTaskOperationDidFinishBlock)(YZHTaskOperation *taskOperation);

@interface YZHTaskOperation : NSOperation

/* 需要做的任务对象 */
@property (nonatomic, strong) id taskObject;

/* <#注释#> */
@property (nonatomic, strong) id key;

/* <#注释#> */
@property (nonatomic, copy) YZHTaskOperationStartBlock startBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHTaskOperationWillFinishBlock willFinishBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHTaskOperationDidFinishBlock didFinishBlock;

-(void)finishExecuting;

@end
