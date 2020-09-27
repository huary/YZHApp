//
//  UIView+UIColor.m
//  LZGameBox
//
//  Created by yuan on 2020/3/23.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "UIView+UIColor.h"
#import "UIView+UITraitCollectionView.h"

typedef NS_ENUM(NSInteger, NSLayerColorTag)
{
    NSLayerColorTagBorder   = 1,
    NSLayerColorTagShadow   = 2,
    NSLayerColorTagBackground   = 3,
};

@implementation UIView (UIColor)

- (void)hz_setupLayerBorderColor:(UIColor *)color
{
    if (@available(iOS 13.0, *)) {
        if (self.hz_traitCollectionView == nil) {
            self.hz_traitCollectionView = [UITraitCollectionView new];
        }
        WEAK_SELF(weakSelf);
        [self.hz_traitCollectionView addTraitCollectionValueChangedBlock:^(UITraitCollectionView *view, id<NSCopying> key) {
            weakSelf.layer.borderColor = [color resolvedColorWithTraitCollection:weakSelf.traitCollection].CGColor;
        } forKey:@(NSLayerColorTagBorder)];
        self.layer.borderColor = [color resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
    else {
        self.layer.borderColor = color.CGColor;
    }
}

- (void)hz_setupLayerShadowColor:(UIColor *)color
{
    if (@available(iOS 13.0, *)) {
        if (self.hz_traitCollectionView == nil) {
            self.hz_traitCollectionView = [UITraitCollectionView new];
        }
        WEAK_SELF(weakSelf);
        [self.hz_traitCollectionView addTraitCollectionValueChangedBlock:^(UITraitCollectionView *view, id<NSCopying> key) {
            weakSelf.layer.shadowColor = [color resolvedColorWithTraitCollection:weakSelf.traitCollection].CGColor;
        } forKey:@(NSLayerColorTagShadow)];
        self.layer.shadowColor = [color resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
    else {
        self.layer.shadowColor = color.CGColor;
    }
}

- (void)hz_setupLayerBackgroundColor:(UIColor *)color
{
    if (@available(iOS 13.0, *)) {
        if (self.hz_traitCollectionView == nil) {
            self.hz_traitCollectionView = [UITraitCollectionView new];
        }
        WEAK_SELF(weakSelf);
        [self.hz_traitCollectionView addTraitCollectionValueChangedBlock:^(UITraitCollectionView *view, id<NSCopying> key) {
            weakSelf.layer.backgroundColor = [color resolvedColorWithTraitCollection:weakSelf.traitCollection].CGColor;
        } forKey:@(NSLayerColorTagBackground)];
        self.layer.backgroundColor = [color resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    }
    else {
        self.layer.backgroundColor = color.CGColor;
    }
}


@end
