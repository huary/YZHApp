//
//  YZHTaskOperation.m
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHTaskOperation.h"
#import "YZHKitType.h"

NSNotificationName const YZHTaskOperationStartNotification = @"YZHTaskOperationStartNotification";
NSNotificationName const YZHTaskOperationWillFinishNotification = @"YZHTaskOperationWillFinishNotification";
NSNotificationName const YZHTaskOperationDidFinishNotification = @"YZHTaskOperationDidFinishNotification";

#define SET_OPERATION_PROPERTY(PROPERTY,...)    [self willChangeValueForKey:PROPERTY]; \
                                                __VA_ARGS__; \
                                                [self didChangeValueForKey:PROPERTY];


@interface YZHTaskOperation ()

@property (nonatomic, assign, getter=isFinished) BOOL finished;
@property (nonatomic, assign, getter=isExecuting) BOOL executing;

/* <#name#> */
@property (nonatomic, assign, getter=isStarted) BOOL started;

@end

@implementation YZHTaskOperation

@synthesize finished = _finished;
@synthesize executing = _executing;

-(void)setDidFinishBlock:(YZHTaskOperationDidFinishBlock)didFinishBlock
{
    _didFinishBlock = didFinishBlock;
    
    WEAK_SELF(weakSelf);
    self.completionBlock = ^{
        NSLog(@"YZHTaskOperation.key=%@===========completionBlock",weakSelf.key);
        if (weakSelf.didFinishBlock) {
            didFinishBlock(weakSelf);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:YZHTaskOperationDidFinishNotification object:weakSelf];
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

-(void)setExecuting:(BOOL)executing
{
    @synchronized (self) {
        if (_executing != executing) {
            SET_OPERATION_PROPERTY(@"isExecuting",_executing = executing)
        }
    }
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
    if (self.startBlock) {
        self.startBlock(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:YZHTaskOperationStartNotification object:self];
}

-(void)_cancelAction
{
    if (self.isFinished || self.isCancelled) {
        return;
    }
    
    if (self.willFinishBlock) {
        self.willFinishBlock(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:YZHTaskOperationWillFinishNotification object:self];
    
    if (self.isStarted) {
        self.finished = YES;
    }
    self.executing = NO;
    
    [super cancel];
}

-(void)finishExecuting
{
    if (self.started) {
        self.finished = YES;
    }
    self.executing = NO;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"key=%@,isCancelled=%d,isExecuting=%d,isFinished=%d,isConcurrent=%d,isAsynchronous=%d,isReady=%d",self.key,self.isCancelled,self.isExecuting,self.isFinished,self.concurrent,self.isAsynchronous,self.isReady];
}


@end
