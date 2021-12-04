//
//  UINavigationControllerDelegateImp.m
//  YZHApp
//
//  Created by bytedance on 2021/11/22.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "UINavigationControllerDelegateImp.h"
//#import "YZHNavigationController+Internal.h"
#import "UINavigationController+YZHNavigation.h"
#import "UINavigationController+YZHNavigationItn.h"
#import "UIViewController+YZHNavigationControllerAnimation.h"
#import "UIViewController+YZHNavigation.h"
#import "YZHBaseAnimatedTransition.h"

@interface UINavigationControllerDelegateImp ()

@property (nonatomic, weak) UINavigationController *target;

@end

@implementation UINavigationControllerDelegateImp

+ (instancetype)delegateWithTarget:(UINavigationController *)target {
    UINavigationControllerDelegateImp *delegate = [UINavigationControllerDelegateImp new];
    delegate.target = target;
    return delegate;
}

#pragma mark UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.target.hz_itn_lastTopVC == viewController) {
        if ([self.target.hz_navDelegate respondsToSelector:@selector(navigationController:didPushViewController:)]) {
            [self.target.hz_navDelegate navigationController:self.target didPushViewController:viewController];
        }
        if (self.target.hz_itn_lastTopVC.itn_pushCompletionBlock) {
            self.target.hz_itn_lastTopVC.itn_pushCompletionBlock(self.target);
        }
    }
    else
    {
        if ([self.target.hz_navDelegate respondsToSelector:@selector(navigationController:didPopViewController:)]) {
            [self.target.hz_navDelegate navigationController:self.target didPopViewController:self.target.hz_itn_lastTopVC];
        }
        if (self.target.hz_itn_lastTopVC.itn_popCompletionBlock) {
            self.target.hz_itn_lastTopVC.itn_popCompletionBlock(self.target);
        }
    }
    self.target.hz_itn_lastTopVC = nil;

}

-(id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.target.hz_itn_isInteractive ? self.target.hz_itn_transition : nil;
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    NSTimeInterval transitionDuration = self.target.hz_transitionDuration;
    if (operation == UINavigationControllerOperationPush) {
        self.target.hz_itn_lastTopVC = toVC;
        if ([self.target.hz_navDelegate respondsToSelector:@selector(navigationController:willPushViewController:)]) {
            [self.target.hz_navDelegate navigationController:self.target willPushViewController:toVC];
        }
    }
    else if (operation == UINavigationControllerOperationPop)
    {
        self.target.hz_itn_lastTopVC = fromVC;
        if ([self.target.hz_navDelegate respondsToSelector:@selector(navigationController:willPopViewController:)]) {
            [self.target.hz_navDelegate navigationController:self.target willPopViewController:fromVC];
        }
    }
    
    NSTimeInterval transitionDurationTmp = self.target.hz_itn_lastTopVC.hz_transitionDuration;
    if (transitionDurationTmp > 0) {
        transitionDuration = transitionDurationTmp;
    }

    YZHBaseAnimatedTransition *transition = [YZHBaseAnimatedTransition navigationController:self.target animationControllerForOperation:operation animatedTransitionStyle:YZHNavigationAnimatedTransitionStyleDefault];
    transition.transitionDuration = transitionDuration;
    self.target.hz_itn_latestTransitionDuration = transitionDuration;
    return transition;
}

@end
