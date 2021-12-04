//
//  YZHNavigationItnTypes.h
//  YZHApp
//
//  Created by bytedance on 2021/11/22.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define MIN_ALPHA_TO_HIDDEN  (0.01)

#define ITN_GET_PROPERTY(TYPE, F_NAME, DEF_V, ...)     \
- (TYPE)F_NAME                                  \
{                                               \
    __VA_ARGS__                                 \
    return self.hz_navigationEnable ? ([self hz_strongReferenceObjectForKey:@#F_NAME] ?: DEF_V) : DEF_V; \
}

#define ITN_SET_PROPERTY(TYPE, PROPERTY, SET_SUF,...)       \
- (void)set##SET_SUF:(TYPE)PROPERTY                         \
{                                                           \
    if (self.hz_navigationEnable) [self hz_addStrongReferenceObject:PROPERTY forKey:@#PROPERTY]; \
    __VA_ARGS__                                             \
}

#define ITN_WGET_PROPERTY(TYPE, F_NAME, DEF_V, ...)    \
- (TYPE)F_NAME                                  \
{                                               \
    __VA_ARGS__                                 \
    return self.hz_navigationEnable ? ([self hz_weakReferenceObjectForKey:@#F_NAME] ?: DEF_V) : DEF_V;    \
}

#define ITN_WSET_PROPERTY(TYPE, PROPERTY, SET_SUF,...)      \
- (void)set##SET_SUF:(TYPE)PROPERTY                         \
{                                                           \
    if (self.hz_navigationEnable) [self hz_addWeakReferenceObject:PROPERTY forKey:@#PROPERTY]; \
    __VA_ARGS__                                             \
}


#define ITN_GET_PROPERTY_C(TYPE, F_NAME, V_M, DEF_V, ...)       \
- (TYPE)F_NAME                                          \
{                                                       \
    __VA_ARGS__                                         \
    return self.hz_navigationEnable ? [({id obj = [self hz_strongReferenceObjectForKey:@#F_NAME]; if (!obj) obj=@(DEF_V); obj;}) V_M] : DEF_V; \
}

#define ITN_SET_PROPERTY_C(TYPE, PROPERTY,SET_SUF,...)       \
- (void)set##SET_SUF:(TYPE)PROPERTY                         \
{                                                           \
    if (self.hz_navigationEnable) [self hz_addStrongReferenceObject:@(PROPERTY) forKey:@#PROPERTY]; \
    __VA_ARGS__                                             \
}

//#define IS_SYSTEM_DEFAULT_NAVIGATION_BARITEM_STYLE(STYLE)       (STYLE ==YZHNavigationBarAndItemStyleDefault)

#define IS_CUSTOM_GLOBAL_NAVIGATION_BAR_STYLE(STYLE)        (STYLE == YZHNavigationBarAndItemStyleGlobalBarDefaultItem || \
                                                             STYLE == YZHNavigationBarAndItemStyleGlobalBarItem)

#define IS_CUSTOM_VC_NAVIGATION_BAR_STYLE(STYLE)            (STYLE == YZHNavigationBarAndItemStyleVCBarItem || \
                                                             STYLE == YZHNavigationBarAndItemStyleVCBarDefaultItem)

#define IS_SYSTEM_DEFAULT_NAVIGATION_ITEM_STYLE(STYLE)      (STYLE == YZHNavigationBarAndItemStyleDefault || \
                                                             STYLE == YZHNavigationBarAndItemStyleGlobalBarDefaultItem || \
                                                             STYLE == YZHNavigationBarAndItemStyleVCBarDefaultItem)

#define IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(STYLE)       (STYLE == YZHNavigationBarAndItemStyleGlobalBarItem)

#define IS_CUSTOM_VC_NAVIGATION_ITEM_STYLE(STYLE)           (STYLE == YZHNavigationBarAndItemStyleVCBarItem)

#define IS_CUSTOM_NAVIGATION_ITEM_STYLE(STYLE)              (!IS_SYSTEM_DEFAULT_NAVIGATION_ITEM_STYLE(STYLE))

static const BOOL NCPopGestureEnabled_s = YES;
static const BOOL NCHidesTabBarAfterPushed_s = YES;
static const NSTimeInterval NCTransitionDuration_s = 0.25;

static const BOOL VCPopGestureEnabled_s = YES;
static const CGFloat VCNavigationItemViewAlpha_s = 1.0;

static const CGFloat minAlphaToHidden_s = 0.01;

static const CGFloat navigationDefaultEdgeSpace_s = 12;
static const CGFloat navigationLeftEdgeSpace_s = 8;
static const CGFloat navigationRightEdgeSpace_s = 8;
static const CGFloat navigationLeftItemsSpace_s = 8;
static const CGFloat navigationRightItemsSpace_s = 8;
