//
//  YZHTaskManager.h
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/8.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHTaskOperationManager.h"

@class YZHTaskManager;

typedef id(^YZHTaskBlock)(YZHTaskManager *taskManager);
typedef void(^YZHTaskStopBlock)(YZHTaskManager *taskManager, id taskObject, id key);
typedef void(^YZHTaskRestartBlock)(YZHTaskManager *taskManager, id taskObject, id key);


@interface YZHTaskManager : NSObject
{
    @protected
    BOOL _sync;
    YZHTaskOperationManager *_operationManager;
}

/* <#name#> */
//@property (nonatomic, assign, readonly) BOOL sync;

//默认为5个任务
@property (nonatomic, assign) NSInteger maxConcurrentRunningTaskCnt;

@property (nonatomic, assign, readonly) NSInteger currentRunningTaskCnt;


-(instancetype)initWithOperationManager:(YZHTaskOperationManager*)operationManager sync:(BOOL)sync;

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

//返回通过addTaskBlock时taskBlock返回的对象
-(id)taskObjectForKey:(id)key;

@end
