//
//  YZHPopView.h
//  YZHPopViewDemo
//
//  Created by yuan on 2018/8/27.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YZHPopViewArrowDirection)
{
    YZHPopViewArrowDirectionAny       = 0,
    YZHPopViewArrowDirectionUp        = 1,
    YZHPopViewArrowDirectionLeft      = 2,
    YZHPopViewArrowDirectionDown      = 3,
    YZHPopViewArrowDirectionRight     = 4,
};

//typedef NS_ENUM(NSInteger, YZHPopViewAdjustType)
//{
//    //不允许调整大小的
//    YZHPopViewAdjustTypeNone          = 0,
//    //可以横线调整大小的
//    YZHPopViewAdjustTypeHorizontal    = 1,
//    //可以纵向调整大小的
//    YZHPopViewAdjustTypeVertical      = 2,
//};

typedef NS_ENUM(NSInteger, YZHPopViewContentType)
{
    YZHPopViewContentTypeTableView        = 0,
    YZHPopViewContentTypeCollectionView   = 1,
    YZHPopViewContentTypeCustom           = 2,
};

typedef UIView*(^YZHPopViewCustomContentViewBlock)(CGSize size);


/****************************************************
 *YZHPopViewDelegate
 ****************************************************/
@class YZHPopView;
@protocol YZHPopViewDelegate <NSObject>
-(NSInteger)numberOfCellsInPopView:(YZHPopView *)popView;
-(CGFloat)popView:(YZHPopView *)popView heightForCellAtIndexPath:(NSIndexPath *)indexPath;

-(UIView *)popView:(YZHPopView *)popView cell:(UIView *)cell cellSubView:(UIView *)cellSubView forCellAtIndexPath:(NSIndexPath *)indexPath;

-(void)popView:(YZHPopView*)popView didSelectedCell:(UIView *)cell cellSubView:(UIView *)cellSubView forCellAtIndexPath:(NSIndexPath *)indexPath;

-(void)popView:(YZHPopView*)popView willDisplayCell:(UIView *)cell cellSubView:(UIView *)cellSubView forCellAtIndexPath:(NSIndexPath *)indexPath;
@end

/**************************************************************************
 *YZHArrowContext
 **************************************************************************/
@interface YZHPopArrowContext : NSObject

/* 这个是arrow的底部的宽和底边上到顶角的高 */
@property (nonatomic, assign) CGSize baseSize;

/* arrowRadian的角度大小（弧度） */
@property (nonatomic, assign) CGFloat arrowRadian;

/* arrowArcRadius的圆弧的半径 */
@property (nonatomic, assign) CGFloat arrowArcRadius;

/*
 *在base的矩形中画一个顶角为arrowRadian的等腰三角形，
 *arrowArcRadius为顶角的圆弧，
 *底边带有圆弧效果根据baseSize和arrowRadian来计算
 */
-(instancetype)initWithBaseSize:(CGSize)baseSize arrowRadian:(CGFloat)arrowRadian arrowArcRadius:(CGFloat)arrowArcRadius;

/*
 *在base的矩形中画一个等腰三角形，
 *arrowArcRadius为顶角的圆弧，
 *底边带有圆弧的半径为baseAngelArcRadius，
 *顶角的大小根据根据三角形相似的公式来计算
 */
-(instancetype)initWithBaseSize:(CGSize)baseSize baseArcRadius:(CGFloat)baseArcRadius arrowArcRadius:(CGFloat)arrowArcRadius;

/*
 *在base的矩形中画一个等腰三角形，
 *arrowArcRadius为顶角的圆弧，
 *baseShift为底边上左右各偏移baseShift,
 *顶角的大小为topAngle = 2 * atan((baseSize.width/2 - baseShift)/baseSize.height)
 *底角大小为baseArcAngle = M_PI_2 - topAngle/2;
 *baseAngelArcRadius为baseShift / tan(baseArcAngle/2);
 */
-(instancetype)initWithBaseSize:(CGSize)baseSize baseShift:(CGFloat)baseShift arrowArcRadius:(CGFloat)arrowArcRadius;

/*
 *在base的矩形中画一个等腰三角形，
 *arrowArcRadius为顶角的圆弧，
 *baseShift为底边上左右各偏移baseShift,
 *顶角的大小为topAngle = arrowRadian
 *底边的大小为baseWidth = 2 * (baseHeight * tan(arrowRadian/2) + baseShift);
 */
