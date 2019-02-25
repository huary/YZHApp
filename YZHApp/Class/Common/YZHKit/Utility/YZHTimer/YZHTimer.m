//
//  YZHTimer.m
//  YZHTimerDemo
//
//  Created by yuan on 2018/12/14.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHTimer.h"
#import "YZHKitType.h"

@implementation YZHTimer
{
    __weak id _target;
    SEL _selector;
    BOOL _isToTarget;
    BOOL _wallTime;
    NSTimeInterval _timeAfter;
    YZHTimerFireBlock _fireBlock;
    dispatch_source_t _timerSource;
    dispatch_semaphore_t _sem;
    uint64_t _startTime;
    uint64_t _endTime;
    
    uint64_t _suspendStartTime;
    uint64_t _suspendTime;
    
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
        
        _sem = dispatch_semaphore_create(1);
        dispatch_queue_t q = queue;
        if (!q) {
            q = dispatch_get_main_queue();
        }
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
        
        [self _registNotification:YES];
    }
    return self;
}


-(void)_registNotification:(BOOL)regist
{
//    if (regist) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
//    }
//    else {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
//    }
}

-(void)_didEnterBackground:(NSNotification*)notification
{
    _suspendStartTime = USEC_FROM_DATE_SINCE1970_NOW;
    [self suspend];
}

-(void)_willEnterForeground:(NSNotification*)notification
{
    [self resume];
    _suspendTime += USEC_FROM_DATE_SINCE1970_NOW - _suspendStartTime;
}

-(void)updateTimeInterval:(NSTimeInterval)interval
{
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC);
    if (_wallTime) {
        start = dispatch_walltime(NULL, interval * NSEC_PER_SEC);
    }
    dispatch_source_set_timer(_timerSource, start, interval * NSEC_PER_SEC, 0);
}


- (void)invalidate
{
    dispatch_semaphore_wait(_sem, DISPATCH_TIME_FOREVER);
    if (_valid) {
        _endTime = USEC_FROM_DATE_SINCE1970_NOW;
        dispatch_source_cancel(_timerSource);
        _timerSource = NULL;
        _target = nil;
        _selector = NULL;
        _fireBlock = nil;
        
        _valid = NO;
    }
    dispatch_semaphore_signal(_sem);
}

- (void)fire
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    dispatch_semaphore_wait(_sem, DISPATCH_TIME_FOREVER);

    if (!_valid) {
        dispatch_semaphore_signal(_sem);
        return;
    }
    dispatch_semaphore_signal(_sem);
    
    if (_fireBlock) {
        _fireBlock(self);
    }
    else {
        [_target performSelector:_selector withObject:self];
    }
    if (self.repeat == NO || (_isToTarget && _target == nil)) {
        [self invalidate];
    }
#pragma clang diagnostic pop
}

-(NSTimeInterval)elapseTime
{
    NSTimeInterval endTime = _endTime;
    if (self.valid) {
        endTime = USEC_FROM_DATE_SINCE1970_NOW;
    }
    if (_wallTime) {
        return (endTime - _startTime) * 1.0 / USEC_PER_SEC;
    }
    return (endTime - _startTime - _suspendTime) * 1.0 / USEC_PER_SEC;
}

-(void)suspend
{
    if (_timerSource) {
        dispatch_suspend(_timerSource);
        dispatch_semaphore_wait(_sem, DISPATCH_TIME_FOREVER);
        _isSuspend = YES;
        dispatch_semaphore_signal(_sem);
    }
}

-(void)resume
{
    if (_timerSource) {
        dispatch_resume(_timerSource);
        dispatch_semaphore_wait(_sem, DISPATCH_TIME_FOREVER);
        _isSuspend = NO;
        dispatch_semaphore_signal(_sem);
    }
}

-(BOOL)isSuspend
{
    return _isSuspend;
}

-(void)dealloc
{
//    NSLog(@"timer dealloc");
    [self invalidate];
    [self _registNotification:NO];
}

@end
