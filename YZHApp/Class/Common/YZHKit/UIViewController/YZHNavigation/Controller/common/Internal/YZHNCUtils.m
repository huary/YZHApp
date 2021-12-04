//
//  YZHNCUtils.m
//  YZHApp
//
//  Created by bytedance on 2021/11/22.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "YZHNCUtils.h"
#import "UIViewController+YZHNavigation.h"
#import "UINavigationControllerDelegateImp.h"
#import "UINavigationController+YZHNavigation.h"
#import "UINavigationController+YZHNavigationItn.h"
#import "NSObject+YZHAddForKVO.h"
#import "NSObject+YZHAddForDealloc.h"
#import "YZHNavigationItnTypes.h"
#import "UIViewController+YZHNavigationControllerAnimation.h"

#import "NSMapTable+YZHAdd.h"


#define MIN_PERCENT_PUSH_VIEWCONTROLLER     (0.15)
#define MIN_PERCENT_POP_VIEWCONTROLLER      (0.2)

//清空原有的navigationBar
void _clearOldUINavigationBarView(UINavigationController *nc)
{
    [nc.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [nc.navigationBar setShadowImage:[UIImage new]];
}

//创建新的navigationBarView
void _createNavigationBarView(UINavigationController *nc, BOOL atTop)
{
    UINavigationController *self = nc;
    if (!IS_CUSTOM_GLOBAL_NAVIGATION_BAR_STYLE(self.hz_navigationBarAndItemStyle)) {
        return;
    }
    if (self.hz_itn_nc_navigationBarView == nil) {
        CGRect frame =  CGRectMake(SAFE_X, -STATUS_BAR_HEIGHT, SAFE_WIDTH, STATUS_NAV_BAR_HEIGHT);
        YZHNavigationBarView *barView = [[YZHNavigationBarView alloc] initWithFrame:frame];
        barView.style = YZHNavBarStyleNone;
        if (atTop) {
            [self.navigationBar addSubview:barView];
        }
        else {
            if (IS_AVAILABLE_NSSET_OBJ(self.navigationBar.subviews)) {
                UIView *first = [self.navigationBar.subviews firstObject];
                [first addSubview:barView];
            }
            else {
                [self.navigationBar addSubview:barView];
            }
        }
        self.hz_itn_nc_navigationBarView = barView;
    }
}

YZHNavigationItemView *_createNavigationItemRootView(UINavigationController *nc)
{
    if (!IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(nc.hz_navigationBarAndItemStyle)) {
        return nil;
    }
    _createNavigationBarView(nc, YES);
    if (nc.hz_itn_nc_navigationItemView == nil) {
        YZHNavigationBarView *barView = nc.hz_itn_nc_navigationBarView;
        YZHNavigationItemView *itemView = [[YZHNavigationItemView alloc] initWithFrame:barView.bounds];
        [barView addSubview:itemView];
        nc.hz_itn_nc_navigationItemView = itemView;
    }
    return nc.hz_itn_nc_navigationItemView;
}

#pragma mark UIGestureRecognizerDelegate
BOOL _gestureRecognizerShouldBegin(UINavigationController *nc, UIPanGestureRecognizer *panGestureRecognizer)
{
    if ([panGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [panGestureRecognizer velocityInView:nc.view];
        if (panGestureRecognizer == nc.hz_itn_pushPan) {
            UIViewController *topVC = nc.viewControllers.lastObject;
            if ([nc.hz_navDelegate respondsToSelector:@selector(navigationController:pushNextViewControllerForViewController:)]) {
                UIViewController *nextVC = [nc.hz_navDelegate navigationController:nc pushNextViewControllerForViewController:topVC];
                return nextVC != nil && velocity.x < 0;
            }
            return NO;
        }
        else
        {
            if (nc.hz_popGestureEnabled == NO) {
                return NO;
            }
            else {
                UIViewController *topVC = nc.viewControllers.lastObject;
                if (!topVC.hz_popGestureEnabled) {
                    return NO;
                }
            }
            return nc.viewControllers.count > 1 && velocity.x > 0;
        }
    }
    return YES;
}

void _doUpdateInteractiveTransitionToFinish(UINavigationController *nc, CGFloat fromPercent, NSTimeInterval duration)
{
    NSTimeInterval interval = 0.01;
    NSInteger stepCnt = (NSInteger)(duration/interval + 0.5);
    CGFloat stepPercent = 1 - fromPercent;
    if (stepCnt > 0) {
        stepPercent = stepPercent / stepCnt;
    }
    __block CGFloat percent = fromPercent;
    WEAK_NSOBJ(nc, weakSelf);
    YZHTimer *timer = [YZHTimer timerWithTimeInterval:interval repeat:YES fireBlock:^(YZHTimer *timer) {
        percent += stepPercent;
        percent = MIN(1.0, percent);
        [weakSelf.hz_itn_transition updateInteractiveTransition:percent];
        if (percent >= 1.0) {
            [weakSelf.hz_itn_transition finishInteractiveTransition];
            weakSelf.hz_itn_isInteractive = NO;
            
            [timer invalidate];
            weakSelf.hz_itn_updateTransitionTimer = nil;
        }
    }];
    
    [nc hz_addDeallocBlock:^(void * _Nonnull deallocTarget) {
        [timer invalidate];
    }];
    nc.hz_itn_updateTransitionTimer = timer;
}


void _handlePushAction(UINavigationController *nc, UIPanGestureRecognizer *sender)
{
    CGFloat tx = [sender translationInView:nc.view].x;
    CGFloat percent = tx / CGRectGetWidth(nc.view.frame);
    CGFloat vx = [sender velocityInView:nc.view].x;
    
    percent = - MIN(percent, 0);
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        nc.hz_itn_isInteractive = YES;
        if ([nc.hz_navDelegate respondsToSelector:@selector(navigationController:pushNextViewControllerForViewController:)]) {
            UIViewController *nextVC = [nc.hz_navDelegate navigationController:nc pushNextViewControllerForViewController:nc.viewControllers.lastObject];
            [nc pushViewController:nextVC animated:YES];
        }
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        [nc.hz_itn_transition updateInteractiveTransition:percent];
    }
    else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
    {
        if ([nc.hz_navDelegate respondsToSelector:@selector(navigationController:updateInteractiveTransition:forPanGesture:operation:completion:)]) {
            
            WEAK_NSOBJ(nc, weakSelf);
            [nc.hz_navDelegate navigationController:nc updateInteractiveTransition:nc.hz_itn_transition forPanGesture:sender operation:UINavigationControllerOperationPush completion:^(BOOL finish) {
                weakSelf.hz_itn_isInteractive = NO;
                if (finish) {
                    [weakSelf.hz_itn_transition updateInteractiveTransition:1.0];
                    [weakSelf.hz_itn_transition finishInteractiveTransition];
                }
                else {
                    [weakSelf.hz_itn_transition cancelInteractiveTransition];
                }
            }];
        }
        else {
            if (vx > 0 || tx >= 0 || percent < MIN_PERCENT_PUSH_VIEWCONTROLLER) {
                [nc.hz_itn_transition cancelInteractiveTransition];
                nc.hz_itn_isInteractive = NO;
            }else{
                /*调用updateInteractiveTransition:1.0再来调用finish在iOS9.3.5系统上不会出现有黑边（随机）的情况
                 *这样调用更为安全吧
                 */
//                [self.transition updateInteractiveTransition:1.0];
//                [self.transition finishInteractiveTransition];
                
                NSTimeInterval duration = nc.hz_itn_latestTransitionDuration;
                if ([nc.hz_navDelegate respondsToSelector:@selector(navigationController:doFinishInteractiveTransitionDurationForPercent:operation:)]) {
                    duration = [nc.hz_navDelegate navigationController:nc doFinishInteractiveTransitionDurationForPercent:percent operation:UINavigationControllerOperationPush];
                }
                _doUpdateInteractiveTransitionToFinish(nc, percent, duration);
            }
        }
    }
}

void _handlePopAction(UINavigationController *nc,UIPanGestureRecognizer *sender)
{
    CGFloat tx = [sender translationInView:nc.view].x;
    CGFloat percent = tx / CGRectGetWidth(nc.view.frame);
    CGFloat vx = [sender velocityInView:nc.view].x;
    
    percent = MAX(percent, 0);
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        nc.hz_itn_isInteractive = YES;
        [nc popViewControllerAnimated:YES];
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        [nc.hz_itn_transition updateInteractiveTransition:percent];
    }else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        if ([nc.hz_navDelegate respondsToSelector:@selector(navigationController:updateInteractiveTransition:forPanGesture:operation:completion:)]) {
            WEAK_NSOBJ(nc, weakSelf);
            [nc.hz_navDelegate navigationController:nc updateInteractiveTransition:nc.hz_itn_transition forPanGesture:sender operation:UINavigationControllerOperationPop completion:^(BOOL finish) {
                weakSelf.hz_itn_isInteractive = NO;
                if (finish) {
                    [weakSelf.hz_itn_transition updateInteractiveTransition:1.0];
                    [weakSelf.hz_itn_transition finishInteractiveTransition];
                }
                else {
                    [weakSelf.hz_itn_transition cancelInteractiveTransition];
                }
            }];
        }
        else {
            
            if (vx < 0 || percent < MIN_PERCENT_POP_VIEWCONTROLLER) {
                [nc.hz_itn_transition cancelInteractiveTransition];
                nc.hz_itn_isInteractive = NO;
                
            }else{
                NSTimeInterval duration = nc.hz_itn_latestTransitionDuration;
                if ([nc.hz_navDelegate respondsToSelector:@selector(navigationController:doFinishInteractiveTransitionDurationForPercent:operation:)]) {
                    duration = [nc.hz_navDelegate navigationController:nc doFinishInteractiveTransitionDurationForPercent:percent operation:UINavigationControllerOperationPop];
                }
                _doUpdateInteractiveTransitionToFinish(nc, percent, duration);
            }
        }
        
    }
}

