//
//  YZHDefaultAnimatedTransition.m
//  BaseDefaultUINavigationController
//
//  Created by yuan on 16/11/10.
//  Copyright © 2016年 yzh. All rights reserved.
//

#import "YZHDefaultAnimatedTransition.h"
//#import "UIViewController+NavigationBarAndItemView.h"
#import "UIViewController+YZHNavigation.h"
#import "UITabBarController+YZHTabBarView.h"

#import "UINavigationController+YZHNavigation.h"
#import "UINavigationController+YZHNavigationItn.h"

/**************************************************************************
 *UITabBarController (UITabBarTransitionView)
 **************************************************************************/
@interface UITabBarController (TabBarTransitionView)

/** tabBarTransitionView,主要用于NavigationController上进行交互使用的，不要使用此属性 */
@property (nonatomic, strong) UIView *hz_itn_tabBarTransitionView;

@end

@implementation UITabBarController (TabBarTransitionView)

- (void)setHz_itn_tabBarTransitionView:(UIView *)hz_itn_tabBarTransitionView {
    [self hz_addStrongReferenceObject:hz_itn_tabBarTransitionView forKey:@"hz_itn_tabBarTransitionView"];
}

- (UIView *)hz_itn_tabBarTransitionView {
    return [self hz_strongReferenceObjectForKey:@"hz_itn_tabBarTransitionView"];
}

-(UIView*)createTabBarTransitionView
{
    BOOL hidden = self.tabBar.hidden;
    self.tabBar.hidden = NO;
    
    UIView *transitionView = [self.tabBar hz_snapshotImageView];
    CALayer *lineLayer = [[CALayer alloc] init];
    lineLayer.frame = CGRectMake(0, -SINGLE_LINE_WIDTH, transitionView.bounds.size.width, SINGLE_LINE_WIDTH);
    lineLayer.backgroundColor = RGBA_F(0, 0, 0, 0.3).CGColor;
    [transitionView.layer addSublayer:lineLayer];
    
    self.tabBar.hidden = hidden;
    return transitionView;
}

@end


/**************************************************************************
 *YZHDefaultAnimatedTransition
 **************************************************************************/
@implementation YZHDefaultAnimatedTransition

