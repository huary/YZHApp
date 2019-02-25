//
//  CALayer+SubLayer.h
//  YZHUIPageScrollViewDemo
//
//  Created by yuan on 2018/5/12.
//  Copyright © 2018年 dlodlo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (SubLayer)

-(void)bringSubLayerToFront:(CALayer*)subLayer;

-(void)sendSubLayerToBack:(CALayer*)subLayer;

@end
