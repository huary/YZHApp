//
//  YZHImageBrowser.m
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/6.
//  Copyright © 2019 yuan. All rights reserved.
//

#import "YZHImageBrowser.h"
#import "UIImageView+YZHAdd.h"
#import "YZHImageCell.h"
#import "YZHCGUtil.h"
#import "UIView+YZHAdd.h"

@implementation YZHImageBrowserAnimationContext

@end

@interface YZHImageBrowser ()<YZHLoopScrollViewDelegate, YZHImageCellDelegate,YZHImageBrowserViewDelegate>

@property (nonatomic, strong) UIView *showInView;

@property (nonatomic, strong) UIView *fromView;
@end

@implementation YZHImageBrowser

@synthesize imageBrowserView = _imageBrowserView;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupImageBrowserDefault];
    }
    return self;
}

- (void)_setupImageBrowserDefault
{
    self.animateDuration = 0.3;
    self.animationOptions = UIViewAnimationOptionCurveLinear;
    self.minZoomScale = 1.0;
    self.maxZoomScale = 5.0;
    self.actionOptions = -1;
//    self.separatorSpace = 20;
    self.imageCellClass = [YZHImageCell class];
}

-(YZHImageBrowserView*)imageBrowserView
{
    if (_imageBrowserView == nil) {
        _imageBrowserView = [YZHImageBrowserView new];
        _imageBrowserView.delegate = self;
        _imageBrowserView.loopScrollView.delegate = self;
    }
    return _imageBrowserView;
}

- (void)setImageCellClass:(Class)imageCellClass
{
    if ([imageCellClass isSubclassOfClass:[YZHImageCell class]]) {
        _imageCellClass = imageCellClass;
    }
}

- (void)_dismissFromImageCell:(YZHImageCell*)imageCell
{
    UIView *dismissToView = self.fromView;
    CGRect dismissToFrame = CGRectMake(self.showInView.frame.size.width/2, self.showInView.frame.size.height/2, 0, 0);
    if (dismissToView) {
        dismissToFrame = [dismissToView.superview convertRect:dismissToView.frame toView:self.showInView];
    }
    
    UIImageView *imageView = [UIImageView new];
    imageView.image = imageCell.zoomView.image;
    imageView.frame = [imageCell.zoomView.imageView.superview convertRect:imageCell.zoomView.imageView.frame toView:self.showInView];
    
    [self.showInView addSubview:imageView];
    self.imageBrowserView.loopScrollView.hidden = YES;
    
//    self.fromView.hidden = YES;
    dismissToView.hidden = YES;
    [UIView animateWithDuration:self.animateDuration delay:0 options:self.animationOptions animations:^{
        imageView.frame = dismissToFrame;
        self.imageBrowserView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
        [self pri_removeImageBrowserView];
//        self.fromView.hidden = NO;
        dismissToView.hidden = NO;
    }];
    
    if ([self.delegate respondsToSelector:@selector(imageBrowserDidDismiss:)]) {
        [self.delegate imageBrowserDidDismiss:self];
    }
}

- (void)pri_removeImageBrowserView
{
    [self.imageBrowserView removeFromSuperview];
    _imageBrowserView = nil;
}

- (YZHImageCell*)_updateImageCellWithModel:(id<YZHImageCellModelProtocol>)cellModel reusableCell:(YZHImageCell *_Nullable)reusableCell
{
    YZHImageCell *cell = reusableCell;
    if (!cell) {
        cell = [self.imageCellClass new];//[YZHImageCell new];
    }
    
    cell.zoomView.scrollView.minimumZoomScale = self.minZoomScale;
    cell.zoomView.scrollView.maximumZoomScale = self.maxZoomScale;
    
    cell.delegate = self;
    cell.model = cellModel;
    return cell;
}

- (void)_imageCell:(YZHImageCell*)cell zoomScaleInPoint:(CGPoint)point
{
    if (cell == nil || cell.zoomView.image == nil) {
        return;
    }
    
    CGFloat zoomScale = cell.zoomView.scrollView.zoomScale;
    CGFloat minScale = cell.zoomView.scrollView.minimumZoomScale;
    CGFloat maxScale = cell.zoomView.scrollView.maximumZoomScale;
    
    if (zoomScale < minScale) {
        zoomScale = minScale;
    }
    else if (zoomScale < maxScale) {
        zoomScale = maxScale;
    }
    else if (zoomScale >= maxScale) {
        zoomScale = minScale;
    }
    
    [cell.zoomView zoomScale:zoomScale inPoint:point];
}

