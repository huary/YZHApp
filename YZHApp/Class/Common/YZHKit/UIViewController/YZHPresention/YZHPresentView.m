//
//  YZHPresentView.m
//  YZHApp
//
//  Created by bytedance on 2022/5/20.
//  Copyright © 2022 yuan. All rights reserved.
//

#import "YZHPresentView.h"

@implementation YZHPresentView

- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11.0, *)) {
    } else {
        CGFloat r = self.layer.cornerRadius;
        CGFloat tl = (self.maskedCornerRadius & UIRectCornerTopLeft) ? r : 0;
        CGFloat tr = (self.maskedCornerRadius & UIRectCornerTopRight) ? r : 0;
        CGFloat bl = (self.maskedCornerRadius & UIRectCornerBottomLeft) ? r : 0;
        CGFloat br = (self.maskedCornerRadius & UIRectCornerBottomRight) ? r : 0;

        CAShapeLayer *shapeLayer = (CAShapeLayer*)self.layer.mask;
        shapeLayer.path = [UIBezierPath hz_bezierPathWithRoundedRect:self.bounds byRoundingCorners:self.maskedCornerRadius cornerRadiusList:@[@(tl),@(tr),@(bl),@(br)]].CGPath;
        self.layer.mask = shapeLayer;
    }
}

- (void)setMaskedCornerRadius:(UIRectCorner)maskedCornerRadius {
    _maskedCornerRadius = maskedCornerRadius;
    if (@available(iOS 11.0, *)) {
        self.layer.maskedCorners = (CACornerMask)maskedCornerRadius;
    } else {
        CGFloat r = self.layer.cornerRadius;
        CGFloat tl = (maskedCornerRadius & UIRectCornerTopLeft) ? r : 0;
        CGFloat tr = (maskedCornerRadius & UIRectCornerTopRight) ? r : 0;
        CGFloat bl = (maskedCornerRadius & UIRectCornerBottomLeft) ? r : 0;
        CGFloat br = (maskedCornerRadius & UIRectCornerBottomRight) ? r : 0;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [UIBezierPath hz_bezierPathWithRoundedRect:self.bounds byRoundingCorners:maskedCornerRadius cornerRadiusList:@[@(tl),@(tr),@(bl),@(br)]].CGPath;
        self.layer.mask = shapeLayer;
    }
}

@end
