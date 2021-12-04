//
//  YZHVCUtils.m
//  YZHApp
//
//  Created by bytedance on 2021/11/20.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "YZHVCUtils.h"
#import "UIViewController+YZHNavigation.h"
#import "UIViewController+YZHNavigationItn.h"
#import "YZHNavigationItnTypes.h"
#import "UINavigationController+YZHNavigation.h"
#import "UINavigationController+YZHNavigationItn.h"
#import "YZHNavigationController+Internal.h"

#define IS_USEABLE_FOR_NC(NC)   ([NC isKindOfClass:[YZHNavigationController class]] || NC.hz_navigationEnable)


void _clearOldNavigationBar(UIViewController *vc)
{
    [vc.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [vc.navigationController.navigationBar setShadowImage:[UIImage new]];
}

void _clearOldNavigationItemTitleView(UIViewController *vc)
{
    vc.navigationItem.titleView = [[UIView alloc] init];
}

void _clearOldNavigationItemLeftBarButtonItem(UIViewController *vc)
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    vc.navigationItem.leftBarButtonItem = barButtonItem;
}

void _clearOldNavigationItemRightBarButtonItem(UIViewController *vc)
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    vc.navigationItem.rightBarButtonItem = barButtonItem;
}

void _setUpNavigationBarAndItemView(UIViewController *vc)
{
    UIViewController *self = vc;
    UINavigationController *navigationController = self.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(barAndItemStyle)) {
            _clearOldNavigationItemTitleView(self);
            _clearOldNavigationItemLeftBarButtonItem(self);
            _clearOldNavigationItemRightBarButtonItem(self);
            [navigationController hz_itn_createNewNavigationItemViewForViewController:self];
            self.hz_layoutTopY = 0;
        }
        else if (barAndItemStyle == YZHNavigationBarAndItemStyleVCBarItem)
        {
            CGFloat w = self.view.bounds.size.width;
                        
            CGRect frame = CGRectMake(0, 0, w, STATUS_NAV_BAR_HEIGHT);
            self.hz_itn_navigationBarView = [[YZHNavigationBarView alloc] initWithFrame:frame];
            [self.view addSubview:self.hz_itn_navigationBarView];
            
            self.hz_itn_navigationItemView = [[YZHNavigationItemView alloc] initWithFrame:self.hz_itn_navigationBarView.bounds];
            self.hz_itn_navigationItemView.backgroundColor = CLEAR_COLOR;
            [self.hz_itn_navigationBarView addSubview:self.hz_itn_navigationItemView];
            
            self.hz_layoutTopY = CGRectGetMaxY(frame);
        }
        else if (barAndItemStyle == YZHNavigationBarAndItemStyleVCBarDefaultItem)
        {
            CGFloat w = self.view.bounds.size.width;
            CGRect frame = CGRectMake(0, 0, w, STATUS_NAV_BAR_HEIGHT);
            self.hz_itn_navigationBarView = [[YZHNavigationBarView alloc] initWithFrame:frame];
            [self.view addSubview:self.hz_itn_navigationBarView];
            self.hz_layoutTopY = CGRectGetMaxY(frame);
        }
    }
}

void _navigationBarNotificationAction(UIViewController *vc, NSNotification*notification)
{
    NSValue *centerPointValue = [notification.userInfo objectForKey:YZHNavigationBarCenterPointKey];
    if (!centerPointValue) {
        return;
    }
    CGPoint center = [centerPointValue CGPointValue];
    UINavigationController *navigationController = vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
        if (barAndItemStyle == YZHNavigationBarAndItemStyleVCBarItem) {
            if (center.y > 0) {
                center.y = vc.hz_itn_navigationBarView.bounds.size.height/2;
            }
            else {
                center.y = -vc.hz_itn_navigationBarView.bounds.size.height/2;
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                vc.hz_itn_navigationBarView.center = center;
            }];
        }
    }
}

void _addNavigationObserver(UIViewController *vc)
{
    __weak UIViewController *weakVC = vc;
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:YZHNavigationBarAttributeChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong UIViewController *strongVC = weakVC;
        if (strongVC) {
            _navigationBarNotificationAction(strongVC, note);
        }
    }];
    [vc hz_addDeallocBlock:^(void * _Nonnull deallocTarget) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer name:YZHNavigationBarAttributeChangedNotification object:nil];
    }];
}

void itn_viewDidLoad(UIViewController *vc) {
    _setUpNavigationBarAndItemView(vc);
    _addNavigationObserver(vc);
}

void itn_viewWillLayoutSubviews(UIViewController *vc)
{
    UIViewController *self = vc;
    CGRect frame = CGRectMake(SAFE_X, -STATUS_BAR_HEIGHT, SAFE_WIDTH, STATUS_NAV_BAR_HEIGHT);
    UINavigationController *navigationController = self.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(barAndItemStyle)) {
            [navigationController hz_resetNavigationBarAndItemViewFrame:frame];
        }
    }
    
    if (self.hz_itn_navigationBarView) {
        CGFloat width = self.view.bounds.size.width;
        frame = CGRectMake(0, 0, width, STATUS_NAV_BAR_HEIGHT);
        [self.view bringSubviewToFront:self.hz_itn_navigationBarView];
        self.hz_itn_navigationBarView.frame = frame;
    }
    self.hz_layoutTopY = CGRectGetMaxY(self.hz_itn_navigationBarView.frame);
    self.hz_navigationTitle = self.hz_navigationTitle;
}

void itn_setNavigationBarViewBackgroundColor(UIViewController *vc, UIColor *navigationBarViewBackgroundColor)
{
    UINavigationController *navigationController = vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        if (IS_CUSTOM_VC_NAVIGATION_BAR_STYLE(navigationController.hz_navigationBarAndItemStyle)) {
            vc.hz_itn_navigationBarView.backgroundColor = navigationBarViewBackgroundColor;
        }
        else
        {
            navigationController.hz_navigationBarViewBackgroundColor = navigationBarViewBackgroundColor;
        }
    }
    else
    {
        vc.navigationController.navigationBar.barTintColor = navigationBarViewBackgroundColor;
    }
}

