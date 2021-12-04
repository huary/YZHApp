//
//  UINavigationController+YZHNavigation.m
//  YZHApp
//
//  Created by bytedance on 2021/11/22.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "UINavigationController+YZHNavigation.h"
#import "UINavigationController+YZHNavigationItn.h"
#import "UIViewController+YZHNavigation.h"
#import "UIViewController+YZHNavigationRootVCInitSetup.h"
#import "YZHNavigationItnTypes.h"
#import "YZHNCUtils.h"

#define PREV_NC_CHECK(ret)   if (!self.hz_navigationEnable || ![self isKindOfClass:[UINavigationController class]]) return ret;


@implementation UINavigationController (YZHNavigation)

- (void)setHz_navigationEnable:(BOOL)hz_navigationEnable {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return;
    }
    [super setHz_navigationEnable:hz_navigationEnable];
}

- (BOOL)hz_navigationEnable {
    return [super hz_navigationEnable];
}

ITN_SET_PROPERTY_C(YZHNavBarStyle, hz_navBarStyle, Hz_navBarStyle, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).navBarStyle = hz_navBarStyle;
        return;
    }
    itn_nc_setNavBarStyle(self, hz_navBarStyle);
});
ITN_GET_PROPERTY_C(YZHNavBarStyle, hz_navBarStyle, integerValue, YZHNavBarStyleNone, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).navBarStyle;
    }
});

ITN_SET_PROPERTY(UIColor *, hz_navigationBarViewBackgroundColor, Hz_navigationBarViewBackgroundColor, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).navigationBarViewBackgroundColor = hz_navigationBarViewBackgroundColor;
        return;
    }
    itn_nc_setNavigationBarViewBackgroundColor(self, hz_navigationBarViewBackgroundColor);
});
ITN_GET_PROPERTY(UIColor *, hz_navigationBarViewBackgroundColor, nil, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).navigationBarViewBackgroundColor;
    }
});

ITN_SET_PROPERTY(UIColor *, hz_navigationBarBottomLineColor, Hz_navigationBarBottomLineColor, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).navigationBarBottomLineColor = hz_navigationBarBottomLineColor;
        return;
    }
    itn_nc_setNavigationBarBottomLineColor(self, hz_navigationBarBottomLineColor);
});
ITN_GET_PROPERTY(UIColor *, hz_navigationBarBottomLineColor, nil, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).navigationBarBottomLineColor;
    }
});

ITN_SET_PROPERTY_C(CGFloat, hz_navigationBarViewAlpha, Hz_navigationBarViewAlpha, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).navigationBarViewAlpha = hz_navigationBarViewAlpha;
        return;
    }
    itn_nc_setNavigationBarViewAlpha(self, hz_navigationBarViewAlpha);
});
ITN_GET_PROPERTY_C(CGFloat, hz_navigationBarViewAlpha, floatValue, 0, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).navigationBarViewAlpha;
    }
});

//默认是YES
ITN_SET_PROPERTY_C(BOOL, hz_popGestureEnabled, Hz_popGestureEnabled, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).popGestureEnabled = hz_popGestureEnabled;
        return;
    }
});
ITN_GET_PROPERTY_C(BOOL, hz_popGestureEnabled, boolValue, NCPopGestureEnabled_s, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).popGestureEnabled;
    }
});

ITN_SET_PROPERTY_C(NSTimeInterval, hz_transitionDuration, Hz_transitionDuration, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).transitionDuration = hz_transitionDuration;
        return;
    }
});
ITN_GET_PROPERTY_C(NSTimeInterval, hz_transitionDuration, doubleValue, NCTransitionDuration_s, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).transitionDuration;
    }
});

ITN_SET_PROPERTY_C(BOOL, hz_hidesTabBarAfterPushed, Hz_hidesTabBarAfterPushed, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).hidesTabBarAfterPushed = hz_hidesTabBarAfterPushed;
        return;
    }
});
ITN_GET_PROPERTY_C(BOOL, hz_hidesTabBarAfterPushed, boolValue, NCHidesTabBarAfterPushed_s, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).hidesTabBarAfterPushed;
    }
});

ITN_WSET_PROPERTY(id<YZHNavigationControllerDelegate>, hz_navDelegate, Hz_navDelegate, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).navDelegate = hz_navDelegate;
        return;
    }
});
ITN_WGET_PROPERTY(id<YZHNavigationControllerDelegate>, hz_navDelegate, nil, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).navDelegate;
    }
});