void _createPanGestureAction(UINavigationController *nc)
{
    nc.hz_itn_isInteractive = NO;
    
    WEAK_NSOBJ(nc, weakSelf);
    UIPanGestureRecognizer *pushPan = [nc.view hz_addPanGestureRecognizerBlock:^(UIGestureRecognizer *gesture) {
        _handlePushAction(weakSelf, (UIPanGestureRecognizer *)gesture);
    } shouldBeginBlock:^BOOL(UIGestureRecognizer *gesture) {
        return _gestureRecognizerShouldBegin(weakSelf, (UIPanGestureRecognizer *)gesture);
    }];
    pushPan.cancelsTouchesInView = NO;
    nc.hz_itn_pushPan = pushPan;
    
    UIPanGestureRecognizer *popPan = [nc.view hz_addPanGestureRecognizerBlock:^(UIGestureRecognizer *gesture) {
        _handlePopAction(weakSelf, (UIPanGestureRecognizer *)gesture);
    } shouldBeginBlock:^BOOL(UIGestureRecognizer *gesture) {
        return _gestureRecognizerShouldBegin(weakSelf, (UIPanGestureRecognizer*)gesture);
    }];
    popPan.cancelsTouchesInView = NO;
    nc.hz_itn_popPan = popPan;

    UINavigationControllerDelegateImp *delegate = [UINavigationControllerDelegateImp delegateWithTarget:nc];
    nc.delegate = delegate;
    [nc hz_addStrongReferenceObject:delegate forKey:@"UINavigationControllerDelegate.imp"];
}

