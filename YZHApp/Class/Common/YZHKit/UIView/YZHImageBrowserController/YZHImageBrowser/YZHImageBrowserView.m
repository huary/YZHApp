//
//  YZHImageBrowserView.m
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/11.
//  Copyright © 2019 yuan. All rights reserved.
//

#import "YZHImageBrowserView.h"
//#import "YZHImageCell.h"
#import "YZHImageCellModelProtocol.h"

#define USE_IMAGEVIEW_TO_PAN        (1)


/**********************************************************************
 *YZHImageCellTransitionContext
 ***********************************************************************/
@interface YZHImageCellTransitionContext : YZHLoopTransitionContext

@property (nonatomic, strong) YZHImageCell *transitionCell;

@end

@implementation YZHImageCellTransitionContext

@end




/**********************************************************************
 *YZHImageBrowserView
 ***********************************************************************/
@interface YZHImageBrowserView ()

@property (nonatomic, strong) YZHImageCellTransitionContext *panContext;

@end

@implementation YZHImageBrowserView
@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self pri_setupImageBrowserView];
    }
    return self;
}

- (void)pri_setupImageBrowserView
{
    
}

- (YZHLoopTransitionContext*)panContext
{
    if (_panContext == nil) {
        _panContext = [YZHImageCellTransitionContext new];
    }
    return _panContext;
}

- (CGFloat)pri_changedValueForPoint:(CGPoint)point
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

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIPanGestureRecognizer *panGesture = panGestureRecognizer;
    CGPoint point = [panGesture translationInView:panGesture.view];
    CGPoint loc = [panGesture locationInView:self];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        YZHImageCell *cell = (YZHImageCell*)self.loopScrollView.currentShowCell;
        
        self.panContext.transitionCell = cell;

        self.loopScrollView.hidden = YES;
        cell.zoomView.scrollView.scrollEnabled = NO;
        self.loopScrollView.scrollView.scrollEnabled = NO;
        self.panContext.transitionContainerView.frame = self.bounds;
        
//        self.panContext.imageCellModel = (id<YZHImageCellModelProtocol>)cell.model;

        UIImageView *cellImageView = cell.zoomView.imageView;
        CGSize cellImageSize = cellImageView.bounds.size;

        loc = [panGesture locationInView:cellImageView];
        CGPoint imgAnchorPoint = CGPointMake(0.5, 0.5);
        if (cellImageSize.width > 0 && cellImageSize.height > 0) {
            imgAnchorPoint = CGPointMake(loc.x/cellImageSize.width, loc.y/cellImageSize.height);
        }
#if USE_IMAGEVIEW_TO_PAN
        CGRect imgFrame = [cellImageView.superview convertRect:cellImageView.frame toView:self];
        //不要用initWithFrame 来初始化，用如下：
        UIImageView *transitionView = [[UIImageView alloc] init];
        transitionView.layer.anchorPoint = imgAnchorPoint;
        transitionView.frame = imgFrame;
        transitionView.image = cell.zoomView.image;
        [self.panContext.transitionContainerView addSubview:transitionView];
#else
        YZHZoomView *transitionView = [[YZHZoomView alloc] initWithFrame:self.bounds];
        transitionView.image = cell.zoomView.image;
        transitionView.imageView.layer.anchorPoint = imgAnchorPoint;
        transitionView.imageView.frame = cell.zoomView.imageView.frame;
        transitionView.scrollView.contentSize = cell.zoomView.scrollView.contentSize;
        transitionView.scrollView.contentOffset = cell.zoomView.scrollView.contentOffset;
        [self.panContext.transitionContainerView addSubview:transitionView];