-(instancetype)initWithBaseHeight:(CGFloat)baseHeight baseShift:(CGFloat)baseShift arrowRadian:(CGFloat)arrowRadian arrowArcRadius:(CGFloat)arrowArcRadius;

-(UIBezierPath*)bezierPathForArrowDirection:(YZHPopViewArrowDirection)arrowDirection;

@end


/**************************************************************************
 *YZHPopView
 **************************************************************************/
@interface YZHPopView : UIView

@property (nonatomic, assign) YZHPopViewArrowDirection arrowDirection;

/* popContent的类型 */
@property (nonatomic, assign) YZHPopViewContentType contentType;


/*
 *effectView是指底层带有灰色的view
 */
@property (nonatomic, strong, readonly) UIButton *cover;

/*
 *effectView是指带有毛玻璃效果的view
 */
@property (nonatomic, strong, readonly) UIView *effectView;

/*
 *contentType == YZHPopViewContentTypeTableView
 *系统生成
 */
@property (nonatomic, strong, readonly) UITableView *tableView;
/*
 *contentType == YZHPopViewContentTypeCollectionView
 *系统生成，
 *需要指定UICollectionViewLayout
 */
@property (nonatomic, strong, readonly) UICollectionView *collectionView;
/*
 *需要指定collectionView的UICollectionViewLayout属性
 */
@property (nonatomic, strong) UICollectionViewLayout *collectionViewLayout;
/*
 *contentType == YZHPopViewContentTypeCustom
 *此时customContentViewBlock返回的UIView
 */
@property (nonatomic, weak, readonly) UIView *customContentView;

/*
 *borderLayer
 */
@property (nonatomic, strong, readonly) CAShapeLayer *borderLayer;

/*
 *指定border的width
 */
@property (nonatomic, assign) CGFloat borderWidth;

/*
 *指定border的color
 */
@property (nonatomic, strong) UIColor *borderColor;

//设置delegate
@property (nonatomic, weak) id<YZHPopViewDelegate> delegate;

//这里主要是设置从那里开始
@property (nonatomic, assign) CGRect popOverRect;

//这里主要是这是popView的大小的宽度,不包含三角形的大小
@property (nonatomic, assign) CGSize popContentSize;

/* default is 5.0 */
@property (nonatomic, assign) CGFloat contentCornerRadius;

/* innerContent的backgroundColor */
@property (nonatomic, strong) UIColor *innerBackgroundColor;

/*注意，设置等腰三角行（△）的信息，
 *默认为：
 *baseSize=CGSizeMake(36, 15);
 *radian=DEGREES_TO_RADIANS(82);
 *arrowArcRadius=3
 */
@property (nonatomic, strong) YZHPopArrowContext *arrowCtx;

//这就是popView显示时距离屏幕最小的边距，默认为(10, 10, 10, 10);
@property (nonatomic, assign) UIEdgeInsets popViewEdgeInsets;

//调整类型
//@property (nonatomic, assign) YZHPopViewAdjustType adjustType;

//就是上面up，left，down，right的nsnumber的顺序，默认顺序为up，left，down，right
@property (nonatomic, copy) NSArray<NSNumber*> *arrowDirectionPriorityOrder;

/*
 *此时返回的customView就是customContentView
 *此时的adjustType就是为YZHPopViewAdjustTypeNone
 */
@property (nonatomic, copy) YZHPopViewCustomContentViewBlock customContentViewBlock;


//使用此方法时，后面进行show的时候只能是[popview popViewFromOverView:(UIView*)overView showInView:(UIView*)showInView animated:(BOOL)animated];
-(instancetype)initWithPopContentSize:(CGSize)popContentSize;
//后面进行show的时候三者均可以，但是popOverRect必须是相当于showInView的rect
-(instancetype)initWithPopContentSize:(CGSize)popContentSize fromRect:(CGRect)popOverRect;
//后面进行show的时候三者均可以
-(instancetype)initWithPopContentSize:(CGSize)popContentSize fromOverView:(UIView*)overView showInView:(UIView*)showInView;

-(void)popViewShow:(BOOL)animated;

-(void)popViewShowInView:(UIView*)showInView animated:(BOOL)animated;

-(void)popViewFromOverView:(UIView*)overView showInView:(UIView*)showInView animated:(BOOL)animated;

-(void)dismiss;

@end