void _addObserverNavigationBar(UINavigationController *nc, BOOL add)
{
    WEAK_NSOBJ(nc, weakSelf);
    YZHNavigationBarAndItemStyle style = nc.hz_navigationBarAndItemStyle;
    YZHKVOObserverBlock block = ^(id target, NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey,id> *change, void *context) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if ([keyPath isEqualToString:@"center"]) {
            CGPoint center = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
            if (center.y > 0) {
                if (style == YZHNavigationBarAndItemStyleVCBarItem) {
                    weakSelf.navigationBar.hidden = YES;
                }
                else if (style == YZHNavigationBarAndItemStyleVCBarDefaultItem) {
                }
            }
            [userInfo setObject:[NSValue valueWithCGPoint:center] forKey:YZHNavigationBarCenterPointKey];
        }
        else if ([keyPath isEqualToString:@"bounds"]) {
            CGRect bounds = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            [userInfo setObject:[NSValue valueWithCGRect:bounds] forKey:YZHNavigationBarBoundsKey];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:YZHNavigationBarAttributeChangedNotification object:nil userInfo:userInfo];
    };
    UINavigationBar *navBar = nc.navigationBar;
    [navBar hz_addKVOForKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil block:block];
    [navBar hz_addKVOForKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil block:block];
    [navBar hz_addKVOForKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil block:block];
    [navBar hz_addKVOForKeyPath:@"transform" options:NSKeyValueObservingOptionNew context:nil block:block];

    [nc hz_addDeallocBlock:^(void * _Nonnull deallocTarget) {        
        [navBar hz_removeKVOObserverBlockForKeyPath:@"frame"];
        [navBar hz_removeKVOObserverBlockForKeyPath:@"center"];
        [navBar hz_removeKVOObserverBlockForKeyPath:@"bounds"];
        [navBar hz_removeKVOObserverBlockForKeyPath:@"transform"];
    }];
}

