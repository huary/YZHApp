//
//  UIBezierPath+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIBezierPath+YZHAdd.h"
#import "YZHKitMacro.h"

@implementation UIBezierPath (YZHAdd)

+(instancetype)hz_bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadius:(CGFloat)cornerRadius
{
    CGFloat X = rect.origin.x;
    CGFloat Y = rect.origin.y;
    CGFloat MX = CGRectGetMaxX(rect);
    CGFloat MY = CGRectGetMaxY(rect);
    
    CGFloat maxRadius = MIN(rect.size.width, rect.size.height)/2;
    cornerRadius = MIN(cornerRadius, maxRadius);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    //画上横线
    CGFloat x = 0;
    CGFloat y = Y;
    if (TYPE_AND(corners, UIRectCornerTopLeft)) {
        x = X + cornerRadius;
        y = Y;
    }
    [bezierPath moveToPoint:CGPointMake(x, y)];
    
    y = Y;
    if (TYPE_AND(corners, UIRectCornerTopRight)) {
        x = MX - cornerRadius;
    }
    else {
        x = MX;
    }
    [bezierPath addLineToPoint:CGPointMake(x, y)];
    
    //画topRight的corner
    if (TYPE_AND(corners, UIRectCornerTopRight)) {
        y = Y + cornerRadius;
        [bezierPath addArcWithCenter:CGPointMake(x, y) radius:cornerRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    }
    
//    画Right的竖线
    x = MX;
    if (TYPE_AND(corners, UIRectCornerBottomRight)) {
        y = MY - cornerRadius;
    }
    else {
        y = MY;
    }
    [bezierPath addLineToPoint:CGPointMake(x, y)];
    
    //画bottomRight的corner
    if (TYPE_AND(corners, UIRectCornerBottomRight)) {
        x = MX - cornerRadius;
        y = MY - cornerRadius;
        [bezierPath addArcWithCenter:CGPointMake(x, y) radius:cornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    }

    //画bottom的横线
    y = MY;
    if (TYPE_AND(corners, UIRectCornerBottomLeft)) {
        x = X + cornerRadius;
    }
    else {
        x = X;
    }
    [bezierPath addLineToPoint:CGPointMake(x, y)];

    //画bottomLeft的corner
    if (TYPE_AND(corners, UIRectCornerBottomLeft)) {
        y = MY - cornerRadius;
        [bezierPath addArcWithCenter:CGPointMake(x, y) radius:cornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    }

    //画left的竖线
    x = X;
    if (TYPE_AND(corners, UIRectCornerTopLeft)) {
        y = Y + cornerRadius;
    }
    else {
        y = Y;
    }
    [bezierPath addLineToPoint:CGPointMake(x, y)];

    //画topLeft的corner
    if (TYPE_AND(corners, UIRectCornerTopLeft)) {
        x = X + cornerRadius;
        y = Y + cornerRadius;
        [bezierPath addArcWithCenter:CGPointMake(x, y) radius:cornerRadius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    }
    
    return bezierPath;
}


+(instancetype)hz_borderBezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth
{
    CGFloat halfBorderWidth = borderWidth/2;
    CGRect newRect = CGRectInset(rect, halfBorderWidth, halfBorderWidth);
    CGFloat radius = cornerRadius - halfBorderWidth;
    return [UIBezierPath hz_bezierPathWithRoundedRect:newRect byRoundingCorners:corners cornerRadius:radius];
}

+(CGRect)hz_borderRectForRoundedRect:(CGRect)rect borderWidth:(CGFloat)borderWidth
{
    CGFloat halfBorderWidth = borderWidth/2;
    return CGRectInset(rect, halfBorderWidth, halfBorderWidth);
}

@end
