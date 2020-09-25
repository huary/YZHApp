//
//  YZHZoomView.h
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/6.
//  Copyright © 2019 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YZHZoomView;
typedef void(^YZHZoomViewDidUpdateBlock)(YZHZoomView *zoomView);

@interface YZHZoomView : UIView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

//contentMode 为UIViewContentModeScaleAspectFit
@property (nonatomic, strong, readonly) UIImageView *imageView;

//在imageView的image被更新时或者layout时调用
@property (nonatomic, copy, class) YZHZoomViewDidUpdateBlock didImageViewUpdateBlock;

/**
 * 是否自动根据UIImage来计算ImageView的contentMode，
 * 只会自动计算出UIViewContentModeScaleAspectFit和UIViewContentModeScaleAspectFill两种模式
 * 默认为NO
 */
@property (nonatomic, assign) BOOL autoFitImageViewContentModeWithImage;

//zoomscale > 0
- (void)zoomScale:(CGFloat)zoomScale inPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