void _removeNavigationItemView(UINavigationController *nc,YZHNavigationItemView *navigationItemView)
{
    if (navigationItemView == nil) {
        return;
    }
    __block id findKey = nil;
    [nc.hz_itn_navigationItemViewWithVCMap hz_enumerateKeysAndObjectsUsingBlock:^(id key, YZHNavigationItemView *itemView, BOOL *stop) {
        if (itemView == navigationItemView) {
            findKey = key;
            *stop = YES;
        }
    }];
    [nc.hz_itn_navigationItemViewWithVCMap removeObjectForKey:findKey];
    [navigationItemView removeFromSuperview];
}

void _doCheckNavigationItemView(UINavigationController *nc)
{
    NSMutableDictionary *outMutDict = [nc.hz_itn_navigationItemViewWithVCMap dictionaryRepresentation].mutableCopy;
    [nc.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = itn_getKeyFromVC(obj);
        if ([outMutDict objectForKey:key]) {
            [outMutDict removeObjectForKey:key];
        }
    }];
    [outMutDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, YZHNavigationItemView * _Nonnull obj, BOOL * _Nonnull stop) {
        _removeNavigationItemView(nc, obj);
    }];
}

void itn_nc_viewDidLoad(UINavigationController *nc) {
    YZHNavigationBarAndItemStyle style = nc.hz_navigationBarAndItemStyle;
    if (style == YZHNavigationBarAndItemStyleDefault)
    {
    }
    else if (style == YZHNavigationBarAndItemStyleGlobalBarDefaultItem)
    {
        _clearOldUINavigationBarView(nc);
        
        _createNavigationBarView(nc, NO);
    }
    else if (style == YZHNavigationBarAndItemStyleGlobalBarItem)
    {
        _clearOldUINavigationBarView(nc);
        nc.navigationItem.titleView = [[UIView alloc] init];
        _createNavigationItemRootView(nc);
    }
    else if (style == YZHNavigationBarAndItemStyleVCBarItem)
    {
        nc.navigationBar.hidden = YES;
    }
    else if (style == YZHNavigationBarAndItemStyleVCBarDefaultItem)
    {
        _clearOldUINavigationBarView(nc);
    }
    
    _createPanGestureAction(nc);
    
    _addObserverNavigationBar(nc, YES);
}

void itn_nc_viewWillLayoutSubviews(UINavigationController *nc) {
    if (nc.hz_navigationBarAndItemStyle == YZHNavigationBarAndItemStyleGlobalBarDefaultItem) {
        [nc.navigationBar.subviews.firstObject addSubview:nc.hz_itn_nc_navigationBarView];
    }
}

void itn_resetNavigationBarAndItemViewFrame(UINavigationController *nc, CGRect frame) {
    YZHNavigationBarView *barView = nc.hz_itn_nc_navigationBarView;
    if (barView) {
        barView.frame = frame;
    }
    YZHNavigationItemView *itemView = nc.hz_itn_nc_navigationItemView;
    if (itemView) {
        itemView.frame = barView.bounds;
    }
    [nc.hz_itn_navigationItemViewWithVCMap hz_enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YZHNavigationItemView * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.frame = itemView.bounds;
    }];
}

