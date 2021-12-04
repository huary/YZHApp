//
//  YZHCropView.h
//  YZHCropView
//
//  Created by yuan on 2018/5/16.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSCropRectType)
{
    NSCropRectTypeIn    = 0,
    NSCropRectTypeMid   = 1,
    NSCropRectTypeOut   = 2,
};

typedef NS_ENUM(NSInteger, NSPointViewTag)
{
    NSPointViewTagA = 1,
    NSPointViewTagB = 2,
    NSPointViewTagC = 3,
    NSPointViewTagD = 4,
    NSPointViewTagE = 5,
    NSPointViewTagF = 6,
    NSPointViewTagG = 7,
    NSPointViewTagH = 8,
    //这个是不存在的pointView
    NSPointViewTagMax   = 9,
};

typedef NS_ENUM(NSInteger, NSLineViewTag)
{
    NSLineViewTagA  = 101,
    NSLineViewTagB  = 102,
    NSLineViewTagC  = 103,
    NSLineViewTagD  = 104,
    //这个是不存在的LineView
    NSLineViewTagMax = 105,
};


/*
 *  A----------E----------B ->lineA
 *  |                     |
 *  |                     |
 *  |                     |
 *  H                     F
 *  |                     |
 *  |                     |
 *  |                     |
 *  D----------G----------C ->lineC
 *  |                     |
 *  lineD                 lineB
 */

@interface YZHCropView : UIView

/** lineWidth,default is 1.0 */
@property (nonatomic, assign) CGFloat lineWidth;

/** pointWidth, 触摸点宽高 */
@property (nonatomic, assign) CGFloat pointWidth;

/** lineColor */
@property (nonatomic, strong) UIColor *lineColor;

/** pointColor,default is white color with Alpha 0.6 */
@property (nonatomic, strong) UIColor *pointColor;

/** 注释，default is red color with Alpha 0.6 */
@property (nonatomic, strong) UIColor *dragPointColor;

/** 注释, default is gray color with Alpha 0.3 */
@property (nonatomic, strong) UIColor *outColor;

///** cropViewType,暂时只能支持 NSCropViewTypeRect */
//@property (nonatomic, assign) NSCropViewType cropViewType;
//
///** 进行多边形的时候是否联动两边的两个点,default is YES */
//@property (nonatomic, assign) BOOL polygonLinkageTwoNearPoint;

-(instancetype)initWithCropOverView:(UIView*)cropOverView;

-(instancetype)initWithCropTargetView:(UIView *)cropTargetView;

-(void)updatePoint:(NSPointViewTag)tag centerPoint:(CGPoint)centerPoint;
-(void)updatePoint:(NSPointViewTag)tag hidden:(BOOL)hidden;
-(void)updateLine:(NSLineViewTag)tag hiddent:(BOOL)hidden;

-(CGRect)cropRectForType:(NSCropRectType)type;

-(UIBezierPath*)cropBezierPathForType:(NSCropRectType)type;

@end
