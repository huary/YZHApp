//
//  YZHGestureRecognizerInteractiveTransition.h
//  YZHApp
//
//  Created by bytedance on 2022/5/5.
//  Copyright © 2022 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YZHGestureRecognizerInteractiveTransition;
typedef void(^YZHGestureRecognizerInteractiveTransitionActionBlock)(YZHGestureRecognizerInteractiveTransition *interactiveTransition);

@interface YZHGestureRecognizerInteractiveTransition : UIPercentDrivenInteractiveTransition

- (instancetype)initWithPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, strong) YZHGestureRecognizerInteractiveTransitionActionBlock interactiveTransitionActionBlock;

- (id<UIViewControllerContextTransitioning>)transitionContext;

- (void)interactiveTransitionAction;

- (BOOL)isInteractive;

@end

NS_ASSUME_NONNULL_END
