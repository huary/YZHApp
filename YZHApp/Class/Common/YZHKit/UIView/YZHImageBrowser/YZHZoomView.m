//
//  YZHZoomView.m
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/6.
//  Copyright © 2019 yuan. All rights reserved.
//

#import "YZHZoomView.h"
#import "UIImageView+YZHAdd.h"

@interface YZHZoomView () <UIScrollViewDelegate>

@end

@implementation YZHZoomView

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupZoomImageViewChildView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!CGRectEqualToRect(self.scrollView.frame, self.bounds)) {
        self.scrollView.frame = self.bounds;
    }
    [self _updateZoomImageView:self.scrollView.zoomScale];
}

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
        _scrollView.delaysContentTouches = NO;
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_imageView addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return _imageView;
}

- (void)_setupZoomImageViewChildView
{
    [self addSubview:self.scrollView];
    self.scrollView.frame = self.bounds;
    [self.scrollView addSubview:self.imageView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]) {
        _image = self.imageView.image;
        [self _updateZoomImageView:1.0];
    }
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

- (void)_updateZoomImageView:(CGFloat)zoomScale
{
    self.scrollView.zoomScale = zoomScale;

    CGSize scrollViewSize = self.scrollView.bounds.size;
    if (scrollViewSize.width == 0 || scrollViewSize.height == 0) {
        return;
    }
    
    CGSize scrollContentSize = self.scrollView.contentSize;
    CGFloat w = MAX(scrollContentSize.width, scrollViewSize.width);
    CGFloat h = MAX(scrollContentSize.height, scrollViewSize.height);
    scrollContentSize = CGSizeMake(w, h);
    
    CGSize contentSize = [self.imageView contentImageSizeInSize:scrollContentSize];
    
    if (contentSize.width == 0 || contentSize.height == 0) {
        return;
    }
    
    CGFloat x = (scrollContentSize.width - contentSize.width)/2;
    CGFloat y = (scrollContentSize.height - contentSize.height)/2;
    
    self.imageView.frame = CGRectMake(x, y, contentSize.width, contentSize.height);
}

- (CGRect)_zoomRectForScale:(float)scale inPoint:(CGPoint)point
{
    CGRect zoomRect;
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.origin.x = point.x - (zoomRect.size.width/2.0);
    zoomRect.origin.y = point.y - (zoomRect.size.height/2.0);
    return zoomRect;
}

- (void)zoomScale:(CGFloat)zoomScale inPoint:(CGPoint)point
{
    if (zoomScale == 0) {
        return;
    }
    CGRect zoomRect = [self _zoomRectForScale:zoomScale inPoint:point];
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

- (CGPoint)imageViewScaleInSize:(CGSize)size forContentMode:(UIViewContentMode)contentMode
{
    if (self.image == nil) {
        return CGPointZero;
    }
    CGSize contentSize = [UIImageView image:self.image contentSizeInSize:size contentMode:contentMode];
    
    if (contentSize.width == 0 || contentSize.height == 0) {
        return CGPointZero;
    }
    
    CGSize scrollViewSize = size;//self.scrollView.bounds.size;
    
    CGFloat xScale = scrollViewSize.width/contentSize.width;
    CGFloat yScale = scrollViewSize.height/contentSize.height;
    
    return CGPointMake(xScale, yScale);
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
    [self.imageView removeObserver:self forKeyPath:@"image"];
}

@end
