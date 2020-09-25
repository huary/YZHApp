//
//  CALayer+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "CALayer+YZHAdd.h"

@implementation CALayer (YZHAdd)

GET_SET_PROPERTY(CGFloat, top, Top)

GET_SET_PROPERTY(CGFloat, left, Left)

GET_SET_PROPERTY(CGFloat, right, Right)

GET_SET_PROPERTY(CGFloat, bottom, Bottom)

GET_SET_PROPERTY(CGFloat, width, Width)

GET_SET_PROPERTY(CGFloat, height, Height)

-(CGPoint)center
{
    return CGPointMake(self.frame.origin.x + self.frame.size.width * 0.5,
                       self.frame.origin.y + self.frame.size.height * 0.5);
}

-(void)setCenter:(CGPoint)center
{
    CGRect frame = self.frame;
    frame.origin.x = center.x - frame.size.width * 0.5;
    frame.origin.y = center.y - frame.size.height * 0.5;
    self.frame = frame;
}

GET_SET_PROPERTY(CGFloat, centerX, CenterX)

GET_SET_PROPERTY(CGFloat, centerY, CenterY)

GET_SET_PROPERTY(CGPoint, origin, Origin)

GET_SET_PROPERTY(CGSize, size, Size)

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
