//
//  UITabBarController+UITabBarView.m
//  YZHNavigationController


#import "UITabBarController+YZHTabBarView.h"

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
