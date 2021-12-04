//
//  UIViewController+YZHNavigation.m
//  YZHApp
//
//  Created by bytedance on 2021/11/20.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "UIViewController+YZHNavigation.h"
#import "UIViewController+YZHNavigationItn.h"
#import "NSObject+YZHAdd.h"
#import "YZHVCUtils.h"
#import "YZHViewController.h"
#import "YZHViewController+Internal.h"
#import "YZHNavigationItnTypes.h"

static NSString *const kYZHIsViewDidLoadKey_s = @"hz_isViewDidLoadKey";
static NSString *const kYZHVCNavigationEnableKey_s = @"hz_VCNavigationEnableKey";

#define PREV_VC_CHECK(ret)   if (!self.hz_navigationEnable || [self isKindOfClass:[YZHViewController class]] || [self isKindOfClass:[UINavigationController class]] || [self isKindOfClass:[UITabBarController class]]) return ret;

@implementation UIViewController (YZHNavigation)

- (void)setHz_navigationEnable:(BOOL)hz_navigationEnable {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return;
    }
    if ([self hz_strongReferenceObjectForKey:kYZHIsViewDidLoadKey_s]) {
        return;
    }
    if (![self hz_strongReferenceObjectForKey:kYZHVCNavigationEnableKey_s]) {
        [self hz_addStrongReferenceObject:@(hz_navigationEnable) forKey:kYZHVCNavigationEnableKey_s];
    }
}

- (BOOL)hz_navigationEnable {
    return [[self hz_strongReferenceObjectForKey:kYZHVCNavigationEnableKey_s] boolValue];
}

ITN_SET_PROPERTY(NSString *, hz_navigationTitle, Hz_navigationTitle, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).navigationTitle = hz_navigationTitle;
        return;
    }
    itn_setNavigationTitle(self, hz_navigationTitle);
});
ITN_GET_PROPERTY(NSString *, hz_navigationTitle, nil, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).navigationTitle;
    }
});

ITN_SET_PROPERTY_C(YZHNavBarStyle, hz_navBarStyle, Hz_navBarStyle, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).navBarStyle = hz_navBarStyle;
        return;
    }
    itn_setNavBarStyle(self, hz_navBarStyle);
});
ITN_GET_PROPERTY_C(YZHNavBarStyle, hz_navBarStyle, integerValue, YZHNavBarStyleNone, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).navBarStyle;
    }
});

ITN_SET_PROPERTY(UIColor *, hz_navigationBarViewBackgroundColor,Hz_navigationBarViewBackgroundColor, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).navigationBarViewBackgroundColor = hz_navigationBarViewBackgroundColor;
        return;
    }
    itn_setNavigationBarViewBackgroundColor(self, hz_navigationBarViewBackgroundColor);
});
ITN_GET_PROPERTY(UIColor *, hz_navigationBarViewBackgroundColor, [[UINavigationBar appearance] barTintColor], {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).navigationBarViewBackgroundColor;
    }
});

ITN_SET_PROPERTY(UIColor *, hz_navigationBarBottomLineColor,Hz_navigationBarBottomLineColor, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).navigationBarBottomLineColor = hz_navigationBarBottomLineColor;
        return;
    }
    itn_setNavigationBarBottomLineColor(self, hz_navigationBarBottomLineColor);
});
ITN_GET_PROPERTY(UIColor *, hz_navigationBarBottomLineColor, nil, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).navigationBarBottomLineColor;
    }
});

ITN_SET_PROPERTY_C(CGFloat, hz_navigationBarViewAlpha,Hz_navigationBarViewAlpha, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).navigationBarViewAlpha = hz_navigationBarViewAlpha;
        return;
    }
    itn_setNavigationBarViewAlpha(self, hz_navigationBarViewAlpha);
});
ITN_GET_PROPERTY_C(CGFloat, hz_navigationBarViewAlpha, floatValue, 0, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).navigationBarViewAlpha;
    }
});