ITN_SET_PROPERTY_C(YZHNavigationBarAndItemStyle, hz_navigationBarAndItemStyle, Hz_navigationBarAndItemStyle, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).navigationBarAndItemStyle = hz_navigationBarAndItemStyle;
        return;
    }
});
ITN_GET_PROPERTY_C(YZHNavigationBarAndItemStyle, hz_navigationBarAndItemStyle, integerValue, YZHNavigationBarAndItemStyleDefault, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).navigationBarAndItemStyle;
    }
});

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self hz_exchangeInstanceMethod:@selector(initWithRootViewController:) with:@selector(hz_initWithRootViewController:)];
        [self hz_exchangeInstanceMethod:@selector(viewDidLoad) with:@selector(hz_nc_viewDidLoad)];
        [self hz_exchangeInstanceMethod:@selector(viewWillLayoutSubviews) with:@selector(hz_nc_viewWillLayoutSubviews)];
        [self hz_exchangeInstanceMethod:@selector(pushViewController:animated:) with:@selector(hz_pushViewController:animated:)];
    });
}

- (instancetype)hz_initWithRootViewController:(UIViewController *)rootViewController {
    self.hz_navigationEnable = rootViewController.hz_navigationEnableForRootVCInitSetToNavigation;
    self.hz_navigationBarAndItemStyle = rootViewController.hz_barAndItemStyleForRootVCInitSetToNavigation;
    return [self hz_initWithRootViewController:rootViewController];
}

- (void)hz_nc_viewDidLoad {
    [self hz_nc_viewDidLoad];

//    [self hz_addStrongReferenceObject:@(YES) forKey:@"hz_isViewDidLoad"];
    
    PREV_NC_CHECK();
        
    itn_nc_viewDidLoad(self);
}

- (void)hz_nc_viewWillLayoutSubviews {
    [self hz_nc_viewWillLayoutSubviews];

    PREV_NC_CHECK();

    itn_nc_viewWillLayoutSubviews(self);
}

#pragma mark override
-(void)hz_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    itn_pushViewController(self, viewController, animated);
    [self hz_pushViewController:viewController animated:animated];
}


-(void)hz_resetNavigationBarAndItemViewFrame:(CGRect)frame
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self resetNavigationBarAndItemViewFrame:frame];
        return;
    }
    PREV_NC_CHECK();

    itn_resetNavigationBarAndItemViewFrame(self, frame);
}

//自定义
-(void)hz_pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(YZHNavigationControllerAnimationCompletionBlock)completion
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self pushViewController:viewController animated:animated completion:completion];
        return;
    }
    PREV_NC_CHECK();

    itn_pushViewControllerCompletion(self, viewController, completion);
    [self pushViewController:viewController animated:animated];
}

-(void)hz_setViewControllers:(NSArray<UIViewController *> *)viewControllers
                   completion:(YZHNavigationControllerAnimationCompletionBlock)completion {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self setViewControllers:viewControllers completion:completion];
        return;
    }
    PREV_NC_CHECK();
    itn_pushViewControllerCompletion(self, viewControllers.lastObject, completion);
    self.viewControllers = viewControllers;
}

-(void)hz_setViewControllers:(NSArray<UIViewController *> *)viewControllers
                     animated:(BOOL)animated
                   completion:(YZHNavigationControllerAnimationCompletionBlock)completion {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self setViewControllers:viewControllers animated:animated completion:completion];
        return;
    }
    PREV_NC_CHECK();
    itn_pushViewControllerCompletion(self, viewControllers.lastObject, completion);
    [self setViewControllers:viewControllers animated:animated];
}

- (UIViewController *)hz_popViewControllerAnimated:(BOOL)animated completion:(YZHNavigationControllerAnimationCompletionBlock)completion
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return [(YZHNavigationController*)self popViewControllerAnimated:animated completion:completion];
    }
    PREV_NC_CHECK(nil);

    itn_popViewControllerCompletion(self, completion);
    UIViewController *vc = [self popViewControllerAnimated:animated];
    return vc;
}

- (NSArray *)hz_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(YZHNavigationControllerAnimationCompletionBlock)completion
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return [(YZHNavigationController*)self popToViewController:viewController animated:animated completion:completion];
    }
    PREV_NC_CHECK(nil);
    itn_popViewControllerCompletion(self, completion);
    return [self popToViewController:viewController animated:animated];
}

- (NSArray *)hz_popToRootViewControllerAnimated:(BOOL)animated completion:(YZHNavigationControllerAnimationCompletionBlock)completion
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return [(YZHNavigationController*)self popToRootViewControllerAnimated:animated completion:completion];
    }
    PREV_NC_CHECK(nil);
    itn_popViewControllerCompletion(self, completion);
    return [self popToRootViewControllerAnimated:animated];
}

@end
