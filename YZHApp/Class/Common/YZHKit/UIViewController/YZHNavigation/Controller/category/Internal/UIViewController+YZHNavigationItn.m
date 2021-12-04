//
//  UIViewController+YZHNavigationItn.m
//  YZHApp
//
//  Created by bytedance on 2021/11/26.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "UIViewController+YZHNavigation.h"
#import "UIViewController+YZHNavigationItn.h"
#import "YZHNavigationItnTypes.h"
#import "YZHViewController+Internal.h"

@implementation UIViewController (YZHNavigationItn)

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
ITN_GET_PROPERTY_C(CGFloat, hz_itn_leftItemsSpace, floatValue, navigationLeftItemsSpace_s, {
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
ITN_GET_PROPERTY_C(CGFloat, hz_itn_rightItemsSpace, floatValue, navigationRightItemsSpace_s, {
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
ITN_GET_PROPERTY_C(CGFloat, hz_itn_leftEdgeSpace, floatValue, navigationLeftEdgeSpace_s, {
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
ITN_GET_PROPERTY_C(CGFloat, hz_itn_rightEdgeSpace, floatValue, navigationRightEdgeSpace_s, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).rightEdgeSpace;
    }
});

@end