ITN_SET_PROPERTY_C(CGFloat, hz_navigationItemViewAlpha,Hz_navigationItemViewAlpha, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).navigationItemViewAlpha = hz_navigationItemViewAlpha;
        return;
    }
    itn_setNavigationItemViewAlpha(self, hz_navigationItemViewAlpha);
});
ITN_GET_PROPERTY_C(CGFloat, hz_navigationItemViewAlpha, floatValue, VCNavigationItemViewAlpha_s, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).navigationItemViewAlpha;
    }
});

ITN_SET_PROPERTY_C(BOOL, hz_popGestureEnabled, Hz_popGestureEnabled, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).popGestureEnabled = hz_popGestureEnabled;
        return;
    }
});
ITN_GET_PROPERTY_C(BOOL, hz_popGestureEnabled, boolValue, VCPopGestureEnabled_s, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).popGestureEnabled;
    }
});

ITN_SET_PROPERTY_C(NSTimeInterval, hz_transitionDuration, Hz_transitionDuration, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).transitionDuration = hz_transitionDuration;
        return;
    }
});
ITN_GET_PROPERTY_C(NSTimeInterval, hz_transitionDuration, floatValue, 0, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).transitionDuration;
    }
});

ITN_SET_PROPERTY_C(CGFloat, hz_layoutTopY, Hz_layoutTopY, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).layoutTopY = hz_layoutTopY;
        return;
    }
});
ITN_GET_PROPERTY_C(CGFloat, hz_layoutTopY, floatValue, 0, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).layoutTopY;
    }
});

ITN_SET_PROPERTY(NSDictionary*, hz_titleTextAttributes, Hz_titleTextAttributes, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        ((YZHViewController*)self).titleTextAttributes = hz_titleTextAttributes;
        return;
    }
    itn_setTitleTextAttributes(self, hz_titleTextAttributes);
});
ITN_GET_PROPERTY(NSDictionary*, hz_titleTextAttributes, nil, {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return ((YZHViewController*)self).titleTextAttributes;
    }
});

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self hz_exchangeInstanceMethod:@selector(viewDidLoad) with:@selector(hz_viewDidLoad)];
        [self hz_exchangeInstanceMethod:@selector(viewWillLayoutSubviews) with:@selector(hz_viewWillLayoutSubviews)];
        [self hz_exchangeInstanceMethod:@selector(setTitle:) with:@selector(hz_setTitle:)];
    });
}

- (void)hz_viewDidLoad {
    [self hz_viewDidLoad];
    
    [self hz_addStrongReferenceObject:@(YES) forKey:kYZHIsViewDidLoadKey_s];
    
    PREV_VC_CHECK();
    
    itn_viewDidLoad(self);
}

- (void)hz_viewWillLayoutSubviews {
    [self hz_viewWillLayoutSubviews];

    PREV_VC_CHECK();

    itn_viewWillLayoutSubviews(self);
}

- (void)hz_setTitle:(NSString *)title {
    [self hz_setTitle:title];
    
    PREV_VC_CHECK();
    
    self.hz_navigationTitle = title;
}

//这个带<剪头的返回按钮
-(UIButton *)hz_addNavigationFirstLeftBackItemWithTitle:(NSString*)title target:(id)target action:(SEL)selector
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationFirstLeftBackItemWithTitle:title target:target action:selector];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationFirstLeftBackItemWithTitleTargetSelector(self, title, target, selector);
}

//这个带<剪头的返回按钮,这个是重置操作，清空原来所有的LeftButtonItems,block
-(UIButton *)hz_addNavigationFirstLeftBackItemWithTitle:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationFirstLeftBackItemWithTitle:title actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationFirstLeftBackItemWithTitleActionBlock(self, title, actionBlock);
}

//自定义第一个按钮（image，title）
-(UIButton *)hz_addNavigationFirstLeftItemWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)selector
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationFirstLeftItemWithImageName:imageName title:title target:target action:selector];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationFirstLeftItemWithImageNameTitleTargetSelector(self, imageName, title, target, selector);
}

//自定义第一个按钮（image，title）block
-(UIButton *)hz_addNavigationFirstLeftItemWithImageName:(NSString*)imageName title:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationFirstLeftItemWithImageName:imageName title:title actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationFirstLeftItemWithImageNameTitleActionBlock(self, imageName, title, actionBlock);
}