#pragma mark override
void itn_pushViewController(UINavigationController *nc, UIViewController *viewController, BOOL animated)
{
    if (!animated) {
        UIViewController *fromVC = nc.topViewController;
        itn_setNavigationItemViewAlphaMinToHiddenForVC(nc, 0, YES, fromVC);
    }
}

//自定义
void itn_pushViewControllerCompletion(UINavigationController *nc, UIViewController *vc, YZHNavigationControllerAnimationCompletionBlock completion)
{
    nc.hz_itn_lastTopVC = vc;
    vc.itn_pushCompletionBlock = completion;
}

void itn_popViewControllerCompletion(UINavigationController *nc, YZHNavigationControllerAnimationCompletionBlock completion) {
    UIViewController *topVC = nc.topViewController;
    nc.hz_itn_lastTopVC = topVC;
    topVC.itn_popCompletionBlock = completion;
}

//void itn_popToViewController(UINavigationController *nc, UIViewController *vc, YZHNavigationControllerAnimationCompletionBlock completion) {
//    UIViewController *topVC = nc.topViewController;
//    nc.hz_itn_lastTopVC = topVC;
//    topVC.itn_popCompletionBlock = completion;
//}
//
//void itn_popToRootViewController(UINavigationController *nc, YZHNavigationControllerAnimationCompletionBlock completion) {
//    UIViewController *topVC = nc.topViewController;
//    nc.hz_itn_lastTopVC = topVC;
//    topVC.itn_popCompletionBlock = completion;
//}



id itn_getKeyFromVC(UIViewController *vc) {
    return @((uintptr_t)vc);
//    return [[NSString alloc] initWithFormat:@"%@",@([vc hash])];
}

//在viewController初始化的时候调用，此函数仅仅是创建了一个NavigationItemView，在push的时候添加
void itn_createNewNavigationItemViewForViewController(UINavigationController *nc, UIViewController *vc) {
    if (!vc) {
        return;
    }
    
    YZHNavigationBarAndItemStyle style = nc.hz_navigationBarAndItemStyle;
    if (!IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(style)) {
        return;
    }
    
    id key = itn_getKeyFromVC(vc);
    NSMapTable *mapTable = nc.hz_itn_navigationItemViewWithVCMap;
    YZHNavigationItemView *navigationItemView = [mapTable objectForKey:key];
    if (navigationItemView == nil) {
        
        navigationItemView = [[YZHNavigationItemView alloc] initWithFrame:nc.hz_itn_nc_navigationItemView.bounds];
        
        [mapTable setObject:navigationItemView forKey:key];

        itn_addNewNavigationItemViewForViewController(nc, vc);
    }
}

void itn_addNewNavigationItemViewForViewController(UINavigationController *nc, UIViewController *vc) {
    
    _doCheckNavigationItemView(nc);
    
    id key = itn_getKeyFromVC(vc);
    
    YZHNavigationItemView *navigationItemView = [nc.hz_itn_navigationItemViewWithVCMap objectForKey:key];
    
    if (navigationItemView) {
        YZHNavigationItemView *rootItemView = nc.hz_itn_nc_navigationItemView;
        navigationItemView.frame = rootItemView.bounds;
        [navigationItemView removeFromSuperview];
        [rootItemView addSubview:navigationItemView];
    }
}

void itn_removeNavigationItemViewForViewController(UINavigationController *nc, UIViewController *vc) {
    if (vc == nil) {
        return;
    }
    id key = itn_getKeyFromVC(vc);
    YZHNavigationItemView *navigationItemView = [nc.hz_itn_navigationItemViewWithVCMap objectForKey:key];
    if (navigationItemView == nil) {
        return;
    }
    _removeNavigationItemView(nc, navigationItemView);
    
    _doCheckNavigationItemView(nc);
}

