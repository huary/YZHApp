//
//  CALayer+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "YZHKitType.h"

@interface CALayer (YZHAdd)

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize  size;


-(UIImage*)hz_snapshotImage;

-(UIImageView*)hz_snapshotImageView;

-(void)hz_bringSubLayerToFront:(CALayer*)subLayer;

-(void)hz_sendSubLayerToBack:(CALayer*)subLayer;

@end
