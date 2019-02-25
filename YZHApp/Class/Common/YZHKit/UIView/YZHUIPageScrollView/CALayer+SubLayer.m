//
//  CALayer+SubLayer.m
//  YZHUIPageScrollViewDemo
//
//  Created by yuan on 2018/5/12.
//  Copyright © 2018年 dlodlo. All rights reserved.
//

#import "CALayer+SubLayer.h"

@implementation CALayer (SubLayer)

-(void)bringSubLayerToFront:(CALayer*)subLayer
{
    [subLayer removeFromSuperlayer];
    [self addSublayer:subLayer];
}

-(void)sendSubLayerToBack:(CALayer*)subLayer
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