void itn_nc_setNavigationBarViewBackgroundColor(UINavigationController *nc, UIColor *navigationBarViewBackgroundColor)
{
    YZHNavigationBarView *barView = nc.hz_itn_nc_navigationBarView;
    if (barView != nil) {
        barView.backgroundColor = navigationBarViewBackgroundColor;
    }
    else {
        nc.navigationBar.barTintColor = navigationBarViewBackgroundColor;
    }
}

void itn_nc_setNavigationBarBottomLineColor(UINavigationController *nc,UIColor *navigationBarBottomLineColor)
{
    YZHNavigationBarView *barView = nc.hz_itn_nc_navigationBarView;
    if (barView != nil) {
        barView.bottomLine.backgroundColor = navigationBarBottomLineColor;
    }
    else {
        if (navigationBarBottomLineColor) {
            UIImage *image = [[UIImage new] hz_createImageWithSize:CGSizeMake(nc.navigationBar.bounds.size.width, SINGLE_LINE_WIDTH) tintColor:navigationBarBottomLineColor];
            [nc.navigationBar setShadowImage:image];
        }
        else {
            [nc.navigationBar setShadowImage:nil];
        }
    }
}

void itn_nc_setNavigationBarViewAlpha(UINavigationController *nc, CGFloat navigationBarViewAlpha)
{
    YZHNavigationBarView *barView = nc.hz_itn_nc_navigationBarView;
    if (barView != nil) {
        barView.alpha = navigationBarViewAlpha;
        barView.hidden = navigationBarViewAlpha <= minAlphaToHidden_s ? YES : NO;
    }
    else
    {
        nc.navigationBar.alpha = navigationBarViewAlpha;
        nc.navigationBar.hidden = navigationBarViewAlpha <= minAlphaToHidden_s ? YES : NO;
    }
}

void itn_nc_setNavBarStyle(UINavigationController *nc, YZHNavBarStyle navBarStyle)
{
    nc.hz_itn_nc_navigationBarView.style = navBarStyle;
}

//设置NavigationItemView相关
void itn_setNavigationItemViewAlphaMinToHiddenForVC(UINavigationController *nc,CGFloat alpha, BOOL minToHidden, UIViewController *vc)
{
    id key = itn_getKeyFromVC(vc);
    YZHNavigationItemView *navigationItemView = [nc.hz_itn_navigationItemViewWithVCMap objectForKey:key];
    if (navigationItemView) {
        navigationItemView.alpha = alpha;
        if (minToHidden) {
            navigationItemView.hidden = alpha <= minAlphaToHidden_s ? YES : NO;
        }
    }
}

void itn_setNavigationItemViewTransformForVC(UINavigationController *nc, CGAffineTransform transform, UIViewController *vc)
{
    id key = itn_getKeyFromVC(vc);
    YZHNavigationItemView *navigationItemView = [nc.hz_itn_navigationItemViewWithVCMap objectForKey:key];
    if (navigationItemView) {
        navigationItemView.t = transform;
    }
}

void itn_setNavigationItemTitleForVC(UINavigationController *nc, NSString *title, UIViewController *vc)
{
    YZHNavigationBarAndItemStyle style = nc.hz_navigationBarAndItemStyle;
    if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(style)) {
        id key = itn_getKeyFromVC(vc);
        YZHNavigationItemView *navigationItemView = [nc.hz_itn_navigationItemViewWithVCMap objectForKey:key];
        [navigationItemView setTitle:title];
    }
    else
    {
        nc.navigationItem.title = title;
    }
}

void itn_setNavigationItemTitleTextAttributesForVC(UINavigationController *nc, NSDictionary<NSAttributedStringKey, id> *textAttributes, UIViewController *vc)
{
    YZHNavigationBarAndItemStyle style = nc.hz_navigationBarAndItemStyle;
    if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(style)) {
        id key = itn_getKeyFromVC(vc);
        YZHNavigationItemView *navigationItemView = [nc.hz_itn_navigationItemViewWithVCMap objectForKey:key];
        navigationItemView.titleTextAttributes = textAttributes;
    }
}

