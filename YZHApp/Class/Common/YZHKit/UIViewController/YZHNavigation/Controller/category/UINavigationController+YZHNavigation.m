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
#import "YZHNavigationController.h"
#import "YZHNavigationController+Internal.h"

#define PREV_NC_CHECK_EXE(C,...) if ( C PREV_NC_COND) __VA_ARGS__


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
        [self hz_exchangeInstanceMethod:@selector(popViewControllerAnimated:) with:@selector(hz_popViewControllerAnimated:)];
        [self hz_exchangeInstanceMethod:@selector(popToViewController:animated:) with:@selector(hz_popToViewController:animated:)];
        [self hz_exchangeInstanceMethod:@selector(popToRootViewControllerAnimated:) with:@selector(hz_popToRootViewControllerAnimated:)];
        
        [self hz_exchangeInstanceMethod:@selector(setViewControllers:) with:@selector(hz_setViewControllers:)];
        [self hz_exchangeInstanceMethod:@selector(setViewControllers:animated:) with:@selector(hz_setViewControllers:animated:)];
    });
}

- (instancetype)hz_initWithRootViewController:(UIViewController *)rootViewController {
    self.hz_navbarFrameBlock = rootViewController.hz_navbarFrameBlockForRootVCInitSetToNavigation;
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
    PREV_NC_CHECK_EXE(!, {
        [self hz_pushViewController:viewController animated:animated completion:nil];
    } else {
        [self hz_pushViewController:viewController animated:animated];
    })
}

- (UIViewController *)hz_popViewControllerAnimated:(BOOL)animated {
    PREV_NC_CHECK_EXE(!, {
        return [self hz_popViewControllerAnimated:animated completion:nil];
    } else {
        return [self hz_popViewControllerAnimated:animated];
    })
}

- (NSArray<UIViewController *> *)hz_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    PREV_NC_CHECK_EXE(!, {
        return [self hz_popToViewController:viewController animated:animated completion:nil];
    } else {
        return [self hz_popToViewController:viewController animated:animated];
    })
}

- (NSArray<UIViewController *> *)hz_popToRootViewControllerAnimated:(BOOL)animated {
    PREV_NC_CHECK_EXE(!, {
        return [self hz_popToRootViewControllerAnimated:animated completion:nil];
    } else {
        return [self hz_popToRootViewControllerAnimated:animated];
    })
}

- (void)hz_setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
#if 0
    BOOL push = NO;
    UIViewController *fromVC = nil;
    PREV_NC_CHECK_EXE(!, {
        push = viewControllers.count >= self.viewControllers.count;
        self.hz_itn_isSetViewControllersToRootVC = viewControllers.count == 1;
        fromVC = self.viewControllers.count ? self.viewControllers.lastObject : nil;
    });
    [self hz_setViewControllers:viewControllers];
    PREV_NC_CHECK_EXE(!, {
        itn_afterPushPopForNavigationController(self, fromVC, push, NO);
    });
#else
    PREV_NC_CHECK_EXE(!, {
        [self hz_setViewControllers:viewControllers completion:nil];
    } else {
        [self hz_setViewControllers:viewControllers];
    })
#endif
}

- (void)hz_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
#if 0
    BOOL push = NO;
    UIViewController *fromVC = nil;
    PREV_NC_CHECK_EXE(!, {
        push = viewControllers.count >= self.viewControllers.count;
        self.hz_itn_isSetViewControllersToRootVC = viewControllers.count == 1;
        fromVC = self.viewControllers.count ? self.viewControllers.lastObject : nil;
    });
    [self hz_setViewControllers:viewControllers animated:animated];
    
    PREV_NC_CHECK_EXE(!, {
        itn_afterPushPopForNavigationController(self, fromVC, push, animated);
    });
#else
    PREV_NC_CHECK_EXE(!, {
        [self hz_setViewControllers:viewControllers animated:animated completion:nil];
    } else {
        [self hz_setViewControllers:viewControllers animated:animated];
    })
