//
//  UIView+UITraitCollectionView.m
//  LZGameBox
//
//  Created by yuan on 2020/3/23.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "UIView+UITraitCollectionView.h"


@implementation UIView (UITraitCollectionView)

- (void)setTraitCollectionView:(UITraitCollectionView *)traitCollectionView
{
    UITraitCollectionView *prevView = self.traitCollectionView;
    if (traitCollectionView != prevView) {
        [prevView removeFromSuperview];
        if (traitCollectionView) {
            traitCollectionView.hidden = YES;
            [self insertSubview:traitCollectionView atIndex:0];
        }
    }
    objc_setAssociatedObject(self, @selector(traitCollectionView), traitCollectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITraitCollectionView *)traitCollectionView
{
    return objc_getAssociatedObject(self, @selector(traitCollectionView));
}

@end
