//
//  UINavigationController+YZHNavigationItn.m
//  YZHApp
//
//  Created by bytedance on 2021/11/22.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "UINavigationController+YZHNavigationItn.h"
#import "UINavigationController+YZHNavigation.h"
#import "YZHNavigationItnTypes.h"
#import "YZHNavigationController+Internal.h"
#import "YZHNCUtils.h"

@implementation UINavigationController (YZHNavigationItn)

#pragma mark private
ITN_SET_PROPERTY(YZHNavigationBarView *, hz_itn_nc_navigationBarView, Hz_itn_nc_navigationBarView, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).navigationBarView = hz_itn_nc_navigationBarView;
        return;
    }
});
ITN_GET_PROPERTY(YZHNavigationBarView *, hz_itn_nc_navigationBarView, nil, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).navigationBarView;
    }
});

//创建新的NavigationItem，此Item为rootItem，以后每个ViewController上的Item都是以此为根节点
//@property (nonatomic, strong) YZHNavigationItemView *hz_navigationItemRootView;
ITN_SET_PROPERTY(YZHNavigationItemView *, hz_itn_nc_navigationItemView, Hz_itn_nc_navigationItemView, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).navigationItemView = hz_itn_nc_navigationItemView;
        return;
    }
});
ITN_GET_PROPERTY(YZHNavigationItemView *, hz_itn_nc_navigationItemView, nil, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).navigationItemView;
    }
});

ITN_SET_PROPERTY(NSMapTable *, hz_itn_navigationItemViewWithVCMap, Hz_itn_navigationItemViewWithVCMap);
ITN_GET_PROPERTY(NSMapTable *, hz_itn_navigationItemViewWithVCMap, nil, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        if (!((YZHNavigationController*)self).navigationItemViewWithVCMap) {
            ((YZHNavigationController*)self).navigationItemViewWithVCMap = [NSMapTable strongToWeakObjectsMapTable];
        }
        return ((YZHNavigationController*)self).navigationItemViewWithVCMap;
    }
    if (!self.hz_navigationEnable) return nil;
    NSMapTable *t = [self hz_strongReferenceObjectForKey:@"hz_navigationItemViewWithVCMap"];
    if (!t) {
        t = [NSMapTable strongToWeakObjectsMapTable];
        [self hz_addStrongReferenceObject:t forKey:@"hz_navigationItemViewWithVCMap"];
    }
    return t;
})

ITN_SET_PROPERTY(UIPercentDrivenInteractiveTransition *, hz_itn_transition, Hz_itn_transition);
ITN_GET_PROPERTY(UIPercentDrivenInteractiveTransition *, hz_itn_transition, nil, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        if (!((YZHNavigationController*)self).transition) {
            ((YZHNavigationController*)self).transition = [UIPercentDrivenInteractiveTransition new];
        }
        return ((YZHNavigationController*)self).transition;
    }
    if (!self.hz_navigationEnable) return nil;
    UIPercentDrivenInteractiveTransition *t = [self hz_strongReferenceObjectForKey:@"hz_transition"];
    if (!t) {
        t = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self hz_addStrongReferenceObject:t forKey:@"hz_transition"];
    }
    return t;
});


ITN_SET_PROPERTY_C(BOOL, hz_itn_isInteractive, Hz_itn_isInteractive, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).isInteractive = hz_itn_isInteractive;
        return;
    }
});
ITN_GET_PROPERTY_C(BOOL, hz_itn_isInteractive, boolValue, NO, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).isInteractive;
    }
});


ITN_SET_PROPERTY(UIPanGestureRecognizer *, hz_itn_pushPan, Hz_itn_pushPan, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).pushPan = hz_itn_pushPan;
        return;
    }
});
ITN_GET_PROPERTY(UIPanGestureRecognizer *, hz_itn_pushPan, nil, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).pushPan;
    }
});

ITN_SET_PROPERTY(UIPanGestureRecognizer *, hz_itn_popPan, Hz_itn_popPan, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).popPan = hz_itn_popPan;
        return;
    }
});
ITN_GET_PROPERTY(UIPanGestureRecognizer *, hz_itn_popPan, nil, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).popPan;
    }
});


ITN_SET_PROPERTY(UIViewController *, hz_itn_lastTopVC, Hz_itn_lastTopVC, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).lastTopVC = hz_itn_lastTopVC;
        return;
    }
});
ITN_GET_PROPERTY(UIViewController *, hz_itn_lastTopVC, nil, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).lastTopVC;
    }
});

ITN_SET_PROPERTY_C(NSTimeInterval, hz_itn_latestTransitionDuration, Hz_itn_latestTransitionDuration, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).latestTransitionDuration = hz_itn_latestTransitionDuration;
        return;
    }
});
ITN_GET_PROPERTY_C(NSTimeInterval, hz_itn_latestTransitionDuration, doubleValue, 0, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).latestTransitionDuration;
    }
});

ITN_SET_PROPERTY(YZHTimer *, hz_itn_updateTransitionTimer, Hz_itn_updateTransitionTimer, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        ((YZHNavigationController*)self).updateTransitionTimer = hz_itn_updateTransitionTimer;
        return;
    }
});
ITN_GET_PROPERTY(YZHTimer *, hz_itn_updateTransitionTimer, nil, {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return ((YZHNavigationController*)self).updateTransitionTimer;
    }
});


