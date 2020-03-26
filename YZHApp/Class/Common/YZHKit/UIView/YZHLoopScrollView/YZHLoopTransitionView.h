//
//  YZHLoopTransitionView.h
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/10.
//  Copyright © 2019 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHLoopScrollView.h"


@class YZHLoopTransitionView;
@protocol YZHLoopTransitionViewDelegate <NSObject>

- (void)transitionView:(YZHLoopTransitionView *_Nonnull)transitionView didStartAtPoint:(CGPoint)point;

- (void)transitionView:(YZHLoopTransitionView *_Nonnull)transitionView updateAtPoint:(CGPoint)point changedValue:(CGFloat)changedValue;

- (void)transitionView:(YZHLoopTransitionView *_Nonnull)transitionView didDismissAtPoint:(CGPoint)point changedValue:(CGFloat)changedValue;
@end

NS_ASSUME_NONNULL_BEGIN

/**********************************************************************
 *YZHLoopTransitionContext
 ***********************************************************************/
@interface YZHLoopTransitionContext : NSObject


@property (nonatomic, strong, readonly) UIView *transitionContainerView;

@property (nonatomic, assign) CGFloat changedRatio;

@property (nonatomic, strong) UIView *transitionView;

@property (nonatomic, copy) NSDictionary *userInfo;

//默认0.25
@property (nonatomic, assign) NSTimeInterval animateTimeInterval;

@end


/**********************************************************************
 *YZHLoopTransitionView
 ***********************************************************************/
@interface YZHLoopTransitionView : UIView

@property (nonatomic, strong, readonly) YZHLoopScrollView *loopScrollView;

@property (nonatomic, weak) id<YZHLoopTransitionViewDelegate> delegate;

@property (nonatomic, assign) BOOL enableTransition;

//最小允许的缩小值
@property (nonatomic, assign) CGFloat minScale;

//小于minScaleToRemove时松开进行removefromSuperView操作
@property (nonatomic, assign) CGFloat minScaleToRemove;

#pragma mark public can override
- (void)panGestureRecognizerAction:(UIPanGestureRecognizer*)panGestureRecognizer;

- (BOOL)panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIPanGestureRecognizer *)otherPanGestureRecognizer;

- (BOOL)panGestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
