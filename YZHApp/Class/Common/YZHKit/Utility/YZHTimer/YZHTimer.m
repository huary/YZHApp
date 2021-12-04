//
//  YZHTimer.m
//  YZHTimerDemo
//
//  Created by yuan on 2018/12/14.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHTimer.h"
#import "YZHKitType.h"
#import "YZHQueue.h"

@implementation YZHTimer
{
    __weak id _target;
    SEL _selector;
    BOOL _isToTarget;
    BOOL _wallTime;
    YZHQueue *_queue;
    NSTimeInterval _timeAfter;
    YZHTimerFireBlock _fireBlock;
    dispatch_source_t _timerSource;
    uint64_t _startTime;
    uint64_t _endTime;
    
//    uint64_t _suspendStartTime;
//    uint64_t _suspendTime;
    
    BOOL _isSuspend;
}

//默认在mainQueue
+(instancetype)timerWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeat:(BOOL)repeat queue:(dispatch_queue_t)queue userInfo:(id)userInfo
{
    return [[[self class] alloc] initWithFireTimeAfter:timeAfter interval:interval target:target selector:selector repeat:repeat queue:queue userInfo:userInfo];
}

+(instancetype)timerWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval repeat:(BOOL)repeat queue:(dispatch_queue_t)queue userInfo:(id)userInfo fireBlock:(YZHTimerFireBlock)fireBlock
{
    return [[[self class] alloc] initWithFireTimeAfter:timeAfter interval:interval repeat:repeat queue:queue userInfo:userInfo fireBlock:fireBlock];
}

+(instancetype)timerWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeat:(BOOL)repeat
{
    return [[[self class] alloc] initWithFireTimeAfter:interval interval:interval target:target selector:selector repeat:repeat];
}

+(instancetype)timerWithTimeInterval:(NSTimeInterval)interval repeat:(BOOL)repeat fireBlock:(YZHTimerFireBlock)fireBlock
{
    return [[[self class] alloc] initWithTimeInterval:interval repeat:repeat fireBlock:fireBlock];
}

-(instancetype)initWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeat:(BOOL)repeat queue:(dispatch_queue_t)queue userInfo:(id)userInfo
{
    return [self _initWithFireTimeAfter:timeAfter interval:interval target:target selector:selector repeat:repeat wallTime:NO queue:queue userInfo:userInfo isToTarget:YES fireBlock:nil];
}

-(instancetype)initWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval repeat:(BOOL)repeat queue:(dispatch_queue_t)queue userInfo:(id)userInfo fireBlock:(YZHTimerFireBlock)fireBlock
{
    return [self _initWithFireTimeAfter:timeAfter interval:interval target:nil selector:NULL repeat:repeat wallTime:NO queue:queue userInfo:userInfo isToTarget:NO fireBlock:fireBlock];
}

-(instancetype)initWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeat:(BOOL)repeat
{
    return [self _initWithFireTimeAfter:timeAfter interval:interval target:target selector:selector repeat:repeat wallTime:NO queue:nil userInfo:nil isToTarget:YES fireBlock:nil];
}

-(instancetype)initWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval repeat:(BOOL)repeat fireBlock:(YZHTimerFireBlock)fireBlock
{
    return [self _initWithFireTimeAfter:timeAfter interval:interval target:nil selector:NULL repeat:repeat wallTime:NO queue:nil userInfo:nil isToTarget:NO fireBlock:fireBlock];
}

-(instancetype)initWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeat:(BOOL)repeat
{
    return [self _initWithFireTimeAfter:interval interval:interval target:target selector:selector repeat:repeat wallTime:NO queue:nil userInfo:nil isToTarget:YES fireBlock:nil];
}

-(instancetype)initWithTimeInterval:(NSTimeInterval)interval repeat:(BOOL)repeat fireBlock:(YZHTimerFireBlock)fireBlock
{
    return [self _initWithFireTimeAfter:interval interval:interval target:nil selector:NULL repeat:repeat wallTime:NO queue:nil userInfo:nil isToTarget:NO fireBlock:fireBlock];
}


