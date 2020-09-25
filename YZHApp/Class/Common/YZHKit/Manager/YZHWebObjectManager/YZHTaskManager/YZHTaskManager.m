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

static NSString *taskCancelPreKey_s = @"cancelPrev";
static NSString *taskBlockKey_s  = @"taskBlock";
static NSString *taskStopBlockKey_s = @"stopBlock";
static NSString *taskRestartBlockKey_s = @"restartBlock";


/****************************************************
 *YZHOperation (Task)
 ****************************************************/
@interface YZHOperation (Task)

@property (nonatomic, assign) BOOL hasAddToQueue;

@property (nonatomic, strong) NSMapTable *taskStartInfo;

@end

@implementation YZHOperation (Task)

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
    NSMapTable *info = objc_getAssociatedObject(self, _cmd);
    if (!info) {
        info = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        self.taskStartInfo = info;
    }
    return info;
}

@end


/****************************************************
 *YZHTaskManager
 ****************************************************/
@interface YZHTaskManager ()

@property (nonatomic, strong) dispatch_semaphore_t lock;

@property (nonatomic, strong) NSMutableArray<YZHOperation*> *taskList;

@property (nonatomic, strong) NSMapTable<id, YZHOperation*> *taskMapTable;


@end

@implementation YZHTaskManager

-(instancetype)initWithOperationManager:(YZHOperationManager*)operationManager sync:(BOOL)sync
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
    _operationManager = [[YZHOperationManager alloc] initWithExecutionOrder:YZHOperationExecutionOrderFIFO];
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

-(NSMutableArray<YZHOperation*>*)taskList
{
    if (_taskList == nil) {
        _taskList = [NSMutableArray array];
    }
    return _taskList;
}

-(NSMapTable<id, YZHOperation*>*)taskMapTable
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
    [self _addTaskBlock:taskBlock restartBlock:restartBlock stopBlock:stopBlock forKey:key cancelPrev:cancelPrev save:YES];
}

-(YZHOperation*)_addTaskBlock:(YZHTaskBlock)taskBlock restartBlock:(YZHTaskRestartBlock)restartBlock stopBlock:(YZHTaskStopBlock)stopBlock forKey:(id)key cancelPrev:(BOOL)cancelPrev save:(BOOL)save
{
    if (!taskBlock) {
        return nil;
    }
    if (cancelPrev) {
        [self _cancelTaskOperationForKey:key cancelRetain:NO];
    }
    
    BOOL sync = _sync;
    WEAK_SELF(weakSelf);
    YZHOperation *taskOperation = [_operationManager addTaskOperation:^(YZHOperationManager *manager, YZHOperation *operation) {
        if (![[operation.taskStartInfo objectForKey:taskHaveStartKey_s] boolValue]) {
            id task = taskBlock(weakSelf);
            operation.taskObject = task;
            [operation.taskStartInfo setObject:@(YES) forKey:taskHaveStartKey_s];
        }
        else {
            if (restartBlock) {
                restartBlock(weakSelf, operation.taskObject);
            }
        }
        
        [weakSelf _taskStartAction];
        
        if (!sync) {
            [operation finishExecuting];
        }
    } completion:^(YZHOperationManager *manager, YZHOperation *operation) {
        [weakSelf  _operationCompletion:operation inOperationMamager:manager];
    } forKey:key addToQueue:NO];
    
    taskOperation.key = key;
    [taskOperation.taskStartInfo setObject:taskBlock forKey:taskBlockKey_s];
    [taskOperation.taskStartInfo setObject:stopBlock forKey:taskStopBlockKey_s];
    [taskOperation.taskStartInfo setObject:restartBlock forKey:taskRestartBlockKey_s];
    [taskOperation.taskStartInfo setObject:@(cancelPrev) forKey:taskCancelPreKey_s];
    
    if (save) {
        sync_lock(self.lock, ^{
            [self.taskList addObject:taskOperation];
            [self.taskMapTable setObject:taskOperation forKey:key];
            [self _checkTaskListQueue];
        });
    }
    return taskOperation;
}

