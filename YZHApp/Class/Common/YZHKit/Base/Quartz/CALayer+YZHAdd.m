//
//  CALayer+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "CALayer+YZHAdd.h"

@implementation CALayer (YZHAdd)

GET_SET_PROPERTY(CGFloat, top, hz_top, Hz_top)

GET_SET_PROPERTY(CGFloat, left, hz_left, Hz_left)

GET_SET_PROPERTY(CGFloat, right, hz_right, Hz_right)

GET_SET_PROPERTY(CGFloat, bottom, hz_bottom, Hz_bottom)

GET_SET_PROPERTY(CGFloat, width, hz_width, Hz_width)

GET_SET_PROPERTY(CGFloat, height, hz_height, Hz_height)

-(CGPoint)hz_center
{
    return CGPointMake(self.frame.origin.x + self.frame.size.width * 0.5,
                       self.frame.origin.y + self.frame.size.height * 0.5);
}

-(void)setHz_center:(CGPoint)hz_center
{
    CGRect frame = self.frame;
    frame.origin.x = hz_center.x - frame.size.width * 0.5;
    frame.origin.y = hz_center.y - frame.size.height * 0.5;
    self.frame = frame;
}

- (CGFloat)hz_centerX
{
    return self.hz_center.x;
}

- (void)setHz_centerX:(CGFloat)hz_centerX
{
    CGPoint c = self.hz_center;
    c.x = hz_centerX;
    self.hz_center = c;
}

- (CGFloat)hz_centerY
{
    return self.hz_center.y;
}

- (void)setHz_centerY:(CGFloat)hz_centerY
{
    CGPoint c = self.hz_center;
    c.y = hz_centerY;
    self.hz_center = c;
}

//GET_SET_PROPERTY(CGFloat, centerX, hz_centerX, Hz_centerX)

//GET_SET_PROPERTY(CGFloat, centerY, hz_centerY, Hz_centerY)

GET_SET_PROPERTY(CGPoint, origin, hz_origin, Hz_origin)

GET_SET_PROPERTY(CGSize, size, hz_size, Hz_size)

-(UIImage*)hz_snapshotImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self renderInContext:ctx];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImageView*)hz_snapshotImageView
{
    UIImage *image = [self hz_snapshotImage];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.bounds;
    return imageView;
}

-(void)hz_bringSubLayerToFront:(CALayer*)subLayer
{
    [subLayer removeFromSuperlayer];
    [self addSublayer:subLayer];
}

-(void)hz_sendSubLayerToBack:(CALayer*)subLayer
{
    [subLayer removeFromSuperlayer];
    if (self.sublayers.count > 0) {
        [self insertSublayer:subLayer atIndex:0];
    }
    else {
        [self addSublayer:subLayer];
    }
}
@end
