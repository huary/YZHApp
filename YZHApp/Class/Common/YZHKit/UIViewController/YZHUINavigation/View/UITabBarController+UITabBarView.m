//
//  UITabBarController+UITabBarView.m
//  YZHUINavigationController
//
//  Created by yuan on 2018/6/14.
//  Copyright © 2018年 dlodlo. All rights reserved.
//

#import "UITabBarController+UITabBarView.h"
#import <objc/runtime.h>

@implementation UITabBarController (UITabBarView)

-(void)setTabBarView:(UIView *)tabBarView
{
    objc_setAssociatedObject(self, @selector(tabBarView), tabBarView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIView*)tabBarView
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
