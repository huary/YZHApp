//
//  YZHPresentationController.m
//  YZHApp
//
//  Created by bytedance on 2022/5/5.
//  Copyright © 2022 yuan. All rights reserved.
//

#import "YZHPresentationController.h"

@interface YZHPresentationController ()

@property (nonatomic, strong) UIView *presentView;

@property (nonatomic, strong) UIView *dimmingView;

@property (nonatomic, assign) CGFloat dimmingViewBeginAlpha;

@property (nonatomic, strong) YZHTransitionAnimator *transitionAnimator;

@end

@implementation YZHPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
    presentedViewController.transitioningDelegate = self;
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        self.defaultTopLayoutY = 0;
        self.panPercentToDismiss = 0.25;
        self.panVelocityToDismiss = 1000;
        self.panDismissFailedToRecoverDuration = 0.25;
    }
    return self;
}

- (UIView *)presentView {
    if (!_presentView) {
        _presentView = [[UIView alloc] initWithFrame:[self frameOfPresentedViewInContainerView]];
    }
    return _presentView;
}

- (UIView *)dimmingView {
    if (!_dimmingView) {
        _dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    }
    return _dimmingView;
}

- (void)setupGestureRecognizer {
    UIPanGestureRecognizer *panGesture = [self.presentView hz_addPanGestureRecognizerBlock:nil];
    _dismissInteractiveTransition = [[YZHGestureRecognizerInteractiveTransition alloc] initWithPanGestureRecognizer:panGesture];
    WEAK_SELF(weakSelf);
    self.dismissInteractiveTransition.interactiveTransitionActionBlock = ^(YZHGestureRecognizerInteractiveTransition * _Nonnull interactiveTransition) {
        [weakSelf dismissPercentForInteractiveTransition:interactiveTransition];
    };
}

- (void)dismissPercentForInteractiveTransition:(YZHGestureRecognizerInteractiveTransition*)interactiveTransition {
    CGFloat ty = [interactiveTransition.panGestureRecognizer translationInView:self.presentView].y;
    ty = MAX(ty, 0);
    CGFloat percent = ty / self.presentView.hz_height;

    UIGestureRecognizerState state = interactiveTransition.panGestureRecognizer.state;
    if (state == UIGestureRecognizerStateBegan) {
        self.dimmingViewBeginAlpha = self.dimmingView.alpha;
        self.dimmingView.alpha = (1-percent) * self.dimmingViewBeginAlpha;
        self.presentView.transform = CGAffineTransformMakeTranslation(0, ty);
    }
    else if (state == UIGestureRecognizerStateChanged) {
        self.dimmingView.alpha = (1-percent) * self.dimmingViewBeginAlpha;
        self.presentView.transform = CGAffineTransformMakeTranslation(0, ty);
    }
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        CGFloat vy = [interactiveTransition.panGestureRecognizer velocityInView:self.presentView].y;
        if (percent >= self.panPercentToDismiss || vy >= self.panVelocityToDismiss) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }else{
            [UIView animateWithDuration:self.panDismissFailedToRecoverDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.dimmingView.alpha = self.dimmingViewBeginAlpha;
                self.presentView.transform = CGAffineTransformIdentity;
            } completion:nil];
        }
    }
}

#pragma mark override
- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    if ([self.dismissInteractiveTransition isInteractive] || [self.presentInteractiveTransition isInteractive]) {
        return;
    }
    CGSize size = self.containerView.hz_size;
    self.presentedView.frame = CGRectMake(0, self.defaultTopLayoutY, size.width, size.height - self.defaultTopLayoutY);
    self.presentedViewController.view.frame = self.presentedView.bounds;
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGSize size = self.containerView.hz_size;
    return CGRectMake(0, self.defaultTopLayoutY, size.width, size.height - self.defaultTopLayoutY);
}

- (void)presentationTransitionWillBegin {
    UIView *presentedView = [super presentedView];
        
    [self.presentView addSubview:presentedView];
    
    [self.containerView addSubview:self.dimmingView];
    [self.containerView addSubview:self.presentView];
    
    [self setupGestureRecognizer];
    
    WEAK_SELF(weakSelf);
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (weakSelf.presentWillBeginAnimationBlock) {
            weakSelf.presentWillBeginAnimationBlock(weakSelf, context);
        }
    } completion:NULL];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        _dimmingView = nil;
    }
}

- (void)dismissalTransitionWillBegin {
    WEAK_SELF(weakSelf);
    [self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (weakSelf.dismissWillBeginAnimationBlock) {
            weakSelf.dismissWillBeginAnimationBlock(weakSelf, context);
        }
    } completion:NULL];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        _dimmingView = nil;
    }
}

