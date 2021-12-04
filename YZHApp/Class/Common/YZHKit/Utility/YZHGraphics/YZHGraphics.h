//
//  YZHGraphicsImage.h
//  YZHAlertViewDemo
//
//  Created by yuan on 2018/5/18.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YZHGraphicsImageAlignment)
{
    YZHGraphicsImageAlignmentLeft        = 0,
    YZHGraphicsImageAlignmentCenter      = 1,
    YZHGraphicsImageAlignmentRight       = 2,
};

typedef NS_ENUM(NSInteger, YZHArrowDirection)
{
    YZHArrowDirectionUp       = 0,
    YZHArrowDirectionLeft     = 1,
    YZHArrowDirectionDown     = 2,
    YZHArrowDirectionRight    = 3,
};

@class YZHGraphicsContext;

//这个是可以addpath的block
typedef void(^YZHGraphicsRunBlock)(YZHGraphicsContext *context);
//这个是通过beginblock获取YZHGraphicsBeginInfo中的需要的信息
typedef void(^YZHGraphicsBeginBlock)(YZHGraphicsContext *context);
//这个如strokepath，fillpath所需要的操作。
typedef void(^YZHGraphicsEndPathBlock)(YZHGraphicsContext *context);
//这个UIGraphicsEndImageContext后返回image的操作
typedef void(^YZHGraphicsCompletionBlock)(YZHGraphicsContext *context, UIImage *image);


@interface YZHGraphicsBeginInfo : NSObject

@property (nonatomic, assign) BOOL opaque;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGSize graphicsSize;
@property (nonatomic, assign) CGFloat lineWidth;

-(instancetype)initWithGraphicsSize:(CGSize)graphicsSize opaque:(BOOL)opaque scale:(CGFloat)scale lineWidth:(CGFloat)lineWidth;

@end

@interface YZHGraphicsContext : NSObject

//这个ctx只会在graphicsBeginBlock后面才会有值的情况
@property (nonatomic, assign) CGContextRef ctx;
//默认为left
@property (nonatomic, assign) YZHGraphicsImageAlignment imageAlignment;
/*
 *beginInfo就是开始UIGraphicsBeginImageContextWithOptions所需要的信息和笔画粗细，
 *可以YZHGraphicsBeginBlock中再来设置，也可以初始化的时候设置好
 */
@property (nonatomic, strong) YZHGraphicsBeginInfo *beginInfo;


@property (nonatomic, copy) YZHGraphicsRunBlock graphicsRunBlock;
@property (nonatomic, copy) YZHGraphicsBeginBlock graphicsBeginBlock;
@property (nonatomic, copy) YZHGraphicsEndPathBlock graphicsEndPathBlock;
@property (nonatomic, copy) YZHGraphicsCompletionBlock graphicsCompletionBlock;

-(instancetype)initWithBeginBlock:(YZHGraphicsBeginBlock)beginBlock runBlock:(YZHGraphicsRunBlock)runBlock endPathBlock:(YZHGraphicsEndPathBlock)endPathBlock;

-(instancetype)initWithBeginBlock:(YZHGraphicsBeginBlock)beginBlock runBlock:(YZHGraphicsRunBlock)runBlock endPathBlock:(YZHGraphicsEndPathBlock)endPathBlock completionBlock:(YZHGraphicsCompletionBlock)completionBlock;

-(UIImage*)createGraphicesImageWithStrokeColor:(UIColor*)strokeColor;

///创建交叉的符号：+，可以选择transform
+(UIImage*)createCrossImageWithSize:(CGSize)size lineWidth:(CGFloat)lineWidth backgroundColor:(UIColor*)backgroundColor strokeColor:(UIColor*)strokeColor transform:(CGAffineTransform)transform;

//创建关闭的符号：x
+(UIImage*)createCrossImageWithSize:(CGSize)size lineWidth:(CGFloat)lineWidth backgroundColor:(UIColor*)backgroundColor strokeColor:(UIColor*)strokeColor;

