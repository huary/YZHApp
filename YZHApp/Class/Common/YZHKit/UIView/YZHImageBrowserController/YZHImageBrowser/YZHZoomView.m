//
//  YZHZoomView.m
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/6.
//  Copyright © 2019 yuan. All rights reserved.
//

#import "YZHZoomView.h"
#import "UIImageView+YZHAdd.h"
#import "YZHCGUtil.h"

static YZHZoomViewDidUpdateBlock _didImageViewUpdateBlock_s = nil;

@interface YZHZoomView () <UIScrollViewDelegate>

@end

@implementation YZHZoomView

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;

+ (void)setDidImageViewUpdateBlock:(YZHZoomViewDidUpdateBlock)didImageViewUpdateBlock
{
    _didImageViewUpdateBlock_s = didImageViewUpdateBlock;
}

+ (YZHZoomViewDidUpdateBlock)didImageViewUpdateBlock
{
    return _didImageViewUpdateBlock_s;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self pri_setupZoomImageViewChildView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!CGRectEqualToRect(self.scrollView.frame, self.bounds)) {
        self.scrollView.frame = self.bounds;
    }
    [self pri_updateZoomImageView];
}

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
        _scrollView.delaysContentTouches = NO;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
        }
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self pri_setupImageViewKeyPathObserver:YES];
    }
    return _imageView;
}

- (void)pri_setupImageViewKeyPathObserver:(BOOL)add
{
    if (add) {
        [_imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//        [_imageView addObserver:self forKeyPath:@"contentMode" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    else {
        [_imageView removeObserver:self forKeyPath:@"image"];
//        [_imageView removeObserver:self forKeyPath:@"contentMode"];
    }
}

- (void)pri_setupZoomImageViewChildView
{
    [self addSubview:self.scrollView];
    self.scrollView.frame = self.bounds;
    [self.scrollView addSubview:self.imageView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]) {
        self.scrollView.zoomScale = 1.0;
        _image = self.imageView.image;
        [self pri_updateZoomImageView];
    }
    else if ([keyPath isEqualToString:@"contentMode"]) {
        [self pri_updateZoomImageView];
    }
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

- (void)pri_updateZoomImageView
{
    CGSize scrollViewSize = self.scrollView.bounds.size;
    if (scrollViewSize.width == 0 || scrollViewSize.height == 0 /*|| self.image == nil*/) {
        return;
    }
    CGSize imgSize = self.image.size;
    UIViewContentMode contentMode = self.imageView.contentMode;
    if (self.autoFitImageViewContentModeWithImage) {
        contentMode = contentModeThatFits(scrollViewSize, imgSize);
        self.imageView.contentMode = contentMode;
    }
    
    CGRect frame = rectWithContentMode(scrollViewSize, imgSize, contentMode);
    CGFloat w = MAX(scrollViewSize.width, frame.size.width);
    CGFloat h = MAX(scrollViewSize.height, frame.size.height);
    
    CGFloat x = (w - frame.size.width)/2;
    CGFloat y = (h - frame.size.height)/2;
    self.imageView.frame = CGRectMake(x, y, frame.size.width, frame.size.height);
    self.scrollView.contentSize = CGSizeMake(w, h);
    if (_didImageViewUpdateBlock_s) {
        _didImageViewUpdateBlock_s(self);
    }
}

- (CGRect)pri_zoomRectForScale:(float)scale inPoint:(CGPoint)point
{
    CGRect zoomRect;
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.origin.x = point.x - zoomRect.size.width * 0.5;
    zoomRect.origin.y = point.y - zoomRect.size.height * 0.5;
    return zoomRect;
}

- (void)zoomScale:(CGFloat)zoomScale inPoint:(CGPoint)point
{
    if (zoomScale == 0) {
        return;
    }
    CGRect zoomRect = [self pri_zoomRectForScale:zoomScale inPoint:point];
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark UIScrollViewDelegate
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize cSize = scrollView.contentSize;
    CGSize size = scrollView.bounds.size;
    
    CGFloat w = MAX(cSize.width, size.width);
    CGFloat h = MAX(cSize.height, size.height);
    self.imageView.center = CGPointMake(w/2, h/2);
}

- (void)dealloc
{
    [self pri_setupImageViewKeyPathObserver:NO];
}

@end
