//
//  UIView+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YZHAdd)

@property (nonatomic, assign) CGFloat hz_top;
@property (nonatomic, assign) CGFloat hz_left;
@property (nonatomic, assign) CGFloat hz_right;
@property (nonatomic, assign) CGFloat hz_bottom;

@property (nonatomic, assign) CGFloat hz_width;
@property (nonatomic, assign) CGFloat hz_height;

@property (nonatomic, assign) CGFloat hz_centerX;
@property (nonatomic, assign) CGFloat hz_centerY;

@property (nonatomic, assign) CGPoint hz_origin;
@property (nonatomic, assign) CGSize  hz_size;

-(UIImage*)hz_snapshotImage;

-(UIImageView*)hz_snapshotImageView;

-(UIViewController*)hz_viewController;

@end