void itn_setNavigationBarBottomLineColor(UIViewController *vc, UIColor *navigationBarBottomLineColor)
{
    UINavigationController *navigationController = vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        if (IS_CUSTOM_VC_NAVIGATION_BAR_STYLE(navigationController.hz_navigationBarAndItemStyle)) {
            vc.hz_itn_navigationBarView.bottomLine.backgroundColor = navigationBarBottomLineColor;
        }
        else
        {
            navigationController.hz_navigationBarBottomLineColor = navigationBarBottomLineColor;
        }
    }
    else
    {
        if (navigationBarBottomLineColor) {
            UIImage *image = [[UIImage new] hz_createImageWithSize:CGSizeMake(vc.navigationController.navigationBar.bounds.size.width, SINGLE_LINE_WIDTH) tintColor:navigationBarBottomLineColor];
            [vc.navigationController.navigationBar setShadowImage:image];
        }
        else {
            [vc.navigationController.navigationBar setShadowImage:nil];
        }
    }
}

void itn_setNavBarStyle(UIViewController *vc, YZHNavBarStyle navBarStyle)
{
    UINavigationController *navigationController = vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        if (IS_CUSTOM_VC_NAVIGATION_BAR_STYLE(navigationController.hz_navigationBarAndItemStyle)) {
            vc.hz_itn_navigationBarView.style = navBarStyle;
        }
        else
        {
            navigationController.hz_navBarStyle = navBarStyle;
        }
    }
}

void itn_setNavigationTitle(UIViewController *vc, NSString *navigationTitle)
{
    UINavigationController *navigationController = vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(barAndItemStyle)) {
            [navigationController hz_itn_setNavigationItemTitle:navigationTitle forViewController:vc];
        }
        else if (IS_CUSTOM_VC_NAVIGATION_ITEM_STYLE(barAndItemStyle))
        {
            [vc.hz_itn_navigationItemView setTitle:navigationTitle];
        }
        else {
            vc.navigationItem.title = navigationTitle;
        }
    }
    else {
        vc.navigationItem.title = navigationTitle;
    }
}

void itn_setTitle(UIViewController *vc, NSString *title)
{
    vc.hz_navigationTitle = title;
}

void itn_setNavigationBarViewAlpha(UIViewController *vc, CGFloat navigationBarViewAlpha)
{
    UINavigationController *navigationController = vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        if (IS_CUSTOM_VC_NAVIGATION_BAR_STYLE(navigationController.hz_navigationBarAndItemStyle)) {
            vc.hz_itn_navigationBarView.alpha = navigationBarViewAlpha;
            if (navigationBarViewAlpha <= minAlphaToHidden_s) {
                vc.hz_itn_navigationBarView.hidden = YES;
                vc.hz_layoutTopY = 0;
            }
            else {
                vc.hz_itn_navigationBarView.hidden = NO;
                vc.hz_layoutTopY = CGRectGetMaxY(vc.hz_itn_navigationBarView.frame);
            }
        }
        else
        {
            navigationController.hz_navigationBarViewAlpha = navigationBarViewAlpha;
            vc.hz_layoutTopY = 0;
        }
    }
    else
    {
        vc.navigationController.navigationBar.alpha = navigationBarViewAlpha;
        if (navigationBarViewAlpha <= minAlphaToHidden_s) {
            vc.navigationController.navigationBar.hidden = YES;
        }
        else {
            vc.navigationController.navigationBar.hidden = NO;
        }
        vc.hz_layoutTopY = 0;
    }
}

void itn_setNavigationItemViewAlpha(UIViewController *vc, CGFloat navigationItemViewAlpha)
{
    UINavigationController *navigationController = vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(barAndItemStyle)) {
            [navigationController hz_itn_setNavigationItemViewAlpha:navigationItemViewAlpha minToHidden:YES forViewController:vc];
        }
        else if (IS_CUSTOM_VC_NAVIGATION_ITEM_STYLE(barAndItemStyle))
        {
            vc.hz_itn_navigationItemView.alpha = navigationItemViewAlpha;
            if (navigationItemViewAlpha <= minAlphaToHidden_s) {
                vc.hz_itn_navigationItemView.hidden = YES;
            }
            else {
                vc.hz_itn_navigationItemView.hidden = NO;
            }
        }
        else
        {
        }
    }
}

void itn_setTitleTextAttributes(UIViewController *vc, NSDictionary<NSAttributedStringKey,id> *titleTextAttributes)
{
    UINavigationController *navigationController = vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(barAndItemStyle)) {
            [navigationController hz_itn_setNavigationItemTitleTextAttributes:titleTextAttributes forViewController:vc];
        }
        else if (IS_CUSTOM_VC_NAVIGATION_ITEM_STYLE(barAndItemStyle))
        {
            vc.hz_itn_navigationItemView.titleTextAttributes = titleTextAttributes;
        }
        else
        {
            
        }
    }
}

BOOL _shouldGraphiceImage(UIViewController *vc,UIImage *image)
{
    UIViewController *self = vc;
    if (image == nil) {
        return YES;
    }
    if (image.size.height > NAV_ITEM_HEIGH) {
        return YES;
    }
    return NO;
}

