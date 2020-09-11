//
//  YZHZoomView.h
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/6.
//  Copyright © 2019 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZHZoomView : UIView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

//contentMode 为UIViewContentModeScaleAspectFit
@property (nonatomic, strong, readonly) UIImageView *imageView;

//zoomscale > 0
- (void)zoomScale:(CGFloat)zoomScale inPoint:(CGPoint)point;
//这个需要在设置image后的才调用
- (CGPoint)imageViewScaleInSize:(CGSize)size forContentMode:(UIViewContentMode)contentMode;

@end

NS_ASSUME_NONNULL_END