//自定义一个按钮（image，title）
-(UIButton *)hz_addNavigationLeftItemWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemWithImageName:imageName title:title target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemWithImageNameTitleTargetSelectorIsReset(self, imageName, title, target, selector, reset);
}

//自定义一个按钮（image，title）block
-(UIButton *)hz_addNavigationLeftItemWithImageName:(NSString*)imageName title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemWithImageName:imageName title:title isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemWithImageNameTitleIsResetActionBlock(self, imageName, title, reset, actionBlock);
}

//自定义一个按钮（image，title）
-(UIButton *)hz_addNavigationLeftItemWithImage:(UIImage*)image title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemWithImage:image title:title target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemWithImageTitleTargetSelectorIsReset(self, image, title, target, selector, reset);
}

//自定义一个按钮（image，title）block
-(UIButton *)hz_addNavigationLeftItemWithImage:(UIImage*)image title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemWithImage:image title:title isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemWithImageTitleIsResetActionBlock(self, image, title, reset, actionBlock);
}

//titles中的第一个NSString被用来作为第一个item的title
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationFirstLeftBackItemsWithTitles:titles target:target action:selector];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationFirstLeftBackItemsWithTitlesTargetSelector(self, titles, target, selector);
}

//titles中的第一个NSString被用来作为第一个item的title,block
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithTitles:(NSArray<NSString*> *)titles actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationFirstLeftBackItemsWithTitles:titles actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationFirstLeftBackItemsWithTitlesActionBlock(self, titles, actionBlock);
}

//imageNames中的第一个imageName是第二个item
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationFirstLeftBackItemsWithImageNames:imageNames target:target action:selector];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationFirstLeftBackItemsWithImageNamesTargetSelector(self, imageNames, target, selector);
}

//imageNames中的第一个imageName是第二个item,block
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithImageNames:(NSArray<NSString*> *)imageNames actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationFirstLeftBackItemsWithImageNames:imageNames actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationFirstLeftBackItemsWithImageNamesActionBlock(self, imageNames, actionBlock);
}

//images中的第一个image是第二个item
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithImage:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationFirstLeftBackItemsWithImage:images target:target action:selector];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationFirstLeftBackItemsWithImageTargetSelector(self, images, target, selector);
}

//images中的第一个image是第二个item,block
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithImage:(NSArray<UIImage*> *)images actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationFirstLeftBackItemsWithImage:images actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationFirstLeftBackItemsWithImageActionBlock(self, images, actionBlock);
}

//添加leftButtonItem
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithTitles:titles target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithTitlesTargetSelectorIsReset(self, titles, target, selector, reset);
}

//添加leftButtonItem,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithTitles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithTitles:titles isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithTitlesIsResetActionBlock(self, titles, reset, actionBlock);
}

//添加leftButtonItem
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithImageNames:imageNames target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithImageNamesTargetSelectorIsReset(self, imageNames, target, selector, reset);
}

//添加leftButtonItem,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithImageNames:imageNames isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithImageNamesIsResetActionBlock(self, imageNames, reset, actionBlock);
}

//添加leftButtonItem
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithImages:images target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithImagesTargetSelectorIsReset(self, images, target, selector, reset);
}

//添加leftButtonItem,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithImages:images isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithImagesIsResetActionBlock(self, images, reset, actionBlock);
}

//添加自定义的leftButtonItem
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithCustomView:leftItems target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithCustomViewTargetSelectorIsReset(self, leftItems, target, selector, reset);
}

//添加自定义的leftButtonItem,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithCustomView:leftItems isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithCustomViewIsResetActionBlock(self, leftItems, reset, actionBlock);
}

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithImageNames:imageNames titles:titles target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithImageNamesTitlesTargetSelectorIsReset(self, imageNames, titles, target, selector, reset);
}

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithImageNames:imageNames titles:titles isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithImageNamesTitlesIsResetActionBlock(self, imageNames, titles, reset, actionBlock);
}

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithImages:images titles:titles target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithImagesTitlesTargetSelectorIsReset(self, images, titles, target, selector, reset);
}

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemsWithImages:images titles:titles isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemsWithImagesTitlesIsResetActionBlock(self, images, titles, reset, actionBlock);
}

