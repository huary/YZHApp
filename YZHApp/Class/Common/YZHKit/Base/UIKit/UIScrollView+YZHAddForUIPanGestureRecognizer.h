//
//  UIScrollView+YZHAddForUIPanGestureRecognizer.h
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL(^UIGestureRecognizerShouldBeginBlock)(UIScrollView *scrollView, UIGestureRecognizer *gestureRecognizer);

typedef BOOL(^UIGestureRecognizerShouldRecognizeSimultaneouslyBlock)(UIScrollView *scrollView,UIGestureRecognizer *first, UIGestureRecognizer *second);


@interface UIScrollView (YZHAddForUIPanGestureRecognizer) <UIGestureRecognizerDelegate>

//@property (nonatomic, copy) UIGestureRecognizerShouldBeginBlock panGestureRecognizerShouldBeginBlock;
//
//@property (nonatomic, copy) UIGestureRecognizerShouldRecognizeSimultaneouslyBlock panGestureRecognizerShouldSimultaneouslyBlock;

-(void)setUIPanGestureRecognizersEnabled:(BOOL)enabled whitPanGestureRecognizerShouldBeginBlock:(UIGestureRecognizerShouldBeginBlock)panGestureRecognizerShouldBeginBlock panGestureRecognizerShouldSimultaneouslyBlock:(UIGestureRecognizerShouldRecognizeSimultaneouslyBlock)panGestureRecognizerShouldSimultaneouslyBlock;


@end
