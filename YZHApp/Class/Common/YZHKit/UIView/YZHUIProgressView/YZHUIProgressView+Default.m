//
//  YZHUIProgressView+Default.m
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2017/6/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIProgressView+Default.h"
#import "YZHKitType.h"
#import "UIImage+YZHAdd.h"

static const CGFloat dismissTime_s = 1.0f;

@implementation YZHUIProgressView (Default)
#pragma mark - 操作成功简短提示

/**
 操作成功提示

 @param successText 提示内容
 */
-(void)progressWithSuccessText:(NSString*)successText
{
    [self progressWithSuccessText:successText showTimeInterval:dismissTime_s];
}

-(void)progressWithFailText:(NSString*)failText
{
    [self progressWithFailText:failText showTimeInterval:dismissTime_s];
}


-(void)progressWithSuccessText:(NSString*)successText showTimeInterval:(NSTimeInterval)timeInterval
{
    UIImage *successImage = [[UIImage imageNamed:@"success"] tintColor:WHITE_COLOR];
    [self progressShowInView:nil titleText:successText animationImages:@[successImage] showTimeInterval:timeInterval];
}

-(void)progressWithFailText:(NSString*)failText showTimeInterval:(NSTimeInterval)timeInterval
{
    UIImage *failImage = [[UIImage imageNamed:@"error"] tintColor:WHITE_COLOR];
    [self progressShowInView:nil titleText:failText animationImages:@[failImage] showTimeInterval:timeInterval];
}

-(void)updateWithSuccessText:(NSString*)successText
{
    [self updateWithSuccessText:successText showTimeInterval:dismissTime_s];
}

-(void)updateWithFailText:(NSString*)failText
{
    [self updateWithFailText:failText showTimeInterval:dismissTime_s];
}

-(void)updateWithSuccessText:(NSString*)successText showTimeInterval:(NSTimeInterval)timeInterval
{
    UIImage *successImage = [[UIImage imageNamed:@"success"] tintColor:WHITE_COLOR];
    [self updateTitleText:successText animationImages:@[successImage] showTimeInterval:timeInterval];
}

-(void)updateWithFailText:(NSString*)failText showTimeInterval:(NSTimeInterval)timeInterval
{
    UIImage *failImage = [[UIImage imageNamed:@"error"] tintColor:WHITE_COLOR];
    [self updateTitleText:failText animationImages:@[failImage] showTimeInterval:timeInterval];
}

-(void)updateWithInfoText:(NSString*)infoText
{
    UIImage *InfoImage = [[UIImage imageNamed:@"info"] tintColor:WHITE_COLOR];
    [self updateTitleText:infoText animationImages:@[InfoImage] showTimeInterval:dismissTime_s];
}

-(void)updateWithInfoText:(NSString*)infoText showTimeInterval:(NSTimeInterval)timeInterval
{
    UIImage *InfoImage = [[UIImage imageNamed:@"info"] tintColor:WHITE_COLOR];
    [self updateTitleText:infoText animationImages:@[InfoImage] showTimeInterval:timeInterval];
}

@end

static const NSTimeInterval toastViewNormalShowTimeInterval = 0;
static const NSTimeInterval toastViewShowTimeInterval_s = 1.5f;
static const NSTimeInterval toastViewUpdateTimeInterval_s = 1.0f;
static YZHUIProgressView *_toastView_s = nil;

@implementation YZHToast : NSObject

+ (YZHUIProgressView *)toastView
{
    if (_toastView_s == nil) {
        _toastView_s = [[YZHUIProgressView alloc] init];
        _toastView_s.canClose = NO;        
        _toastView_s.backgroundColor = RGBA(0x86, 0x7f, 0x6f, 0.7);
    }
    return _toastView_s;
}

+ (void)toastWithText:(NSString *)text
{
    [self toastWithText:text inView:nil];
}

+ (void)toastWithSuccessText:(NSString *)successText
{
    [self toastWithSuccessText:successText inView:nil];
}

+ (void)toastWithInfoText:(NSString *)infoText
{
    [self toastWithInfoText:infoText inView:nil];
}

+ (void)toastWithFailText:(NSString *)failText
{
    [self toastWithFailText:failText inView:nil];
}

+ (void)updateWithSuccessText:(NSString *)successText
{
    [self updateWithSuccessText:successText timeInterval:toastViewUpdateTimeInterval_s];
}

+ (void)updateWithInfoText:(NSString *)infoText
{
    [self updateWithInfoText:infoText timeInterval:toastViewUpdateTimeInterval_s];
}

+ (void)updateWithFailText:(NSString *)failText
{
    [self updateWithFailText:failText timeInterval:toastViewUpdateTimeInterval_s];
}

+ (void)toastWithText:(NSString *)text inView:(UIView *)inView
{
    [self toastWithText:text inView:inView timeInterval:toastViewNormalShowTimeInterval];
}

+ (void)toastWithSuccessText:(NSString *)successText inView:(UIView *)inView
{
    [self toastWithSuccessText:successText inView:inView timeInterval:toastViewShowTimeInterval_s];
}

+ (void)toastWithInfoText:(NSString *)infoText inView:(UIView *)inView
{
    [self toastWithInfoText:infoText inView:inView timeInterval:toastViewShowTimeInterval_s];
}

+ (void)toastWithFailText:(NSString *)failText inView:(UIView *)inView
{
    [self toastWithFailText:failText inView:inView timeInterval:toastViewShowTimeInterval_s];
}

+ (void)toastWithText:(NSString *)text inView:(UIView *)inView timeInterval:(NSTimeInterval)timeInterval
{
    [[self toastView] progressShowInView:inView titleText:text showTimeInterval:timeInterval];
}

+ (void)toastWithSuccessText:(NSString *)successText inView:(UIView *)inView timeInterval:(NSTimeInterval)timeInterval
{
    UIImage *successImage = [[UIImage imageNamed:@"success"] tintColor:WHITE_COLOR];
    [[self toastView] progressShowInView:inView titleText:successText animationImages:@[successImage] showTimeInterval:timeInterval];
}

+ (void)toastWithInfoText:(NSString *)infoText inView:(UIView *)inView timeInterval:(NSTimeInterval)timeInterval
{
    UIImage *infoImage = [[UIImage imageNamed:@"info"] tintColor:WHITE_COLOR];
    [[self toastView] progressShowInView:inView titleText:infoText animationImages:@[infoImage] showTimeInterval:timeInterval];
}

+ (void)toastWithFailText:(NSString *)failText inView:(UIView *)inView timeInterval:(NSTimeInterval)timeInterval
{
    UIImage *failImage = [[UIImage imageNamed:@"error"] tintColor:WHITE_COLOR];
    [[self toastView] progressShowInView:inView titleText:failText animationImages:@[failImage] showTimeInterval:timeInterval];
}

+ (void)updateWithSuccessText:(NSString *)successText timeInterval:(NSTimeInterval)timeInterval
{
    [[self toastView] updateWithSuccessText:successText showTimeInterval:timeInterval];
}

+ (void)updateWithFailText:(NSString *)failText timeInterval:(NSTimeInterval)timeInterval
{
    [[self toastView] updateWithFailText:failText showTimeInterval:timeInterval];
}

+ (void)updateWithInfoText:(NSString *)infoText timeInterval:(NSTimeInterval)timeInterval
{
    [[self toastView] updateWithInfoText:infoText showTimeInterval:timeInterval];
}

+ (void)dismiss
{
    [[self toastView] dismiss];
}

@end
