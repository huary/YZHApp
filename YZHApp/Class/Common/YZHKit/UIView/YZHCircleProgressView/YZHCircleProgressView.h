//
//  YZHCircleProgressView.h
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UICircleProgressViewType)
{
    UICircleProgressViewTypeDefaultOnce           = 0,
    UICircleProgressViewTypeInfinitePartRadian    = 1,
    UICircleProgressViewTypeInfiniteAllRadian     = 2,
};

@interface YZHCircleProgressView : UIView

@property (nonatomic, strong) UILabel *titleLabel;

//进度圈的border，默认为0；
@property (nonatomic, assign) CGFloat progressBorderWidth;
//进度条的线宽度，默认值为5，
@property (nonatomic, assign) CGFloat progressLineWidth;
//进度条的内侧半径，默认值为YZHCircleProgressView的width/2-progressLineWidth;
@property (nonatomic, assign) CGFloat progressInsideRadius;
//轨道的线宽度，默认值为progressLineWidth，
@property (nonatomic, assign) CGFloat progressTrackLineWidth;
//轨道的内侧半径，默认值为progressInsideRadius
@property (nonatomic, assign) CGFloat progressTrackInsideRadius;

@property (nonatomic, copy) UIColor *progressColor;
@property (nonatomic, copy) UIColor *progressTrackColor;
@property (nonatomic, copy) UIColor *progressBorderColor;

//默认为CircleProgressViewTypeDefaultOnce
@property (nonatomic, assign) UICircleProgressViewType circleType;

//在circleType为CircleProgressViewTypeDefaultOnce时，progress就是进度数
//在circleType为CircleProgressViewTypeInfinitePartRadian时progress为无限循环时固定不变的progressLay的弧度
//在circleType为CircleProgressViewTypeInfiniteAllRadian时progress就是一次转换的百分比
-(void)setProgress:(CGFloat)progress animated:(BOOL)animated;

-(void)stopAnimate;

@end
