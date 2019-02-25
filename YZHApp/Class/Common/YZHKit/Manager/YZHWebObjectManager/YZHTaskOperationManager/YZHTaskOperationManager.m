//
//  YZHTaskOperationManager.m
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHTaskOperationManager.h"
#import "YZHTaskOperation.h"
#import "YZHKitType.h"

@interface YZHTaskOperationManager ()

@property (nonatomic, strong) dispatch_semaphore_t lock;

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, weak) YZHTaskOperation *lastTaskOperation;

//是从开始创建到完成时保留的对象
@property (nonatomic, strong) NSMapTable<id, YZHTaskOperation*> *taskOperationMapTable;

//还没有进入到operationQueue中的YZHTaskOperation
@property (nonatomic, strong) NSHashTable<YZHTaskOperation*> *notInQueueTaskOperationList;

@end

@implementation YZHTaskOperationManager


-(instancetype)initWithExecutionOrder:(YZHTaskOperationExecutionOrder)executionOrder
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

-(NSMapTable<id,YZHTaskOperation*>*)taskOperationMapTable
{
    if (_taskOperationMapTable == nil) {
        _taskOperationMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _taskOperationMapTable;
}

-(NSHashTable<YZHTaskOperation*>*)notInQueueTaskOperationList
{
    if (_notInQueueTaskOperationList == nil) {
        _notInQueueTaskOperationList = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _notInQueueTaskOperationList;
}

-(YZHTaskOperation*)_firstFILOTaskOperation
{
    if (self.executionOrder != YZHTaskOperationExecutionOrderFILO) {
        return nil;
    }
    YZHTaskOperation *firstLIFOTaskOperation = [[YZHTaskOperation alloc] init];
    firstLIFOTaskOperation.key = @"helloFirstNull";
    firstLIFOTaskOperation.startBlock = ^(YZHTaskOperation *taskOperation) {
        [taskOperation finishExecuting];
    };
    [self.operationQueue addOperation:firstLIFOTaskOperation];
    return firstLIFOTaskOperation;
}


-(void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
{
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    if (self.executionOrder == YZHTaskOperationExecutionOrderNone) {
        self.operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount;        
    }
}

-(YZHTaskOperation*)addTaskOperation:(YZHTaskOperationBlock)taskBlock completion:(YZHTaskOperationCompletionBlock)completion forKey:(id)key
{
    return [self addTaskOperation:taskBlock completion:completion forKey:key addToQueue:YES];
}

-(YZHTaskOperation*)addTaskOperation:(YZHTaskOperationBlock)taskBlock completion:(YZHTaskOperationCompletionBlock)completion forKey:(id)key addToQueue:(BOOL)addToQueue
{
    YZHTaskOperation *taskOperation = [[YZHTaskOperation alloc] init];
    taskOperation.key = key;
    
    WEAK_SELF(weakSelf);
    taskOperation.startBlock = ^(YZHTaskOperation *taskOperation) {
//        NSLog(@"%@-beginStart.operationCnt=%ld,operations=%@,thread=%@",taskOperation.key,self.operationQueue.operationCount,self.operationQueue.operations,[NSThread currentThread]);
        [weakSelf _willStartAction:key];
        if (taskBlock) {
            taskBlock(weakSelf, taskOperation);
        }
    };
    
    taskOperation.didFinishBlock = ^(YZHTaskOperation *taskOperation) {
//        NSLog(@"%@-didFinish.operationCnt=%ld,operations=%@,thread=%@",key,self.operationQueue.operationCount,self.operationQueue.operations,[NSThread currentThread]);
        [weakSelf _didFinishAction:key];
        if (completion) {
            completion(weakSelf, taskOperation);
        }
    };
    
    sync_lock(self.lock, ^{
        if (self.executionOrder == YZHTaskOperationExecutionOrderFILO) {
            YZHTaskOperation *lastTaskOperation = self.lastTaskOperation ? self.lastTaskOperation : [self _firstFILOTaskOperation];
            [lastTaskOperation addDependency:taskOperation];
        }
        else if (self.executionOrder == YZHTaskOperationExecutionOrderFIFO) {
            if (self.lastTaskOperation) {
                [taskOperation addDependency:self.lastTaskOperation];
            }
        }
        else {
        }
        if (addToQueue) {
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

+(BOOL)_canAddOperationIntoQueue:(YZHTaskOperation*)taskOperation
{
    if (taskOperation && !taskOperation.isExecuting && !taskOperation.finished) {
        return YES;
    }
    return NO;
}

-(void)startAllTaskOperationInQueue
{
    sync_lock(self.lock, ^{
        NSEnumerator *objEnumerator = [self.notInQueueTaskOperationList objectEnumerator];
        YZHTaskOperation *taskOperation = nil;
        while (taskOperation = [objEnumerator nextObject]) {
            if ([[self class] _canAddOperationIntoQueue:taskOperation]) {
                [self.operationQueue addOperation:taskOperation];                
            }
        }
        [self.notInQueueTaskOperationList removeAllObjects];
    });
}


-(void)startTaskOperationForKey:(id)key
{
    sync_lock(self.lock, ^{
        YZHTaskOperation *taskOperation = [self.taskOperationMapTable objectForKey:key];
        if ([[self class] _canAddOperationIntoQueue:taskOperation] && [self.notInQueueTaskOperationList containsObject:taskOperation]) {
            [self.operationQueue addOperation:taskOperation];
        }
        [self.notInQueueTaskOperationList removeObject:taskOperation];
    });
}

-(YZHTaskOperation*)taskOperationForKey:(id)key
{
    __block YZHTaskOperation *taskOperation = nil;
    sync_lock(self.lock, ^{
        taskOperation = [self.taskOperationMapTable objectForKey:key];
    });
    return taskOperation;
}

-(void)addTaskOperationIntoQueue:(YZHTaskOperation*)taskOperation forKey:(id)key
{
    sync_lock(self.lock, ^{
        taskOperation.key = key;
        [self.operationQueue addOperation:taskOperation];
        [self.taskOperationMapTable setObject:taskOperation forKey:key];
    });
}

-(void)cancelTaskOperationForKey:(id)key
{
    YZHTaskOperation *taskOperation = [self.taskOperationMapTable objectForKey:key];
    [taskOperation cancel];
}

#pragma mark private
-(void)_willStartAction:(id)key
{
}

-(void)_didFinishAction:(id)key
{
    sync_lock(self.lock, ^{
        YZHTaskOperation *taskOperation = [self.taskOperationMapTable objectForKey:key];
        [self.taskOperationMapTable removeObjectForKey:key];
        /*如果外部持有了taskOperation，导致notInQueueTaskOperationList没有释放掉，
         *所以这里从notInQueueTaskOperationList中remove掉,
         *在有依赖关系的operation时，就会对operation产生强引用，就不会在释放完成时释放掉
         */
        [self.notInQueueTaskOperationList removeObject:taskOperation];
        NSLog(@"%@,%@",self.taskOperationMapTable,self.notInQueueTaskOperationList);
    });
}

@end
