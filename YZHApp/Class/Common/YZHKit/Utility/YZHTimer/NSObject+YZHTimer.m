//
//  NSObject+YZHTimer.m
//  YZHTimerDemo
//
//  Created by yuan on 2018/12/15.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "NSObject+YZHTimer.h"
#import "YZHKitType.h"
#import <objc/runtime.h>

@implementation NSObject (YZHTimer)

-(void)setHz_actionTimerList:(NSMutableArray<YZHTimer *> *)hz_actionTimerList
{
    objc_setAssociatedObject(self, @selector(hz_actionTimerList), hz_actionTimerList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray<YZHTimer*>*)hz_actionTimerList
{
    NSMutableArray<YZHTimer*> *list = objc_getAssociatedObject(self, _cmd);
    if (list == nil) {
        list = [NSMutableArray array];
        self.hz_actionTimerList = list;
    }
    return list;
}

-(void)setHz_actionTimer:(YZHTimer *)hz_actionTimer
{
    objc_setAssociatedObject(self, @selector(hz_actionTimer), hz_actionTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(YZHTimer*)hz_actionTimer
{
    return objc_getAssociatedObject(self, _cmd);
}

//只调用一次的
-(void)hz_startTimerAfter:(NSTimeInterval)after actionBlock:(YZHObjectTimerActionBlock)actionBlock
{
    WEAK_SELF(weakSelf);
    self.hz_actionTimer = [YZHTimer timerWithTimeInterval:after repeat:NO fireBlock:^(YZHTimer *timer) {
        if (actionBlock) {
            actionBlock(weakSelf, timer);
        }
    }];
}

//这个是循环的
-(void)hz_startTimerInterval:(NSTimeInterval)interval actionBlock:(YZHObjectTimerActionBlock)actionBlock
{
    WEAK_SELF(weakSelf);
    self.hz_actionTimer = [YZHTimer timerWithTimeInterval:interval repeat:YES fireBlock:^(YZHTimer *timer) {
        if (actionBlock) {
            actionBlock(weakSelf, timer);
        }
    }];
}

//取消timer
-(void)hz_cancelTimer
{
    [self.hz_actionTimer invalidate];
    self.hz_actionTimer = nil;
}

//只调用一次的
-(YZHTimer*)hz_addTimerAfter:(NSTimeInterval)after actionBlock:(YZHObjectTimerActionBlock)actionBlock
{
    WEAK_SELF(weakSelf);
    YZHTimer *actionTimer = [YZHTimer timerWithTimeInterval:after repeat:NO fireBlock:^(YZHTimer *timer) {
        if (actionBlock) {
            actionBlock(weakSelf, timer);
        }
    }];
    if (actionTimer) {
        [self.hz_actionTimerList addObject:actionTimer];
    }
    return actionTimer;
}

//这个是循环的
-(YZHTimer*)hz_addTimerInterval:(NSTimeInterval)interval actionBlock:(YZHObjectTimerActionBlock)actionBlock
{
    WEAK_SELF(weakSelf);
    YZHTimer *actionTimer = [YZHTimer timerWithTimeInterval:interval repeat:YES fireBlock:^(YZHTimer *timer) {
        if (actionBlock) {
            actionBlock(weakSelf, timer);
        }
    }];
    if (actionTimer) {
        [self.hz_actionTimerList addObject:actionTimer];
    }
    return actionTimer;
}

//取消timer,调用了上面的必须要调用cancel
-(void)hz_cancelTimer:(YZHTimer*)timer
{
    if (timer) {
        [timer invalidate];
        [self.hz_actionTimerList removeObject:timer];
    }
}

@end
