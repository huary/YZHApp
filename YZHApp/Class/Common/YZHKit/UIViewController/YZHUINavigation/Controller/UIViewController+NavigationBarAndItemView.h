//
//  UIViewController+NavigationBarAndItemView.h
//  BaseDefaultUINavigationController
//
//  Created by yuan on 16/11/11.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUINavigationController.h"

@interface UIViewController (NavigationBarAndItemView)

@property (nonatomic, strong, readonly) YZHUINavigationController *YZHNavigationController;

-(void)setHz_NavigationBarViewBGColor:(UIColor*)color;
-(UIColor*)hz_navigationBarViewBGColor;

-(void)setHz_NavigationItemViewAlpha:(CGFloat)alpha;
-(CGFloat)hz_navigationItemViewAlpha;
@end
