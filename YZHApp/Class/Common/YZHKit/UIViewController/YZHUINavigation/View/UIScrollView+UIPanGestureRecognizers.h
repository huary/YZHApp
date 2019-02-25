//
//  UIScrollView+UIPanGestureRecognizers.h
//  YZHUINavigationController
//
//  Created by yzh on 17/3/8.
//  Copyright © 2017年 dlodlo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHKitType.h"

@interface UIScrollView (UIPanGestureRecognizers)

//-(void)setUIPanGestureRecognizersEnabled:(BOOL)enabled withShouldRecognizesBlock:(UIPanGestureRecognizersShouldRecognizeSimultaneouslyBlock)panRecognizersBlock;

-(void)setUIPanGestureRecognizersEnabled:(BOOL)enabled whitPanGestureRecognizerShouldBeginBlock:(UIPanGestureRecognizerShouldBeginBlock)panRecognizerShouldBeginBlock panGestureRecognizersShouldRecognizeSimultaneouslyBlock:(UIPanGestureRecognizersShouldRecognizeSimultaneouslyBlock)panRecognizersShouldRecognizeSimultaneouslyBlock;
@end
