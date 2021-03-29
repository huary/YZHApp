//
//  YZHImageCell.h
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/6.
//  Copyright © 2019 yuan. All rights reserved.
//

#import "YZHLoopCell.h"
#import "YZHZoomView.h"


NS_ASSUME_NONNULL_BEGIN
@class YZHImageCell;
@protocol YZHImageCellDelegate <NSObject>

- (void)imageCell:(YZHImageCell *)cell didTap:(UITapGestureRecognizer*)tap;

- (void)imageCell:(YZHImageCell *)cell didDoubleTap:(UITapGestureRecognizer *)doubleTap;

- (void)imageCell:(YZHImageCell *)cell didLongPress:(UILongPressGestureRecognizer *)longPress;


@end

@interface YZHImageCell : YZHLoopCell

@property (nonatomic, weak) id<YZHImageCellDelegate> delegate;

@property (nonatomic, strong, readonly) YZHZoomView *zoomView;

- (void)updateWithImage:(UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
