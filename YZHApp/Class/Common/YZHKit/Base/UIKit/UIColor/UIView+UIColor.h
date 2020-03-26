//
//  UIView+UIColor.h
//  LZGameBox
//
//  Created by yuan on 2020/3/23.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (UIColor)

- (void)setupLayerBorderColor:(UIColor *)color;

- (void)setupLayerShadowColor:(UIColor *)color;

- (void)setupLayerBackgroundColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
