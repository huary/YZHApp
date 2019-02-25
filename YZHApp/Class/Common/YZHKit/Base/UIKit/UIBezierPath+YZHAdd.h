//
//  UIBezierPath+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (YZHAdd)

/*
 *此方法为了和UIView的layer的corneradius保持一致，
 *+ (instancetype)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;方法同layer上的corneradius存在微小的差别
 */
+(instancetype)bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadius:(CGFloat)cornerRadius;

/*
 *创建一个rect边缘的border的bezierPath
 */
+(instancetype)borderBezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth;

+(CGRect)borderRectForRoundedRect:(CGRect)rect borderWidth:(CGFloat)borderWidth;

@end
