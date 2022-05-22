//
//  YZHTransitionAnimator.h
//  YZHApp
//
//  Created by bytedance on 2022/5/20.
//  Copyright © 2022 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^YZHTransitionAnimationBlock)(void);
typedef void(^YZHTransitionAnimationCompletionBlock)(BOOL finished);

@interface YZHTransitionAnimator : NSObject <UIViewImplicitlyAnimating>

+ (instancetype)defaultPresentationTransitionAnimator;

- (instancetype)initWithAnimator:(UIViewPropertyAnimator *)animator API_AVAILABLE(ios(10.0));

- (instancetype)initWidthDuration:(NSTimeInterval)duration timingParameters:(id <UITimingCurveProvider>)parameters;

+ (instancetype)animatorWithAnimation:(YZHTransitionAnimationBlock)animationBlock;

- (instancetype)initWithAnimation:(YZHTransitionAnimationBlock)animationBlock;


- (UIViewPropertyAnimator *)animator;

//执行animationBlock
- (void)animate:(YZHTransitionAnimationCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
