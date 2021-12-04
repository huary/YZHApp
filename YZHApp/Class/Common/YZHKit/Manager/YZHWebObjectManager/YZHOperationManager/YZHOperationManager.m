//
//  YZHOperationManager.m
//  YZHApp
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//


#import "YZHOperationManager.h"
#import "YZHKitType.h"

@interface YZHOperationManager ()

@property (nonatomic, strong) dispatch_semaphore_t lock;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, weak) YZHOperation *lastTaskOperation;

//是从开始创建到完成时保留的对象
@property (nonatomic, strong) NSMapTable<id, YZHOperation*> *taskOperationMapTable;

//还没有进入到operationQueue中的YZHTaskOperation
@property (nonatomic, strong) NSHashTable<YZHOperation*> *notInQueueTaskOperationList;

@end

@implementation YZHOperationManager


-(instancetype)initWithExecutionOrder:(YZHOperationExecutionOrder)executionOrder
{
    self = [super init];
    if (self) {
        [self _setupDefault];
        _executionOrder = executionOrder;
    }
    return self;
}

-(void)_setupDefault
{
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.maxConcurrentOperationCount = 1;
    self.lock = dispatch_semaphore_create(1);
}

-(NSMapTable<id,YZHOperation*>*)taskOperationMapTable
{
    if (_taskOperationMapTable == nil) {
        _taskOperationMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _taskOperationMapTable;
}

-(NSHashTable<YZHOperation*>*)notInQueueTaskOperationList
{
    if (_notInQueueTaskOperationList == nil) {
        _notInQueueTaskOperationList = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _notInQueueTaskOperationList;
}

-(YZHOperation*)_firstFILOTaskOperation
{
    if (self.executionOrder != YZHOperationExecutionOrderFILO) {
        return nil;
    }
    YZHOperation *firstLIFOTaskOperation = [[YZHOperation alloc] init];
    firstLIFOTaskOperation.key = @"helloFirstNull";
    firstLIFOTaskOperation.startBlock = ^(YZHOperation *operation) {
        [operation finishExecuting];
    };
    if ([self _shouldAddIntoQueueForTaskOperation:firstLIFOTaskOperation]) {
        [self.operationQueue addOperation:firstLIFOTaskOperation];
    }
    return firstLIFOTaskOperation;
}


-(void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
{
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    if (self.executionOrder == YZHOperationExecutionOrderNone) {
        self.operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount;
    }
}

-(YZHOperation*)addTaskOperation:(YZHTaskOperationBlock)taskBlock completion:(YZHTaskOperationCompletionBlock)completion forKey:(id)key
{
    return [self addTaskOperation:taskBlock completion:completion forKey:key addToQueue:YES];
}

-(YZHOperation*)addTaskOperation:(YZHTaskOperationBlock)taskBlock completion:(YZHTaskOperationCompletionBlock)completion forKey:(id)key addToQueue:(BOOL)addToQueue
{
    YZHOperation *taskOperation = [[YZHOperation alloc] init];
    taskOperation.key = key;
    
    WEAK_SELF(weakSelf);
    taskOperation.startBlock = ^(YZHOperation *operation) {
        [weakSelf _willStartAction:key];
        if (taskBlock) {
            taskBlock(weakSelf, operation);
        }
    };
    
    taskOperation.finishBlock = ^(YZHOperation *operation) {
        [weakSelf _didFinishAction:key];
        if (completion) {
            completion(weakSelf, operation);
        }
    };
    
    sync_lock(self.lock, ^{
        if (self.executionOrder == YZHOperationExecutionOrderFILO) {
            YZHOperation *lastTaskOperation = self.lastTaskOperation ? self.lastTaskOperation : [self _firstFILOTaskOperation];
            [lastTaskOperation addDependency:taskOperation];
        }
        else if (self.executionOrder == YZHOperationExecutionOrderFIFO) {
            if (self.lastTaskOperation) {
                [taskOperation addDependency:self.lastTaskOperation];
            }
        }
        else {
        }
        if (addToQueue && [self _shouldAddIntoQueueForTaskOperation:taskOperation]) {
            [self.operationQueue addOperation:taskOperation];
        }
        else {
            [self.notInQueueTaskOperationList addObject:taskOperation];
        }
        [self.taskOperationMapTable setObject:taskOperation forKey:key];
        self.lastTaskOperation = taskOperation;
    });
    
    return taskOperation;
}

-(void)startAllTaskOperationInQueue
{
    sync_lock(self.lock, ^{
        NSEnumerator *objEnumerator = [self.notInQueueTaskOperationList objectEnumerator];
        YZHOperation *taskOperation = nil;
        while (taskOperation = [objEnumerator nextObject]) {
            if ([self _shouldAddIntoQueueForTaskOperation:taskOperation]) {
                [self.operationQueue addOperation:taskOperation];
            }
        }
        [self.notInQueueTaskOperationList removeAllObjects];
    });
}


-(void)startTaskOperationForKey:(id)key
{
    sync_lock(self.lock, ^{
        YZHOperation *taskOperation = [self.taskOperationMapTable objectForKey:key];
        if ([self _shouldAddIntoQueueForTaskOperation:taskOperation] &&
            [self.notInQueueTaskOperationList containsObject:taskOperation]) {
            [self.operationQueue addOperation:taskOperation];
        }
        [self.notInQueueTaskOperationList removeObject:taskOperation];
    });
}

-(YZHOperation*)taskOperationForKey:(id)key
{
    __block YZHOperation *taskOperation = nil;
    sync_lock(self.lock, ^{
        taskOperation = [self.taskOperationMapTable objectForKey:key];
    });
    return taskOperation;
}

-(void)addTaskOperationIntoQueue:(YZHOperation*)taskOperation forKey:(id)key
{
    sync_lock(self.lock, ^{
        taskOperation.key = key;
        if ([self _shouldAddIntoQueueForTaskOperation:taskOperation]) {
            [self.operationQueue addOperation:taskOperation];
        }
        else {
            [self.notInQueueTaskOperationList addObject:taskOperation];
        }
        [self.taskOperationMapTable setObject:taskOperation forKey:key];
    });
}

-(void)cancelTaskOperationForKey:(id)key
{
    YZHOperation *taskOperation = [self.taskOperationMapTable objectForKey:key];
    [taskOperation cancel];
}

#pragma mark private
-(void)_willStartAction:(id)key
{
}

-(void)_didFinishAction:(id)key
{
    sync_lock(self.lock, ^{
        YZHOperation *taskOperation = [self.taskOperationMapTable objectForKey:key];
        [self.taskOperationMapTable removeObjectForKey:key];
        /*如果外部持有了taskOperation，导致notInQueueTaskOperationList没有释放掉，
         *所以这里从notInQueueTaskOperationList中remove掉,
         *在有依赖关系的operation时，就会对operation产生强引用，就不会在释放完成时释放掉
         */
        [self.notInQueueTaskOperationList removeObject:taskOperation];
//        NSLog(@"self.notInQueueTaskOperationList=%ld",self.notInQueueTaskOperationList.count);
//        NSLog(@"=====%@,%@",self.taskOperationMapTable,self.notInQueueTaskOperationList);
    });
}


/// 需要在lock中调用
- (BOOL)_shouldAddIntoQueueForTaskOperation:(YZHOperation*)taskOperation {
    BOOL canAdd = [taskOperation canAddIntoOperationQueue];
    if (!canAdd) {
        return NO;
    }
    if (self.maxAddIntoQueueCount > 0 &&
        self.operationQueue.operationCount < self.maxAddIntoQueueCount) {
        return YES;
    }
    return YES;
}

@end
