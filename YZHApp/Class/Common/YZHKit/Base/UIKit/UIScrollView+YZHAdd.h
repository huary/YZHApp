//
//  UIScrollView+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL(^UIGestureRecognizerShouldBeginBlock)(UIScrollView *scrollView, UIGestureRecognizer *gestureRecognizer);

typedef BOOL(^UIGestureRecognizerShouldRecognizeSimultaneouslyBlock)(UIScrollView *scrollView,UIGestureRecognizer *first, UIGestureRecognizer *second);

//typedef BOOL(^YZHTouchesShouldCancelInContentViewBlock)(UIScrollView *scrollView,UIView *contentView);


@interface UIScrollView (YZHAdd) <UIGestureRecognizerDelegate>

//@property (nonatomic, assign) BOOL touchToNextResponder;

//@property (nonatomic, copy) YZHTouchesShouldCancelInContentViewBlock touchesShouldCancelBlock;

-(void)setUIPanGestureRecognizersEnabled:(BOOL)enabled whitPanGestureRecognizerShouldBeginBlock:(UIGestureRecognizerShouldBeginBlock)panGestureRecognizerShouldBeginBlock panGestureRecognizerShouldSimultaneouslyBlock:(UIGestureRecognizerShouldRecognizeSimultaneouslyBlock)panGestureRecognizerShouldSimultaneouslyBlock;

@end
