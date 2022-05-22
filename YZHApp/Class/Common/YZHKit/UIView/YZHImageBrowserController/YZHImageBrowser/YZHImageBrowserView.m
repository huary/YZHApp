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
        
        UIView *transitionView = nil;
        if ([self.delegate respondsToSelector:@selector(imageBrowserView:willPanStartAtPoint:forCell:)]) {
//            loc = [panGesture locationInView:cell];
            transitionView = [self.delegate imageBrowserView:self willPanStartAtPoint:loc forCell:cell];
        }
        if (!transitionView) {
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
            UIImageView *transitionImageView = [[UIImageView alloc] init];
            transitionImageView.layer.anchorPoint = imgAnchorPoint;
            transitionImageView.frame = imgFrame;
            transitionImageView.image = cell.zoomView.image;
            transitionView = transitionImageView;
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
        }
        else {
            CGPoint anchorPoint = CGPointMake(0.5, 0.5);
            loc = [panGesture locationInView:transitionView];
            if (transitionView.bounds.size.width > 0 && transitionView.bounds.size.height > 0) {
                anchorPoint = CGPointMake(loc.x/transitionView.bounds.size.width, loc.y/transitionView.bounds.size.height);
            }
            CGRect frame = [transitionView.superview convertRect:transitionView.frame toView:self];
            transitionView.layer.anchorPoint = anchorPoint;
            transitionView.frame = frame;
            [self.panContext.transitionContainerView addSubview:transitionView];
        }
        
        self.panContext.transitionView = transitionView;
        [self.superview addSubview:self.panContext.transitionContainerView];

        if ([self.delegate respondsToSelector:@selector(imageBrowserView:didPanStartAtPoint:forCell:)]) {
            [self.delegate imageBrowserView:self didPanStartAtPoint:loc forCell:cell];
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
        
        if ([self.delegate respondsToSelector:@selector(imageBrowserView:updateAtPoint:changedValue:forCell:)]) {
            [self.delegate imageBrowserView:self updateAtPoint:loc changedValue:changedValue forCell:self.panContext.transitionCell];
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
            
            YZHImageCell *cell = self.panContext.transitionCell;
            
            self.panContext = nil;
            
            CGFloat changedValue = [self pri_changedValueForPoint:point];
            if (dismiss) {
                if ([self.delegate respondsToSelector:@selector(imageBrowserView:didDismissAtPoint:changedValue:forCell:)]) {
                    [self.delegate imageBrowserView:self didDismissAtPoint:loc changedValue:changedValue forCell:cell];
                }
            }
            else {
                if ([self.delegate respondsToSelector:@selector(imageBrowserView:didEndPanToRecoverAtPoint:changedValue:forCell:)]) {
                    [self.delegate imageBrowserView:self didEndPanToRecoverAtPoint:loc changedValue:changedValue forCell:cell];
                }
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
