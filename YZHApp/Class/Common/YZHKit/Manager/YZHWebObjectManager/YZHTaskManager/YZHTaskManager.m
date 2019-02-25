//
//  YZHTaskManager.m
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/8.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHTaskManager.h"
#import "YZHKitType.h"
#import <objc/runtime.h>

static NSString *taskHaveStartKey_s = @"TaskHaveStart";


/****************************************************
 *YZHTaskOperation (Task)
 ****************************************************/
@interface YZHTaskOperation (Task)

@property (nonatomic, assign) BOOL hasAddToQueue;

@property (nonatomic, strong) NSMapTable *taskStartInfo;

/* <#name#> */
@property (nonatomic, copy) YZHTaskStopBlock stopBlock;

@end

@implementation YZHTaskOperation (Task)

-(void)setHasAddToQueue:(BOOL)hasAddToQueue
{
    objc_setAssociatedObject(self, @selector(hasAddToQueue), @(hasAddToQueue), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)hasAddToQueue
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setTaskStartInfo:(NSMapTable *)taskStartInfo
{
    objc_setAssociatedObject(self, @selector(taskStartInfo), taskStartInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMapTable*)taskStartInfo
{
    NSMapTable *mapTable = objc_getAssociatedObject(self, _cmd);
    if (!mapTable) {
        mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        self.taskStartInfo = mapTable;
    }
    return mapTable;
}


-(void)setStopBlock:(YZHTaskStopBlock)stopBlock
{
    objc_setAssociatedObject(self, @selector(stopBlock), stopBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHTaskStopBlock)stopBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

@end


/****************************************************
 *YZHTaskManager
 ****************************************************/
@interface YZHTaskManager ()

@property (nonatomic, strong) dispatch_semaphore_t lock;

/* <#注释#> */
//@property (nonatomic, strong) YZHTaskOperationManager *operationManager;

/*  */
@property (nonatomic, strong) NSMutableArray<YZHTaskOperation*> *taskList;

/* <#注释#> */
@property (nonatomic, strong) NSMapTable<id, YZHTaskOperation*> *taskMapTable;


@end

@implementation YZHTaskManager

-(instancetype)initWithOperationManager:(YZHTaskOperationManager*)operationManager sync:(BOOL)sync
{
    self = [super init];
    if (self) {
        [self _setupDefault];
        _operationManager = operationManager;
        [self _setupSync:sync];
    }
    return self;
}

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
    self.lock = dispatch_semaphore_create(1);
    
    self.maxConcurrentRunningTaskCnt = 5;
    _operationManager = [[YZHTaskOperationManager alloc] initWithExecutionOrder:YZHTaskOperationExecutionOrderFIFO];
    _operationManager.maxConcurrentOperationCount = 1;
}

-(void)_setupSync:(BOOL)sync
{
    _sync = sync;
    if (sync) {
//        _operationManager.maxConcurrentOperationCount = self.maxConcurrentRunningTaskCnt;
    }
    else {
        _operationManager.maxConcurrentOperationCount = 1;
    }
}

-(NSMutableArray<YZHTaskOperation*>*)taskList
{
    if (_taskList == nil) {
        _taskList = [NSMutableArray array];
    }
    return _taskList;
}

-(NSMapTable<id, YZHTaskOperation*>*)taskMapTable
{
    if (_taskMapTable == nil) {
        _taskMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return _taskMapTable;
}

//默认cancelPrev默认为NO
-(void)addTaskBlock:(YZHTaskBlock)taskBlock forKey:(id)key
{
    [self addTaskBlock:taskBlock forKey:key cancelPrev:NO];
}

-(void)addTaskBlock:(YZHTaskBlock)taskBlock forKey:(id)key cancelPrev:(BOOL)cancelPrev
{
    [self addTaskBlock:taskBlock restartBlock:nil stopBlock:nil forKey:key cancelPrev:cancelPrev];

}

-(void)addTaskBlock:(YZHTaskBlock)taskBlock restartBlock:(YZHTaskRestartBlock)restartBlock stopBlock:(YZHTaskStopBlock)stopBlock forKey:(id)key cancelPrev:(BOOL)cancelPrev
{
    if (!taskBlock) {
        return;
    }
    if (cancelPrev) {
        [self _cancelTaskOperationForKey:key cancelRetain:NO];
    }
    
    BOOL sync = _sync;
    WEAK_SELF(weakSelf);
    YZHTaskOperation *taskOperation = [_operationManager addTaskOperation:^(YZHTaskOperationManager *manager, YZHTaskOperation *taskOperation) {
        if (![[taskOperation.taskStartInfo objectForKey:taskHaveStartKey_s] boolValue]) {
            id task = taskBlock(weakSelf);
            taskOperation.taskObject = task;
            [taskOperation.taskStartInfo setObject:@(YES) forKey:taskHaveStartKey_s];
        }
        else {
            if (restartBlock) {
                restartBlock(weakSelf, taskOperation.taskObject, key);
            }
        }
        if (!sync) {
            [taskOperation finishExecuting];
        }
        [weakSelf _taskStartAction];
    } completion:^(YZHTaskOperationManager *manager, YZHTaskOperation *taskOperation) {
    } forKey:key addToQueue:NO];
    
    taskOperation.key = key;
    taskOperation.stopBlock = stopBlock;
    
    sync_lock(self.lock, ^{
        [self.taskList addObject:taskOperation];
        [self.taskMapTable setObject:taskOperation forKey:key];
        [self _checkTaskListQueue];
    });
    
//    return taskOperation;
}

-(void)notifyTaskFinishForKey:(id)key
{
    [self _cancelTaskOperationForKey:key cancelRetain:NO];
}

-(void)notifyTaskFinishForKey:(id)key cancelRetain:(BOOL)cancelRetain
{
    [self _cancelTaskOperationForKey:key cancelRetain:cancelRetain];
}

-(void)cancelAllTask
{
    sync_lock(self.lock, ^{
        [self.taskList enumerateObjectsUsingBlock:^(YZHTaskOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
        [self.taskList removeAllObjects];
        [self.taskMapTable removeAllObjects];
        _currentRunningTaskCnt = 0;
    });
}

-(id)taskObjectForKey:(id)key
{
    //这里不用锁
    YZHTaskOperation *taskOperation = [self.taskMapTable objectForKey:key];
    return taskOperation.taskObject;
}

-(void)_cancelTaskOperationForKey:(id)key cancelRetain:(BOOL)cancelRetain
{
    sync_lock(self.lock, ^{
        YZHTaskOperation *taskOperation = [self.taskMapTable objectForKey:key];
        if (!taskOperation) {
            [self _checkTaskListQueue];
            return ;
        }
        
        if (taskOperation.stopBlock) {
            taskOperation.stopBlock(self, taskOperation.taskObject, key);
        }
                
        [taskOperation cancel];

        if (cancelRetain) {
            taskOperation.hasAddToQueue = NO;
        }
        else {
            [self.taskList removeObject:taskOperation];
            [self.taskMapTable removeObjectForKey:key];
        }
        --_currentRunningTaskCnt;
        [self _checkTaskListQueue];
    });
}

//在operation启动的时候
-(void)_taskStartAction
{
    sync_lock(self.lock, ^{
        ++_currentRunningTaskCnt;
    });
}

//这里不能单独调用，需要放在lock里面
-(void)_checkTaskListQueue
{
    NSInteger diffCnt = self.maxConcurrentRunningTaskCnt - self.currentRunningTaskCnt;
    if (diffCnt == 0) {
        return;
    }
    if (diffCnt > 0) {
        __block NSInteger addCnt = 0;
        [self.taskList enumerateObjectsUsingBlock:^(YZHTaskOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (addCnt < diffCnt) {
                if (!obj.hasAddToQueue) {
                    ++addCnt;
                    [_operationManager addTaskOperationIntoQueue:obj forKey:obj.key];
                    obj.hasAddToQueue = YES;
                }
            }
            else {
                *stop = YES;
            }
        }];
    }
    else {
        diffCnt = -diffCnt;
        __block NSInteger cancelCnt = 0;
        [self.taskList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(YZHTaskOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (cancelCnt < diffCnt) {
                if (obj.hasAddToQueue) {
                    ++cancelCnt;
                    if (obj.stopBlock) {
                        obj.stopBlock(self, obj.taskObject, obj.key);
                    }
                    [obj cancel];
                    obj.hasAddToQueue = NO;
                }
            }
        }];
    }
}

@end
