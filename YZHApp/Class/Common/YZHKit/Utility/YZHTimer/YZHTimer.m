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

-(void)updateNextStart:(NSTimeInterval)after
{
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC);
    if (_wallTime) {
        start = dispatch_walltime(NULL, after * NSEC_PER_SEC);
    }
    dispatch_source_set_timer(_timerSource, start, _timeInterval * NSEC_PER_SEC, 0);
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
        // 在已经suspend的情况下，如果释放source会导致crash
        [self _resumeAction];
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
    dispatch_semaphore_wait(_sem, DISPATCH_TIME_FOREVER);

    if (!_valid) {
        dispatch_semaphore_signal(_sem);
        return;
    }
    // 临时持有各个对象，防止fire和invalidate同时执行的临界情况
    // 防止出现（null selector）的异常情况
    BOOL repeat = _repeat;
    id targetTmp = _target;
    SEL selectorTmp = _selector;
    BOOL isToTarget = _isToTarget;
    YZHTimerFireBlock fireBlockTmp = _fireBlock;
    dispatch_semaphore_signal(_sem);
    
    if (fireBlockTmp) {
        fireBlockTmp(self);
    }
    else {
        if (selectorTmp) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [targetTmp performSelector:selectorTmp withObject:self];
#pragma clang diagnostic pop
        }
    }
    
    if (repeat == NO || (isToTarget && targetTmp == nil)) {
        [self invalidate];
    }
    targetTmp = nil;
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

- (void)_suspendAction
{
    if (_timerSource) {
        if (_isSuspend == NO) {
            dispatch_suspend(_timerSource);
            _isSuspend = YES;
        }
    }
}

- (void)_resumeAction
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
    dispatch_semaphore_wait(_sem, DISPATCH_TIME_FOREVER);
    [self _suspendAction];
    dispatch_semaphore_signal(_sem);
}

-(void)resume
{
    dispatch_semaphore_wait(_sem, DISPATCH_TIME_FOREVER);
    [self _resumeAction];
    dispatch_semaphore_signal(_sem);
}

-(BOOL)isSuspend
{
    return _isSuspend;
}

-(void)dealloc
{
    NSLog(@"timer dealloc");
    [self invalidate];
    [self _registNotification:NO];
}

@end