#pragma mark YZHLoopScrollViewDelegate
//这个代理方法后会自动给cell设置model
- (YZHLoopCell *_Nullable)loopScrollView:(YZHLoopScrollView * _Nonnull)loopScrollView cellForModel:(id<YZHLoopCellModelProtocol>_Nullable)model withReusableCell:(YZHLoopCell *_Nullable)reusableCell
{
    id<YZHImageCellModelProtocol> cellModel = (id<YZHImageCellModelProtocol>)model;
    id<YZHImageCellModelProtocol> currModel = (id<YZHImageCellModelProtocol>)model;
    id<YZHImageCellModelProtocol> possibleModel = (id<YZHImageCellModelProtocol>)reusableCell.model;
    if ([self.delegate respondsToSelector:@selector(imageBrowser:newModelWithCurrentShowModel:possibleModel:)]) {
        cellModel = [self.delegate imageBrowser:self newModelWithCurrentShowModel:currModel possibleModel:possibleModel];
    }

    return [self _updateImageCellWithModel:(id<YZHImageCellModelProtocol>)cellModel reusableCell:(YZHImageCell * _Nullable)reusableCell];
}

//这个代理方法后不会给cell设置model,在返回cell的时候，cell的model已经赋值（因为不知道model）
- (YZHLoopCell *_Nullable)loopScrollView:(YZHLoopScrollView * _Nonnull)loopScrollView nextCellWithCurrentShowModel:(id<YZHLoopCellModelProtocol>_Nullable)currentShowModel withReusableCell:(YZHLoopCell *_Nullable)reusableCell
{
    id<YZHImageCellModelProtocol> cellModel = nil;
    id<YZHImageCellModelProtocol> currModel = (id<YZHImageCellModelProtocol>)currentShowModel;
    id<YZHImageCellModelProtocol> possibleModel = (id<YZHImageCellModelProtocol>)reusableCell.model;
    if ([self.delegate respondsToSelector:@selector(imageBrowser:nextModelWithCurrentShowModel:possibleModel:)]) {
        cellModel = [self.delegate imageBrowser:self nextModelWithCurrentShowModel:currModel possibleModel:possibleModel];
    }
    if (!cellModel) {
        return nil;
    }
    
    return [self _updateImageCellWithModel:cellModel reusableCell:(YZHImageCell * _Nullable)reusableCell];
}

//这个代理方法后不会给cell设置model,在返回cell的时候，cell的model已经赋值（因为不知道model）
-(YZHLoopCell *_Nullable)loopScrollView:(YZHLoopScrollView * _Nonnull)loopScrollView prevCellWithCurrentShowModel:(id<YZHLoopCellModelProtocol>_Nullable)currentShowModel withReusableCell:(YZHLoopCell *_Nullable)reusableCell
{
    id<YZHImageCellModelProtocol> cellModel = nil;
    id<YZHImageCellModelProtocol> currModel = (id<YZHImageCellModelProtocol>)currentShowModel;
    id<YZHImageCellModelProtocol> possibleModel = (id<YZHImageCellModelProtocol>)reusableCell.model;
    if ([self.delegate respondsToSelector:@selector(imageBrowser:prevModelWithCurrentShowModel:possibleModel:)]) {
        cellModel = [self.delegate imageBrowser:self prevModelWithCurrentShowModel:currModel possibleModel:possibleModel];
    }
    if (!cellModel) {
        return nil;
    }
    
    return [self _updateImageCellWithModel:cellModel reusableCell:(YZHImageCell * _Nullable)reusableCell];
}

- (void)loopScrollViewDidEndDragging:(YZHLoopScrollView * _Nonnull)loopScrollView willDecelerate:(BOOL)decelerate { 
    
}


- (void)loopScrollViewWillBeginDragging:(YZHLoopScrollView * _Nonnull)loopScrollView { 
    
}


#pragma mark YZHImageCellDelegate
- (void)imageCell:(YZHImageCell *)cell didTap:(UITapGestureRecognizer*)tap
{
    if (self.actionOptions & YZHImageBrowserActionOptionsSingleTapDismiss) {
        [self _dismissFromImageCell:cell];
    }
    if ([self.delegate respondsToSelector:@selector(imageBrowser:didTapImageCell:)]) {
        [self.delegate imageBrowser:self didTapImageCell:cell];
    }
}

- (void)imageCell:(YZHImageCell *)cell didDoubleTap:(UITapGestureRecognizer *)doubleTap
{
    if (self.actionOptions & YZHImageBrowserActionOptionsDoubleTapZoomScale) {
//        CGPoint point = [doubleTap locationInView:cell.zoomView.scrollView];
        CGPoint pt = [doubleTap locationInView:cell.zoomView.imageView];
        [self _imageCell:cell zoomScaleInPoint:pt];
    }
    if ([self.delegate respondsToSelector:@selector(imageBrowser:didDoubleTapImageCell:)]) {
        [self.delegate imageBrowser:self didDoubleTapImageCell:cell];
    }
}

- (void)imageCell:(YZHImageCell *)cell didLongPress:(UILongPressGestureRecognizer *)longPress
{
    if ([self.delegate respondsToSelector:@selector(imageBrowser:didLongPressImageCell:)]) {
        [self.delegate imageBrowser:self didLongPressImageCell:cell];
    }
}


