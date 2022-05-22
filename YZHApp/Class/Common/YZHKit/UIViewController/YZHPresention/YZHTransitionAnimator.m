//
//  YZHTransitionAnimator.m
//  YZHApp
//
//  Created by bytedance on 2022/5/20.
//  Copyright © 2022 yuan. All rights reserved.
//

#import "YZHTransitionAnimator.h"

@interface YZHTransitionAnimator ()

@property (nonatomic, strong) UIViewPropertyAnimator *mainAnimator;

@property (nonatomic, strong) NSMutableArray<UIViewPropertyAnimator*> *animators;

@property (nonatomic, copy) YZHTransitionAnimationBlock animationBlock;

@end

@implementation YZHTransitionAnimator

+ (instancetype)defaultPresentationTransitionAnimator {
    static YZHTransitionAnimator *transitionAnimator_s = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UISpringTimingParameters *timingParamters = [[UISpringTimingParameters alloc] initWithDampingRatio:1];
        transitionAnimator_s = [[YZHTransitionAnimator alloc] initWidthDuration:0.25 timingParameters:timingParamters];
    });
    return transitionAnimator_s;
}

- (instancetype)initWithAnimator:(UIViewPropertyAnimator *)animator {
    self = [super init];
    if (self) {
        self.mainAnimator = animator;
        [self.animators addObject:animator];
    }
    return self;
}

- (instancetype)initWidthDuration:(NSTimeInterval)duration timingParameters:(id <UITimingCurveProvider>)parameters {
    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:duration timingParameters:parameters];
    return [self initWithAnimator:animator];
}

- (UIViewPropertyAnimator *)animator {
    return self.mainAnimator;
}

- (NSMutableArray<UIViewPropertyAnimator *> *)animators {
    if (!_animators) {
        _animators = [NSMutableArray array];
    }
    return _animators;
}

- (void)addAnimations:(void (^)(void))animation {
    [self.mainAnimator addAnimations:animation];
}

- (void)addCompletion:(void (^)(UIViewAnimatingPosition))completion {
    [self.mainAnimator addCompletion:completion];
}

- (UIViewAnimatingState)state {
    return self.mainAnimator.state;
}

- (BOOL)isRunning {
    return self.mainAnimator.isRunning;
}

- (BOOL)isReversed {
    return self.mainAnimator.isReversed;
}

- (void)setReversed:(BOOL)reversed {
    for (UIViewPropertyAnimator *animator in _animators) {
        animator.reversed = reversed;
    }
}

- (CGFloat)fractionComplete {
    return self.mainAnimator.fractionComplete;
}

- (void)setFractionComplete:(CGFloat)fractionComplete {
    for (UIViewPropertyAnimator *animator in _animators) {
        animator.fractionComplete = fractionComplete;
    }
}

- (void)startAnimation {
    for (UIViewPropertyAnimator *animator in _animators) {
        [animator startAnimation];
    }
}

- (void)startAnimationAfterDelay:(NSTimeInterval)delay {
    for (UIViewPropertyAnimator *animator in _animators) {
        [animator startAnimationAfterDelay:delay];
    }
}

- (void)pauseAnimation {
    for (UIViewPropertyAnimator *animator in _animators) {
        [animator pauseAnimation];
    }
}

- (void)stopAnimation:(BOOL)withoutFinishing {
    for (UIViewPropertyAnimator *animator in _animators) {
        [animator stopAnimation:withoutFinishing];
    }
}

- (void)finishAnimationAtPosition:(UIViewAnimatingPosition)finalPosition {
    for (UIViewPropertyAnimator *animator in _animators) {
        [animator finishAnimationAtPosition:finalPosition];
    }
}

#pragma mark - animationBlokc
+ (instancetype)animatorWithAnimation:(YZHTransitionAnimationBlock)animationBlock {
    return [[YZHTransitionAnimator alloc] initWithAnimation:animationBlock];
}

- (instancetype)initWithAnimation:(YZHTransitionAnimationBlock)animationBlock {
    self = [super init];
    if (self) {
        self.animationBlock = animationBlock;
    }
    return self;
}


- (void)animate:(YZHTransitionAnimationCompletionBlock)completionBlock {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (completionBlock) {
            completionBlock(YES);
        }
    }];
    self.animationBlock();
    [CATransaction commit];
}

@end
