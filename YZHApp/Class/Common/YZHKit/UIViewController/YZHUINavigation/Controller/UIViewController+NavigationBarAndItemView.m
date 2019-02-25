//
//  UIViewController+NavigationBarAndItemView.m
//  BaseDefaultUINavigationController
//
//  Created by captain on 16/11/11.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "UIViewController+NavigationBarAndItemView.h"
#import "YZHUINavigationController.h"
#import "YZHUIViewController.h"

@implementation UIViewController (NavigationBarAndItemView)

-(YZHUINavigationController*)YZHNavigationController
{
    UINavigationController *navgatioinController = self.navigationController;
    if ([navgatioinController isKindOfClass:[YZHUINavigationController class]]) {
        return (YZHUINavigationController*)navgatioinController;
    }
    return nil;
}

-(void)setNavigationBarViewBGColor:(UIColor*)color
{
    if ([self isKindOfClass:[YZHUIViewController class]]) {
        YZHUIViewController *YZHVC = (YZHUIViewController*)self;
        YZHVC.navigationBarViewBackgroundColor = color;
    }
}

-(UIColor*)navigationBarViewBGColor
{
    if ([self isKindOfClass:[YZHUIViewController class]]) {
        YZHUIViewController *YZHVC = (YZHUIViewController*)self;
        return YZHVC.navigationBarViewBackgroundColor;
    }
    else
    {
        return nil;
    }
}

-(void)setNavigationItemViewAlpha:(CGFloat)alpha
{
    if ([self isKindOfClass:[YZHUIViewController class]]) {
        YZHUIViewController *YZHVC = (YZHUIViewController*)self;
        YZHVC.navigationItemViewAlpha = alpha;
    }
}

-(CGFloat)navigationItemViewAlpha
{
    if ([self isKindOfClass:[YZHUIViewController class]]) {
        YZHUIViewController *YZHVC = (YZHUIViewController*)self;
        return YZHVC.navigationItemViewAlpha;
    }
    else
    {
        return 0.0;
    }
}

@end
