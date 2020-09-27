//
//  UIViewController+NavigationBarAndItemView.m
//  BaseDefaultUINavigationController
//
//  Created by yuan on 16/11/11.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "UIViewController+NavigationBarAndItemView.h"
#import "YZHUINavigationController.h"

@implementation UIViewController (NavigationBarAndItemView)

-(YZHUINavigationController*)hz_navigationController
{
    UINavigationController *navgatioinController = self.navigationController;
    if ([navgatioinController isKindOfClass:[YZHUINavigationController class]]) {
        return (YZHUINavigationController*)navgatioinController;
    }
    return nil;
}

-(void)setHz_NavigationBarViewBGColor:(UIColor*)color
{
    if ([self isKindOfClass:[YZHUIViewController class]]) {
        YZHUIViewController *YZHVC = (YZHUIViewController*)self;
        YZHVC.navigationBarViewBackgroundColor = color;
    }
}

-(UIColor*)hz_navigationBarViewBGColor
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

-(void)setHz_NavigationItemViewAlpha:(CGFloat)alpha
{
    if ([self isKindOfClass:[YZHUIViewController class]]) {
        YZHUIViewController *YZHVC = (YZHUIViewController*)self;
        YZHVC.navigationItemViewAlpha = alpha;
    }
}

-(CGFloat)hz_navigationItemViewAlpha
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