#endif
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
#if 0
    [self pushViewController:viewController animated:animated];
#else
    UIViewController *fromVC = nil;
    PREV_NC_CHECK_EXE(!, {
        self.hz_itn_isSetViewControllersToRootVC = self.viewControllers.count == 0;
        fromVC = self.viewControllers.count ? self.viewControllers.lastObject : nil;
        itn_pushViewController(self, viewController, animated);
    });
    [self hz_pushViewController:viewController animated:animated];
    PREV_NC_CHECK_EXE(!, {
        itn_afterPushPopForNavigationController(self, fromVC, YES, animated);
    });
#endif
}

-(void)hz_setViewControllers:(NSArray<UIViewController *> *)viewControllers
                   completion:(YZHNavigationControllerAnimationCompletionBlock)completion {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self setViewControllers:viewControllers completion:completion];
        return;
    }
    PREV_NC_CHECK();
    itn_pushViewControllerCompletion(self, viewControllers.lastObject, completion);
#if 0
    self.viewControllers = viewControllers;
#else
    BOOL push = NO;
    UIViewController *fromVC = nil;
    PREV_NC_CHECK_EXE(!, {
        push = viewControllers.count >= self.viewControllers.count;
        self.hz_itn_isSetViewControllersToRootVC = viewControllers.count == 1;
        fromVC = self.viewControllers.count ? self.viewControllers.lastObject : nil;
    });
    [self hz_setViewControllers:viewControllers];
    PREV_NC_CHECK_EXE(!, {
        itn_afterPushPopForNavigationController(self, fromVC, push, NO);
    });
#endif
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
#if 0
    [self setViewControllers:viewControllers animated:animated];
#else
    BOOL push = NO;
    UIViewController *fromVC = nil;
    PREV_NC_CHECK_EXE(!, {
        push = viewControllers.count >= self.viewControllers.count;
        self.hz_itn_isSetViewControllersToRootVC = viewControllers.count == 1;
        fromVC = self.viewControllers.count ? self.viewControllers.lastObject : nil;
    });
    [self hz_setViewControllers:viewControllers animated:animated];
    
    PREV_NC_CHECK_EXE(!, {
        itn_afterPushPopForNavigationController(self, fromVC, push, animated);
    });
#endif
}

- (UIViewController *)hz_popViewControllerAnimated:(BOOL)animated completion:(YZHNavigationControllerAnimationCompletionBlock)completion
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return [(YZHNavigationController*)self popViewControllerAnimated:animated completion:completion];
    }
    PREV_NC_CHECK(nil);

    itn_popViewControllerCompletion(self, completion);
    UIViewController *vc = [self hz_popViewControllerAnimated:animated];
    itn_afterPushPopForNavigationController(self, vc, NO, animated);
    return vc;
}

- (NSArray *)hz_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(YZHNavigationControllerAnimationCompletionBlock)completion
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return [(YZHNavigationController*)self popToViewController:viewController animated:animated completion:completion];
    }
    PREV_NC_CHECK(nil);
    itn_popViewControllerCompletion(self, completion);
    NSArray *vcs = [self hz_popToViewController:viewController animated:animated];
    itn_afterPushPopForNavigationController(self, vcs.count ? vcs.lastObject : nil, NO, animated);
    return vcs;
}

- (NSArray *)hz_popToRootViewControllerAnimated:(BOOL)animated completion:(YZHNavigationControllerAnimationCompletionBlock)completion
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return [(YZHNavigationController*)self popToRootViewControllerAnimated:animated completion:completion];
    }
    PREV_NC_CHECK(nil);
    itn_popViewControllerCompletion(self, completion);
    NSArray *vcs = [self hz_popToRootViewControllerAnimated:animated];
    itn_afterPushPopForNavigationController(self, vcs.count ? vcs.lastObject : nil, NO, animated);
    return vcs;
}

@end
