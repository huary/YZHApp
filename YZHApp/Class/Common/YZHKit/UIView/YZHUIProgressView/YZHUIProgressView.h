//
//  YZHUIProgressView.h
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2017/6/9.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUIAlertView.h"

typedef NS_ENUM(NSInteger, YZHUIProgressViewStyle)
{
//    YZHUIProgressViewStyleNULL          = -1,
    YZHUIProgressViewStyleIndicator     = 0,
};

@class YZHUIProgressView;
typedef void(^YZHUIProgressTimeoutBlock)(YZHUIProgressView *progressView);
typedef void(^YZHUIProgressDismissCompletionBlock)(YZHUIProgressView *progressView,NSInteger dismissTag, BOOL finished);

@interface YZHUIProgressView : UIView

@property (nonatomic, strong, readonly) YZHUIAlertView *alertView;
@property (nonatomic, strong, readonly) UIImageView *animationView;
@property (nonatomic, strong, readonly) UILabel *titleView;

//在completionBlock回调回来的
@property (nonatomic, assign) NSInteger dismissTag;

/*
 *指定为weak，是怕出现循环应用的问题，可以在dimss时界面循环引用，但是如果没有调用dismiss时
 *或者调用removeFromSupperView(已在removefromsupperview上做解除循环引用)等其他的方法时没法解除循环应用，
 *为了保险起见使用weak(这里支持使用strong，不会出现循环引用的问题)
 */
@property (nonatomic, strong) UIView *customView;

//在设置这些属性（contentColor、progressViewStyle、showTimeInterval）的都需要在主线程
@property (nonatomic, copy) UIColor *contentColor;

/** customContentSize 自定义的大小 */
@property (nonatomic, assign) CGSize customContentSize;

/** 边框,默认是UIEdgeInsetsMake(15, 15, 15, 15) */
@property (nonatomic, assign) UIEdgeInsets contentInsets;

/** midSpaceWithTopBottomInsetsRatio,中间的距离,默认为0.4
 * 下面将midSpaceWithTopBottomInsetsRatio简称为midRatio，可以将midRatio理解为上（top）下（bottom）
 * 同时在contentInsets的top、bottom扩展为R，那么上部为top*(1+R),下部为bottom*(1+R)，则中间重叠为（top+Bottom）*R
 * (top+Bottom)*R/(top+Bottom) = R = midRatio,所以midRatio理解上下同时扩展比例R。
 * 总共的空白区域为2top + 2bottom，
 * 中间空白区域为 (1-midSpaceWithTopBottomInsetsRatio) *（top+bottom）,值越大的话相距越近，上下越高，
 * 上部的高度为 top*(1 + midRatio) = X;
 * 中部的高度为 （top+bottom）* （1 - midRatio）= Y;
 * 下部的的高度为 bottom * (1 + midRatio) = Z;
 * 通过已知的（UI设计图）X,Y,Z高度可以求得如下：
 * top = (X+Y+Z)*X/(2 * (X+Z))
 * bottom = (X+Y+Z)*Z/(2 * (X+Z))
 * midRatio = (X-Y+Z)/(X+Y+Z)
 * 根据默认的contentInsets=UIEdgeInsetsMake(15, 15, 15, 15),可以求知
 * 上部 = 21,
 * 下部 = 21,
 * 中部 = 18,
 */
@property (nonatomic, assign) CGFloat midSpaceWithTopBottomInsetsRatio;

/** 是否允许关闭,default is YES */
@property (nonatomic, assign) BOOL canClose;

@property (nonatomic, assign) YZHUIProgressViewStyle progressViewStyle;

@property (nonatomic, assign) NSTimeInterval showTimeInterval;

//此timeoutBlock为showTimeInterval结束时调用，并且不会调用dismiss。只会调用一次，在调用时已经置空，否则有可能出现死循环
@property (nonatomic, copy) YZHUIProgressTimeoutBlock timeoutBlock;
//此completionBlock为在dismiss后回调
@property (nonatomic, copy) YZHUIProgressDismissCompletionBlock completionBlock;

@property (nonatomic, assign, readonly) BOOL isShowing;

@property (nonatomic, assign) BOOL outSideUserInteractionEnabled;

//提供了一个share的全局对象，不是单例
+(instancetype)shareProgressView;

-(void)progressShowTitleText:(NSString*)titleText;

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText;

-(void)progressShowTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)progressShowTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages;

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)updateTitleText:(NSString*)titleText;

//原来的计时作废,从update后开始计时，下同
-(void)updateTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)updateTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval  timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages;

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage*>*)animationImages;

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval;

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock;

-(void)dismiss;

@end