UIColor *_navigationBarButtonItemTintColor(void)
{
    UIColor *color = [[[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal] objectForKey:NSForegroundColorAttributeName];
    if (color) {
        return color;
    }
    color = [UIBarButtonItem appearance].tintColor;
    if (color) {
        return color;
    }
    color = [[UINavigationBar appearance].titleTextAttributes objectForKey:NSForegroundColorAttributeName];
    if (color) {
        return color;
    }
    return BLACK_COLOR;
}

UIFont *_navigationBarButtonItemFont(void)
{
    UIFont *font = [[[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal] objectForKey:NSFontAttributeName];
    if (font) {
        return font;
    }
    return [[UINavigationBar appearance].titleTextAttributes objectForKey:NSFontAttributeName];
}

UIColor *_navigationBarButtonItemBGColor(UIControlState state)
{
    UIColor *color = [[[UIBarButtonItem appearance] titleTextAttributesForState:state] objectForKey:NSBackgroundColorAttributeName];
    if (color) {
        return color;
    }

    color = [[UINavigationBar appearance].titleTextAttributes objectForKey:NSBackgroundColorAttributeName];
    if (!color) {
        color = CLEAR_COLOR;
    }
    return color;
}

CGRect _getNavigationItemFrameForImageSize(UIViewController *vc, CGSize imageSize, CGSize*graphicsSize)
{
    UIViewController *self = vc;
    if (imageSize.width == 0 || imageSize.height == 0) {
        return CGRectMake(0, 0, 0, 0);
    }
    CGFloat itemHeight = NAV_ITEM_HEIGH;
    CGFloat itemWidth = itemHeight * NAV_IMAGE_ITEM_WIDTH_WITH_HEIGHT_RATIO;
    
    CGFloat imageRatio = imageSize.width/imageSize.height;
    CGFloat imageHeigth = itemHeight * NAVIGATION_ITEM_IMAGE_HEIGHT_WITH_NAVIGATION_BAR_HEIGHT_RATIO;
    CGFloat imageWidth = imageHeigth * imageRatio;
    
    itemWidth = MAX(itemWidth, imageWidth);
    
    if (graphicsSize) {
        *graphicsSize = CGSizeMake(itemWidth, itemHeight);
    }
    
    return CGRectMake((itemWidth - imageWidth)/2, (itemHeight - imageHeigth)/2, imageWidth, imageHeigth);
}

UIImage *_createGraphicesImage(UIViewController *vc, YZHGraphicsContext *graphicsContext, UIColor*strokeColor)
{
    UIViewController *self = vc;
    YZHGraphicsBeginInfo *beginInfo = graphicsContext.beginInfo;
    if (beginInfo && beginInfo.graphicsSize.width <= 0 && beginInfo.graphicsSize.height <= 0) {
        beginInfo.graphicsSize = CGSizeMake(NAV_BAR_HEIGHT, NAV_BAR_HEIGHT);
    }
    return [graphicsContext createGraphicesImageWithStrokeColor:strokeColor];
}

UIImage *_createLeftBackImageForColor(UIViewController *vc, UIColor *color, CGFloat width)
{
    UIViewController *self = vc;
    width = MAX(15, width);
    YZHGraphicsContext *ctx = [[YZHGraphicsContext alloc] initWithBeginBlock:^(YZHGraphicsContext *context) {
        context.beginInfo = [[YZHGraphicsBeginInfo alloc] init];
        context.beginInfo.lineWidth = 2.5;
        context.beginInfo.graphicsSize = CGSizeMake(width, NAV_BAR_HEIGHT);
        context.imageAlignment = YZHGraphicsImageAlignmentLeft;
    } runBlock:^(YZHGraphicsContext *context) {
        
        CGSize size = context.beginInfo.graphicsSize;
        CGFloat height = size.height * NAVIGATION_ITEM_LEFT_BACK_HEIGHT_WITH_NAVIGATION_BAR_HEIGHT_RATIO;//0.55;
        CGFloat width = height/2;
        CGFloat startY = (size.height - height)/2;
        CGFloat endY = size.height - startY;
        
        CGFloat remX = size.width - width;
        CGFloat shiftX = 0;
        if (context.imageAlignment == YZHGraphicsImageAlignmentLeft) {
            shiftX += 0;
        }
        else if (context.imageAlignment == YZHGraphicsImageAlignmentCenter) {
            shiftX += remX/2;
        }
        else if (context.imageAlignment == YZHGraphicsImageAlignmentRight) {
            shiftX += remX;
        }
        CGFloat lineWidth = context.beginInfo.lineWidth;
        
        CGContextMoveToPoint(context.ctx, shiftX + width, startY + lineWidth/2);
        CGContextAddLineToPoint(context.ctx, shiftX + lineWidth/2, (startY + endY)/2);
        CGContextAddLineToPoint(context.ctx, shiftX + width, endY - lineWidth/2);
        
        CGContextSetStrokeColorWithColor(context.ctx, color.CGColor);
    } endPathBlock:nil];
    UIImage *image = _createGraphicesImage(self, ctx, nil);
    return image;
}

UIImage *_createNavigationItemImageForImage(UIViewController *vc,UIImage *image)
{
    if (!image) {
        return nil;
    }
    
    if (!_shouldGraphiceImage(vc, image)) {
        return image;
    }
    CGSize graphicsSize;
    CGRect frame = _getNavigationItemFrameForImageSize(vc, image.size, &graphicsSize);
    YZHGraphicsContext *ctx = [[YZHGraphicsContext alloc] initWithBeginBlock:^(YZHGraphicsContext *context) {
        context.beginInfo = [[YZHGraphicsBeginInfo alloc] init];
        context.beginInfo.graphicsSize = graphicsSize;
    } runBlock:^(YZHGraphicsContext *context) {
        [image drawInRect:frame];
    } endPathBlock:nil];
    UIImage *newImage =_createGraphicesImage(vc,ctx,nil);
    return newImage;
}

UIImage *_createNavigationItemImageForView(UIViewController *vc, UIView*view)
{
    CGSize viewSize = view.bounds.size;
    if (CGSizeEqualToSize(viewSize, CGSizeZero)) {
        [view sizeToFit];
        viewSize = view.bounds.size;
    }
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, SCREEN_SCALE);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

UIButton* _createButtonItemWithImage(UIViewController *vc, UIImage*image, NSString *title, UIColor *color)
{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.backgroundColor = _navigationBarButtonItemBGColor(UIControlStateNormal);
    if (image) {
        [buttonItem setImage:image forState:UIControlStateNormal];
        [buttonItem setImage:image forState:UIControlStateHighlighted];
        [buttonItem setImage:image forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    if (IS_AVAILABLE_NSSTRNG(title)) {
        [buttonItem setTitle:title forState:UIControlStateNormal];
        [buttonItem setTitleColor:color forState:UIControlStateNormal];
        buttonItem.titleLabel.font = _navigationBarButtonItemFont();
    }
    [buttonItem sizeToFit];
    
#if 0
    [buttonItem.titleLabel sizeToFit];
    CGRect frame = buttonItem.titleLabel.frame;
    frame.origin.x = (buttonItem.bounds.size.width-buttonItem.titleLabel.bounds.size.width)/2;
    if (image) {
        frame.origin.x = CGRectGetMaxX(buttonItem.imageView.frame);
    }
    frame.origin.y = (buttonItem.bounds.size.height - buttonItem.titleLabel.bounds.size.height)/2;
    buttonItem.titleLabel.frame = frame;
#endif
    return buttonItem;
}

UIButton *_createButtonItemWithImageTitleColorTargetSelector(UIViewController *vc, UIImage *image, NSString *title, UIColor *color, id target, SEL selector)
{
    UIButton *buttonItem = _createButtonItemWithImage(vc,image,title,color);
    
    [buttonItem addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return buttonItem;
}

UIButton *_createButtonItemWithImageTitleColorActionBlock(UIViewController *vc,UIImage *image, NSString *title, UIColor *color, YZHNavigationItemActionBlock actionBlock)
{
    UIButton *buttonItem = _createButtonItemWithImage(vc,image,title,color);
    __weak UIViewController *weakVC = vc;
    [buttonItem hz_addControlEvent:UIControlEventTouchUpInside actionBlock:^(UIButton *button) {
        __strong UIViewController *strongVC = weakVC;
        if (actionBlock) {
            actionBlock(strongVC, button);
        }
    }];
    return buttonItem;
}

UIButton *_createButtonItemWithGraphicsImageContextTitleTargetSelector(UIViewController *vc, YZHGraphicsContext *graphicsImageContext, NSString *title, id target, SEL selector)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    UIImage *image = _createGraphicesImage(vc,graphicsImageContext,color);
    UIButton *buttonItem = _createButtonItemWithImageTitleColorTargetSelector(vc, image, title, color, target, selector);
    return buttonItem;
}

UIButton *_createButtonItemWithGraphicsImageContextTitleActionBlock(UIViewController *vc, YZHGraphicsContext *graphicsImageContext, NSString *title, YZHNavigationItemActionBlock actionBlock)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    UIImage *image = _createGraphicesImage(vc,graphicsImageContext, color);
    UIButton *buttonItem = _createButtonItemWithImageTitleColorActionBlock(vc,image, title, color, actionBlock);
    return buttonItem;
}

UIImage *_createNavigationItemImageWithImageName(UIViewController *vc, NSString*imageName, UIColor *color ,BOOL hasTitle)
{
    UIImage *image = nil;
    if (IS_AVAILABLE_NSSTRNG(imageName)) {
        image = _createNavigationItemImageForImage(vc,[UIImage imageNamed:imageName]);
    }
    else {
        if (hasTitle) {
            image = _createLeftBackImageForColor(vc,color,0);
        }
        else {
            image = _createLeftBackImageForColor(vc,color,40);
        }
    }
    return image;
}

UIButton *_createLeftBackButtonItemWithImageNameTitleTargetSelector(UIViewController *vc,NSString* imageName, NSString *title, id target, SEL selector)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    UIImage *image = _createNavigationItemImageWithImageName(vc, imageName, color, IS_AVAILABLE_NSSTRNG(title));
    UIButton *buttonItem = _createButtonItemWithImageTitleColorTargetSelector(vc,image, title, color, target, selector);
    return buttonItem;
}

UIButton *_createLeftBackButtonItemWithImageNameTitleActionBlock(UIViewController *vc, NSString*imageName, NSString *title, YZHNavigationItemActionBlock actionBlock)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    UIImage *image = _createNavigationItemImageWithImageName(vc, imageName, color, IS_AVAILABLE_NSSTRNG(title));
    UIButton *buttonItem = _createButtonItemWithImageTitleColorActionBlock(vc, image, title, color, actionBlock);
    return buttonItem;
}

NSArray<UIButton*>* _createNavigationButtonItemsWithTitlesTargetSelector(UIViewController *vc, NSArray<NSString*>*titles, id target, SEL selector)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (NSString *title in titles) {
        UIButton *btn = _createButtonItemWithImageTitleColorTargetSelector(vc, nil, title, color, target, selector);
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

NSArray<UIButton*>* _createNavigationButtonItemsWithTitlesActionBlock(UIViewController *vc, NSArray<NSString*> *titles, YZHNavigationItemActionBlock actionBlock)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (NSString *title in titles) {
        UIButton *btn = _createButtonItemWithImageTitleColorActionBlock(vc, nil, title, color, actionBlock);
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

NSArray<UIButton*> *_createNavigationButtonItemsWithImageNamesTargetSelector(UIViewController *vc, NSArray<NSString*> *imageNames, id target, SEL selector)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    NSMutableArray *navigationButtonItems = [NSMutableArray array];

    for (NSString *imageName in imageNames) {
        UIImage *oldImage = [UIImage imageNamed:imageName];
        UIImage *image = _createNavigationItemImageForImage(vc, oldImage);
        UIButton *btn = _createButtonItemWithImageTitleColorTargetSelector(vc, image, nil, color, target,selector);
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

NSArray<UIButton*> *_createNavigationButtonItemsWithImageNamesActionBlock(UIViewController *vc, NSArray<NSString*>*imageNames, YZHNavigationItemActionBlock actionBlock)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (NSString *imageName in imageNames) {
        UIImage *oldImage = [UIImage imageNamed:imageName];
        UIImage *image = _createNavigationItemImageForImage(vc,oldImage);
        UIButton *btn = _createButtonItemWithImageTitleColorActionBlock(vc, image, nil, color, actionBlock);
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

NSArray<UIButton*> *_createNavigationButtonItemsWithImagesTargetSelector(UIViewController *vc, NSArray<UIImage*> *images, id target, SEL selector)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (UIImage *image in images) {
        UIImage *newImg = _createNavigationItemImageForImage(vc,image);
        UIButton *btn = _createButtonItemWithImageTitleColorTargetSelector(vc, newImg, nil, color, target, selector);
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

NSArray<UIButton*> *_createNavigationButtonItemsWithImagesActionBlock(UIViewController *vc, NSArray<UIImage*> *images, YZHNavigationItemActionBlock actionBlock)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (UIImage *image in images) {
        UIImage *newImg = _createNavigationItemImageForImage(vc,image);
        UIButton *btn = _createButtonItemWithImageTitleColorActionBlock(vc,newImg, nil, color, actionBlock);
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

NSArray<UIButton*> *_createNavigationButtonItemsWithViewsTargetSelector(UIViewController *vc, NSArray<UIView*>*views, id target, SEL selector)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (UIView *view in views) {
        UIImage *viewImg = _createNavigationItemImageForView(vc,view);
        UIImage *image = _createNavigationItemImageForImage(vc,viewImg);
        UIButton *btn = _createButtonItemWithImageTitleColorTargetSelector(vc, image, nil, color, target, selector);
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

NSArray<UIButton*> *_createNavigationButtonItemsWithViewsActionBlock(UIViewController *vc,NSArray<UIView*>* views, YZHNavigationItemActionBlock actionBlock)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (UIView *view in views) {
        UIImage *viewImg = _createNavigationItemImageForView(vc,view);
        UIImage *image = _createNavigationItemImageForImage(vc,viewImg);
        UIButton *btn = _createButtonItemWithImageTitleColorActionBlock(vc, image, nil, color, actionBlock);
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

NSArray<UIButton*> *_createNavigationButtonItemsWithImageNamesTitlesTargetSelectorActionBlock(UIViewController *vc, NSArray<NSString*> *imageNames, NSArray<NSString*> *titles, id target, SEL selector, YZHNavigationItemActionBlock actionBlock)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    NSInteger cnt = MAX(imageNames.count, titles.count);
    
    for (NSInteger i = 0; i < cnt; ++i) {
        UIImage *image = nil;
        NSString *title = nil;
        if (i < imageNames.count) {
            NSString *imageName = [imageNames objectAtIndex:i];
            UIImage *oldImage = [UIImage imageNamed:imageName];
            image = _createNavigationItemImageForImage(vc,oldImage);
        }
        
        if (i < titles.count) {
            title = [titles objectAtIndex:i];
        }
        
        UIButton *btn = nil;
        if (target) {
            btn = _createButtonItemWithImageTitleColorTargetSelector(vc, image, title, color, target, selector);
        }
        else if (actionBlock) {
            btn = _createButtonItemWithImageTitleColorActionBlock(vc, image, title, color, actionBlock);
        }

        if (!btn) {
            btn = _createButtonItemWithImageTitleColorTargetSelector(vc, image, title, color, target, selector);
        }
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

NSArray<UIButton*> *_createNavigationButtonItemsWithImagesTitlesTargetSelectorActionBlock(UIViewController *vc, NSArray<UIImage*> *images, NSArray<NSString*> *titles, id target, SEL selector, YZHNavigationItemActionBlock actionBlock)
{
    UIColor *color = _navigationBarButtonItemTintColor();
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    NSInteger cnt = MAX(images.count, titles.count);
    
    for (NSInteger i = 0; i < cnt; ++i) {
        UIImage *image = nil;
        NSString *title = nil;
        if (i < images.count) {
            UIImage *oldImage = [images objectAtIndex:i];
            image = _createNavigationItemImageForImage(vc,oldImage);
        }
        
        if (i < titles.count) {
            title = [titles objectAtIndex:i];
        }

        UIButton *btn = nil;
        if (target) {
            btn = _createButtonItemWithImageTitleColorTargetSelector(vc, image, title, color, target, selector);
        }
        else if (actionBlock) {
            btn = _createButtonItemWithImageTitleColorActionBlock(vc, image, title, color, actionBlock);
        }
        
        if (!btn) {
            btn = _createButtonItemWithImageTitleColorTargetSelector(vc, image, title, color, target, selector);
        }
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

void _addNavigationItemWithButton(UIViewController *vc, UIButton *button, BOOL reset, BOOL left)
{
    UINavigationController *navigationController = vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(barAndItemStyle)) {
            if (left) {
                _clearOldNavigationItemLeftBarButtonItem(vc);
                [navigationController hz_itn_addNavigationItemViewLeftButtonItems:@[button] isReset:reset forViewController:vc];
            }
            else {
                _clearOldNavigationItemRightBarButtonItem(vc);
                [navigationController hz_itn_addNavigationItemViewRightButtonItems:@[button] isReset:reset forViewController:vc];
            }
            return;
        }
        else if (IS_CUSTOM_VC_NAVIGATION_ITEM_STYLE(barAndItemStyle))
        {
            if (left) {
                _clearOldNavigationItemLeftBarButtonItem(vc);
                [vc.hz_itn_navigationItemView setLeftButtonItems:@[button] isReset:reset];
            }
            else {
                _clearOldNavigationItemRightBarButtonItem(vc);
                [vc.hz_itn_navigationItemView setRightButtonItems:@[button] isReset:reset];
            }
            return;
        }
    }
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.tag = 1;
    if (left) {
        space.width = vc.hz_itn_leftEdgeSpace;
        _clearOldNavigationItemLeftBarButtonItem(vc);
        vc.navigationItem.leftBarButtonItems = @[space, item];
    }
    else {
        space.width = vc.hz_itn_rightEdgeSpace;
        _clearOldNavigationItemRightBarButtonItem(vc);
        vc.navigationItem.rightBarButtonItems = @[space, item];
    }
}

void _addNavigationItemWithButtons(UIViewController *vc, NSArray<UIButton*>*buttons, BOOL reset, BOOL left)
{
    UINavigationController *navigationController = (UINavigationController*)vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(barAndItemStyle)) {
            if (left) {
                [navigationController hz_itn_addNavigationItemViewLeftButtonItems:buttons isReset:reset forViewController:vc];
            }
            else {
                [navigationController hz_itn_addNavigationItemViewRightButtonItems:buttons isReset:reset forViewController:vc];
            }
            return;
        }
        else if (IS_CUSTOM_VC_NAVIGATION_ITEM_STYLE(barAndItemStyle))
        {
            if (left) {
                [vc.hz_itn_navigationItemView setLeftButtonItems:buttons isReset:reset];
            }
            else {
                [vc.hz_itn_navigationItemView setRightButtonItems:buttons isReset:reset];
            }
            return;
        }
    }
    
    NSMutableArray *systemItems = nil;
    if (!reset) {
        if (left) {
            systemItems = [vc.navigationItem.leftBarButtonItems mutableCopy];
        }
        else {
            systemItems = [vc.navigationItem.rightBarButtonItems mutableCopy];
        }
    }
    if (systemItems == nil) {
        systemItems = [NSMutableArray array];
    }
    
    __block NSInteger tag = 0;
    [systemItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.customView) {
            tag = MAX(tag, obj.customView.tag);
        }
    }];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if (systemItems.count == 0) {
        space.width = left ? vc.hz_itn_leftEdgeSpace : vc.hz_itn_rightEdgeSpace;
    }
    else {
        space.width = left ? vc.hz_itn_leftItemsSpace : vc.hz_itn_rightItemsSpace;
    }
    [systemItems addObject:space];
    
    space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = left ? vc.hz_itn_leftItemsSpace : vc.hz_itn_rightItemsSpace;
    
    for (UIButton *buttonItem in buttons) {
        buttonItem.tag = ++tag;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
        [systemItems addObject:item];
        [systemItems addObject:space];
    }
    [systemItems removeLastObject];
    if (left) {
        vc.navigationItem.leftBarButtonItems = systemItems;
    }
    else {
        vc.navigationItem.rightBarButtonItems = systemItems;
    }
}

//这个带<剪头的返回按钮
UIButton *itn_addNavigationFirstLeftBackItemWithTitleTargetSelector(UIViewController *vc, NSString *title, id target, SEL selector)
{
    UIButton *leftButtonItem = _createLeftBackButtonItemWithImageNameTitleTargetSelector(vc, nil, title, target, selector);
    _addNavigationItemWithButton(vc, leftButtonItem,YES, YES);
    return leftButtonItem;
}

//这个带<剪头的返回按钮,这个是重置操作，清空原来所有的LeftButtonItems,block
UIButton *itn_addNavigationFirstLeftBackItemWithTitleActionBlock(UIViewController *vc, NSString *title, YZHNavigationItemActionBlock actionBlock)
{
    UIButton *leftButtonItem = _createLeftBackButtonItemWithImageNameTitleActionBlock(vc, nil, title, actionBlock);
    _addNavigationItemWithButton(vc, leftButtonItem, YES, YES);
    return leftButtonItem;
}

//自定义第一个按钮（image，title）
UIButton *itn_addNavigationFirstLeftItemWithImageNameTitleTargetSelector(UIViewController *vc, NSString *imageName, NSString *title, id target, SEL selector)
{
    UIButton *leftBtn = itn_addNavigationLeftItemWithImageNameTitleTargetSelectorIsReset(vc, imageName, title, target, selector, YES);
    return leftBtn;
}

//自定义第一个按钮（image，title）block
UIButton *itn_addNavigationFirstLeftItemWithImageNameTitleActionBlock(UIViewController *vc, NSString *imageName, NSString *title, YZHNavigationItemActionBlock actionBlock)
{
    UIButton *leftBtn = itn_addNavigationLeftItemWithImageNameTitleIsResetActionBlock(vc, imageName, title, YES, actionBlock);
    return leftBtn;
}

//自定义一个按钮（image，title）
UIButton *itn_addNavigationLeftItemWithImageNameTitleTargetSelectorIsReset(UIViewController *vc, NSString *imageName, NSString *title, id target, SEL selector, BOOL reset)
{
    UIImage *image = [UIImage imageNamed:imageName];
    return itn_addNavigationLeftItemWithImageTitleTargetSelectorIsReset(vc, image, title, target, selector, reset);
}

//自定义一个按钮（image，title）block
UIButton *itn_addNavigationLeftItemWithImageNameTitleIsResetActionBlock(UIViewController *vc, NSString *imageName, NSString *title, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    UIImage *image = [UIImage imageNamed:imageName];
    return itn_addNavigationLeftItemWithImageTitleIsResetActionBlock(vc, image, title, reset, actionBlock);
}

//自定义一个按钮（image，title）
UIButton *itn_addNavigationLeftItemWithImageTitleTargetSelectorIsReset(UIViewController *vc, UIImage *image, NSString *title, id target, SEL selector, BOOL reset)
{
    image = _createNavigationItemImageForImage(vc, image);
    UIButton *leftButtonItem = _createButtonItemWithImageTitleColorTargetSelector(vc, image, title, _navigationBarButtonItemTintColor(), target, selector);
    _addNavigationItemWithButton(vc, leftButtonItem, reset, YES);
    return leftButtonItem;
}

//自定义一个按钮（image，title）block
UIButton *itn_addNavigationLeftItemWithImageTitleIsResetActionBlock(UIViewController *vc, UIImage *image, NSString *title, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    image = _createNavigationItemImageForImage(vc, image);
    UIButton *leftButtonItem = _createButtonItemWithImageTitleColorActionBlock(vc, image, title, _navigationBarButtonItemTintColor(),actionBlock);
    _addNavigationItemWithButton(vc, leftButtonItem, reset, YES);
    return leftButtonItem;
}

//titles中的第一个NSString被用来作为第一个item的title
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithTitlesTargetSelector(UIViewController *vc, NSArray<NSString*> *titles, id target, SEL selector)
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = _createLeftBackButtonItemWithImageNameTitleTargetSelector(vc, nil, [titles firstObject], target, selector);
    [leftButtonItems addObject:leftBackButton];
    
    if (titles.count > 1) {
        NSArray *sub = [titles subarrayWithRange:NSMakeRange(1, titles.count - 1)];
        NSArray *leftButtonItemsTmp = _createNavigationButtonItemsWithImageNamesTitlesTargetSelectorActionBlock(vc, nil, sub, target, selector, nil);
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    _addNavigationItemWithButtons(vc, leftButtonItems, YES, YES);
    
    return [leftButtonItems copy];
}

//titles中的第一个NSString被用来作为第一个item的title,block
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithTitlesActionBlock(UIViewController *vc, NSArray<NSString*> *titles, YZHNavigationItemActionBlock actionBlock)
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = _createLeftBackButtonItemWithImageNameTitleActionBlock(vc, nil, [titles firstObject], actionBlock);
    [leftButtonItems addObject:leftBackButton];
    
    if (titles.count > 1) {
        NSArray *sub = [titles subarrayWithRange:NSMakeRange(1, titles.count - 1)];
        NSArray *leftButtonItemsTmp = _createNavigationButtonItemsWithImageNamesTitlesTargetSelectorActionBlock(vc, nil, sub, nil, NULL, actionBlock);
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    _addNavigationItemWithButtons(vc, leftButtonItems, YES, YES);
    
    return [leftButtonItems copy];
}

//imageNames中的第一个imageName是第二个item
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithImageNamesTargetSelector(UIViewController *vc, NSArray<NSString*> *imageNames, id target, SEL selector)
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = _createLeftBackButtonItemWithImageNameTitleTargetSelector(vc, nil, nil, target, selector);
    [leftButtonItems addObject:leftBackButton];
    
    if (imageNames.count > 0) {
        NSArray *leftButtonItemsTmp = _createNavigationButtonItemsWithImageNamesTargetSelector(vc, imageNames, target, selector);
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    _addNavigationItemWithButtons(vc, leftButtonItems, YES, YES);
    
    return [leftButtonItems copy];
}

//imageNames中的第一个imageName是第二个item,block
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithImageNamesActionBlock(UIViewController *vc, NSArray<NSString*> *imageNames, YZHNavigationItemActionBlock actionBlock)
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = _createLeftBackButtonItemWithImageNameTitleActionBlock(vc, nil, nil, actionBlock);
    [leftButtonItems addObject:leftBackButton];
    
    if (imageNames.count > 0) {
        NSArray *leftButtonItemsTmp = _createNavigationButtonItemsWithImageNamesActionBlock(vc, imageNames, actionBlock);
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    _addNavigationItemWithButtons(vc, leftButtonItems, YES, YES);
    
    return [leftButtonItems copy];
}

//images中的第一个image是第二个item
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithImageTargetSelector(UIViewController *vc, NSArray<UIImage*> *images, id target, SEL selector)
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = _createLeftBackButtonItemWithImageNameTitleTargetSelector(vc, nil, nil, target, selector);
    [leftButtonItems addObject:leftBackButton];
    if (images.count > 0) {
        NSArray *leftButtonItemsTmp = _createNavigationButtonItemsWithImagesTargetSelector(vc, images, target, selector);
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    _addNavigationItemWithButtons(vc, leftButtonItems, YES, YES);
    return [leftButtonItems copy];
}

//images中的第一个image是第二个item,block
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithImageActionBlock(UIViewController *vc, NSArray<UIImage*> *images, YZHNavigationItemActionBlock actionBlock)
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = _createLeftBackButtonItemWithImageNameTitleActionBlock(vc, nil, nil, actionBlock);
    [leftButtonItems addObject:leftBackButton];
    if (images.count > 0) {
        NSArray *leftButtonItemsTmp = _createNavigationButtonItemsWithImagesActionBlock(vc, images, actionBlock);
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    _addNavigationItemWithButtons(vc, leftButtonItems, YES, YES);
    return [leftButtonItems copy];
}

//添加leftButtonItem
NSArray<UIButton*> *itn_addNavigationLeftItemsWithTitlesTargetSelectorIsReset(UIViewController *vc, NSArray<NSString*> *titles, id target, SEL selector, BOOL reset)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithTitlesTargetSelector(vc, titles, target, selector);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//添加leftButtonItem,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithTitlesIsResetActionBlock(UIViewController *vc, NSArray<NSString*> *titles, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithTitlesActionBlock(vc, titles, actionBlock);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//添加leftButtonItem
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImageNamesTargetSelectorIsReset(UIViewController *vc, NSArray<NSString*> *imageNames, id target, SEL selector, BOOL reset)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithImageNamesTargetSelector(vc, imageNames, target, selector);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//添加leftButtonItem,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImageNamesIsResetActionBlock(UIViewController *vc, NSArray<NSString*> *imageNames,  BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithImageNamesActionBlock(vc, imageNames, actionBlock);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//添加leftButtonItem
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImagesTargetSelectorIsReset(UIViewController *vc, NSArray<UIImage*> *images, id target, SEL selector, BOOL reset)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithImagesTargetSelector(vc, images, target, selector);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//添加leftButtonItem,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImagesIsResetActionBlock(UIViewController *vc, NSArray<UIImage*> *images, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithImagesActionBlock(vc, images, actionBlock);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//添加自定义的leftButtonItem
NSArray<UIButton*> *itn_addNavigationLeftItemsWithCustomViewTargetSelectorIsReset(UIViewController *vc, NSArray<UIView*> *leftItems, id target,  SEL selector, BOOL reset)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithViewsTargetSelector(vc, leftItems, target, selector);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//添加自定义的leftButtonItem,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithCustomViewIsResetActionBlock(UIViewController *vc, NSArray<UIView*> *leftItems, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithViewsActionBlock(vc, leftItems, actionBlock);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//添加（Image,title）这样的按钮
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImageNamesTitlesTargetSelectorIsReset(UIViewController *vc, NSArray<NSString*> *imageNames, NSArray<NSString*> *titles, id target, SEL selector, BOOL reset)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithImageNamesTitlesTargetSelectorActionBlock(vc, imageNames, titles, target, selector, nil);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//添加（Image,title）这样的按钮,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImageNamesTitlesIsResetActionBlock(UIViewController *vc, NSArray<NSString*> *imageNames, NSArray<NSString*>* titles, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithImageNamesTitlesTargetSelectorActionBlock(vc, imageNames, titles, nil, NULL, actionBlock);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//添加（Image,title）这样的按钮
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImagesTitlesTargetSelectorIsReset(UIViewController *vc, NSArray<UIImage*> *images, NSArray<NSString*> *titles, id target, SEL selector, BOOL reset)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithImagesTitlesTargetSelectorActionBlock(vc, images, titles, target, selector, nil);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//添加（Image,title）这样的按钮,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImagesTitlesIsResetActionBlock(UIViewController *vc, NSArray<UIImage*> *images, NSArray<NSString*> *titles, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    NSArray *leftButtonItems = _createNavigationButtonItemsWithImagesTitlesTargetSelectorActionBlock(vc, images, titles, nil, NULL, actionBlock);
    _addNavigationItemWithButtons(vc, leftButtonItems, reset, YES);
    return leftButtonItems;
}

//通过YZHGraphicsContext来添加leftButtonItem
UIButton *itn_addNavigationLeftItemWithGraphicsImageContextTitleTargetSelectorIsReset(UIViewController *vc, YZHGraphicsContext *graphicsImageContext, NSString *title, id target, SEL selector, BOOL reset)
{
    UIButton *leftBtn = _createButtonItemWithGraphicsImageContextTitleTargetSelector(vc, graphicsImageContext, title, target, selector);
    _addNavigationItemWithButton(vc, leftBtn, reset, YES);
    return leftBtn;
}

//通过YZHGraphicsContext来添加leftButtonItem,block
UIButton *itn_addNavigationLeftItemWithGraphicsImageContextTitleIsResetActionBlock(UIViewController *vc,YZHGraphicsContext *graphicsImageContext, NSString *title, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    UIButton *leftBtn = _createButtonItemWithGraphicsImageContextTitleActionBlock(vc, graphicsImageContext, title, actionBlock);
    _addNavigationItemWithButton(vc, leftBtn, reset, YES);
    return leftBtn;
}

//right
//添加（title）这样的按钮
NSArray<UIButton*> *itn_addNavigationRightItemsWithTitlesTargetSelectorIsReset(UIViewController *vc, NSArray<NSString*> *titles, id target, SEL selector, BOOL reset)
{
    NSArray *rightButtonItems = _createNavigationButtonItemsWithTitlesTargetSelector(vc, titles, target, selector);
    _addNavigationItemWithButtons(vc, rightButtonItems, reset, NO);
    return rightButtonItems;
}

//添加（title）这样的按钮，block
NSArray<UIButton*> *itn_addNavigationRightItemsWithTitlesIsResetActionBlock(UIViewController *vc, NSArray<NSString*> *titles, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    NSArray *rightButtonItems = _createNavigationButtonItemsWithTitlesActionBlock(vc, titles, actionBlock);
    _addNavigationItemWithButtons(vc, rightButtonItems, reset, NO);
    return rightButtonItems;
}

//添加（image）这样的按钮
NSArray<UIButton*> *itn_addNavigationRightItemsWithImageNamesTargetSelectorIsReset(UIViewController *vc, NSArray<NSString*> *imageNames, id target, SEL selector, BOOL reset)
{
    NSArray *rightButtonItems = _createNavigationButtonItemsWithImageNamesTargetSelector(vc, imageNames, target, selector);
    _addNavigationItemWithButtons(vc, rightButtonItems, reset, NO);
    return rightButtonItems;
}

//添加（image）这样的按钮,block
NSArray<UIButton*> *itn_addNavigationRightItemsWithImageNamesIsResetActionBlock(UIViewController *vc, NSArray<NSString*> *imageNames, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    NSArray *rightButtonItems = _createNavigationButtonItemsWithImageNamesActionBlock(vc, imageNames, actionBlock);
    _addNavigationItemWithButtons(vc, rightButtonItems, reset, NO);
    return rightButtonItems;
}

//添加（image）这样的按钮
NSArray<UIButton*> *itn_addNavigationRightItemsWithImagesTargetSelectorIsReset(UIViewController *vc, NSArray<UIImage*> *images,  id target, SEL selector, BOOL reset)
{
    NSArray *rightButtonItems = _createNavigationButtonItemsWithImagesTargetSelector(vc, images, target, selector);
    _addNavigationItemWithButtons(vc, rightButtonItems, reset, NO);
    return rightButtonItems;
}

//添加（image）这样的按钮,block
NSArray<UIButton*> *itn_addNavigationRightItemsWithImagesIsResetActionBlock(UIViewController *vc, NSArray<UIImage*> *images, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    NSArray *rightButtonItems = _createNavigationButtonItemsWithImagesActionBlock(vc, images, actionBlock);
    _addNavigationItemWithButtons(vc, rightButtonItems, reset, NO);
    return rightButtonItems;
}

//添加（UIView）这样的按钮
NSArray<UIButton*> *itn_addNavigationRightItemsWithCustomViewTargetSelectorIsReset(UIViewController *vc, NSArray<UIView*> *rightItems, id target, SEL selector, BOOL reset)
{
    NSArray *rightButtonItems = _createNavigationButtonItemsWithViewsTargetSelector(vc, rightItems, target, selector);
    _addNavigationItemWithButtons(vc, rightButtonItems, reset, NO);
    return rightButtonItems;
}

//添加（UIView）这样的按钮,block
NSArray<UIButton*> *itn_addNavigationRightItemsWithCustomViewIsResetActionBlock(UIViewController *vc, NSArray<UIView*> * rightItems, BOOL reset, YZHNavigationItemActionBlock actionBlock)
{
    NSArray *rightButtonItems = _createNavigationButtonItemsWithViewsActionBlock(vc,rightItems,actionBlock);
    _addNavigationItemWithButtons(vc, rightButtonItems, reset, NO);
    return rightButtonItems;
}

void itn_setupItemsSpace(UIViewController *vc, CGFloat itemsSpace, BOOL left) {
    UINavigationController *navigationController = (UINavigationController*)vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(barAndItemStyle)) {
            [navigationController hz_itn_setupItemsSpace:itemsSpace left:left forViewController:vc];
            return;
        }
        else if (IS_CUSTOM_VC_NAVIGATION_ITEM_STYLE(barAndItemStyle))
        {
            if (left) {
                [vc.hz_itn_navigationItemView setLeftItemsSpace:itemsSpace];
            }
            else {
                [vc.hz_itn_navigationItemView setRightItemsSpace:itemsSpace];
            }
            return;
        }
    }
    NSArray *items = nil;
    if (left) {
        items = vc.navigationItem.leftBarButtonItems;
    }
    else {
        items = vc.navigationItem.rightBarButtonItems;
    }
    
    NSInteger cnt = items.count;
    if (cnt <= 1) {
        return;
    }
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = itemsSpace;
    
    NSMutableArray *customViewItems = [NSMutableArray array];
    [items enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.customView) {
            [customViewItems addObject:obj];
            [customViewItems addObject:spaceItem];
        }
    }];
    if (left) {
        vc.navigationItem.leftBarButtonItems = customViewItems;
    }
    else {
        vc.navigationItem.rightBarButtonItems = customViewItems;
    }
}

void itn_setupItemEdgeSpace(UIViewController *vc, CGFloat edgeSpace, BOOL left) {
    UINavigationController *navigationController = (UINavigationController*)vc.navigationController;
    if (IS_USEABLE_FOR_NC(navigationController)) {
        YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_NAVIGATION_ITEM_STYLE(barAndItemStyle)) {
            [navigationController hz_itn_setupItemEdgeSpace:edgeSpace left:left forViewController:vc];
            return;
        }
        else if (IS_CUSTOM_VC_NAVIGATION_ITEM_STYLE(barAndItemStyle))
        {
            if (left) {
                [vc.hz_itn_navigationItemView setLeftEdgeSpace:edgeSpace];
            }
            else {
                [vc.hz_itn_navigationItemView setRightEdgeSpace:edgeSpace];
            }
            return;
        }
    }
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = edgeSpace;
    
    NSMutableArray *items = [NSMutableArray array];
    if (left) {
        items = vc.navigationItem.leftBarButtonItems.mutableCopy;
        if (items.count == 0 && vc.navigationItem.leftBarButtonItem) {
            items = @[vc.navigationItem.leftBarButtonItem].mutableCopy;
        }
    }
    else {
        items = vc.navigationItem.rightBarButtonItems.mutableCopy;
        if (items.count == 0 && vc.navigationItem.rightBarButtonItem) {
            items = @[vc.navigationItem.rightBarButtonItem].mutableCopy;
        }
    }
    if (items.count == 0) {
        return;
    }
    [items insertObject:spaceItem atIndex:0];
    
    if (left) {
        vc.navigationItem.leftBarButtonItems = items;
    }
    else {
        vc.navigationItem.rightBarButtonItems = items;
    }
}

