//
//  YZHUIProgressView+Default.h
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2017/6/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIProgressView.h"

@interface YZHUIProgressView (Default)

//默认1.0秒后dimiss
-(void)progressWithSuccessText:(NSString*)successText;
-(void)progressWithFailText:(NSString*)failText;

-(void)progressWithSuccessText:(NSString*)successText showTimeInterval:(NSTimeInterval)timeInterval;
-(void)progressWithFailText:(NSString*)failText showTimeInterval:(NSTimeInterval)timeInterval;

-(void)updateWithSuccessText:(NSString*)successText;
-(void)updateWithFailText:(NSString*)failText;

-(void)updateWithSuccessText:(NSString*)successText showTimeInterval:(NSTimeInterval)timeInterval;
-(void)updateWithFailText:(NSString*)failText showTimeInterval:(NSTimeInterval)timeInterval;

-(void)updateWithInfoText:(NSString*)infoText;
-(void)updateWithInfoText:(NSString*)infoText showTimeInterval:(NSTimeInterval)timeInterval;


@end


@interface YZHToast : NSObject

+ (void)toastWithText:(NSString *)text;

+ (void)toastWithSuccessText:(NSString *)successText;

+ (void)toastWithInfoText:(NSString *)infoText;

+ (void)toastWithFailText:(NSString *)failText;

+ (void)updateWithSuccessText:(NSString *)successText;

+ (void)updateWithInfoText:(NSString *)infoText;

+ (void)updateWithFailText:(NSString *)failText;

+ (void)toastWithText:(NSString *)text inView:(UIView *)inView;

+ (void)toastWithSuccessText:(NSString *)successText inView:(UIView *)inView;

+ (void)toastWithInfoText:(NSString *)infoText inView:(UIView *)inView;

+ (void)toastWithFailText:(NSString *)failText inView:(UIView *)inView;

+ (void)toastWithText:(NSString *)text inView:(UIView *)inView timeInterval:(NSTimeInterval)timeInterval;

+ (void)toastWithSuccessText:(NSString *)successText inView:(UIView *)inView timeInterval:(NSTimeInterval)timeInterval;

+ (void)toastWithInfoText:(NSString *)infoText inView:(UIView *)inView timeInterval:(NSTimeInterval)timeInterval;

+ (void)toastWithFailText:(NSString *)failText inView:(UIView *)inView timeInterval:(NSTimeInterval)timeInterval;

+ (void)updateWithSuccessText:(NSString *)successText timeInterval:(NSTimeInterval)timeInterval;

+ (void)updateWithFailText:(NSString *)failText timeInterval:(NSTimeInterval)timeInterval;

+ (void)updateWithInfoText:(NSString *)infoText timeInterval:(NSTimeInterval)timeInterval;


+ (void)dismiss;

@end
