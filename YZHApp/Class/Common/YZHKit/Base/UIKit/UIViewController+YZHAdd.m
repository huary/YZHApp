//
//  UIViewController+YZHAdd.m
//  LZGameBox
//
//  Created by yuan on 2020/4/8.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "UIViewController+YZHAdd.h"

@class NSBundleInterfaceOrientation;
static NSBundleInterfaceOrientation *defaultInterfaceOrientation_s = nil;

@interface NSBundleInterfaceOrientation : NSObject

@property (nonatomic, assign) BOOL rotatable;

@property (nonatomic, assign) UIInterfaceOrientationMask mask;

@property (nonatomic, assign) UIInterfaceOrientation preferred;

@end

@implementation NSBundleInterfaceOrientation

+ (NSDictionary<NSString *, NSNumber *>*)interfaceOrientationInfo
{
    return @{@"UIInterfaceOrientationPortrait":@(UIInterfaceOrientationPortrait),
             @"UIInterfaceOrientationLandscapeLeft":@(UIInterfaceOrientationLandscapeLeft),
             @"UIInterfaceOrientationLandscapeRight":@(UIInterfaceOrientationLandscapeRight),
             @"UIInterfaceOrientationPortraitUpsideDown":@(UIInterfaceOrientationPortraitUpsideDown)};
}

+ (instancetype)defaultInterfaceOrientation
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSString*> *list = nil;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            list = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations"];
        }
        else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            list = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UISupportedInterfaceOrientations~ipad"];
        }
        UIInterfaceOrientationMask mask = 0;
        NSDictionary<NSString *, NSNumber *> *interfaceOrientationInfo = [self interfaceOrientationInfo];
        UIInterfaceOrientation preferred = list.count > 0 ? [[interfaceOrientationInfo objectForKey:[list firstObject]] integerValue] : UIInterfaceOrientationPortrait;
        for (NSString *orientation in list) {
            NSNumber *n = [interfaceOrientationInfo objectForKey:orientation];
            mask = mask | [n integerValue];
        }
        
        defaultInterfaceOrientation_s = [NSBundleInterfaceOrientation new];
        defaultInterfaceOrientation_s.rotatable = list.count > 1 ? YES : NO;
        defaultInterfaceOrientation_s.mask = mask;
        defaultInterfaceOrientation_s.preferred = preferred;
    });
    return defaultInterfaceOrientation_s;
}
@end


@interface NSVCInterfaceOrientationConfig ()

@property (nonatomic, copy) NSVCInterfaceOrientationConfigDynamicProvider provider;

@end

@implementation NSVCInterfaceOrientationConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self pri_setupDefault];
    }
    return self;
}

- (instancetype)initWithDynamicProvider:(NSVCInterfaceOrientationConfigDynamicProvider _Nullable )provider
{
    self = [super init];
    if (self) {
        [self pri_setupDefault];
        self.provider = provider;
    }
    return self;
}

- (void)pri_setupDefault
{
    NSBundleInterfaceOrientation *interfaceOrientation = [NSBundleInterfaceOrientation defaultInterfaceOrientation];
    self.autoRotatable = interfaceOrientation.rotatable;
    self.interfaceOrientationMask = interfaceOrientation.mask;
    self.preferredInterfaceOrientation = interfaceOrientation.preferred;
}

@end


@implementation UIViewController (YZHAdd)

- (void)setHz_interfaceOrientationConfig:(NSVCInterfaceOrientationConfig *)hz_interfaceOrientationConfig
{
    objc_setAssociatedObject(self, @selector(hz_interfaceOrientationConfig), hz_interfaceOrientationConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSVCInterfaceOrientationConfig *)hz_interfaceOrientationConfig
{
    NSVCInterfaceOrientationConfig *config = objc_getAssociatedObject(self, _cmd);
    if (!config) {
        config = [NSVCInterfaceOrientationConfig new];
        self.hz_interfaceOrientationConfig = config;
    }
    return config;
}

- (BOOL)hz_shouldAutorotate
{
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController*)self).selectedViewController shouldAutorotate];
    }
    else if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController*)self).topViewController shouldAutorotate];
    }
    if (self.hz_interfaceOrientationConfig.provider) {
        return [self.hz_interfaceOrientationConfig.provider(self, NSVCInterfaceOrientationConfigOptionAutoRotatable) boolValue];
    }
    return self.hz_interfaceOrientationConfig.autoRotatable;
}

- (UIInterfaceOrientationMask)hz_supportedInterfaceOrientations
{
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController*)self).selectedViewController supportedInterfaceOrientations];
    }
    else if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController*)self).topViewController supportedInterfaceOrientations];
    }
    if (self.hz_interfaceOrientationConfig.provider) {
        return [self.hz_interfaceOrientationConfig.provider(self, NSVCInterfaceOrientationConfigOptionInterfaceOrientationMask) unsignedIntegerValue];
    }
    return self.hz_interfaceOrientationConfig.interfaceOrientationMask;
}

- (UIInterfaceOrientation)hz_preferredInterfaceOrientationForPresentation
{
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController*)self).selectedViewController preferredInterfaceOrientationForPresentation];
    }
    else if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController*)self).topViewController preferredInterfaceOrientationForPresentation];
    }
    if (self.hz_interfaceOrientationConfig.provider) {
        return [self.hz_interfaceOrientationConfig.provider(self, NSVCInterfaceOrientationConfigOptionPreferredInterfaceOrientation) integerValue];
    }
    return self.hz_interfaceOrientationConfig.preferredInterfaceOrientation;
}

- (void)hz_updateCurrentDeviceOrientation:(UIDeviceOrientation)orientation
{
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
}


//- (BOOL)shouldAutorotate
//{
//    return [self hz_shouldAutorotate];
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return [self hz_supportedInterfaceOrientations];
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return [self hz_preferredInterfaceOrientationForPresentation];
//}

@end