#pragma mark public

- (void)setSeparatorSpace:(CGFloat)separatorSpace
{
    self.imageBrowserView.loopScrollView.separatorSpace = separatorSpace;
}

- (UIView *)showInView
{
    return _showInView;
}

- (UIView *)fromView
{
    return _fromView;
}

- (YZHImageCell*)currentShowCell
{
    return (YZHImageCell*)[self.imageBrowserView.loopScrollView currentShowCell];
}

- (void)showInView:(UIView *_Nullable)showInView
          fromView:(UIView *_Nullable)fromView
             image:(UIImage *_Nullable)image
         withModel:(id<YZHImageCellModelProtocol>)model
{
    YZHImageBrowserAnimationContext *ctx = [YZHImageBrowserAnimationContext new];
    ctx.willAnimateBlock = ^(YZHImageBrowser * _Nonnull imageBrowser, YZHImageBrowserAnimationContext * _Nonnull context) {
        
        UIView *showInView = context.showInView;
        
        CGRect fromFrame = CGRectMake(showInView.frame.size.width/2, context.showInView.frame.size.height/2, 0, 0);
        if (fromView) {
            fromFrame = [fromView.superview convertRect:fromView.frame toView:showInView];
        }
    
        UIViewContentMode contentMode = contentModeThatFits(showInView.hz_size, image.size);
        
        UIImageView *fromImageView = [UIImageView new];
        fromImageView.image = image;
        fromImageView.frame = fromFrame;
        fromImageView.contentMode = contentMode;
        fromImageView.layer.masksToBounds = YES;
        context.animationView = fromImageView;
    
        CGRect toFrame = rectWithContentMode(showInView.bounds.size, image.size, contentMode);
        //如果是长图，用fill显示时，从位置0开始
        if (contentMode == UIViewContentModeScaleAspectFill &&
            toFrame.origin.y < 0) {
            toFrame.origin.y = 0;
        }
        context.animationViewEndFrame = toFrame;
    };
    [self showInView:showInView fromView:fromView withModel:model animationContext:ctx];
}

- (void)showInView:(UIView *_Nullable)showInView
          fromView:(UIView *_Nullable)fromView
         withModel:(id<YZHImageCellModelProtocol>)model
  animationContext:(YZHImageBrowserAnimationContext *)animationContext
{
    if (showInView == nil) {
        showInView = [UIApplication sharedApplication].keyWindow;
    }
    self.showInView = showInView;
    self.fromView = fromView;
    
    [showInView addSubview:self.imageBrowserView];
    self.imageBrowserView.frame = showInView.bounds;
    [self.imageBrowserView.loopScrollView loadViewWithModel:model];
    
    animationContext.showInView = showInView;
    
    if (animationContext.willAnimateBlock) {
        animationContext.willAnimateBlock(self, animationContext);
    }
    
    if (animationContext.animationBlock) {
        animationContext.animationBlock(self, animationContext);
    }
    else {
        UIView *animationView = animationContext.animationView;
        [self.showInView addSubview:animationView];
    
        CGRect toFrame = animationContext.animationViewEndFrame;
    
        self.imageBrowserView.alpha = 0.0;
        self.imageBrowserView.loopScrollView.hidden = YES;
        fromView.hidden = YES;
        [UIView animateWithDuration:self.animateDuration delay:0 options:self.animationOptions animations:^{
            animationView.frame = toFrame;
            self.imageBrowserView.alpha = 1.0;
        } completion:^(BOOL finished) {
            fromView.hidden = NO;
            self.imageBrowserView.loopScrollView.hidden = NO;
            [animationView removeFromSuperview];
        }];
    }
    
    if (animationContext.didAnimateBlock) {
        animationContext.didAnimateBlock(self, animationContext);
    }
}

- (void)dismiss
{
    [self _dismissFromImageCell:[self currentShowCell]];
}


#pragma mark - YZHImageBrowserViewDelegate
- (CGRect)imageBrowserView:(YZHImageBrowserView * _Nonnull)imageBrowserView dismissToFrameForCell:(nonnull YZHImageCell *)imageCell {
    UIView *dismissToView = self.fromView;
    CGRect dismissToFrame = CGRectMake(self.showInView.frame.size.width/2, self.showInView.frame.size.height/2, 0, 0);
    if (dismissToView) {
        dismissToFrame = [dismissToView.superview convertRect:dismissToView.frame toView:self.showInView];
    }
    return dismissToFrame;
}

- (void)transitionView:(YZHLoopTransitionView *_Nonnull)transitionView didDismissAtPoint:(CGPoint)point changedValue:(CGFloat)changedValue
{
    if ([self.delegate respondsToSelector:@selector(imageBrowserDidDismiss:)]) {
        [self.delegate imageBrowserDidDismiss:self];
    }
}

@end
