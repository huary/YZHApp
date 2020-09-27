//
//  UIImage+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YZHAdd)

-(UIImage*)hz_tintColor:(UIColor*)color;

-(UIImage*)hz_tintColor:(UIColor*)color alpha:(CGFloat)alpha inRect:(CGRect)rect;

-(UIImage*)hz_createImageWithSize:(CGSize)size tintColor:(UIColor*)color;

-(UIImage*)hz_resizeImageToSize:(CGSize)size;

-(UIImage*)hz_scaleAspectFitInSize:(CGSize)size backgroundColor:(UIColor*)backgroundColor;

-(UIImage*)hz_fixImageOrientation;

-(UIImage*)hz_imageByCornerRadius:(CGFloat)cornerRadius;

-(UIImage*)hz_imageByCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

-(UIImage*)hz_imageByCornerRadius:(CGFloat)cornerRadius corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor;

-(CGSize)hz_contentSizeInSize:(CGSize)inSize contentMode:(UIViewContentMode)contentMode;

@end
