//
//  YZHTimer.h
//  YZHTimerDemo
//
//  Created by yuan on 2018/12/14.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YZHTimer;
typedef void(^YZHTimerFireBlock)(YZHTimer *timer);

@interface YZHTimer : NSObject

/* <#注释#> */
@property (nonatomic, strong) id userInfo;

/* <#name#> */
@property (nonatomic, assign, readonly) NSTimeInterval timeInterval;

/* 为可读写，在执行action的时候，可以修改repeat为YES或者NO来进行继续或者停止 */
@property (nonatomic, assign) BOOL repeat;

/* <#name#> */
@property (nonatomic, assign, readonly, getter=isValid) BOOL valid;

//默认在mainQueue
+(instancetype)timerWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeat:(BOOL)repeat queue:(dispatch_queue_t)queue userInfo:(id)userInfo;

+(instancetype)timerWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval repeat:(BOOL)repeat queue:(dispatch_queue_t)queue userInfo:(id)userInfo fireBlock:(YZHTimerFireBlock)fireBlock;

+(instancetype)timerWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeat:(BOOL)repeat;

+(instancetype)timerWithTimeInterval:(NSTimeInterval)interval repeat:(BOOL)repeat fireBlock:(YZHTimerFireBlock)fireBlock;


-(instancetype)initWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeat:(BOOL)repeat queue:(dispatch_queue_t)queue userInfo:(id)userInfo;

-(instancetype)initWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval repeat:(BOOL)repeat queue:(dispatch_queue_t)queue userInfo:(id)userInfo fireBlock:(YZHTimerFireBlock)fireBlock;

-(instancetype)initWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeat:(BOOL)repeat;

-(instancetype)initWithFireTimeAfter:(NSTimeInterval)timeAfter interval:(NSTimeInterval)interval repeat:(BOOL)repeat fireBlock:(YZHTimerFireBlock)fireBlock;

-(instancetype)initWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector repeat:(BOOL)repeat;

-(instancetype)initWithTimeInterval:(NSTimeInterval)interval repeat:(BOOL)repeat fireBlock:(YZHTimerFireBlock)fireBlock;

//更新运行间隔，将在interval后进行第一次的fire
-(void)updateTimeInterval:(NSTimeInterval)interval;

-(void)invalidate;

-(void)fire;

-(void)suspend;

-(void)resume;

-(BOOL)isSuspend;

-(NSTimeInterval)elapseTime;

@end
