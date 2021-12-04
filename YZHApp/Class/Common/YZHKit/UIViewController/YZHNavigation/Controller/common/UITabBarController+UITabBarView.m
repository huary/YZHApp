//
//  UITabBarController+UITabBarView.m
//  YZHNavigationController
//
//  Created by yuan on 2018/6/14.
//  Copyright © 2018年 dlodlo. All rights reserved.
//

#import "UITabBarController+UITabBarView.h"
#import "NSObject+YZHAdd.h"

@implementation UITabBarController (YZHTabBarView)

-(void)setHz_tabBarView:(UIView *)hz_tabBarView
{
    [self hz_addStrongReferenceObject:hz_tabBarView forKey:@"hz_tabBarView"];
}

-(UIView*)hz_tabBarView
{
    return [self hz_strongReferenceObjectForKey:@"hz_tabBarView"];
}

@end