void itn_addNavigationBarCustomView(UIViewController *vc, UIView *customView)
{
    UINavigationController *navigationController = vc.navigationController;
    YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
    if (IS_CUSTOM_GLOBAL_NAVIGATION_BAR_STYLE(barAndItemStyle)) {
        [navigationController hz_itn_addNavigationBarCustomView:customView];
    }
    else if (IS_CUSTOM_VC_NAVIGATION_BAR_STYLE(barAndItemStyle))
    {
        if (vc.hz_itn_navigationBarView && customView) {
            [vc.hz_itn_navigationBarView addSubview:customView];
        }
    }
}

UIView *itn_navigationBar(UIViewController *vc)
{
    UINavigationController *navigationController = vc.navigationController;
    YZHNavigationBarAndItemStyle barAndItemStyle = navigationController.hz_navigationBarAndItemStyle;
    if (IS_CUSTOM_GLOBAL_NAVIGATION_BAR_STYLE(barAndItemStyle)) {
        return [navigationController hz_itn_navigationBarView];
    }
    else if (IS_CUSTOM_VC_NAVIGATION_BAR_STYLE(barAndItemStyle))
    {
        return vc.hz_itn_navigationBarView;
    }
    return navigationController.navigationBar;
}

CGFloat itn_navigationBarTopLayout(UIViewController *vc)
{
    UIView *barView = itn_navigationBar(vc);
    if ([barView isKindOfClass:[YZHNavigationBarView class]]) {
        return STATUS_BAR_HEIGHT;
    }
    return 0;
}

