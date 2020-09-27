//
//  UIView+UITraitCollectionView.m
//  LZGameBox
//
//  Created by yuan on 2020/3/23.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "UIView+UITraitCollectionView.h"


@implementation UIView (UITraitCollectionView)

- (void)setHz_traitCollectionView:(UITraitCollectionView *)hz_traitCollectionView
{
    UITraitCollectionView *prevView = self.hz_traitCollectionView;
    if (hz_traitCollectionView != prevView) {
        [prevView removeFromSuperview];
        if (hz_traitCollectionView) {
            hz_traitCollectionView.hidden = YES;
            [self insertSubview:hz_traitCollectionView atIndex:0];
        }
    }
    objc_setAssociatedObject(self, @selector(hz_traitCollectionView), hz_traitCollectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITraitCollectionView *)hz_traitCollectionView
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
