//
//  UITabBarItem+UIButton.m
//  YZHApp
//
//  Created by yuan on 2018/3/2.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UITabBarItem+UIButton.h"
#import <objc/runtime.h>
#import "YZHKitType.h"

@implementation UITabBarItem (UIButton)

-(void)setHz_buttonStyle:(NSButtonImageTitleStyle)hz_buttonStyle
{
    objc_setAssociatedObject(self, @selector(hz_buttonStyle), @(hz_buttonStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSButtonImageTitleStyle)hz_buttonStyle
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

-(void)setHz_buttonItemOrigin:(CGPoint)hz_buttonItemOrigin
{
    objc_setAssociatedObject(self, @selector(hz_buttonItemOrigin), [NSValue valueWithCGPoint:hz_buttonItemOrigin], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGPoint)hz_buttonItemOrigin
{
    return [objc_getAssociatedObject(self, _cmd) CGPointValue];
}

-(void)setHz_buttonItemSize:(CGSize)hz_buttonItemSize
{
    objc_setAssociatedObject(self, @selector(hz_buttonItemSize), [NSValue valueWithCGSize:hz_buttonItemSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGSize)hz_buttonItemSize
{
    return [objc_getAssociatedObject(self, _cmd) CGSizeValue];
}

-(void)setHz_imageRange:(CGRange)hz_imageRange
{
    NSValue *value = [NSValue valueWithBytes:&hz_imageRange objCType:@encode(CGRange)];
    objc_setAssociatedObject(self, @selector(hz_imageRange), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGRange)hz_imageRange
{
    CGRange r = CGRangeMake(0, 0);
    NSValue *value = objc_getAssociatedObject(self, _cmd);
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
    objc_setAssociatedObject(self, @selector(hz_titleRange), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGRange)hz_titleRange
{
    CGRange r = CGRangeMake(0, 0);
    NSValue *value = objc_getAssociatedObject(self, _cmd);
    if (SYSTEMVERSION_NUMBER < 11.0) {
        [value getValue:&r];
    }
    else {
        AVAILABLE_IOS_V_EXP(11.0, [value getValue:&r size:sizeof(r)];, );
//        [value getValue:&r size:sizeof(r)];
    }
    return r;
}

-(void)setHz_normalBackgroundColor:(UIColor *)hz_normalBackgroundColor
{
    objc_setAssociatedObject(self, @selector(hz_normalBackgroundColor), hz_normalBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIColor*)hz_normalBackgroundColor
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setHz_selectedBackgroundColor:(UIColor *)hz_selectedBackgroundColor
{
    objc_setAssociatedObject(self, @selector(hz_selectedBackgroundColor), hz_selectedBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIColor*)hz_selectedBackgroundColor
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setHz_highlightedBackgroundColor:(UIColor *)hz_highlightedBackgroundColor
{
    objc_setAssociatedObject(self, @selector(hz_highlightedBackgroundColor), hz_highlightedBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIColor*)hz_highlightedBackgroundColor
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setHz_badgeBackgroundColor:(UIColor *)hz_badgeBackgroundColor
{
    objc_setAssociatedObject(self, @selector(hz_badgeBackgroundColor), hz_badgeBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIColor*)hz_badgeBackgroundColor
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setHz_badgeStateTextAttributes:(NSDictionary<NSNumber *,NSDictionary<NSString *,id> *> *)hz_badgeStateTextAttributes
{
    objc_setAssociatedObject(self, @selector(hz_badgeStateTextAttributes), hz_badgeStateTextAttributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSDictionary<NSNumber *,NSDictionary<NSString *,id> *> *)hz_badgeStateTextAttributes
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setHz_badgeValueUpdateBlock:(UITabBarItemBadgeBlock)hz_badgeValueUpdateBlock
{
    objc_setAssociatedObject(self, @selector(hz_badgeValueUpdateBlock), hz_badgeValueUpdateBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(UITabBarItemBadgeBlock)hz_badgeValueUpdateBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
