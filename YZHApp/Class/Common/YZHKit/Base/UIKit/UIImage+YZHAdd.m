//
//  UIImage+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIImage+YZHAdd.h"
#import "YZHGraphics.h"
#import "YZHCGUtil.h"

@implementation UIImage (YZHAdd)

-(UIImage*)hz_tintColor:(UIColor*)color
{
    return [self hz_tintColor:color alpha:1.0 inRect:CGRectMake(0, 0, self.size.width, self.size.height)];
}

-(UIImage*)hz_tintColor:(UIColor*)color alpha:(CGFloat)alpha inRect:(CGRect)rect
{
    CGRect graphicsImageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(graphicsImageRect.size, NO, self.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self drawInRect:graphicsImageRect];

    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextSetAlpha(ctx, alpha);
    CGContextSetBlendMode(ctx, kCGBlendModeSourceAtop);
    CGContextFillRect(ctx, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage*)hz_createImageWithSize:(CGSize)size tintColor:(UIColor*)color
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage*)hz_resizeImageToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, size}];
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageNew;
}

-(UIImage*)hz_scaleAspectFitInSize:(CGSize)size backgroundColor:(UIColor*)backgroundColor
{
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    if (self.size.width == 0 || self.size.height == 0) {
        return nil;
    }
    CGFloat wR = size.width / self.size.width;
    CGFloat hR =  size.height / self.size.height;
    
    CGFloat R = MIN(wR, hR);
    CGFloat w = self.size.width * R;
    CGFloat h = self.size.height * R;
    CGFloat x = (size.width - w)/2;
    CGFloat y = (size.height - h)/2;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (backgroundColor) {
        CGContextSetFillColorWithColor(ctx, backgroundColor.CGColor);
        CGContextFillRect(ctx, (CGRect){0,0,size});
    }
    [self drawInRect:(CGRect){x,y,w,h}];
    UIImage *mergeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return mergeImage;
}

-(UIImage*)hz_fixImageOrientation
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *imageNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageNew;
}

-(UIImage*)hz_imageByCornerRadius:(CGFloat)cornerRadius
{
    return [self hz_imageByCornerRadius:cornerRadius borderWidth:0 borderColor:nil];
}

-(UIImage*)hz_imageByCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor
{
    return [self hz_imageByCornerRadius:cornerRadius corners:UIRectCornerAllCorners borderWidth:borderWidth borderColor:borderColor];
}

-(UIImage*)hz_imageByCornerRadius:(CGFloat)cornerRadius corners:(UIRectCorner)corners borderWidth:(CGFloat)borderWidth borderColor:(UIColor*)borderColor
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    return [YZHGraphicsContext graphicesImage:self graphicsSize:self.size inRect:rect byRoundingCorners:corners cornerRadius:cornerRadius borderWidth:borderWidth borderColor:borderColor];
}

-(CGSize)hz_contentSizeInSize:(CGSize)inSize contentMode:(UIViewContentMode)contentMode
{
    return rectWithContentMode(inSize, self.size, contentMode).size;
}
@end
