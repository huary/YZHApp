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

-(void)setActionTimerList:(NSMutableArray<YZHTimer *> *)actionTimerList
{
    objc_setAssociatedObject(self, @selector(actionTimerList), actionTimerList, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray<YZHTimer*>*)actionTimerList
{
    NSMutableArray<YZHTimer*> *list = objc_getAssociatedObject(self, _cmd);
    if (list == nil) {
        list = [NSMutableArray array];
        self.actionTimerList = list;
    }
    return list;
}

-(void)setActionTimer:(YZHTimer *)actionTimer
{
    objc_setAssociatedObject(self, @selector(actionTimer), actionTimer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(YZHTimer*)actionTimer
{
    return objc_getAssociatedObject(self, _cmd);
}

//只调用一次的
-(void)startTimerAfter:(NSTimeInterval)after actionBlock:(YZHObjectTimerActionBlock)actionBlock
{
    WEAK_SELF(weakSelf);
    self.actionTimer = [YZHTimer timerWithTimeInterval:after repeat:NO fireBlock:^(YZHTimer *timer) {
        if (actionBlock) {
            actionBlock(weakSelf, timer);
        }
    }];
}

//这个是循环的
-(void)startTimerInterval:(NSTimeInterval)interval actionBlock:(YZHObjectTimerActionBlock)actionBlock
{
    WEAK_SELF(weakSelf);
    self.actionTimer = [YZHTimer timerWithTimeInterval:interval repeat:YES fireBlock:^(YZHTimer *timer) {
        if (actionBlock) {
            actionBlock(weakSelf, timer);
        }
    }];
}

//取消timer
-(void)cancelTimer
{
    [self.actionTimer invalidate];
    self.actionTimer = nil;
}

//只调用一次的
-(YZHTimer*)addTimerAfter:(NSTimeInterval)after actionBlock:(YZHObjectTimerActionBlock)actionBlock
{
    WEAK_SELF(weakSelf);
    YZHTimer *actionTimer = [YZHTimer timerWithTimeInterval:after repeat:NO fireBlock:^(YZHTimer *timer) {
        if (actionBlock) {
            actionBlock(weakSelf, timer);
        }
    }];
    if (actionTimer) {
        [self.actionTimerList addObject:actionTimer];
    }
    return actionTimer;
}

//这个是循环的
-(YZHTimer*)addTimerInterval:(NSTimeInterval)interval actionBlock:(YZHObjectTimerActionBlock)actionBlock
{
    WEAK_SELF(weakSelf);
    YZHTimer *actionTimer = [YZHTimer timerWithTimeInterval:interval repeat:YES fireBlock:^(YZHTimer *timer) {
        if (actionBlock) {
            actionBlock(weakSelf, timer);
        }
    }];
    if (actionTimer) {
        [self.actionTimerList addObject:actionTimer];
    }
    return actionTimer;
}

//取消timer,调用了上面的必须要调用cancel
-(void)cancelTimer:(YZHTimer*)timer
{
    if (timer) {
        [timer invalidate];
        [self.actionTimerList removeObject:timer];
    }
}

@end
