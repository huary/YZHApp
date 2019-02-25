//
//  YZHUIProgressView+Default.m
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2017/6/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIProgressView+Default.h"

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
    UIImage *successImage = [UIImage imageNamed:@"success"];
    [self progressShowInView:nil titleText:successText animationImages:@[successImage] showTimeInterval:timeInterval];
}

-(void)progressWithFailText:(NSString*)failText showTimeInterval:(NSTimeInterval)timeInterval
{
    UIImage *failImage = [UIImage imageNamed:@"fail"];
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
    UIImage *successImage = [UIImage imageNamed:@"success"];
    [self updateTitleText:successText animationImages:@[successImage] showTimeInterval:timeInterval];
}

-(void)updateWithFailText:(NSString*)failText showTimeInterval:(NSTimeInterval)timeInterval
{
    UIImage *failImage = [UIImage imageNamed:@"fail"];
    [self updateTitleText:failText animationImages:@[failImage] showTimeInterval:timeInterval];
}

@end
