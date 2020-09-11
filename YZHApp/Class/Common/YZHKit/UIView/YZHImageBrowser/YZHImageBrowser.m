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


@interface YZHImageBrowser ()<YZHLoopScrollViewDelegate, YZHImageCellDelegate,YZHImageBrowserViewDelegate>

@property (nonatomic, strong) UIView *showInView;

@property (nonatomic, strong) UIImageView *fromView;
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
    self.animateTimeInterval = 0.3;
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
//    id<YZHImageCellModelProtocol> cellModel = (id<YZHImageCellModelProtocol>)imageCell.model;
    UIImageView *dismissToView = self.fromView;
//    if ([cellModel respondsToSelector:@selector(dismissToImageViewBlock)] && cellModel.dismissToImageViewBlock) {
//        dismissToView = cellModel.dismissToImageViewBlock(cellModel, imageCell);
//    }
    CGRect dismissToFrame = [dismissToView.superview convertRect:dismissToView.frame toView:self.showInView];
    
    UIImageView *imageView = [UIImageView new];
    imageView.image = imageCell.zoomView.image;
    imageView.frame = [imageCell.zoomView.imageView.superview convertRect:imageCell.zoomView.imageView.frame toView:self.showInView];
    
    [self.showInView addSubview:imageView];
    self.imageBrowserView.loopScrollView.hidden = YES;
    
    self.fromView.hidden = YES;
    dismissToView.hidden = YES;
    [UIView animateWithDuration:self.animateTimeInterval delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        imageView.frame = dismissToFrame;
        self.imageBrowserView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
        [self pri_removeImageBrowserView];
        self.fromView.hidden = NO;
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
    cell.delegate = self;
    cell.model = cellModel;

//    CGPoint scale = [cell.zoomView imageViewScaleForContentMode:cell.zoomView.imageView.contentMode];
    CGPoint scale = [cell.zoomView imageViewScaleInSize:[self.imageBrowserView.loopScrollView cellContentViewFrame].size forContentMode:cell.zoomView.imageView.contentMode];
    
    CGFloat max = MAX(scale.x, scale.y);
    CGFloat min = MIN(scale.x, scale.y);
    
    cell.zoomView.scrollView.minimumZoomScale = MIN(self.minZoomScale, min);
    cell.zoomView.scrollView.maximumZoomScale = MAX(self.maxZoomScale, max);
    
//    if ([cellModel respondsToSelector:@selector(didUpdateBlock)] && cellModel.didUpdateBlock) {
//        cellModel.didUpdateBlock(cellModel, cell);
//    }
    
    return cell;
}

- (void)_imageCell:(YZHImageCell*)cell zoomScaleInPoint:(CGPoint)point
{
    if (cell == nil || cell.zoomView.image == nil) {
        return;
    }
    CGFloat zoomScale = cell.zoomView.scrollView.zoomScale;
    
//    CGPoint scale = [cell.zoomView imageViewScaleForContentMode:UIViewContentModeScaleAspectFit];
    CGPoint scale = [cell.zoomView imageViewScaleInSize:[self.imageBrowserView.loopScrollView cellContentViewFrame].size forContentMode:UIViewContentModeScaleAspectFit];
    CGFloat fitScale = MIN(scale.x, scale.y);
    CGFloat fullScale = MAX(scale.x, scale.y);
    
    zoomScale = (fullScale - zoomScale > 0.01) ? fullScale : fitScale;
    
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
        [self _imageCell:cell zoomScaleInPoint:[doubleTap locationInView:cell.zoomView]];
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

- (YZHImageCell*)currentShowCell
{
    return (YZHImageCell*)[self.imageBrowserView.loopScrollView currentShowCell];
}

- (void)showInView:(UIView*)showInView fromView:(UIImageView*)fromView withModel:(id<YZHImageCellModelProtocol>)model
{
    if (showInView == nil) {
        showInView = [UIApplication sharedApplication].keyWindow;
    }
    self.showInView = showInView;
    self.fromView = fromView;
    
    [showInView addSubview:self.imageBrowserView];
    self.imageBrowserView.frame = showInView.bounds;
    [self.imageBrowserView.loopScrollView loadViewWithModel:model];
    
    CGRect fromFrame = CGRectMake(self.showInView.frame.size.width/2, self.showInView.frame.size.height/2, 0, 0);
    if (fromView) {
        fromFrame = [fromView.superview convertRect:fromView.frame toView:showInView];
    }
    
    UIImageView *fromImageView = [UIImageView new];
    fromImageView.image = fromView.image;
    fromImageView.frame = fromFrame;
    [self.showInView addSubview:fromImageView];
    
    //这里按UIViewContentModeScaleAspectFit来进行
    UIViewContentMode contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect toFrame = CGRectZero;
    toFrame.size = [UIImageView image:fromImageView.image contentSizeInSize:showInView.bounds.size contentMode:contentMode];
    toFrame.origin = CGPointMake((showInView.bounds.size.width - toFrame.size.width)/2, (showInView.bounds.size.height - toFrame.size.height)/2);
    
    self.imageBrowserView.alpha = 0.0;
    self.imageBrowserView.loopScrollView.hidden = YES;
    fromView.hidden = YES;
    [UIView animateWithDuration:self.animateTimeInterval delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        fromImageView.frame = toFrame;
        self.imageBrowserView.alpha = 1.0;
    } completion:^(BOOL finished) {
        fromView.hidden = NO;
        self.imageBrowserView.loopScrollView.hidden = NO;
        [fromImageView removeFromSuperview];
    }];
}

- (void)dismiss
{
    [self _dismissFromImageCell:[self currentShowCell]];
}


#pragma mark - YZHImageBrowserViewDelegate
- (CGRect)imageBrowserView:(YZHImageBrowserView * _Nonnull)imageBrowserView dismissToFrameForCell:(nonnull YZHImageCell *)imageCell {
    UIImageView *dismissToView = self.fromView;
    CGRect dismissToFrame = [dismissToView.superview convertRect:dismissToView.frame toView:self.showInView];
    return dismissToFrame;
}

- (void)transitionView:(YZHLoopTransitionView *_Nonnull)transitionView didDismissAtPoint:(CGPoint)point changedValue:(CGFloat)changedValue
{
    if ([self.delegate respondsToSelector:@selector(imageBrowserDidDismiss:)]) {
        [self.delegate imageBrowserDidDismiss:self];
    }
}

@end
