//
//  UIViewController+NavigationBarAndItemView.h
//  BaseDefaultUINavigationController
//
//  Created by captain on 16/11/11.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUINavigationController.h"

@interface UIViewController (NavigationBarAndItemView)

@property (nonatomic, strong, readonly) YZHUINavigationController *YZHNavigationController;

-(void)setNavigationBarViewBGColor:(UIColor*)color;
-(UIColor*)navigationBarViewBGColor;

-(void)setNavigationItemViewAlpha:(CGFloat)alpha;
-(CGFloat)navigationItemViewAlpha;
@end
