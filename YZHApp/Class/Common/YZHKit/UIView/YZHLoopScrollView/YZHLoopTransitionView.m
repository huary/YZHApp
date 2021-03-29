//
//  YZHLoopTransitionView.m
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/10.
//  Copyright © 2019 yuan. All rights reserved.
//

#import "YZHLoopTransitionView.h"

/**********************************************************************
 *YZHLoopTransitionContext
 ***********************************************************************/
@implementation YZHLoopTransitionContext

@synthesize transitionContainerView = _transitionContainerView;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self pri_setupDefault];
    }
    return self;
}

- (void)pri_setupDefault
{
    self.animateTimeInterval = 0.25;
}

- (UIView *)transitionContainerView
{
    if (_transitionContainerView == nil) {
        _transitionContainerView = [UIView new];
        _transitionContainerView.clipsToBounds = YES;
        _transitionContainerView.userInteractionEnabled = NO;
    }
    return _transitionContainerView;
}

@end

/**********************************************************************
 *YZHLoopTransitionView
 ***********************************************************************/
@interface YZHLoopTransitionView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) YZHLoopTransitionContext *panInfo;

//@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation YZHLoopTransitionView

@synthesize loopScrollView = _loopScrollView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupLoopTransitionDefault];
        [self _setupLoopTransitionChildView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.loopScrollView.frame = self.bounds;
}

- (YZHLoopScrollView *)loopScrollView
{
    if (_loopScrollView == nil) {
        _loopScrollView = [YZHLoopScrollView new];
    }
    return _loopScrollView;
}

- (void)_setupLoopTransitionDefault
{
    self.minScale = 0.3;
    self.minScaleToRemove = 0.6;
}

- (void)_setupLoopTransitionChildView
{
    self.backgroundColor = [UIColor blackColor];
    self.loopScrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.loopScrollView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
    _panGestureRecognizer = pan;
}

- (YZHLoopTransitionContext *)panInfo
{
    if (_panInfo == nil) {
        _panInfo = [YZHLoopTransitionContext new];
    }
    return _panInfo;
}

- (CGFloat)_changedValueForPoint:(CGPoint)point
{
    CGFloat translation = 0;
    CGFloat maxTranslation = self.bounds.size.height/2;
    if (self.loopScrollView.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
        translation = point.y;
        maxTranslation = self.bounds.size.height/2;
    }
    else {
        translation = point.x;
        maxTranslation = self.bounds.size.width/2;
    }
    
    CGFloat changedValue = translation/maxTranslation;
    changedValue = fmin(1.0, fabs(changedValue));
    return changedValue;
}


- (void)_panAction:(UIPanGestureRecognizer*)panGesture
{
    CGPoint point = [panGesture translationInView:panGesture.view];
    CGPoint loc = [panGesture locationInView:self];

    CGSize contentSize = self.bounds.size;
    if (panGesture.state == UIGestureRecognizerStateBegan) {

        CGPoint anchorPoint =  CGPointMake(loc.x/contentSize.width, loc.y/contentSize.height);
        self.panInfo.transitionContainerView.layer.anchorPoint = anchorPoint;
        self.panInfo.transitionContainerView.frame = self.bounds;
        [self.panInfo.transitionContainerView addSubview:self.loopScrollView];
        [self.superview addSubview:self.panInfo.transitionContainerView];
        
        if ([self.delegate respondsToSelector:@selector(transitionView:didStartAtPoint:)]) {
            [self.delegate transitionView:self didStartAtPoint:loc];
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat changedValue = [self _changedValueForPoint:point];
        CGFloat ratio = 1.0 - changedValue;
            
        ratio = fmax(self.minScale, ratio);
        
        self.panInfo.transitionContainerView.transform = CGAffineTransformMakeScale(ratio, ratio);
        self.panInfo.transitionContainerView.center = loc;
        self.alpha = ratio;
        self.panInfo.changedRatio = ratio;
        if ([self.delegate respondsToSelector:@selector(transitionView:updateAtPoint:changedValue:)]) {
            [self.delegate transitionView:self updateAtPoint:loc changedValue:changedValue];
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {
        
        self.alpha = 1.0;
        [self addSubview:self.loopScrollView];
        self.loopScrollView.frame = self.bounds;
        [self.panInfo.transitionContainerView removeFromSuperview];

        if (self.panInfo.changedRatio < self.minScaleToRemove) {
            [self removeFromSuperview];
        }
        
        if ([self.delegate respondsToSelector:@selector(transitionView:didDismissAtPoint:changedValue:)]) {
            CGFloat changedValue = [self _changedValueForPoint:point];
            [self.delegate transitionView:self didDismissAtPoint:loc changedValue:changedValue];
        }
        _panInfo = nil;
    }
    NSLog(@"point=%@",NSStringFromCGPoint(point));

}

- (void)setEnableTransition:(BOOL)enableTransition
{
    _enableTransition = enableTransition;
    self.panGestureRecognizer.enabled = enableTransition;
}

#pragma mark public can override

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer*)panGestureRecognizer
{
    if ([[self class] isEqual:[YZHLoopTransitionView class]]) {
        [self _panAction:panGestureRecognizer];
    }
}

- (BOOL)panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIPanGestureRecognizer *)otherPanGestureRecognizer
{
    return YES;
}

- (BOOL)panGestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint ts = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    if (self.loopScrollView.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
        if (fabs(ts.y) > fabs(ts.x)) {
            return YES;
        }
    }
    else {
        if (fabs(ts.x) > fabs(ts.y)) {
            return YES;
        }
    }
    return NO;
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        UIPanGestureRecognizer *other = (UIPanGestureRecognizer *)otherGestureRecognizer;
        
        return [self panGestureRecognizer:pan shouldRecognizeSimultaneouslyWithGestureRecognizer:other];
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)gestureRecognizer;
        return [self panGestureRecognizerShouldBegin:pan];
    }
    return NO;
}

@end
