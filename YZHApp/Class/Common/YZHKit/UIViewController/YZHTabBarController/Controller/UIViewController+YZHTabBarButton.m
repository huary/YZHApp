//
//  UIViewController+UITabBarButton.m
//  YZHNavigationController
//
//  Created by yuan on 2018/4/25.
//

#import "UIViewController+YZHTabBarButton.h"
#import "NSObject+YZHAdd.h"

@implementation UIViewController (YZHTabBarButton)

-(void)setHz_tabBarButton:(YZHTabBarButton *)hz_tabBarButton
{
    [self hz_addStrongReferenceObject:hz_tabBarButton forKey:@"hz_tabBarButton"];
}

-(YZHTabBarButton*)hz_tabBarButton
{
    return [self hz_strongReferenceObjectForKey:@"hz_tabBarButton"];
}

@end
