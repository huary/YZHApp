//
//  YZHImageCell.m
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/6.
//  Copyright © 2019 yuan. All rights reserved.
//

#import "YZHImageCell.h"
#import "YZHImageCellModelProtocol.h"

@interface YZHImageCell ()

@end

@implementation YZHImageCell

@synthesize zoomView = _zoomView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self pri_setupImageCellChildView];
    }
    return self;
}

-(YZHZoomView*)zoomView
{
    if (_zoomView == nil) {
        _zoomView = [YZHZoomView new];
    }
    return _zoomView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.zoomView.frame = self.contentView.bounds;
}

- (void)pri_setupImageCellChildView
{
    [self.contentView addSubview:self.zoomView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pri_tapAction:)];
    [self addGestureRecognizer:tap];

    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pri_doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [tap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];


    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pri_longPressAction:)];
    [self addGestureRecognizer:longPress];
}

- (void)setModel:(id)model
{
    [super setModel:model];
    [self pri_updateZoomImageView];
}

- (void)pri_updateZoomImageView
{
    id<YZHImageCellModelProtocol> cellModel = (id<YZHImageCellModelProtocol>)self.model;
    cellModel.bindImageCell = self;
    self.zoomView.imageView.contentMode = cellModel.imageViewContentMode;
    if ([cellModel respondsToSelector:@selector(updateBlock)] && cellModel.updateBlock) {
        cellModel.updateBlock(cellModel, self);
    }
}


- (void)pri_tapAction:(UITapGestureRecognizer *)tapGesture
{
    if ([self.delegate respondsToSelector:@selector(imageCell:didTap:)]) {
        [self.delegate imageCell:self didTap:tapGesture];
    }
}

- (void)pri_doubleTapAction:(UITapGestureRecognizer *)doubleTap
{
    if ([self.delegate respondsToSelector:@selector(imageCell:didDoubleTap:)]) {
        [self.delegate imageCell:self didDoubleTap:doubleTap];
    }
}

- (void)pri_longPressAction:(UILongPressGestureRecognizer *)longPress
{
    if ([self.delegate respondsToSelector:@selector(imageCell:didLongPress:)]) {
        [self.delegate imageCell:self didLongPress:longPress];
    }
}

- (void)updateWithImage:(UIImage * _Nullable)image
{
    self.zoomView.image = image;
}
@end
