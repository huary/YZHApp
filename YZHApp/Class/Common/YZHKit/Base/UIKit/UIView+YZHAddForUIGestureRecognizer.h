//
//  UIView+YZHAddForUIGestureRecognizer.h
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TIME_INTERVAL_INVALID           (-2)
#define TIME_INTERVAL_LAST_OF_TIME      (0)

typedef void(^YZHGestureRecognizerBlock)(UIGestureRecognizer *gesture);
typedef BOOL(^YZHGestureRecognizerShouldBeginBlock)(UIGestureRecognizer *gesture);


UIKIT_EXTERN NSString * const YZHIntervalActionLastTimeIntervalKey;
UIKIT_EXTERN NSString * const YZHIntervalActionElapsedTimeIntervalKey;

/*
 *参数值：
 *elapesedTime为从开始到这次进过了多长的时间
 *lastTimeInterval上一次的间隔时间,如果为0的话表示开始
 *返回值：下一次调用的时间间隔，如果returnval<=0.01且>0的时候则始终以0.01的时间间隔来调用,如果<0的话，则不再调用,如果==0的话，调用最后一次。
 */
typedef NSTimeInterval(^YZHIntervalGestureActionTimingFunctionBlock)(NSTimeInterval elapsedTime,NSTimeInterval lastTimeInterval);

typedef NS_ENUM(NSInteger, YZHIntervalGestureRecognizerActionTimingFunction)
{
    //系统默认的响应时间
    YZHIntervalGestureRecognizerActionTimingFunctionDefault       = 0,
    //平均minimumPressDuration的响应时间间隔
    YZHIntervalGestureRecognizerActionTimingFunctionLinear        = 1,
    //响应时间间隔原来越短，小于一定的值时为Linear
    YZHIntervalGestureRecognizerActionTimingFunctionEaseIn        = 2,
    //响应时间间隔原来越长
    YZHIntervalGestureRecognizerActionTimingFunctionEaseOut       = 3,
    //响应时间间隔由自定定义
    YZHIntervalGestureRecognizerActionTimingFunctionCustom        = 4,
};

//持续性手势选项
typedef NS_ENUM(NSInteger, YZHIntervalGestureRecognizerActionOptions)
{
    //系统默认的
    YZHIntervalGestureRecognizerActionOptionsDefault             = 0,
    //只响应一次，响应时间为开始识别（begin）时间后的minimumPressDuration响应一次
    YZHIntervalGestureRecognizerActionOptionsOnlyOnce            = 1,
    //只在结束的时候响应一次
    YZHIntervalGestureRecognizerActionOptionsOnlyEnd             = 2,
    //在开始和结束的时候各响应一次
    YZHIntervalGestureRecognizerActionOptionsBeginEnd            = 3,
    //在开始、改变、结束的时候个响应一次
    YZHIntervalGestureRecognizerActionOptionsBeginChangeEnd      = 4,
    //在开始、多次改变、结束的时候响应
    YZHIntervalGestureRecognizerActionOptionsBeginChangesEnd     = 5,
    //自己定义
    YZHIntervalGestureRecognizerActionOptionsCustom              = 6,
};





/****************************************************
 *UIGestureRecognizer (GestureRecognizerInfo)
 ****************************************************/
@interface UIGestureRecognizer (GestureRecognizerInfo)

@property (nonatomic, strong) NSDictionary *hz_userInfo;

@end




/****************************************************
 *YZHIntervalGestureRecognizerActionOptionsInfo
 ****************************************************/
@interface YZHIntervalGestureRecognizerActionOptionsInfo : NSObject

//第一次调用的时间间隔（距离开始响应的时间）
//@property (nonatomic, assign) NSTimeInterval firstActionTimeInterval;

// 最小调用的时间间隔，默认为0.01
@property (nonatomic, assign) NSTimeInterval minActionTimeInterval;

// 最大调用的时间间隔，默认为30s
@property (nonatomic, assign) NSTimeInterval maxActionTimeInterval;

//EaseIn的changeRatio，默认为0.8
@property (nonatomic, assign) CGFloat easeInChangeRatio;

//EaseOut的changeRatio，默认为1.25
@property (nonatomic, assign) CGFloat easeOutChangeRatio;

//调用动作的选项
@property (nonatomic, assign) YZHIntervalGestureRecognizerActionOptions actionOptions;
//调用动作的时间选项，时间间隔按算法设计的来实现
@property (nonatomic, assign) YZHIntervalGestureRecognizerActionTimingFunction timingFunction;
//调用动作的时间选项，采用block的方式，时间间隔按接入者自己规定
@property (nonatomic, copy) YZHIntervalGestureActionTimingFunctionBlock timingFunctionBlock;

@end


/****************************************************
 *UIView (YZHAddForUIGestureRecognizer)
 ****************************************************/
@interface UIView (YZHAddForUIGestureRecognizer)

-(UITapGestureRecognizer *)hz_addTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock;
-(UITapGestureRecognizer *)hz_addDoubleTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock;
-(UIPanGestureRecognizer *)hz_addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock;
//这里长按只会调用一次的YZHIntervalGestureRecognizerActionOptionsOnlyOnce，如果没有特别指点系统的那种options的话，长按只会调用一次。
-(UILongPressGestureRecognizer *)hz_addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock;
//这里长按只会调用一次的YZHIntervalGestureRecognizerActionOptionsOnlyEnd，如果没有特别指点系统的那种options的话，长按只会调用一次。
-(UILongPressGestureRecognizer *)hz_addLongPressGestureRecognizerBlockOnlyEnd:(YZHGestureRecognizerBlock)gestureBlock;

-(UITapGestureRecognizer *)hz_addTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock;
-(UITapGestureRecognizer *)hz_addDoubleTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock;
-(UIPanGestureRecognizer *)hz_addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock;
-(UILongPressGestureRecognizer *)hz_addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock;

-(UIPanGestureRecognizer *)hz_addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo*)optionsInfo;
-(UILongPressGestureRecognizer *)hz_addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo*)optionsInfo;

-(UIPanGestureRecognizer *)hz_addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo*)optionsInfo;
-(UILongPressGestureRecognizer *)hz_addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo*)optionsInfo;


@end
