//
//  UITabBarItem+UIButton.m
//  YZHApp
//
//  Created by yuan on 2018/3/2.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UITabBarItem+UIButton.h"
#import <Foundation/Foundation.h>
#import "NSObject+YZHAdd.h"
#import "YZHKitType.h"

@implementation UITabBarItem (UIButton)

-(void)setHz_buttonStyle:(YZHButtonImageTitleStyle)hz_buttonStyle
{
    [self hz_addStrongReferenceObject:@(hz_buttonStyle) forKey:@"hz_buttonStyle"];
}

-(YZHButtonImageTitleStyle)hz_buttonStyle
{
    return [[self hz_strongReferenceObjectForKey:@"hz_buttonStyle"] integerValue];
}

-(void)setHz_buttonItemOrigin:(CGPoint)hz_buttonItemOrigin
{
    [self hz_addStrongReferenceObject:[NSValue valueWithCGPoint:hz_buttonItemOrigin] forKey:@"hz_buttonItemOrigin"];
}

-(CGPoint)hz_buttonItemOrigin
{
    return [[self hz_strongReferenceObjectForKey:@"hz_buttonItemOrigin"] CGPointValue];
}

-(void)setHz_buttonItemSize:(CGSize)hz_buttonItemSize
{
    [self hz_addStrongReferenceObject:[NSValue valueWithCGSize:hz_buttonItemSize] forKey:@"hz_buttonItemSize"];
}

-(CGSize)hz_buttonItemSize
{
    return [[self hz_strongReferenceObjectForKey:@"hz_buttonItemSize"] CGSizeValue];
}

-(void)setHz_imageRange:(CGRange)hz_imageRange
{
    NSValue *value = [NSValue valueWithBytes:&hz_imageRange objCType:@encode(CGRange)];
    [self hz_addStrongReferenceObject:value forKey:@"hz_imageRange"];
}

-(CGRange)hz_imageRange
{
    CGRange r = CGRangeMake(0, 0);
    NSValue *value = [self hz_strongReferenceObjectForKey:@"hz_imageRange"];
    if (SYSTEMVERSION_NUMBER < 11.0) {
        [value getValue:&r];
    }
    else {
        AVAILABLE_IOS_V_EXP(11.0, [value getValue:&r size:sizeof(r)];, );
    }
    return r;
}

-(void)setHz_titleRange:(CGRange)hz_titleRange
{
    NSValue *value = [NSValue valueWithBytes:&hz_titleRange objCType:@encode(CGRange)];
    [self hz_addStrongReferenceObject:value forKey:@"hz_titleRange"];
}

-(CGRange)hz_titleRange
{
    CGRange r = CGRangeMake(0, 0);
    NSValue *value = [self hz_strongReferenceObjectForKey:@"hz_titleRange"];
    if (SYSTEMVERSION_NUMBER < 11.0) {
        [value getValue:&r];
    }
    else {
        AVAILABLE_IOS_V_EXP(11.0, [value getValue:&r size:sizeof(r)];, );
    }
    return r;
}

-(void)setHz_normalBackgroundColor:(UIColor *)hz_normalBackgroundColor
{
    [self hz_addStrongReferenceObject:hz_normalBackgroundColor forKey:@"hz_normalBackgroundColor"];
}

-(UIColor*)hz_normalBackgroundColor
{
    return [self hz_strongReferenceObjectForKey:@"hz_normalBackgroundColor"];
}

-(void)setHz_selectedBackgroundColor:(UIColor *)hz_selectedBackgroundColor
{
    [self hz_addStrongReferenceObject:hz_selectedBackgroundColor forKey:@"hz_selectedBackgroundColor"];
}

-(UIColor*)hz_selectedBackgroundColor
{
    return [self hz_strongReferenceObjectForKey:@"hz_selectedBackgroundColor"];
}

-(void)setHz_highlightedBackgroundColor:(UIColor *)hz_highlightedBackgroundColor
{
    [self hz_addStrongReferenceObject:hz_highlightedBackgroundColor forKey:@"hz_highlightedBackgroundColor"];
}

-(UIColor*)hz_highlightedBackgroundColor
{
    return [self hz_strongReferenceObjectForKey:@"hz_highlightedBackgroundColor"];
}

-(void)setHz_badgeBackgroundColor:(UIColor *)hz_badgeBackgroundColor
{
    [self hz_addStrongReferenceObject:hz_badgeBackgroundColor forKey:@"hz_badgeBackgroundColor"];
}

-(UIColor*)hz_badgeBackgroundColor
{
    return [self hz_strongReferenceObjectForKey:@"hz_badgeBackgroundColor"];
}

-(void)setHz_badgeStateTextAttributes:(NSDictionary<NSNumber *,NSDictionary<NSString *,id> *> *)hz_badgeStateTextAttributes
{
    [self hz_addStrongReferenceObject:hz_badgeStateTextAttributes forKey:@"hz_badgeStateTextAttributes"];
}

-(NSDictionary<NSNumber *,NSDictionary<NSString *,id> *> *)hz_badgeStateTextAttributes
{
    return [self hz_strongReferenceObjectForKey:@"hz_badgeStateTextAttributes"];
}

-(void)setHz_badgeValueUpdateBlock:(UITabBarItemBadgeBlock)hz_badgeValueUpdateBlock
{
    [self hz_addStrongReferenceObject:hz_badgeValueUpdateBlock forKey:@"hz_badgeValueUpdateBlock"];
}

-(UITabBarItemBadgeBlock)hz_badgeValueUpdateBlock
{
    return [self hz_strongReferenceObjectForKey:@"hz_badgeValueUpdateBlock"];
}

@end