-(instancetype)_initWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeat:(BOOL)repeat wallTime:(BOOL)wallTime queue:(dispatch_queue_t)queue userInfo:(id)userInfo isToTarget:(BOOL)isToTarget fireBlock:(YZHTimerFireBlock)fireBlock
{
    self = [super init];
    if (self) {        
        _userInfo = userInfo;
        _timeInterval = interval;
        _repeat = repeat;
        _wallTime = wallTime;
        _valid = YES;
        
        _target = target;
        _selector = selector;
        _isToTarget = isToTarget;
        _fireBlock = fireBlock;
        if (isToTarget) {
            NSAssert(target && selector, @"target or selector must not nil");
        }
        else {
            NSAssert(fireBlock != nil, @"fireBlock must not nil");
        }
        
        dispatch_queue_t q = queue;
        if (!q) {
            q = dispatch_get_main_queue();
        }
        
        _queue = [[YZHQueue alloc] initWithQueue:q];
        _timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, q);
        
        WEAK_SELF(weakSelf);
        dispatch_source_set_event_handler(_timerSource, ^{
            [weakSelf fire];
        });
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, timeAfter * NSEC_PER_SEC);
        if (wallTime) {
            start = dispatch_walltime(NULL, timeAfter * NSEC_PER_SEC);
        }
        dispatch_source_set_timer(_timerSource, start, interval * NSEC_PER_SEC, 0);
        _startTime = USEC_FROM_DATE_SINCE1970_NOW;
        dispatch_resume(_timerSource);
        
        _isSuspend = NO;
    }
    return self;
}

-(void)updateNextStart:(NSTimeInterval)after
{
    @synchronized (self) {
        [_queue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            if (!self->_valid) {
                return;
            }
            dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC);
            if (self->_wallTime) {
                start = dispatch_walltime(NULL, after * NSEC_PER_SEC);
            }
            dispatch_source_set_timer(self->_timerSource, start, self->_timeInterval * NSEC_PER_SEC, 0);
        }];
    }
}

-(void)updateTimeInterval:(NSTimeInterval)interval
{
    @synchronized (self) {
        [_queue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            if (!self->_valid) {
                return;
            }
            dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC);
            if (self->_wallTime) {
                start = dispatch_walltime(NULL, interval * NSEC_PER_SEC);
            }
            dispatch_source_set_timer(self->_timerSource, start, interval * NSEC_PER_SEC, 0);
        }];
    }
}


- (void)invalidate
{
    @synchronized (self) {
        [_queue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            if (self->_valid) {
                self->_endTime = USEC_FROM_DATE_SINCE1970_NOW;
                dispatch_source_cancel(self->_timerSource);
                // 在已经suspend的情况下，如果释放source会导致crash
                [self pri_resumeAction];
                self->_timerSource = NULL;
                self->_target = nil;
                self->_selector = NULL;
                self->_fireBlock = nil;
                
                self->_valid = NO;
                
            }
        }];
        _queue = nil;
    }
}

- (void)fire
{
    @synchronized (self) {
        [_queue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            if (!self->_valid) {
                return;
            }
            
            if (self->_fireBlock) {
                self->_fireBlock(self);
            }
            else {
                if (self->_selector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [self->_target performSelector:self->_selector withObject:self];
#pragma clang diagnostic pop
                }
            }
            
            if (self->_repeat == NO || (self->_isToTarget && self->_target == nil)) {
                [self invalidate];
            }
        }];
    }
}

-(NSTimeInterval)startTime
{
    return _startTime * 1.0/USEC_PER_SEC;
}

-(NSTimeInterval)elapseTime
{
    NSTimeInterval endTime = _endTime;
    if (self.valid) {
        endTime = USEC_FROM_DATE_SINCE1970_NOW;
    }
//    if (_wallTime) {
        return (endTime - _startTime) * 1.0 / USEC_PER_SEC;
//    }
//    return (endTime - _startTime - _suspendTime) * 1.0 / USEC_PER_SEC;
}

- (void)pri_suspendAction
{
    if (_timerSource) {
        if (_isSuspend == NO) {
            dispatch_suspend(_timerSource);
            _isSuspend = YES;
        }
    }
}

- (void)pri_resumeAction
{
    if (_timerSource) {
        if (_isSuspend == YES) {
            dispatch_resume(_timerSource);
            _isSuspend = NO;
        }
    }
}

-(void)suspend
{
    @synchronized (self) {
        [_queue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            [self pri_suspendAction];
        }];
    }
}

-(void)resume
{
    @synchronized (self) {
        [_queue dispatchQueueBlock:^(YZHQueue * _Nonnull queue) {
            [self pri_resumeAction];
        }];
    }
}

-(BOOL)isSuspend
{
    return _isSuspend;
}

-(void)dealloc
{
    @synchronized (self) {
        [_queue dispatchSyncQueueBlock:^(YZHQueue * _Nonnull queue) {
            [self invalidate];
        }];
    }
}

@end
