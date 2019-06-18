//
//  YZHOperation.m
//  YZHApp
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHOperation.h"
#import "YZHKitType.h"

NSNotificationName const YZHOperationStartNotification = @"YZHOperationStartNotification";
NSNotificationName const YZHOperationCancelNotification = @"YZHOperationCancelNotification";
NSNotificationName const YZHOperationCompletionNotification = @"YZHOperationCompletionNotification";

#define SET_OPERATION_PROPERTY(PROPERTY,...)    [self willChangeValueForKey:PROPERTY]; \
                                                __VA_ARGS__; \
                                                [self didChangeValueForKey:PROPERTY];


@interface YZHOperation ()

@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign, getter=isExecuting) BOOL executing;

/* <#name#> */
@property (nonatomic, assign, getter=isStarted) BOOL started;

@end

@implementation YZHOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

+ (void)_threadEntryPoint:(id)object
{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"YZHOperation"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)_taskThread
{
    static NSThread *taskThread_s = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        taskThread_s = [[NSThread alloc] initWithTarget:[self class] selector:@selector(_threadEntryPoint:) object:nil];
        [taskThread_s start];
    });
    return taskThread_s;
}

-(void)setFinishBlock:(YZHOperationCompletionBlock)finishBlock
{
    _finishBlock = finishBlock;
    WEAK_SELF(weakSelf);
    self.completionBlock = ^{
        [weakSelf performSelector:@selector(_completionAction:) onThread:[[weakSelf class] _taskThread] withObject:nil waitUntilDone:NO];
    };
}

#pragma mark override
-(void)start
{
    //要加锁，是因为start有可能同时被多个线程调用
    @autoreleasepool {
        @synchronized (self) {
            [self _startAction];
        }
    }
}

-(void)cancel
{
    //要加锁，是因为cancel有可能同时被多个线程调用
    @autoreleasepool {
        @synchronized (self) {
            [self _cancelAction];
        }
    }
}

-(void)setFinished:(BOOL)finished
{
    @synchronized (self) {
        if (_finished != finished) {
            SET_OPERATION_PROPERTY(@"isFinished", _finished = finished)
        }
    }
}

-(BOOL)isFinished
{
    BOOL finished;
    @synchronized (self) {
        finished = _finished;
    }
    return finished;
}

-(void)setExecuting:(BOOL)executing
{
    @synchronized (self) {
        if (_executing != executing) {
            SET_OPERATION_PROPERTY(@"isExecuting",_executing = executing)
        }
    }
}

-(BOOL)isExecuting
{
    BOOL executing;
    @synchronized (self) {
        executing = _executing;
    }
    return executing;
}

-(BOOL)isConcurrent
{
    return YES;
}

-(void)_startAction
{
    if (self.isCancelled) {
        self.finished = YES;
        return;
    }
    self.started = YES;
    self.finished = NO;
    self.executing = YES;
    
    [self performSelector:@selector(_doStartTask) onThread:[[self class] _taskThread] withObject:nil waitUntilDone:NO];
}

-(void)_cancelAction
{
    if (self.isFinished || self.isCancelled || !self.isStarted) {
        return;
    }
    
    [self performSelector:@selector(_doCancelTask) onThread:[[self class] _taskThread] withObject:nil waitUntilDone:NO];
    
    [super cancel];
    
    [self finishExecuting];
}

-(void)_doStartTask
{
    if (self.startBlock) {
        self.startBlock(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:YZHOperationStartNotification object:self];
}

-(void)_doCancelTask
{
    if (self.cancelBlock) {
        self.cancelBlock(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:YZHOperationCancelNotification object:self];
}

- (void)_completionAction:(id)object
{
    if (self.finishBlock) {
        self.finishBlock(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:YZHOperationCompletionNotification object:self];
}

-(void)finishExecuting
{
    if (self.started) {
        self.finished = YES;
    }
    self.executing = NO;
}

-(BOOL)canAddIntoOperationQueue
{
    if (!self.isExecuting && !self.finished) {
        return YES;
    }
    return NO;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"key=%@,isCancelled=%d,isExecuting=%d,isFinished=%d,isConcurrent=%d,isAsynchronous=%d,isReady=%d",self.key,self.isCancelled,self.isExecuting,self.isFinished,self.concurrent,self.isAsynchronous,self.isReady];
}

-(void)dealloc
{
    NSLog(@"operation.key=%@---dealloc",self.key);
}



@end