//通过YZHGraphicsContext来添加leftButtonItem
-(UIButton *)hz_addNavigationLeftItemWithGraphicsImageContext:(YZHGraphicsContext*)graphicsImageContext title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemWithGraphicsImageContext:graphicsImageContext title:title target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemWithGraphicsImageContextTitleTargetSelectorIsReset(self, graphicsImageContext, title, target, selector, reset);
}

//通过YZHGraphicsContext来添加leftButtonItem,block
-(UIButton *)hz_addNavigationLeftItemWithGraphicsImageContext:(YZHGraphicsContext*)graphicsImageContext title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationLeftItemWithGraphicsImageContext:graphicsImageContext title:title isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationLeftItemWithGraphicsImageContextTitleIsResetActionBlock(self, graphicsImageContext, title, reset, actionBlock);
}

//right
//添加（title）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationRightItemsWithTitles:titles target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationRightItemsWithTitlesTargetSelectorIsReset(self, titles, target, selector, reset);
}

//添加（title）这样的按钮，block
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithTitles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationRightItemsWithTitles:titles isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationRightItemsWithTitlesIsResetActionBlock(self, titles, reset, actionBlock);
}

//添加（image）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationRightItemsWithImageNames:imageNames target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationRightItemsWithImageNamesTargetSelectorIsReset(self, imageNames, target, selector, reset);
}

//添加（image）这样的按钮,block
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithImageNames:(NSArray<NSString*> *)imageNames isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationRightItemsWithImageNames:imageNames isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationRightItemsWithImageNamesIsResetActionBlock(self, imageNames, reset, actionBlock);
}

//添加（image）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithImages:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationRightItemsWithImages:images target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationRightItemsWithImagesTargetSelectorIsReset(self, images, target, selector, reset);
}

//添加（image）这样的按钮,block
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithImages:(NSArray<UIImage*> *)images isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationRightItemsWithImages:images isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationRightItemsWithImagesIsResetActionBlock(self, images, reset, actionBlock);
}

//添加（UIView）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationRightItemsWithCustomView:rightItems target:target action:selector isReset:reset];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationRightItemsWithCustomViewTargetSelectorIsReset(self, rightItems, target, selector, reset);
}

//添加（UIView）这样的按钮,block
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationRightItemsWithCustomView:rightItems isReset:reset actionBlock:actionBlock];
    }
    PREV_VC_CHECK(nil);
    return itn_addNavigationRightItemsWithCustomViewIsResetActionBlock(self, rightItems, reset, actionBlock);
}

-(void)hz_setupItemsSpace:(CGFloat)itemsSpace left:(BOOL)left {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self setupItemsSpace:itemsSpace left:left];
    }
    PREV_VC_CHECK();
    if (left) {
        self.hz_itn_leftItemsSpace = itemsSpace;
    }
    else {
        self.hz_itn_rightItemsSpace = itemsSpace;
    }
    return itn_setupItemsSpace(self, itemsSpace, left);
}

-(void)hz_setupItemEdgeSpace:(CGFloat)edgeSpace left:(BOOL)left {
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self setupItemEdgeSpace:edgeSpace left:left];
    }
    PREV_VC_CHECK();
    if (left) {
        self.hz_itn_leftEdgeSpace = edgeSpace;
    }
    else {
        self.hz_itn_rightEdgeSpace = edgeSpace;
    }
    return itn_setupItemEdgeSpace(self, edgeSpace, left);
}

-(void)hz_addNavigationBarCustomView:(UIView*)customView
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self addNavigationBarCustomView:customView];
    }
    PREV_VC_CHECK();
    return itn_addNavigationBarCustomView(self, customView);
}

- (UIView *)hz_navigationBar
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self navigationBarView];
    }
    PREV_VC_CHECK(nil);
    return itn_navigationBar(self);
}

- (CGFloat)hz_navigationBarTopLayout
{
    if ([self isKindOfClass:[YZHViewController class]]) {
        return [(YZHViewController*)self navigationBarTopLayout];
    }
    PREV_VC_CHECK(0);
    return itn_navigationBarTopLayout(self);
}

@end