#endif
        self.panContext.transitionView = transitionView;
        [self.superview addSubview:self.panContext.transitionContainerView];

        if ([self.delegate respondsToSelector:@selector(transitionView:didStartAtPoint:)]) {
            [self.delegate transitionView:self didStartAtPoint:loc];
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat changedValue = [self pri_changedValueForPoint:point];
        CGFloat ratio = 1.0 - changedValue;

        ratio = fmax(self.minScale, ratio);

        CGAffineTransform ts = CGAffineTransformMakeTranslation(point.x, point.y);
#if USE_IMAGEVIEW_TO_PAN
        UIImageView *transitionView = (UIImageView*)self.panContext.transitionView;
        transitionView.transform = CGAffineTransformScale(ts, ratio, ratio);
#else
        YZHZoomView *transitionView = (YZHZoomView*)self.panContext.transitionView;
        transitionView.imageView.transform = CGAffineTransformScale(ts, ratio, ratio);
#endif
        self.alpha = ratio;
        self.panContext.changedRatio = ratio;
        
        if ([self.delegate respondsToSelector:@selector(transitionView:updateAtPoint:changedValue:)]) {
            [self.delegate transitionView:self updateAtPoint:loc changedValue:changedValue];
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled) {

        YZHImageCell *cell = self.panContext.transitionCell;
        
        UIView *transformView = nil;
        UIView *toView = nil;
#if USE_IMAGEVIEW_TO_PAN
        transformView = self.panContext.transitionView;
        toView = self.panContext.transitionContainerView;
#else
        YZHZoomView *transitionView = (YZHZoomView*)self.panContext.transitionView;
        transformView = transitionView.imageView;
        toView = cell.zoomView.scrollView;
#endif
        
        void (^completion)(BOOL finished, BOOL dismiss) = ^(BOOL finished, BOOL dismiss) {
            self.loopScrollView.hidden = NO;
            cell.zoomView.scrollView.scrollEnabled = YES;
            self.loopScrollView.scrollView.scrollEnabled = YES;
            [self.panContext.transitionContainerView removeFromSuperview];
            self.panContext = nil;
            
            if (dismiss && [self.delegate respondsToSelector:@selector(transitionView:didDismissAtPoint:changedValue:)]) {
                CGFloat changedValue = [self pri_changedValueForPoint:point];
                [self.delegate transitionView:self didDismissAtPoint:loc changedValue:changedValue];
            }
        };
        
        if (self.panContext.changedRatio < self.minScaleToRemove) {
            
            CGSize transitionContainerViewSize = self.panContext.transitionContainerView.bounds.size;

            CGRect toRect = CGRectMake(transitionContainerViewSize.width/2, transitionContainerViewSize.height/2, 0, 0);
            if ([self.delegate respondsToSelector:@selector(imageBrowserView:dismissToFrameForCell:)]) {
                toRect = [self.delegate imageBrowserView:self dismissToFrameForCell:cell];
            }
            [UIView animateWithDuration:self.panContext.animateTimeInterval animations:^{
                self.alpha = 0;
                transformView.frame = toRect;
            } completion:^(BOOL finished) {
                completion(finished, YES);
                [self removeFromSuperview];
            }];
        }
        else {
            [UIView animateWithDuration:self.panContext.animateTimeInterval animations:^{
                self.alpha = 1.0;
                transformView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                completion(finished, NO);
            }];
        }
    }
}


- (BOOL)panGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIPanGestureRecognizer *)otherPanGestureRecognizer
{
    BOOL ret = [super panGestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherPanGestureRecognizer];
    return ret;
}

- (BOOL)panGestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    BOOL ret = [super panGestureRecognizerShouldBegin:panGestureRecognizer];
    if (ret == NO) {
        return ret;
    }
    
    CGPoint ts = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    YZHImageCell *currentShowCell = (YZHImageCell*)self.loopScrollView.currentShowCell;
    if (![currentShowCell isKindOfClass:[YZHImageCell class]]) {
        return NO;
    }
    if (currentShowCell.zoomView.scrollView.isZooming) {
        return NO;
    }
    
    UIScrollView *scrollView = currentShowCell.zoomView.scrollView;
    CGSize size = scrollView.bounds.size;
    CGSize contentSize = scrollView.contentSize;
    CGPoint contentOffset = scrollView.contentOffset;
    
    
    if (self.loopScrollView.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
        if (contentSize.height <= size.height) {
            return YES;
        }
        else {
            if (contentOffset.y<= 0.0 && ts.y > 0.0) {
                return YES;
            }
            else if (contentOffset.y >= contentSize.height - size.height && ts.y < 0) {
                return YES;
            }
        }
    }
    else {
        if (contentSize.width <= size.width) {
            return YES;
        }
        else {
            if (contentOffset.x<= 0.0 && ts.x > 0.0) {
                return YES;
            }
            else if (contentOffset.x >= contentSize.width - size.width && ts.x < 0.0) {
                return YES;
            }
        }
    }
    return NO;
    
}

@end
