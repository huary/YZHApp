//
//  YZHDefaultAnimatedTransition.m
//  BaseDefaultUINavigationController
//
//  Created by captain on 16/11/10.
//  Copyright © 2016年 yzh. All rights reserved.
//

#import "YZHDefaultAnimatedTransition.h"
#import "UIViewController+NavigationBarAndItemView.h"
#import "UITabBarController+UITabBarView.h"
#import "UIView+Snapshot.h"
#import <objc/runtime.h>

//static const CGFloat navigationItemViewAlphaPushChangeDurationWithTotalDurationRatio = 1.0;//0.5;//0.2;
//static const CGFloat navigationItemViewAlphaPopChangeDurationWithTotalDurationRatio = 1.0;//0.5;//0.3;


/**************************************************************************
 *UITabBarController (UITabBarTransitionView)
 **************************************************************************/
@interface UITabBarController (UITabBarTransitionView)

/** tabBarTransitionView,主要用于NavigationController上进行交互使用的，不要使用此属性 */
@property (nonatomic, strong) UIView *tabBarTransitionView;

@end

@implementation UITabBarController (UITabBarTransitionView)

-(void)setTabBarTransitionView:(UIView *)tabBarTransitionView
{
    objc_setAssociatedObject(self, @selector(tabBarTransitionView), tabBarTransitionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIView*)tabBarTransitionView
{
    return objc_getAssociatedObject(self, _cmd);
}

-(UIView*)createTabBarTransitionView
{
    BOOL hidden = self.tabBar.hidden;
    self.tabBar.hidden = NO;
    
    UIView *transitionView = [self.tabBar snapshotImageView];
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
    
    UIColor *fromColor = [fromVC navigationBarViewBGColor];
    UIColor *toColor = [toVC navigationBarViewBGColor];
    
    CGFloat fromAlpha = [fromVC navigationItemViewAlpha];
    CGFloat toAlpha = [toVC navigationItemViewAlpha];
    
    UIColor *shadowColor = BLACK_COLOR;
    CGSize shadowOffset = CGSizeMake(-3, 0);
    CGFloat shadowOpacity = 0.3;
    CGFloat shadowRadius = 3;
    
    [containerView addSubview:toVC.view];
    if (self.operation == UINavigationControllerOperationPush) {
        toVC.view.layer.shadowColor = shadowColor.CGColor;
        toVC.view.layer.shadowOffset = shadowOffset;
        toVC.view.layer.shadowOpacity = shadowOpacity;
        toVC.view.layer.shadowRadius = shadowRadius;
        
        self.navigationController.view.userInteractionEnabled = NO;

        //1.指定最上面的NavigationItem
        [self.navigationController addNewNavigationItemViewForViewController:toVC];
        
        //2.设置NavigationBar的颜色
        self.navigationController.navigationBarViewBackgroundColor = fromColor;

        //3.指定不同ViewController上面NavigationItem的alpha值
        //根据VC属性navigationItemViewAlpha上面的alpha设置ItemView的alpha
        [self.navigationController setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
        //直接把需要push的itemView上面的alpha设置为0
        [self.navigationController setNavigationItemViewAlpha:0 minToHidden:NO forViewController:toVC];
        
        //4.指定不同ItemView的transform
        [self.navigationController setNavigationItemViewTransform:CGAffineTransformMakeTranslation(fromViewTransitionX, 0) forViewController:toVC];
        [self.navigationController setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:fromVC];

        //5.设置ViewController上面View的transform
        toVC.view.transform = CGAffineTransformMakeTranslation(toViewTransitionX, 0);
        fromVC.view.transform = CGAffineTransformIdentity;

        BOOL hideBottomBar = NO;
        if (fromVC.tabBarController && (self.navigationController.hidesTabBarAfterPushed || toVC.hidesBottomBarWhenPushed)) {

            __block BOOL prevHasHide = NO;
            [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj != toVC && obj.hidesBottomBarWhenPushed) {
                    prevHasHide = YES;
                    *stop = YES;
                }
            }];
            if (prevHasHide == NO) {
                hideBottomBar = YES;
                UITabBar *tabBar = fromVC.tabBarController.tabBar;
                UIView *transitionView = nil;
                if (fromVC.tabBarController.tabBarView) {
                    transitionView = fromVC.tabBarController.tabBarView;
                    [transitionView removeFromSuperview];
                }
                else {
                    transitionView = [fromVC.tabBarController createTabBarTransitionView];
                }
                CGRect frame = transitionView.frame;
                frame.origin = CGPointMake(0, fromVC.view.bounds.size.height -tabBar.bounds.size.height);
                transitionView.frame = frame;
                [fromVC.view addSubview:transitionView];
                tabBar.hidden = YES;

                fromVC.tabBarController.tabBarTransitionView = transitionView;
            }
        }
       
        [containerView bringSubviewToFront:toVC.view];
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             //1.变化NavigationBar上面的颜色
                             self.navigationController.navigationBarViewBackgroundColor = toColor;
                             
                             //2.变化不同ItemView的transform
                             [self.navigationController setNavigationItemViewTransform:CGAffineTransformMakeTranslation(-fromViewTransitionX, 0) forViewController:fromVC];
                             [self.navigationController setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:toVC];
                             
                             //3.变化ViewController上View的transform
                             toVC.view.transform = CGAffineTransformIdentity;
                             fromVC.view.transform = CGAffineTransformMakeTranslation(-fromViewTransitionX, 0);
                         }
                         completion:^(BOOL finished) {
                             //1.指定变化完成后的NavigationItemView的Transform
                             [self.navigationController setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:fromVC];
                             [self.navigationController setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:toVC];
                             
                             //2.指定ViewController的View的transform
                             fromVC.view.transform = CGAffineTransformIdentity;
                             toVC.view.transform = CGAffineTransformIdentity;

                             toVC.hidesBottomBarWhenPushed = hideBottomBar;
                             
                             //3.检查是否完成push还是取消
                             BOOL canceled = [transitionContext transitionWasCancelled];
                             [transitionContext completeTransition:!canceled];
                             if (canceled) {
                                 //取消
                                 //1.移除添加的NavigationItem
                                 [self.navigationController removeNavigationItemViewForViewController:toVC];
                                 
                                 //2.还原navigationBar上面的颜色
                                 self.navigationController.navigationBarViewBackgroundColor = fromColor;

                                 if (hideBottomBar) {
                                     UITabBar *tabBar = fromVC.tabBarController.tabBar;
                                     if (fromVC.tabBarController.tabBarView) {
                                         UIView *transitionView = fromVC.tabBarController.tabBarView;
                                         [transitionView removeFromSuperview];
                                         
                                         CGRect frame = transitionView.frame;
                                         frame.origin = CGPointMake(0, 0);
                                         transitionView.frame = frame;
                                         [tabBar addSubview:transitionView];
                                     }
                                     else {
                                         [fromVC.tabBarController.tabBarTransitionView removeFromSuperview];
                                     }
                                     tabBar.hidden = NO;
                                 }
                             }
                             self.navigationController.view.userInteractionEnabled = YES;
                         }];
        
