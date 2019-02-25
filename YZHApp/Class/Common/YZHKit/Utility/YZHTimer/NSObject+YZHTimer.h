//
//  NSObject+YZHTimer.h
//  YZHTimerDemo
//
//  Created by yuan on 2018/12/15.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHTimer.h"


typedef void(^YZHObjectTimerActionBlock)(id object, YZHTimer *timer);

@interface NSObject (YZHTimer)

//只调用一次的
-(void)startTimerAfter:(NSTimeInterval)after actionBlock:(YZHObjectTimerActionBlock)actionBlock;

//这个是循环的
-(void)startTimerInterval:(NSTimeInterval)interval actionBlock:(YZHObjectTimerActionBlock)actionBlock;

//取消timer,调用了上面的必须要调用cancel
-(void)cancelTimer;

//只调用一次的
-(YZHTimer*)addTimerAfter:(NSTimeInterval)after actionBlock:(YZHObjectTimerActionBlock)actionBlock;

//这个是循环的
-(YZHTimer*)addTimerInterval:(NSTimeInterval)interval actionBlock:(YZHObjectTimerActionBlock)actionBlock;

//取消timer,调用了上面的必须要调用cancel
-(void)cancelTimer:(YZHTimer*)timer;

@end