- (UIView *)presentedView {
    return self.presentView;
}

- (NSTimeInterval)transitionAnimationDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.operationType == YZHPresentOperationTypePresent ? 0.407 : 0.3;
}

- (YZHTransitionAnimator *)transitionAnimatorForDuration:(NSTimeInterval)duration transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (@available(iOS 10.0, *)) {
        id<UITimingCurveProvider> provider = nil;
        if (self.operationType == YZHPresentOperationTypePresent) {
            provider = [[UISpringTimingParameters alloc] initWithMass:1 stiffness:512.027 damping:45.009 initialVelocity:CGVectorMake(0, 0)];
        }
        else {
            provider = [[UICubicTimingParameters alloc] initWithControlPoint1:CGPointMake(0.34, 0.69) controlPoint2:CGPointMake(0.1, 1)];
        }
        return [[YZHTransitionAnimator alloc] initWidthDuration:duration timingParameters:provider];
    }
    else {
        YZHPresentOperationType operationType = self.operationType;
        WEAK_SELF(weakSelf);
        return [YZHTransitionAnimator animatorWithAnimation:^{
            if (operationType == YZHPresentOperationTypePresent) {
                [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.994 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    weakSelf.presentView.hz_top = self.defaultTopLayoutY;
                } completion:nil];
            }
            else {
                CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.34 :0.69 :0.1 :1];
                [CATransaction begin];
                [CATransaction setAnimationTimingFunction:timingFunction];
                
                [UIView animateWithDuration:duration animations:^{
                    weakSelf.presentView.hz_top = self.containerView.hz_height;
                } completion:nil];
                [CATransaction commit];
            }
        }];
    }
}

- (void)prepareForTransitionWithTransitionAnimator:(YZHTransitionAnimator *)transitionAnimator transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    WEAK_SELF(weakSelf);
    void (^animationBlock)(BOOL present) = ^(BOOL present) {
        if (present) {
            weakSelf.presentView.hz_top = weakSelf.defaultTopLayoutY;
        }
        else {
            weakSelf.presentView.hz_top = weakSelf.containerView.hz_height;
        }
    };
    BOOL present = NO;
    if (self.operationType == YZHPresentOperationTypePresent) {
        self.presentView.hz_top = self.containerView.hz_height;
        present = YES;
    }
    [transitionAnimator addAnimations:^{
        animationBlock(present);
    }];
}

- (id<UIViewImplicitlyAnimating>)animatorForTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    if (@available(iOS 10.0, *)) {
        if (self.transitionAnimator) {
            return self.transitionAnimator;
        }

        self.transitionAnimator = [self transitionAnimatorForDuration:duration transitionContext:transitionContext];
        [self prepareForTransitionWithTransitionAnimator:self.transitionAnimator transitionContext:transitionContext];
        [self.transitionAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
            BOOL finish = (finalPosition == UIViewAnimatingPositionEnd);
            [transitionContext completeTransition:finish];
        }];
        return self.transitionAnimator;
    }
    else {
        if (self.transitionAnimator) {
            return self.transitionAnimator;
        }
        self.transitionAnimator = [self transitionAnimatorForDuration:duration transitionContext:transitionContext];
        [self prepareForTransitionWithTransitionAnimator:nil transitionContext:transitionContext];
        [self.transitionAnimator animate:^(BOOL finished) {
            BOOL canceled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!canceled];
        }];
        return nil;
    }
}

#pragma mark - UIViewControllerAnimatedTransitioning
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return [self transitionAnimationDuration:transitionContext];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [[self animatorForTransition:transitionContext] startAnimation];
}

- (id<UIViewImplicitlyAnimating>)interruptibleAnimatorForTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    return [self animatorForTransition:transitionContext];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    self.transitionAnimator = nil;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _operationType = YZHPresentOperationTypePresent;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _operationType = YZHPresentOperationTypeDismiss;
    return self;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
    YZHGestureRecognizerInteractiveTransition *interactiveTransition = [self.presentInteractiveTransition isInteractive] ? self.presentInteractiveTransition : nil;
    return interactiveTransition;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    YZHGestureRecognizerInteractiveTransition *interactiveTransition = [self.dismissInteractiveTransition isInteractive] ? self.dismissInteractiveTransition : nil;
    return interactiveTransition;
}

//- (void)dealloc {
//    NSLog(@"YZHPresentationController dealloc");
//}

@end
