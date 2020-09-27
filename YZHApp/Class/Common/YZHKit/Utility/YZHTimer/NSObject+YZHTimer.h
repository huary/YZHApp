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
-(void)hz_startTimerAfter:(NSTimeInterval)after
              actionBlock:(YZHObjectTimerActionBlock)actionBlock;

//这个是循环的
-(void)hz_startTimerInterval:(NSTimeInterval)interval
                 actionBlock:(YZHObjectTimerActionBlock)actionBlock;

//取消timer,调用了上面的必须要调用cancel
-(void)hz_cancelTimer;

//只调用一次的
-(YZHTimer*)hz_addTimerAfter:(NSTimeInterval)after
                 actionBlock:(YZHObjectTimerActionBlock)actionBlock;

//这个是循环的
-(YZHTimer*)hz_addTimerInterval:(NSTimeInterval)interval
                    actionBlock:(YZHObjectTimerActionBlock)actionBlock;

//取消timer,调用了上面的必须要调用cancel
-(void)hz_cancelTimer:(YZHTimer*)timer;

@end