//创建返回的符号：<
+(UIImage*)createBackImageWithSize:(CGSize)size lineWidth:(CGFloat)lineWidth backgroundColor:(UIColor*)backgroundColor strokeColor:(UIColor*)strokeColor;

//创建前进的符号：>
+(UIImage*)createForwardImageWithSize:(CGSize)size lineWidth:(CGFloat)lineWidth backgroundColor:(UIColor*)backgroundColor strokeColor:(UIColor*)strokeColor;

/*
 *创建的符号：< > v ^这样一个等腰三角形的两边
 *arrowAngle为顶角大小,以弧度为单位
 *baseWidth为底边的宽度
 */
+(UIImage*)createArrowImageWithType:(YZHArrowDirection)type arrowAngle:(CGFloat)angle baseWidth:(CGFloat)baseWidth lineWidth:(CGFloat)lineWidth backgroundColor:(UIColor*)backgroundColor strokeColor:(UIColor*)strokeColor;

/*
 *创建的符号：< > v ^这样一个等腰三角形的两边
 *arrowAngle为顶角大小,以弧度为单位
 *baseHeight底边上的高
 */
+(UIImage*)createArrowImageWithType:(YZHArrowDirection)type arrowAngle:(CGFloat)angle baseHeight:(CGFloat)baseHeight lineWidth:(CGFloat)lineWidth backgroundColor:(UIColor*)backgroundColor strokeColor:(UIColor*)strokeColor;

/*
 *创建的符号：< > v ^这样一个等腰三角形的两边
 *为三角形形成的大小，这个形成三角形底边的高度要稍微大点
 */
+(UIImage*)createArrowImageWithType:(YZHArrowDirection)type size:(CGSize)size lineWidth:(CGFloat)lineWidth backgroundColor:(UIColor*)backgroundColor strokeColor:(UIColor*)strokeColor;

//创建带圆角的图片
+(UIImage*)createImageWithSize:(CGSize)size cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor backgroundColor:(UIColor*)backgroundColor;

//创建带圆角的borderStroke
+(UIImage*)createBorderStrokeImageWithSize:(CGSize)size byRoundingCorners:(UIRectCorner)corners cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor backgroundColor:(UIColor*)backgroundColor;

//对图片进行圆角
+(UIImage*)graphicesImage:(UIImage*)image cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

//将图片放入到Rect中，并进行圆角
+(UIImage*)graphicesImage:(UIImage*)image inRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

//将图片放入到Rect中，并进行圆角，在graphicsSize中按rect进行绘画
+(UIImage*)graphicesImage:(UIImage*)image graphicsSize:(CGSize)graphicsSize inRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

//将图片按contentMode放入到graphicsSize中
+(UIImage*)graphicesImage:(UIImage*)image graphicsSize:(CGSize)graphicsSize contentMode:(UIViewContentMode)mode;

//将图片按contentMode放入到graphicsSize中，并进行圆角，可以设置corners
+(UIImage*)graphicesImage:(UIImage*)image graphicsSize:(CGSize)graphicsSize contentMode:(UIViewContentMode)mode byRoundingCorners:(UIRectCorner)corners cornerRadius:(CGFloat)cornerRadius;

//将图片按contentMode放入到graphicsSize中，并进行圆角，可以设置corners
+(UIImage*)graphicesImage:(UIImage*)image graphicsSize:(CGSize)graphicsSize contentMode:(UIViewContentMode)mode byRoundingCorners:(UIRectCorner)corners cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

//将图片放入到Rect中，并进行圆角，在graphicsSize中按rect进行绘画,可以设置corners
+(UIImage*)graphicesImage:(UIImage*)image graphicsSize:(CGSize)graphicsSize inRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

+(UIImage*)createImageWithSize:(CGSize)size path:(UIBezierPath*)path backgroundColor:(UIColor*)backgroundColor;

@end