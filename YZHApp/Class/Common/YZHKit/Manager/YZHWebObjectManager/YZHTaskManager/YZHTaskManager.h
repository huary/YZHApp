//
//  YZHTaskManager.h
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/8.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHOperationManager.h"

@class YZHTaskManager;

typedef id(^YZHTaskBlock)(YZHTaskManager *taskManager);
typedef void(^YZHTaskStopBlock)(YZHTaskManager *taskManager, id taskObject);
typedef void(^YZHTaskRestartBlock)(YZHTaskManager *taskManager, id taskObject);


@interface YZHTaskManager : NSObject
{
    @protected
    BOOL _sync;
    YZHOperationManager *_operationManager;
}

//默认为5个任务
@property (nonatomic, assign) NSInteger maxConcurrentRunningTaskCnt;

@property (nonatomic, assign, readonly) NSInteger currentRunningTaskCnt;


-(instancetype)initWithOperationManager:(YZHOperationManager*)operationManager sync:(BOOL)sync;

//默认cancelPrev默认为NO
-(void)addTaskBlock:(YZHTaskBlock)taskBlock forKey:(id)key;

-(void)addTaskBlock:(YZHTaskBlock)taskBlock forKey:(id)key cancelPrev:(BOOL)cancelPrev;

-(void)addTaskBlock:(YZHTaskBlock)taskBlock restartBlock:(YZHTaskRestartBlock)restartBlock stopBlock:(YZHTaskStopBlock)stopBlock forKey:(id)key cancelPrev:(BOOL)cancelPrev;

/*
 *同notifyTaskFinishForKey:(id)key cancelRetain:(BOOL)cancelRetain;
 *默认为NO
 */
-(void)notifyTaskFinishForKey:(id)key;

/*
 *cancelRetain是否这次完成还是下次可以重新启动
 *如果为YES，则不会移除，只是暂停这次task
 *如果为NO，则会移除，下次不会启动。
 */
-(void)notifyTaskFinishForKey:(id)key cancelRetain:(BOOL)cancelRetain;


-(void)cancelAllTask;

@end