void itn_addNavigationItemViewLeftButtonItemsIsResetForVC(UINavigationController *nc, NSArray *leftButtonItems, BOOL reset, UIViewController *vc)
{
    YZHNavigationBarAndItemStyle style = nc.hz_navigationBarAndItemStyle;
    if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(style)) {
        id key = itn_getKeyFromVC(vc);
        YZHNavigationItemView *navigationItemView = [nc.hz_itn_navigationItemViewWithVCMap objectForKey:key];
        [navigationItemView setLeftButtonItems:leftButtonItems isReset:reset];
    }
    else if (IS_SYSTEM_DEFAULT_NAVIGATION_ITEM_STYLE(style))
    {
        nc.navigationItem.leftBarButtonItems = leftButtonItems;
    }
}

void itn_addNavigationItemViewRightButtonItemsIsResetForVC(UINavigationController *nc, NSArray *rightButtonItems, BOOL reset, UIViewController *vc)
{
    YZHNavigationBarAndItemStyle style = nc.hz_navigationBarAndItemStyle;
    if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(style)) {
        id key = itn_getKeyFromVC(vc);
        YZHNavigationItemView *navigationItemView = [nc.hz_itn_navigationItemViewWithVCMap objectForKey:key];
        [navigationItemView setRightButtonItems:rightButtonItems isReset:reset];
    }
    else if (IS_SYSTEM_DEFAULT_NAVIGATION_ITEM_STYLE(style))
    {
        nc.navigationItem.rightBarButtonItems = rightButtonItems;
    }
}

void itn_nc_setupItemsSpace(UINavigationController *nc, CGFloat itemsSpace, BOOL left, UIViewController *vc) {
    YZHNavigationBarAndItemStyle style = nc.hz_navigationBarAndItemStyle;
    if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(style)) {
        id key = itn_getKeyFromVC(vc);
        YZHNavigationItemView *navigationItemView = [nc.hz_itn_navigationItemViewWithVCMap objectForKey:key];
        if (left) {
            navigationItemView.leftItemsSpace = itemsSpace;
        }
        else {
            navigationItemView.rightItemsSpace = itemsSpace;
        }
    }
}

void itn_nc_setupItemEdgeSpace(UINavigationController *nc, CGFloat edgeSpace, BOOL left, UIViewController *vc) {
    YZHNavigationBarAndItemStyle style = nc.hz_navigationBarAndItemStyle;
    if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(style)) {
        id key = itn_getKeyFromVC(vc);
        YZHNavigationItemView *navigationItemView = [nc.hz_itn_navigationItemViewWithVCMap objectForKey:key];
        if (left) {
            navigationItemView.leftEdgeSpace = edgeSpace;
        }
        else {
            navigationItemView.rightEdgeSpace = edgeSpace;
        }
    }
}

void itn_nc_addNavigationBarCustomView(UINavigationController *nc, UIView *customView)
{
    if (!customView) {
        return;
    }
    YZHNavigationBarAndItemStyle style = nc.hz_navigationBarAndItemStyle;
    if (IS_CUSTOM_GLOBAL_NAVIGATION_BAR_STYLE(style)) {
        [nc.hz_itn_nc_navigationBarView addSubview:customView];
    }
}

UIView * itn_nc_navigationBar(UINavigationController *nc)
{
    if (IS_CUSTOM_GLOBAL_NAVIGATION_BAR_STYLE(nc.hz_navigationBarAndItemStyle)) {
        return nc.hz_itn_nc_navigationBarView;
    }
    return nc.navigationBar;
}

CGFloat itn_nc_navigationBarTopLayout(UINavigationController *nc)
{
    if (IS_CUSTOM_GLOBAL_NAVIGATION_BAR_STYLE(nc.hz_navigationBarAndItemStyle)) {
        return STATUS_BAR_HEIGHT;
    }
    return 0;
}

//YZHNavigationItemView *itemViewForVC(UINavigationController *nc, UIViewController *vc) {
//
//    [nc.hz_itn_navigationItemViewWithVCMap hz_enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        NSLog(@"key=%@,obj=%@",key,obj);
//    }];
//
//    id key = itn_getKeyFromVC(vc);
//    return [nc.hz_itn_navigationItemViewWithVCMap objectForKey:key];
//}
