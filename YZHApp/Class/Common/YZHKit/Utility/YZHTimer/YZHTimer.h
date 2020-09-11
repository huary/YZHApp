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

/* <#name#> */
@property (nonatomic, assign, readonly) BOOL repeat;

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

//更新下一次运行间隔，将在after后进行第一次的fire，后面继续按timeInterval
-(void)updateNextStart:(NSTimeInterval)after;

//更新运行间隔，将在interval后进行第一次的fire
-(void)updateTimeInterval:(NSTimeInterval)interval;

-(void)invalidate;

-(void)fire;

/*
 *这里的suspend、resume、isSuspend放在同一个线程上来操作
 *
 */
-(void)suspend;

-(void)resume;

-(BOOL)isSuspend;

-(NSTimeInterval)startTime;

-(NSTimeInterval)elapseTime;

@end
