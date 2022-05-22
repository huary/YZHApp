//
//  YZHButton.h
//  YZHButton
//
//  Created by yuan on 2017/7/14.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSButtonContentAlignment)
{
    NSButtonContentAlignmentCenter  = 0,
    //如下Left,Right和Up，Down进行或
    NSButtonContentAlignmentLeft    = (1 << 0),
    NSButtonContentAlignmentRight   = (1 << 1),
    NSButtonContentAlignmentUp      = (1 << 2),
    NSButtonContentAlignmentDown    = (1 << 3),
};

//指的是imageview和title的排版方式
typedef NS_ENUM(NSInteger, NSButtonLayoutStyle)
{
    NSButtonLayoutStyleMask           = 0X3,
    NSButtonLayoutStyleLR             = 0,
    NSButtonLayoutStyleRL             = 1,
    NSButtonLayoutStyleUD             = 2,
    NSButtonLayoutStyleDU             = 3,
    //自定义image和title的space，有6个bit位,1111,1100
    NSButtonLayoutStyleSpaceMask      = 0XFC,
    //自定义image和title的space，以及上（左）下（右）等距
    NSButtonLayoutStyleEQSpace        = (1 << 2),
    //自定义image和tile的space，
    NSButtonLayoutStyleCustomSpace    = (1 << 3),
    
    NSButtonLayoutStyleCustomMask     = 0XF00,
    NSButtonLayoutStyleCustomRatio    = 0X100,
    NSButtonLayoutStyleCustomInset    = 0X200,
};

@class YZHButton;

typedef BOOL(^YZHButtonBeginTrackingBlock)(YZHButton *button, UITouch *touch, UIEvent *event);
typedef BOOL(^YZHButtonContinueTrackingBlock)(YZHButton *button, UITouch *touch, UIEvent *event);
typedef void(^YZHButtonEndTrackingBlock)(YZHButton *button, UITouch *touch, UIEvent *event);
typedef void(^YZHButtonCancelTrackingBlock)(YZHButton *button, UIEvent *event);

@interface YZHButton : UIButton

@property (nonatomic, assign) NSButtonLayoutStyle layoutStyle;
@property (nonatomic, assign) CGFloat imageTitleSpace;

//UIButtonImageTitleLayoutStyleCustom时才有效
@property (nonatomic, assign) UIEdgeInsets imageEdgeInsetsRatio;
@property (nonatomic, assign) UIEdgeInsets titleEdgeInsetsRatio;

@property (nonatomic, assign) NSButtonContentAlignment contentAlignment;
//对图片进行圆角处理
@property (nonatomic, assign) BOOL circleCornerImageView;

/* 默认为YES */
@property (nonatomic, assign) BOOL layoutChangeBounds;

//tracking event block
@property (nonatomic, copy) YZHButtonBeginTrackingBlock beginTrackingBlock;
@property (nonatomic, copy) YZHButtonContinueTrackingBlock continueTrackingBlock;
@property (nonatomic, copy) YZHButtonEndTrackingBlock endTrackingBlock;
@property (nonatomic, copy) YZHButtonCancelTrackingBlock cancelTrackingBlock;

-(void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
-(void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)state;
-(void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)state;
//-(void)addControlEvent:(UIControlEvents)controlEvents actionBlock:(YZHButtonActionBlock)actionBlock;

@end
