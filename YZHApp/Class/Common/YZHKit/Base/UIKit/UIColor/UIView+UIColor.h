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

- (void)hz_setupLayerBorderColor:(UIColor *)color;

- (void)hz_setupLayerShadowColor:(UIColor *)color;

- (void)hz_setupLayerBackgroundColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
