//
//  YZHOperation.h
//  YZHApp
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSNotificationName const YZHOperationStartNotification;
UIKIT_EXTERN NSNotificationName const YZHOperationCancelNotification;
UIKIT_EXTERN NSNotificationName const YZHOperationCompletionNotification;


@class YZHOperation;
typedef void(^YZHOperationStartBlock)(YZHOperation *operation);
typedef void(^YZHOperationCancelBlock)(YZHOperation *operation);
typedef void(^YZHOperationCompletionBlock)(YZHOperation *operation);


@interface YZHOperation : NSOperation
/* 需要做的任务对象 */
@property (nonatomic, strong) id taskObject;

@property (nonatomic, strong) id key;

@property (nonatomic, copy) YZHOperationStartBlock startBlock;

@property (nonatomic, copy) YZHOperationCancelBlock cancelBlock;

//为了不和父类的completionBlock重名
@property (nonatomic, copy) YZHOperationCompletionBlock finishBlock;

-(BOOL)isStarted;

-(void)finishExecuting;

-(BOOL)canAddIntoOperationQueue;

@end