//这里不开启检查
-(void)_operationCompletion:(YZHOperation*)operation inOperationMamager:(YZHOperationManager*)operationManager
{
    sync_lock(self.lock, ^{
        [self.taskList removeObject:operation];
        [self.taskMapTable removeObjectForKey:operation.key];
        --self->_currentRunningTaskCnt;
        self->_currentRunningTaskCnt = MAX(self.currentRunningTaskCnt, 0);
    });
}


-(YZHOperation*)_addNewOperationWithOperation:(YZHOperation*)operation
{
    YZHTaskBlock taskBlock = [operation.taskStartInfo objectForKey:taskBlockKey_s];
    YZHTaskStopBlock stopBlock = [operation.taskStartInfo objectForKey:taskStopBlockKey_s];
    YZHTaskRestartBlock restartBlock = [operation.taskStartInfo objectForKey:taskRestartBlockKey_s];
    BOOL cancelPrev = NO;//[operation.taskStartInfo objectForKey:taskCancelPreKey_s];
    
    return [self _addTaskBlock:taskBlock restartBlock:restartBlock stopBlock:stopBlock forKey:operation.key cancelPrev:cancelPrev save:NO];
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
        [self.taskList enumerateObjectsUsingBlock:^(YZHOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
        [self.taskList removeAllObjects];
        [self.taskMapTable removeAllObjects];
        self->_currentRunningTaskCnt = 0;
    });
}

-(void)_cancelTaskOperationForKey:(id)key cancelRetain:(BOOL)cancelRetain
{
    sync_lock(self.lock, ^{
        YZHOperation *taskOperation = [self.taskMapTable objectForKey:key];
        if (!taskOperation) {
            [self _checkTaskListQueue];
            return ;
        }
        
        YZHTaskStopBlock stopBlock = [taskOperation.taskStartInfo objectForKey:taskStopBlockKey_s];
        if (stopBlock) {
            stopBlock(self, taskOperation.taskObject);
        }
    
        [taskOperation cancel];

        [self.taskList removeObject:taskOperation];
        [self.taskMapTable removeObjectForKey:key];
        if (cancelRetain) {
            YZHOperation *newTaskOperation = [self _addNewOperationWithOperation:taskOperation];
            [self.taskList addObject:newTaskOperation];
            [self.taskMapTable setObject:newTaskOperation forKey:key];
        }

        --self->_currentRunningTaskCnt;
        self->_currentRunningTaskCnt = MAX(self->_currentRunningTaskCnt, 0);
        [self _checkTaskListQueue];
    });
}

//在operation启动的时候
-(void)_taskStartAction
{
    sync_lock(self.lock, ^{
        ++self->_currentRunningTaskCnt;
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
        [self.taskList enumerateObjectsUsingBlock:^(YZHOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        NSMutableArray *newList = [NSMutableArray array];
        NSMutableArray *cancelList = [NSMutableArray array];
        [self.taskList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(YZHOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (cancelCnt < diffCnt) {
                if (obj.hasAddToQueue) {
                    ++cancelCnt;
                    YZHTaskStopBlock stopBlock = [obj.taskStartInfo objectForKey:taskStopBlockKey_s];
                    if (stopBlock) {
                        stopBlock(self, obj.taskObject);
                    }
                    [obj cancel];
                    [cancelList addObject:obj];
                    [self.taskMapTable removeObjectForKey:obj.key];
                    YZHOperation *newTaskOperation = [self _addNewOperationWithOperation:obj];
                    [newList addObject:newTaskOperation];
                    [self.taskMapTable setObject:newTaskOperation forKey:newTaskOperation.key];
                }
            }
        }];
        [self.taskList removeObjectsInArray:cancelList];
        [self.taskList addObjectsFromArray:newList];
    }
}

@end
