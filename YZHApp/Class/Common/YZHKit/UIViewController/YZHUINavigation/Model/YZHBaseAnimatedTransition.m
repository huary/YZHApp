//
//  YZHBaseAnimatedTransition.m
//  BaseDefaultUINavigationController
//
//  Created by captain on 16/11/10.
//  Copyright © 2016年 yzh. All rights reserved.
//

#import "YZHBaseAnimatedTransition.h"
#import "YZHDefaultAnimatedTransition.h"

@implementation YZHBaseAnimatedTransition

-(instancetype)initWithNavigation:(UINavigationController*)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation
{
    if (self = [super init]) {
        self.operation = operation;
        self.navigationController = (YZHUINavigationController*)navigationController;
        [self _setupDefaultValue];
    }
    return self;
}

+(instancetype)navigationController:(UINavigationController*)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation animatedTransitionStyle:(YZHNavigationAnimatedTransitionStyle)transitionStyle
{
    if (transitionStyle == YZHNavigationAnimatedTransitionStyleDefault) {
        return [[YZHDefaultAnimatedTransition alloc] initWithNavigation:navigationController animationControllerForOperation:operation];
    }
    return nil;
}

-(void)_setupDefaultValue
{
    self.transitionDuration = 0.2;
}


-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [NSException raise:@"YZHBaseAnimatedTransitionException" format:@"Sub class must override this method at %s %d",__FILE__,__LINE__];
    return self.transitionDuration;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [NSException raise:@"YZHBaseAnimatedTransitionException" format:@"Sub class must override this method at %s %d",__FILE__,__LINE__];
}

@end
