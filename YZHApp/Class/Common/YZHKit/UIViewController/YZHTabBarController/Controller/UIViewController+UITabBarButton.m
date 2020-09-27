//
//  UIViewController+UITabBarButton.m
//  YZHUINavigationController
//
//  Created by yuan on 2018/4/25.
//  Copyright © 2018年 dlodlo. All rights reserved.
//

#import "UIViewController+UITabBarButton.h"
#import <objc/runtime.h>

@implementation UIViewController (UITabBarButton)

-(void)setHz_tabBarButton:(YZHUITabBarButton *)hz_tabBarButton
{
    objc_setAssociatedObject(self, @selector(hz_tabBarButton), hz_tabBarButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(YZHUITabBarButton*)hz_tabBarButton
{
    return (YZHUITabBarButton*)objc_getAssociatedObject(self, _cmd);
}

@end