-(void)printView:(UIView*)view withIndex:(NSInteger)index
{
    NSString *format = @"";
    for (int i = 0; i < index; ++i) {
        format = [NSString stringWithFormat:@"%@-",format];
    }
    NSLog(@"%@view=%@",format,view);
    for (UIView *subView in view.subviews) {
        [self printView:subView withIndex:index+1];
    }
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.transitionDuration;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    CGFloat duration = [self transitionDuration:transitionContext];
    
    CGFloat toViewTransitionX = CGRectGetWidth(containerView.bounds);
    CGFloat fromViewTransitionX = toViewTransitionX/2;
    
    UIColor *fromColor = [fromVC hz_navigationBarViewBackgroundColor];
    UIColor *toColor = [toVC hz_navigationBarViewBackgroundColor];
    
    CGFloat fromAlpha = [fromVC hz_navigationItemViewAlpha];
    CGFloat toAlpha = [toVC hz_navigationItemViewAlpha];
    
    UIColor *shadowColor = BLACK_COLOR;
    CGSize shadowOffset = CGSizeMake(-3, 0);
    CGFloat shadowOpacity = 0.3;
    CGFloat shadowRadius = 3;
    
    [containerView addSubview:toVC.view];
    if (self.operation == UINavigationControllerOperationPush) {
        
        CGColorRef shadowColor_f = toVC.view.layer.shadowColor;
        CGSize shadowOffset_f = toVC.view.layer.shadowOffset;
        CGFloat shadowOpacity_f = toVC.view.layer.shadowOpacity;
        CGFloat shadowRadius_f = toVC.view.layer.shadowRadius;
        void (^shadowRestoreBlock)(void) = ^{
            toVC.view.layer.shadowColor = shadowColor_f;
            toVC.view.layer.shadowOffset = shadowOffset_f;
            toVC.view.layer.shadowOpacity = shadowOpacity_f;
            toVC.view.layer.shadowRadius = shadowRadius_f;
        };
        
        toVC.view.layer.shadowColor = shadowColor.CGColor;
        toVC.view.layer.shadowOffset = shadowOffset;
        toVC.view.layer.shadowOpacity = shadowOpacity;
        toVC.view.layer.shadowRadius = shadowRadius;
        
        self.navigationController.view.userInteractionEnabled = NO;

        //1.指定最上面的NavigationItem
        [self.navigationController hz_itn_addNewNavigationItemViewForViewController:toVC];
        
        //2.设置NavigationBar的颜色
        self.navigationController.hz_navigationBarViewBackgroundColor = fromColor;

        //3.指定不同ViewController上面NavigationItem的alpha值
        //根据VC属性navigationItemViewAlpha上面的alpha设置ItemView的alpha
        [self.navigationController hz_itn_setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
        //直接把需要push的itemView上面的alpha设置为0
        [self.navigationController hz_itn_setNavigationItemViewAlpha:0 minToHidden:NO forViewController:toVC];
        
        //4.指定不同ItemView的transform
        [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformMakeTranslation(fromViewTransitionX, 0) forViewController:toVC];
        [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:fromVC];

        //5.设置ViewController上面View的transform
        toVC.view.transform = CGAffineTransformMakeTranslation(toViewTransitionX, 0);
        fromVC.view.transform = CGAffineTransformIdentity;

        BOOL hideBottomBar = fromVC.hidesBottomBarWhenPushed;
        __block dispatch_block_t tabBarRestoreBlock = nil;
        
        if (fromVC.tabBarController &&
            self.navigationController.hz_hidesTabBarAfterPushed &&
            self.navigationController.hz_itn_isSetViewControllersToRootVC == NO) {
            hideBottomBar = YES;
            if (fromVC.hidesBottomBarWhenPushed == NO) {
                UITabBar *tabBar = fromVC.tabBarController.tabBar;
                UIView *transitionView = nil;
                if (fromVC.tabBarController.hz_tabBarView) {
                    transitionView = fromVC.tabBarController.hz_tabBarView;
                    [transitionView removeFromSuperview];
                }
                else {
                    transitionView = [fromVC.tabBarController createTabBarTransitionView];
                }
                CGRect frame = transitionView.frame;
                frame.size = tabBar.bounds.size;
                frame.origin = CGPointMake(0, SCREEN_HEIGHT - frame.size.height);
                transitionView.frame = frame;
                [fromVC.view addSubview:transitionView];
                BOOL prevHidden = tabBar.hidden;
                tabBar.hidden = YES;

                fromVC.tabBarController.hz_itn_tabBarTransitionView = transitionView;
                UITabBarController *tabBarController = fromVC.tabBarController;
                tabBarRestoreBlock = ^{
                    [tabBarController.hz_itn_tabBarTransitionView removeFromSuperview];
                    if (tabBarController.hz_tabBarView) {
                        UIView *tabBarView = tabBarController.hz_tabBarView;
                        tabBarView.frame = tabBar.bounds;
                        [tabBar addSubview:tabBarView];
                    }
                    tabBar.hidden = prevHidden;
//                    tabBarController.hz_itn_tabBarTransitionView = nil;
                };
            }
        }
       
        [containerView bringSubviewToFront:toVC.view];
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
            //1.变化NavigationBar上面的颜色
            self.navigationController.hz_navigationBarViewBackgroundColor = toColor;
            
            //2.变化不同ItemView的transform
            [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformMakeTranslation(-fromViewTransitionX, 0) forViewController:fromVC];
            [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:toVC];
            
            //3.变化ViewController上View的transform
            toVC.view.transform = CGAffineTransformIdentity;
            fromVC.view.transform = CGAffineTransformMakeTranslation(-fromViewTransitionX, 0);
        }
                         completion:^(BOOL finished) {
            
            shadowRestoreBlock();
            
            //1.指定变化完成后的NavigationItemView的Transform
            [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:fromVC];
            [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:toVC];
            
            //2.指定ViewController的View的transform
            fromVC.view.transform = CGAffineTransformIdentity;
            toVC.view.transform = CGAffineTransformIdentity;
            
            //3.检查是否完成push还是取消
            BOOL canceled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!canceled];
            if (canceled) {
                //取消
                //1.移除添加的NavigationItem
                [self.navigationController hz_itn_removeNavigationItemViewForViewController:toVC];
                
                //2.还原navigationBar上面的颜色
                self.navigationController.hz_navigationBarViewBackgroundColor = fromColor;
                
                //3.还原tabBar
                if (tabBarRestoreBlock) {
                    tabBarRestoreBlock();
                }
            }
            else {
                //如果是直接setViewController:animated:(YES)改变navigationController的rootVC时，rootVC没有TabBarController，因此不显示tabBar
//                toVC.hidesBottomBarWhenPushed = hideBottomBar;
//                if ([self.navigationController.viewControllers containsObject:fromVC]) {
//                    NSInteger fromIdx = [self.navigationController.viewControllers indexOfObject:fromVC] + 1;
//                    for (NSInteger idx = fromIdx; idx < self.navigationController.viewControllers.count; ++idx) {
//                        UIViewController *vc = self.navigationController.viewControllers[idx];
//                        if (vc != toVC) {
//                            vc.hidesBottomBarWhenPushed = hideBottomBar;
//                        }
//                        else {
//                            break;
//                        }
//                    }
//                }
//                else {
//                    for (NSInteger idx = 1; idx < self.navigationController.viewControllers.count; ++idx) {
//                        UIViewController *vc = self.navigationController.viewControllers[idx];
//                        vc.hidesBottomBarWhenPushed = hideBottomBar;
//                    }
//                }
            }
            self.navigationController.view.userInteractionEnabled = YES;
            tabBarRestoreBlock = nil;
        }];
        
