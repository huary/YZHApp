//
//  YZHPresentationController.h
//  YZHApp
//
//  Created by bytedance on 2022/5/5.
//  Copyright © 2022 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHTransitionAnimator.h"
#import "YZHGestureRecognizerInteractiveTransition.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,YZHPresentOperationType) {
    YZHPresentOperationTypePresent  = 0,
    YZHPresentOperationTypeDismiss  = 1,
};

@class YZHPresentationController;
typedef void(^YZHPresentationControllerTransitionBlock)(YZHPresentationController *presentationController,id <UIViewControllerTransitionCoordinatorContext>context);

@interface YZHPresentationController : UIPresentationController <UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate> {
@protected
    UIView *_presentView;
    UIView *_dismissView;
}

//默认0
@property (nonatomic, assign) CGFloat defaultTopLayoutY;
//在往下滑动多少比例时进行dismiss，默认0.25
@property (nonatomic, assign) CGFloat panPercentToDismiss;

//在往下滑动速度为多少时进行dismiss，默认1000
@property (nonatomic, assign) CGFloat panVelocityToDismiss;

//在往下滑动dismiss失败时，恢复到原来的位置的动画时长
@property (nonatomic, assign) CGFloat panDismissFailedToRecoverDuration;


@property (nonatomic, assign, readonly) YZHPresentOperationType operationType;

@property (nonatomic, strong) YZHGestureRecognizerInteractiveTransition *presentInteractiveTransition;

@property (nonatomic, strong) YZHGestureRecognizerInteractiveTransition *dismissInteractiveTransition;

@property (nonatomic, assign) YZHPresentationControllerTransitionBlock presentWillBeginAnimationBlock;


@property (nonatomic, assign) YZHPresentationControllerTransitionBlock dismissWillBeginAnimationBlock;

//子类可以重写覆盖
//进行展示的view
- (UIView *)presentView;

//在展示view下层的蒙层
- (UIView *)dismissView;

//设置手势，暂时只设置dismiss的手势（注意⚠️：不能直接调用，上层类可以重写）
- (void)setupGestureRecognizer;

//消失的百分比交互手势（注意⚠️：不能直接调用，上层类可以重写）
- (void)dismissPercentForInteractiveTransition:(YZHGestureRecognizerInteractiveTransition*)interactiveTransition;

//转场动画时长（注意⚠️：不能直接调用，上层类可以重写）
- (NSTimeInterval)transitionAnimationDuration:(id<UIViewControllerContextTransitioning>)transitionContext;

//转场动画提供者（注意⚠️：不能直接调用，上层类可以重写）
- (YZHTransitionAnimator *)transitionAnimatorForDuration:(NSTimeInterval)duration transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext;

//转场动画前的准备（注意⚠️：不能直接调用，上层类可以重写）
- (void)prepareForTransitionWithTransitionAnimator:(YZHTransitionAnimator *_Nullable)transitionAnimator transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext;
@end

NS_ASSUME_NONNULL_END
