//
//  YZHBaseAnimatedTransition.h
//  BaseDefaultUINavigationController
//
//  Created by yuan on 16/11/10.
//  Copyright © 2016年 yzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "YZHNavigationController.h"

typedef NS_ENUM(NSInteger, YZHNavigationAnimatedTransitionStyle)
{
    YZHNavigationAnimatedTransitionStyleNone    = 0,
    YZHNavigationAnimatedTransitionStyleDefault = 1,
};

@interface YZHBaseAnimatedTransition : NSObject<UIViewControllerAnimatedTransitioning>

/** transitionDuration 动画时长,默认为0.2 */
@property (nonatomic, assign) NSTimeInterval transitionDuration;

-(instancetype)initWithNavigationController:(UINavigationController*)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation;

+(instancetype)navigationController:(UINavigationController*)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation animatedTransitionStyle:(YZHNavigationAnimatedTransitionStyle)transitionStyle;

@property (nonatomic, assign) UINavigationControllerOperation operation;
@property (nonatomic, weak) UINavigationController *navigationController;

@end