//在viewController初始化的时候调用，此函数仅仅是创建了一个NavigationItemView，在push的时候添加
-(void)hz_itn_createNewNavigationItemViewForViewController:(UIViewController*)viewController
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_createNewNavigationItemViewForViewController:viewController];
        return;
    }
    PREV_NC_CHECK();
    itn_createNewNavigationItemViewForViewController(self, viewController);
}

-(void)hz_itn_addNewNavigationItemViewForViewController:(UIViewController*)viewController
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_addNewNavigationItemViewForViewController:viewController];
        return;
    }
    PREV_NC_CHECK();
    itn_addNewNavigationItemViewForViewController(self, viewController);
}

//在viewController pop完成的时候调用，
-(void)hz_itn_removeNavigationItemViewForViewController:(UIViewController*)viewController
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_removeNavigationItemViewForViewController:viewController];
        return;
    }
    PREV_NC_CHECK();
    itn_removeNavigationItemViewForViewController(self, viewController);
}

//设置NavigationItemView相关
-(void)hz_itn_setNavigationItemViewAlpha:(CGFloat)alpha minToHidden:(BOOL)minToHidden forViewController:(UIViewController*)viewController
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_setNavigationItemViewAlpha:alpha minToHidden:minToHidden forViewController:viewController];
        return;
    }
    PREV_NC_CHECK();
    itn_setNavigationItemViewAlphaMinToHiddenForVC(self, alpha, minToHidden, viewController);
}

-(void)hz_itn_setNavigationItemViewTransform:(CGAffineTransform)transform forViewController:(UIViewController*)viewController
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_setNavigationItemViewTransform:transform forViewController:viewController];
        return;
    }
    PREV_NC_CHECK();
    itn_setNavigationItemViewTransformForVC(self, transform, viewController);
}

-(void)hz_itn_setNavigationItemTitle:(NSString*)title forViewController:(UIViewController*)viewController
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_setNavigationItemTitle:title forViewController:viewController];
        return;
    }
    PREV_NC_CHECK();
    itn_setNavigationItemTitleForVC(self, title, viewController);
}

-(void)hz_itn_setNavigationItemTitleTextAttributes:(NSDictionary<NSAttributedStringKey, id>*)textAttributes forViewController:(UIViewController*)viewController
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_setNavigationItemTitleTextAttributes:textAttributes forViewController:viewController];
        return;
    }
    PREV_NC_CHECK();
    itn_setNavigationItemTitleTextAttributesForVC(self, textAttributes, viewController);
}

-(void)hz_itn_addNavigationItemViewLeftButtonItems:(NSArray*)leftButtonItems isReset:(BOOL)reset forViewController:(UIViewController *)viewController
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_addNavigationItemViewLeftButtonItems:leftButtonItems isReset:reset forViewController:viewController];
        return;
    }
    PREV_NC_CHECK();
    itn_addNavigationItemViewLeftButtonItemsIsResetForVC(self, leftButtonItems, reset, viewController);
}

-(void)hz_itn_addNavigationItemViewRightButtonItems:(NSArray*)rightButtonItems isReset:(BOOL)reset forViewController:(UIViewController *)viewController
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_addNavigationItemViewRightButtonItems:rightButtonItems isReset:reset forViewController:viewController];
        return;
    }
    PREV_NC_CHECK();
    itn_addNavigationItemViewRightButtonItemsIsResetForVC(self, rightButtonItems, reset, viewController);
}

-(void)hz_itn_setupItemsSpace:(CGFloat)itemsSpace left:(BOOL)left forViewController:(UIViewController *)viewController {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_setupItemsSpace:itemsSpace left:left forViewController:viewController];
        return;
    }
    PREV_NC_CHECK();
    itn_nc_setupItemsSpace(self, itemsSpace, left, viewController);
}

-(void)hz_itn_setupItemEdgeSpace:(CGFloat)edgeSpace left:(BOOL)left forViewController:(UIViewController *)viewController {
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_setupItemEdgeSpace:edgeSpace left:left forViewController:viewController];
        return;
    }
    PREV_NC_CHECK();
    itn_nc_setupItemEdgeSpace(self, edgeSpace, left, viewController);
}

-(void)hz_itn_addNavigationBarCustomView:(UIView*)customView
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        [(YZHNavigationController*)self itn_addNavigationBarCustomView:customView];
        return;
    }
    PREV_NC_CHECK();
    itn_nc_addNavigationBarCustomView(self, customView);
}

- (UIView *)hz_itn_navigationBar
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return [(YZHNavigationController*)self itn_navigationBar];
    }
    PREV_NC_CHECK(nil);
    return itn_nc_navigationBar(self);
}

- (CGFloat)hz_itn_navigationBarTopLayout
{
    if ([self isKindOfClass:[YZHNavigationController class]]) {
        return [(YZHNavigationController*)self itn_navigationBarTopLayout];
    }
    PREV_NC_CHECK(0);
    return itn_nc_navigationBarTopLayout(self);
}


@end
