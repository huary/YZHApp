//
//  YZHGestureRecognizerInteractiveTransition.m
//  YZHApp
//
//  Created by bytedance on 2022/5/5.
//  Copyright © 2022 yuan. All rights reserved.
//

#import "YZHGestureRecognizerInteractiveTransition.h"

@interface YZHGestureRecognizerInteractiveTransition ()
@property (nonatomic, assign) BOOL isInteractive;

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;


@end

@implementation YZHGestureRecognizerInteractiveTransition

- (instancetype)initWithPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    self = [super init];
    if (self) {
        _panGestureRecognizer = panGestureRecognizer;
        [self pri_setupGesture:YES];
    }
    return self;
}

- (void)pri_setupGesture:(BOOL)add {
    SEL sel = @selector(pri_panGestureUpdate:);
    if (add) {
        [self.panGestureRecognizer addTarget:self action:sel];
    }
    else {
        [self.panGestureRecognizer removeTarget:self action:sel];
    }
}

- (void)pri_panGestureUpdate:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        self.isInteractive = YES;
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        self.isInteractive = NO;
    }
    if (self.interactiveTransitionActionBlock) {
        self.interactiveTransitionActionBlock(self);
    }
    [self interactiveTransitionAction];
}


- (void)interactiveTransitionAction {
}

//- (BOOL)isInteractive {
//    return [self.transitionContext isInteractive];
//}

#pragma mark override
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super startInteractiveTransition:transitionContext];
    self.transitionContext = transitionContext;
}

- (void)dealloc
{
    [self pri_setupGesture:NO];
}

@end
