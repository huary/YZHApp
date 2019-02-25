//
//  UIImage+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YZHAdd)

-(UIImage*)tintColor:(UIColor*)color;

-(UIImage*)tintColor:(UIColor*)color alpha:(CGFloat)alpha inRect:(CGRect)rect;

-(UIImage*)createImageWithSize:(CGSize)size tintColor:(UIColor*)color;

-(UIImage*)resizeImageToSize:(CGSize)size;

-(UIImage*)scaleAspectFitInSize:(CGSize)size backgroundColor:(UIColor*)backgroundColor;

-(UIImage*)updateImageOrientation;

-(UIImage*)imageByCornerRadius:(CGFloat)cornerRadius;

-(UIImage*)imageByCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

-(UIImage*)imageByCornerRadius:(CGFloat)cornerRadius corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

@end
