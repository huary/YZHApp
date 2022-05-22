//
//  UIViewController+YZHNavigationItn.m
//  YZHApp
//
//  Created by bytedance on 2021/11/26.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "UIViewController+YZHNavigation.h"
#import "UIViewController+YZHNavigationItn.h"
#import "UIViewController+YZHNavigationRootVCInitSetup.h"
#import "YZHNavigationItnTypes.h"
#import "YZHViewController+Internal.h"

@implementation UIViewController (YZHNavigationItn)

- (void)setHz_itn_navBarFrame:(CGRect)hz_itn_navBarFrame {
    [self hz_addStrongReferenceObject:[NSValue valueWithCGRect:hz_itn_navBarFrame] forKey:@"hz_itn_navBarFrame"];
}

- (CGRect)hz_itn_navBarFrame {
    NSValue *value = [self hz_strongReferenceObjectForKey:@"hz_itn_navBarFrame"];
    if (!value) {
        CGFloat itemViewLayoutHeight = STATUS_NAV_BAR_HEIGHT - STATUS_BAR_HEIGHT;
        return self.hz_navbarFrameBlock(self, &itemViewLayoutHeight);
    }
    return [value CGRectValue];
}

- (void)setHz_itn_itemViewLayoutHeight:(CGFloat)hz_itn_itemViewLayoutHeight {
    [self hz_addStrongReferenceObject:@(hz_itn_itemViewLayoutHeight) forKey:@"hz_itn_itemViewLayoutHeight"];
}

- (CGFloat)hz_itn_itemViewLayoutHeight {
    return [[self hz_strongReferenceObjectForKey:@"hz_itn_itemViewLayoutHeight"] floatValue];
}

ITN_SET_PROPERTY(YZHNavigationBarView *, hz_itn_navigationBarView, Hz_itn_navigationBarView, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).navigationBarView = hz_itn_navigationBarView;
        return;
    }
});
ITN_GET_PROPERTY(YZHNavigationBarView *, hz_itn_navigationBarView, nil, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).navigationBarView;
    }
});

ITN_SET_PROPERTY(YZHNavigationItemView *, hz_itn_navigationItemView, Hz_itn_navigationItemView, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).navigationItemView = hz_itn_navigationItemView;
        return;
    }
});
ITN_GET_PROPERTY(YZHNavigationItemView *, hz_itn_navigationItemView, nil, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).navigationItemView;
    }
});

ITN_SET_PROPERTY_C(CGFloat, hz_itn_leftItemsSpace, Hz_itn_leftItemsSpace, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).leftItemsSpace = hz_itn_leftItemsSpace;
        return;
    }
});
ITN_GET_PROPERTY_C(CGFloat, hz_itn_leftItemsSpace, floatValue, [UIViewController hz_navigationConfig].navigationLeftItemsSpace, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).leftItemsSpace;
    }
});

ITN_SET_PROPERTY_C(CGFloat, hz_itn_rightItemsSpace, Hz_itn_rightItemsSpace, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).rightItemsSpace = hz_itn_rightItemsSpace;
        return;
    }
});
ITN_GET_PROPERTY_C(CGFloat, hz_itn_rightItemsSpace, floatValue, [UIViewController hz_navigationConfig].navigationRightItemsSpace, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).rightItemsSpace;
    }
});

ITN_SET_PROPERTY_C(CGFloat, hz_itn_leftEdgeSpace, Hz_itn_leftEdgeSpace, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).leftEdgeSpace = hz_itn_leftEdgeSpace;
        return;
    }
});
ITN_GET_PROPERTY_C(CGFloat, hz_itn_leftEdgeSpace, floatValue, [UIViewController hz_navigationConfig].navigationLeftEdgeSpace, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).leftEdgeSpace;
    }
});

ITN_SET_PROPERTY_C(CGFloat, hz_itn_rightEdgeSpace, Hz_itn_rightEdgeSpace, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).rightEdgeSpace = hz_itn_rightEdgeSpace;
        return;
    }
});
ITN_GET_PROPERTY_C(CGFloat, hz_itn_rightEdgeSpace, floatValue, [UIViewController hz_navigationConfig].navigationRightEdgeSpace, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).rightEdgeSpace;
    }
});

@end
