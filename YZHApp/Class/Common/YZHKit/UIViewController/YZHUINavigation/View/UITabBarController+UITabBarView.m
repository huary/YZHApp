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

-(void)setHz_tabBarView:(UIView *)hz_tabBarView
{
    objc_setAssociatedObject(self, @selector(hz_tabBarView), hz_tabBarView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIView*)hz_tabBarView
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