//        CGFloat diff = duration * navigationItemViewAlphaPushChangeDurationWithTotalDurationRatio;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.navigationController setNavigationItemViewAlpha:0 minToHidden:NO forViewController:fromVC];
        } completion:^(BOOL finished) {
            BOOL canceled = [transitionContext transitionWasCancelled];
            if (canceled) {
                [self.navigationController removeNavigationItemViewForViewController:toVC];
                [self.navigationController setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
            }
        }];

        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.navigationController setNavigationItemViewAlpha:toAlpha minToHidden:NO forViewController:toVC];
        } completion:^(BOOL finished) {
            BOOL canceled = [transitionContext transitionWasCancelled];
            if (canceled) {
                [self.navigationController removeNavigationItemViewForViewController:toVC];
                [self.navigationController setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
            }
        }];
    }
    else
    {
        fromVC.view.layer.shadowColor = shadowColor.CGColor;
        fromVC.view.layer.shadowOffset = shadowOffset;
        fromVC.view.layer.shadowOpacity = shadowOpacity;
        fromVC.view.layer.shadowRadius = shadowRadius;
        
        self.navigationController.view.userInteractionEnabled = NO;

        BOOL showBottomBar = NO;
        if (fromVC.hidesBottomBarWhenPushed && toVC.tabBarController) {
            
            __block BOOL prevHasHide = NO;
            [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.hidesBottomBarWhenPushed) {
                    prevHasHide = YES;
                    *stop = YES;
                }
            }];
            
            if (prevHasHide == NO) {
                showBottomBar = YES;
                
                UITabBar *tabBar = toVC.tabBarController.tabBar;
                
                UIView *transitionView = nil;
                if (toVC.tabBarController.tabBarView) {
                    transitionView = toVC.tabBarController.tabBarView;
                    [transitionView removeFromSuperview];
                }
                else {
                    transitionView = toVC.tabBarController.tabBarTransitionView;
                    if (transitionView == nil) {
                        transitionView = [toVC.tabBarController createTabBarTransitionView];
                    }
                }
                CGRect frame = transitionView.frame;
                
                CGFloat h = tabBar.bounds.size.height;
                CGFloat x = 0;
                CGFloat y = toVC.view.bounds.size.height - h;
                CGFloat w = tabBar.bounds.size.width;
                frame = CGRectMake(x, y, w, h);
                transitionView.frame = frame;
                [toVC.view addSubview:transitionView];
                tabBar.hidden = YES;
                
                toVC.tabBarController.tabBarTransitionView = transitionView;
            }
        }
        
        [containerView bringSubviewToFront:fromVC.view];
        
        //1.设置NavigationBar的颜色
        self.navigationController.navigationBarViewBackgroundColor = fromColor;

        //2.指定不同ViewController上面NavigationItem的alpha值
        //根据VC属性navigationItemViewAlpha上面的alpha设置ItemView的alpha
        [self.navigationController setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
        [self.navigationController setNavigationItemViewAlpha:0 minToHidden:NO forViewController:toVC];
        
        //3.指定不同ItemView的transform
        [self.navigationController setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:fromVC];
        [self.navigationController setNavigationItemViewTransform:CGAffineTransformMakeTranslation(-fromViewTransitionX, 0) forViewController:toVC];

        //4.指定不同ItemView的transform
        toVC.view.transform = CGAffineTransformMakeTranslation(-fromViewTransitionX, 0);
        fromVC.view.transform = CGAffineTransformIdentity;
        
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             //1.变化NavigationBar上面的颜色
                             self.navigationController.navigationBarViewBackgroundColor = toColor;
                             
                             //3.变化不同ItemView的transform
                             [self.navigationController setNavigationItemViewTransform:CGAffineTransformMakeTranslation(fromViewTransitionX, 0) forViewController:fromVC];
                             [self.navigationController setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:toVC];
                             
                             //4.变化ViewController上View的transform
                             toVC.view.transform = CGAffineTransformIdentity;
                             fromVC.view.transform = CGAffineTransformMakeTranslation(toViewTransitionX, 0);
                         }
                         completion:^(BOOL finished) {                             
                             //1.指定变化完成后的NavigationItemView的Transform
                             [self.navigationController setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:fromVC];
                             [self.navigationController setNavigationItemViewTransform:CGAffineTransformIdentity forViewController:toVC];
                             
                             //2.指定ViewController的View的transform
                             fromVC.view.transform = CGAffineTransformIdentity;
                             toVC.view.transform = CGAffineTransformIdentity;

                             //3.检查是否完成pop还是取消
                             BOOL canceled = [transitionContext transitionWasCancelled];
                             [transitionContext completeTransition:!canceled];
                             if (canceled) {
                                 //取消
                                 //1.还原navigationBar上面的颜色
                                 self.navigationController.navigationBarViewBackgroundColor = fromColor;
                             }
                             else
                             {
                                 //完成
                                 [self.navigationController removeNavigationItemViewForViewController:fromVC];
                                 
                                 if (showBottomBar) {
                                     UITabBar *tabBar = toVC.tabBarController.tabBar;
                                     if (toVC.tabBarController.tabBarView) {
                                         UIView *transitionView = toVC.tabBarController.tabBarView;
                                         [transitionView removeFromSuperview];
                                         
                                         CGRect frame = tabBar.bounds;
                                         transitionView.frame = frame;
                                         [tabBar addSubview:transitionView];
                                     }
                                     else {
                                         [toVC.tabBarController.tabBarTransitionView removeFromSuperview];
                                     }
                                     toVC.tabBarController.tabBarTransitionView = nil;
                                     tabBar.hidden = NO;
                                 }
                             }
                             
                             self.navigationController.view.userInteractionEnabled = YES;
                         }];
        
//        CGFloat diff = duration * navigationItemViewAlphaPopChangeDurationWithTotalDurationRatio;
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.navigationController setNavigationItemViewAlpha:0 minToHidden:NO forViewController:fromVC];
        } completion:^(BOOL finished) {
            BOOL canceled = [transitionContext transitionWasCancelled];
            if (canceled) {
                [self.navigationController setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
                [self.navigationController setNavigationItemViewAlpha:0 minToHidden:NO forViewController:toVC];
            }
        }];
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.navigationController setNavigationItemViewAlpha:toAlpha minToHidden:NO forViewController:toVC];
        } completion:^(BOOL finished) {
            BOOL canceled = [transitionContext transitionWasCancelled];
            if (canceled) {
                [self.navigationController setNavigationItemViewAlpha:fromAlpha minToHidden:NO forViewController:fromVC];
                [self.navigationController setNavigationItemViewAlpha:0 minToHidden:NO forViewController:toVC];
            }
        }];
    }
}

@end