//        CGFloat diff = duration * navigationItemViewAlphaPushChangeDurationWithTotalDurationRatio;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.navigationController hz_itn_setNavigationItemViewAlpha:0 minToHidden:NO forViewController:fromVC];
        } completion:^(BOOL finished) {
            BOOL canceled = [transitionContext transitionWasCancelled];
            if (canceled) {
                [self.navigationController hz_itn_removeNavigationItemViewForViewController:toVC];
                [self.navigationController hz_itn_setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
            }
        }];

        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.navigationController hz_itn_setNavigationItemViewAlpha:toAlpha minToHidden:NO forViewController:toVC];
        } completion:^(BOOL finished) {
            BOOL canceled = [transitionContext transitionWasCancelled];
            if (canceled) {
                [self.navigationController hz_itn_removeNavigationItemViewForViewController:toVC];
                [self.navigationController hz_itn_setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
            }
        }];
    }
    else
    {
        
        CGColorRef shadowColor_f = fromVC.view.layer.shadowColor;
        CGSize shadowOffset_f = fromVC.view.layer.shadowOffset;
        CGFloat shadowOpacity_f = fromVC.view.layer.shadowOpacity;
        CGFloat shadowRadius_f = fromVC.view.layer.shadowRadius;
        void (^shadowRestoreBlock)(void) = ^{
            fromVC.view.layer.shadowColor = shadowColor_f;
            fromVC.view.layer.shadowOffset = shadowOffset_f;
            fromVC.view.layer.shadowOpacity = shadowOpacity_f;
            fromVC.view.layer.shadowRadius = shadowRadius_f;
        };
        
        fromVC.view.layer.shadowColor = shadowColor.CGColor;
        fromVC.view.layer.shadowOffset = shadowOffset;
        fromVC.view.layer.shadowOpacity = shadowOpacity;
        fromVC.view.layer.shadowRadius = shadowRadius;
        
        self.navigationController.view.userInteractionEnabled = NO;

        BOOL showBottomBar = NO;
        __block dispatch_block_t tabBarFinishBlock = nil;
        if (fromVC.hidesBottomBarWhenPushed && toVC.tabBarController) {
            if (toVC.hidesBottomBarWhenPushed == NO) {
                showBottomBar = YES;
                
                UITabBar *tabBar = toVC.tabBarController.tabBar;
                
                UIView *transitionView = nil;
                if (toVC.tabBarController.hz_tabBarView) {
                    transitionView = toVC.tabBarController.hz_tabBarView;
                    [transitionView removeFromSuperview];
                }
                else {
                    transitionView = toVC.tabBarController.hz_itn_tabBarTransitionView;
                    if (transitionView == nil) {
                        transitionView = [toVC.tabBarController createTabBarTransitionView];
                    }
                }
                CGRect frame = transitionView.frame;
                frame.size = tabBar.bounds.size;
                frame.origin = CGPointMake(0, SCREEN_HEIGHT - frame.size.height);
                transitionView.frame = frame;
                [toVC.view addSubview:transitionView];
                tabBar.hidden = YES;
                
                toVC.tabBarController.hz_itn_tabBarTransitionView = transitionView;
                UITabBarController *tabBarController = toVC.tabBarController;
                tabBarFinishBlock = ^{
                    [tabBarController.hz_itn_tabBarTransitionView removeFromSuperview];
                    if (tabBarController.hz_tabBarView) {
                        UIView *tabBarView = tabBarController.hz_tabBarView;
                        tabBarView.frame = tabBar.bounds;
                        [tabBar addSubview:tabBarView];
                    }
                    tabBarController.hz_itn_tabBarTransitionView = nil;
                    tabBar.hidden = NO;
                };
            }
        }
        
        [containerView bringSubviewToFront:fromVC.view];
        
        //1.设置NavigationBar的颜色
        self.navigationController.hz_navigationBarViewBackgroundColor = fromColor;

        //2.指定不同ViewController上面NavigationItem的alpha值
        //根据VC属性navigationItemViewAlpha上面的alpha设置ItemView的alpha
        [self.navigationController hz_itn_setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
        [self.navigationController hz_itn_setNavigationItemViewAlpha:0 minToHidden:NO forViewController:toVC];
        
        //3.指定不同ItemView的transform
        [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:fromVC];
        [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformMakeTranslation(-fromViewTransitionX, 0) forViewController:toVC];

        //4.指定不同ItemView的transform
        toVC.view.transform = CGAffineTransformMakeTranslation(-fromViewTransitionX, 0);
        fromVC.view.transform = CGAffineTransformIdentity;
        
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
            shadowRestoreBlock();

            //1.变化NavigationBar上面的颜色
            self.navigationController.hz_navigationBarViewBackgroundColor = toColor;
            
            //3.变化不同ItemView的transform
            [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformMakeTranslation(fromViewTransitionX, 0) forViewController:fromVC];
            [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:toVC];
            
            //4.变化ViewController上View的transform
            toVC.view.transform = CGAffineTransformIdentity;
            fromVC.view.transform = CGAffineTransformMakeTranslation(toViewTransitionX, 0);
        }
                         completion:^(BOOL finished) {
            //1.指定变化完成后的NavigationItemView的Transform
            [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:fromVC];
            [self.navigationController hz_itn_setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:toVC];
            
            //2.指定ViewController的View的transform
            fromVC.view.transform = CGAffineTransformIdentity;
            toVC.view.transform = CGAffineTransformIdentity;
            
            //3.检查是否完成pop还是取消
            BOOL canceled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!canceled];
            if (canceled) {
                //取消
                //1.还原navigationBar上面的颜色
                self.navigationController.hz_navigationBarViewBackgroundColor = fromColor;
            }
            else
            {
                //完成
                [self.navigationController hz_itn_removeNavigationItemViewForViewController:fromVC];
                
                if (tabBarFinishBlock) {
                    tabBarFinishBlock();
                }
            }
            
            self.navigationController.view.userInteractionEnabled = YES;
            tabBarFinishBlock = nil;
        }];
        
//        CGFloat diff = duration * navigationItemViewAlphaPopChangeDurationWithTotalDurationRatio;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.navigationController hz_itn_setNavigationItemViewAlpha:0 minToHidden:NO forViewController:fromVC];
        } completion:^(BOOL finished) {
            BOOL canceled = [transitionContext transitionWasCancelled];
            if (canceled) {
                [self.navigationController hz_itn_setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
                [self.navigationController hz_itn_setNavigationItemViewAlpha:0 minToHidden:NO forViewController:toVC];
            }
        }];
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.navigationController hz_itn_setNavigationItemViewAlpha:toAlpha minToHidden:NO forViewController:toVC];
        } completion:^(BOOL finished) {
            BOOL canceled = [transitionContext transitionWasCancelled];
            if (canceled) {
                [self.navigationController hz_itn_setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
                [self.navigationController hz_itn_setNavigationItemViewAlpha:0 minToHidden:NO forViewController:toVC];
            }
        }];
    }
}

+ (void)updateTabBarForNavigationController:(UINavigationController *)navigationController fromVC:(UIViewController *)fromVC whenPushPopNoAnimatedTransition:(BOOL)push {
    UIViewController *topVC = navigationController.topViewController;
    UITabBarController *tabBarVC = topVC.tabBarController;
    if (!tabBarVC || fromVC == topVC) {
        return;
    }
    
    UIColor *toColor = [topVC hz_navigationBarViewBackgroundColor];
    CGFloat toAlpha = [topVC hz_navigationItemViewAlpha];

    if (push) {
        [navigationController hz_itn_addNewNavigationItemViewForViewController:topVC];
        
        navigationController.hz_navigationBarViewBackgroundColor = toColor;
        
        [navigationController hz_itn_setNavigationItemViewAlpha:toAlpha minToHidden:NO forViewController:topVC];

        //如果只有rootVC时，是不隐藏tabBar的
        BOOL hidden = navigationController.viewControllers.count > 1 ? navigationController.hz_hidesTabBarAfterPushed : fromVC.hidesBottomBarWhenPushed;
//        topVC.hidesBottomBarWhenPushed = hidden;
        topVC.tabBarController.tabBar.hidden = hidden;
        
//        if (fromVC) {
//            if ([navigationController.viewControllers containsObject:fromVC]) {
//                NSInteger fromIdx = [navigationController.viewControllers indexOfObject:fromVC] + 1;
//                for (NSInteger idx = fromIdx; idx < navigationController.viewControllers.count; ++idx) {
//                    UIViewController *vc = navigationController.viewControllers[idx];
//                    if (vc != topVC) {
//                        vc.hidesBottomBarWhenPushed = navigationController.hz_hidesTabBarAfterPushed;
//                    }
//                    else {
//                        break;
//                    }
//                }
//            }
//            else {
//                for (NSInteger idx = 1; idx < navigationController.viewControllers.count; ++idx) {
//                    UIViewController *vc = navigationController.viewControllers[idx];
//                    vc.hidesBottomBarWhenPushed = navigationController.hz_hidesTabBarAfterPushed;
//                }
//            }
//        }
    }
    else {
//        BOOL prevHasHide = topVC.hidesBottomBarWhenPushed;
        
        if (!topVC.hidesBottomBarWhenPushed) {
            [topVC.tabBarController.hz_itn_tabBarTransitionView removeFromSuperview];
            UITabBar *tabBar = topVC.tabBarController.tabBar;
            if (topVC.tabBarController.hz_tabBarView) {
                UIView *tabBarView = topVC.tabBarController.hz_tabBarView;
                tabBarView.frame = tabBar.bounds;
                [tabBar addSubview:tabBarView];
            }
            topVC.tabBarController.hz_itn_tabBarTransitionView = nil;
            tabBar.hidden = NO;
        }
        
        navigationController.hz_navigationBarViewBackgroundColor = toColor;
        
        [navigationController hz_itn_setNavigationItemViewAlpha:toAlpha minToHidden:NO forViewController:topVC];
    }
}


@end
