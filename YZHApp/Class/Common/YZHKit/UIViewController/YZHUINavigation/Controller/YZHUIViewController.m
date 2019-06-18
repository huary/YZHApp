//
//  YZHUIViewController.m
//  YZHUINavigationController
//
//  Created by yuan on 16/11/17.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "YZHUIViewController.h"
#import "YZHUINavigationItemView.h"
#import "YZHUINavigationController.h"
#import "YZHUIBarButtonItem.h"
#import "UIImage+YZHAdd.h"
#import "UIButton+YZHAdd.h"

@interface YZHUIViewController ()

@property (nonatomic, strong) YZHUINavigationBarView *navigationBarView;
@property (nonatomic, strong) YZHUINavigationItemView *navigationItemView;

@end

@implementation YZHUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initUIData];
    
    [self _setUpNavigationBarAndItemView];
    
    [self _addNavigationObserver:YES];
}

-(void)_initUIData
{
    _popGestureEnabled = YES;
    _navigationItemViewAlpha = 1.0;
    _navigationBarViewBackgroundColor = [[UINavigationBar appearance] barTintColor];
}

-(void)_clearOldNavigationBar
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

-(void)_clearOldNavigationItemView
{
    self.navigationItem.titleView = [[UIView alloc] init];
}

-(void)_clearOldNavigationItemLeftBarButtonItem
{
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

-(void)_clearOldNavigationItemRightBarButtonItem
{
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

-(void)_setUpNavigationBarAndItemView
{
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        UINavigationControllerBarAndItemStyle barAndItemStyle = navigationController.navigationControllerBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle)) {
            [self _clearOldNavigationItemLeftBarButtonItem];
            [navigationController createNewNavigationItemViewForViewController:self];
            _layoutTopY = 0;
        }
        else if (barAndItemStyle == UINavigationControllerBarAndItemViewControllerBarItemStyle)
        {
            CGFloat w = self.view.bounds.size.width;
                        
            CGRect frame = CGRectMake(0, 0, w, STATUS_NAV_BAR_HEIGHT);
            self.navigationBarView = [[YZHUINavigationBarView alloc] initWithFrame:frame];
            [self.view addSubview:self.navigationBarView];
            
            self.navigationItemView = [[YZHUINavigationItemView alloc] initWithFrame:self.navigationBarView.bounds];
//            self.navigationItemView.frame = self.navigationBarView.bounds;
            self.navigationItemView.backgroundColor = CLEAR_COLOR;
            [self.navigationBarView addSubview:self.navigationItemView];
            
            _layoutTopY = CGRectGetMaxY(frame);
        }
        else if (barAndItemStyle == UINavigationControllerBarAndItemViewControllerBarWithDefaultItemStyle)
        {
            CGFloat w = self.view.bounds.size.width;
            CGRect frame = CGRectMake(0, 0, w, STATUS_NAV_BAR_HEIGHT);
            self.navigationBarView = [[YZHUINavigationBarView alloc] initWithFrame:frame];
            [self.view addSubview:self.navigationBarView];
            _layoutTopY = CGRectGetMaxY(frame);
        }
    }
}

-(void)_addNavigationObserver:(BOOL)add
{
    if (add) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_navigationBarNotificationAction:) name:YZHUINavigationBarAttributeChangNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:YZHUINavigationBarAttributeChangNotification object:nil];
    }
}

-(void)_navigationBarNotificationAction:(NSNotification*)notification
{
    NSValue *centerPointValue = [notification.userInfo objectForKey:YZHUINavigationBarCenterPointKey];
    if (!centerPointValue) {
        return;
    }
    CGPoint center = [centerPointValue CGPointValue];
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        UINavigationControllerBarAndItemStyle barAndItemStyle = navigationController.navigationControllerBarAndItemStyle;
        
        if (barAndItemStyle == UINavigationControllerBarAndItemViewControllerBarItemStyle) {
            if (center.y > 0) {
                center.y = self.navigationBarView.bounds.size.height/2;
            }
            else {
                center.y = -self.navigationBarView.bounds.size.height/2;
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                self.navigationBarView.center = center;
            }];
        }
    }
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect frame = CGRectMake(SAFE_X, -STATUS_BAR_HEIGHT, SAFE_WIDTH, STATUS_NAV_BAR_HEIGHT);
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        UINavigationControllerBarAndItemStyle barAndItemStyle = navigationController.navigationControllerBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle)) {
            [navigationController resetNavigationBarAndItemViewFrame:frame];
        }
    }
    
    if (self.navigationBarView) {
        CGFloat width = self.view.bounds.size.width;
        frame = CGRectMake(0, 0, width, STATUS_NAV_BAR_HEIGHT);
        [self.view bringSubviewToFront:self.navigationBarView];
        self.navigationBarView.frame = frame;
    }
    _layoutTopY = CGRectGetMaxY(self.navigationBarView.frame);
    self.navigationTitle = self.navigationTitle;
}

-(void)setNavigationBarViewBackgroundColor:(UIColor *)navigationBarViewBackgroundColor
{
    _navigationBarViewBackgroundColor = navigationBarViewBackgroundColor;
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        if (IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_BAR_STYLE(navigationController.navigationControllerBarAndItemStyle)) {
            self.navigationBarView.backgroundColor = navigationBarViewBackgroundColor;
        }
        else
        {
            navigationController.navigationBarViewBackgroundColor = navigationBarViewBackgroundColor;
        }
    }
    else
    {
        self.navigationController.navigationBar.barTintColor = navigationBarViewBackgroundColor;
    }
}

-(void)setNavigationBarBottomLineColor:(UIColor *)navigationBarBottomLineColor
{
    _navigationBarBottomLineColor = navigationBarBottomLineColor;
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        if (IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_BAR_STYLE(navigationController.navigationControllerBarAndItemStyle)) {
            self.navigationBarView.bottomLine.backgroundColor = navigationBarBottomLineColor;
        }
        else
        {
            navigationController.navigationBarBottomLineColor = navigationBarBottomLineColor;
        }
    }
    else
    {
        if (navigationBarBottomLineColor) {
            UIImage *image = [[UIImage new] createImageWithSize:CGSizeMake(self.navigationController.navigationBar.bounds.size.width, SINGLE_LINE_WIDTH) tintColor:navigationBarBottomLineColor];
            [self.navigationController.navigationBar setShadowImage:image];
        }
        else {
            [self.navigationController.navigationBar setShadowImage:nil];
        }
    }
}

-(void)setBarViewStyle:(UIBarViewStyle)barViewStyle
{
    _barViewStyle = barViewStyle;
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        if (IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_BAR_STYLE(navigationController.navigationControllerBarAndItemStyle)) {
            self.navigationBarView.style = barViewStyle;
        }
        else
        {
            navigationController.barViewStyle = barViewStyle;
        }
    }
}

-(void)setNavigationTitle:(NSString *)navigationTitle
{
    _navigationTitle = navigationTitle;
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        UINavigationControllerBarAndItemStyle barAndItemStyle = navigationController.navigationControllerBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle)) {
            [navigationController setNavigationItemTitle:navigationTitle forViewController:self];
        }
        else if (IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle))
        {
            [self.navigationItemView setTitle:navigationTitle];
        }
        else {
            self.navigationItem.title = navigationTitle;
        }
    }
    else {
        self.navigationItem.title = navigationTitle;
    }
}

-(void)setTitle:(NSString *)title
{
    super.title = title;
    self.navigationTitle = title;
}

//-(void)setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed
//{
//    super.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed;
//    if (self.tabBarController) {
//        self.tabBarController.tabBar.hidden = hidesBottomBarWhenPushed;
//    }
//}

-(void)setNavigationBarViewAlpha:(CGFloat)navigationBarViewAlpha
{
    _navigationBarViewAlpha = navigationBarViewAlpha;
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        if (IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_BAR_STYLE(navigationController.navigationControllerBarAndItemStyle)) {
            self.navigationBarView.alpha = navigationBarViewAlpha;
            if (navigationBarViewAlpha <= MIN_ALPHA_TO_HIDDEN) {
                self.navigationBarView.hidden = YES;
                _layoutTopY = 0;
            }
            else {
                self.navigationBarView.hidden = NO;
                _layoutTopY = CGRectGetMaxY(self.navigationBarView.frame);
            }
        }
        else
        {
            navigationController.navigationBarViewAlpha = navigationBarViewAlpha;
            _layoutTopY = 0;
        }
    }
    else
    {
        self.navigationController.navigationBar.alpha = navigationBarViewAlpha;
        if (navigationBarViewAlpha <= MIN_ALPHA_TO_HIDDEN) {
            self.navigationController.navigationBar.hidden = YES;
        }
        else {
            self.navigationController.navigationBar.hidden = NO;
        }
        _layoutTopY = 0;
    }
}

-(void)setNavigationItemViewAlpha:(CGFloat)navigationItemViewAlpha
{
    _navigationItemViewAlpha = navigationItemViewAlpha;
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        UINavigationControllerBarAndItemStyle barAndItemStyle = navigationController.navigationControllerBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle)) {
            [navigationController setNavigationItemViewAlpha:navigationItemViewAlpha minToHidden:YES forViewController:self];
        }
        else if (IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle))
        {
            self.navigationItemView.alpha = navigationItemViewAlpha;
            if (navigationItemViewAlpha <= MIN_ALPHA_TO_HIDDEN) {
                self.navigationItemView.hidden = YES;
            }
            else {
                self.navigationItemView.hidden = NO;
            }
        }
        else
        {
        }
    }
}

-(void)setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)titleTextAttributes
{
    _titleTextAttributes = titleTextAttributes;
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        UINavigationControllerBarAndItemStyle barAndItemStyle = navigationController.navigationControllerBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle)) {
            [navigationController setNavigationItemTitleTextAttributes:titleTextAttributes forViewController:self];
        }
        else if (IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle))
        {
            self.navigationItemView.titleTextAttributes = titleTextAttributes;
        }
        else
        {
            
        }
    }
}

-(CGRect)_getNavigationItemFrameForImageSize:(CGSize)imageSize graphicsSize:(CGSize*)graphicsSize
{
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

-(UIImage*)_createGraphicesImage:(YZHUIGraphicsImageContext*)graphicsContext strokeColor:(UIColor*)strokeColor
{
    YZHUIGraphicsImageBeginInfo *beginInfo = graphicsContext.beginInfo;
    if (beginInfo && beginInfo.graphicsSize.width <= 0 && beginInfo.graphicsSize.height <= 0) {
        beginInfo.graphicsSize = CGSizeMake(NAV_BAR_HEIGHT, NAV_BAR_HEIGHT);
    }
    return [graphicsContext createGraphicesImageWithStrokeColor:strokeColor];
}

-(UIImage*)_createLeftBackImageForColor:(UIColor*)color width:(CGFloat)width
{
    width = MAX(15, width);
    YZHUIGraphicsImageContext *ctx = [[YZHUIGraphicsImageContext alloc] initWithBeginBlock:^(YZHUIGraphicsImageContext *context) {
        context.beginInfo = [[YZHUIGraphicsImageBeginInfo alloc] init];
        context.beginInfo.lineWidth = 2.5;
        context.beginInfo.graphicsSize = CGSizeMake(width, NAV_BAR_HEIGHT);
        context.imageAlignment = NSGraphicsImageAlignmentLeft;
    } runBlock:^(YZHUIGraphicsImageContext *context) {
        
        CGSize size = context.beginInfo.graphicsSize;
        CGFloat height = size.height * NAVIGATION_ITEM_LEFT_BACK_HEIGHT_WITH_NAVIGATION_BAR_HEIGHT_RATIO;//0.55;
        CGFloat width = height/2;
        CGFloat startY = (size.height - height)/2;
        CGFloat endY = size.height - startY;
        
        CGFloat remX = size.width - width;
        CGFloat shiftX = 0;
        if (context.imageAlignment == NSGraphicsImageAlignmentLeft) {
            shiftX += 0;
        }
        else if (context.imageAlignment == NSGraphicsImageAlignmentCenter) {
            shiftX += remX/2;
        }
        else if (context.imageAlignment == NSGraphicsImageAlignmentRight) {
            shiftX += remX;
        }
        CGFloat lineWidth = context.beginInfo.lineWidth;
        
        CGContextMoveToPoint(context.ctx, shiftX + width, startY + lineWidth/2);
        CGContextAddLineToPoint(context.ctx, shiftX + lineWidth/2, (startY + endY)/2);
        CGContextAddLineToPoint(context.ctx, shiftX + width, endY - lineWidth/2);
        
        CGContextSetStrokeColorWithColor(context.ctx, color.CGColor);
    } endPathBlock:nil];
    UIImage *image =[self _createGraphicesImage:ctx strokeColor:nil];
    return image;
}

-(UIImage*)_createNavigationItemImageForImage:(UIImage*)image
{
    if (!image) {
        return nil;
    }
    CGSize graphicsSize;
    CGRect frame = [self _getNavigationItemFrameForImageSize:image.size graphicsSize:&graphicsSize];
    YZHUIGraphicsImageContext *ctx = [[YZHUIGraphicsImageContext alloc] initWithBeginBlock:^(YZHUIGraphicsImageContext *context) {
        context.beginInfo = [[YZHUIGraphicsImageBeginInfo alloc] init];
        context.beginInfo.graphicsSize = graphicsSize;
    } runBlock:^(YZHUIGraphicsImageContext *context) {
        [image drawInRect:frame];
    } endPathBlock:nil];
    UIImage *newImage =[self _createGraphicesImage:ctx strokeColor:nil];
    return newImage;
}

-(UIImage*)_createNavigationItemImageForView:(UIView*)view
{
//    NSLog(@"size=%@",NSStringFromCGSize(view.bounds.size));
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

-(UIButton*)_createButtonItemWithImage:(UIImage*)image title:(NSString*)title color:(UIColor*)color
{
    UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonItem.backgroundColor = CLEAR_COLOR;
    if (image) {
        [buttonItem setImage:image forState:UIControlStateNormal];
        [buttonItem setImage:image forState:UIControlStateHighlighted];
        [buttonItem setImage:image forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    if (IS_AVAILABLE_NSSTRNG(title)) {
        [buttonItem setTitle:title forState:UIControlStateNormal];
        [buttonItem setTitleColor:color forState:UIControlStateNormal];
    }
    [buttonItem sizeToFit];
    
    [buttonItem.titleLabel sizeToFit];
    CGRect frame = buttonItem.titleLabel.frame;
    frame.origin.x = (buttonItem.bounds.size.width-buttonItem.titleLabel.bounds.size.width)/2;
    if (image) {
        frame.origin.x = CGRectGetMaxX(buttonItem.imageView.frame);
    }
    frame.origin.y = (buttonItem.bounds.size.height - buttonItem.titleLabel.bounds.size.height)/2;
    buttonItem.titleLabel.frame = frame;
    
    return buttonItem;
}

-(UIButton*)_createButtonItemWithImage:(UIImage*)image title:(NSString*)title color:(UIColor*)color target:(id)target action:(SEL)selector
{
    UIButton *buttonItem = [self _createButtonItemWithImage:image title:title color:color];
    
    [buttonItem addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return buttonItem;
}

-(UIButton*)_createButtonItemWithImage:(UIImage*)image title:(NSString*)title color:(UIColor*)color actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIButton *buttonItem = [self _createButtonItemWithImage:image title:title color:color];
    WEAK_SELF(weakSelf);
    [buttonItem addControlEvent:UIControlEventTouchUpInside actionBlock:^(UIButton *button) {
        if (actionBlock) {
            actionBlock(weakSelf, button);
        }
    }];
    return buttonItem;
}

-(UIButton*)_createButtonItemWithGraphicsImageContext:(YZHUIGraphicsImageContext*)graphicsImageContext title:(NSString*)title target:(id)target action:(SEL)selector
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    UIImage *image = [self _createGraphicesImage:graphicsImageContext strokeColor:color];
    UIButton *buttonItem = [self _createButtonItemWithImage:image title:title color:color target:target action:selector];
    return buttonItem;
}

-(UIButton*)_createButtonItemWithGraphicsImageContext:(YZHUIGraphicsImageContext*)graphicsImageContext title:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    UIImage *image = [self _createGraphicesImage:graphicsImageContext strokeColor:color];
    UIButton *buttonItem = [self _createButtonItemWithImage:image title:title color:color actionBlock:actionBlock];
    return buttonItem;
}

-(UIImage*) _createNavigationItemImageWithImageName:(NSString*)imageName color:(UIColor*)color hasTitle:(BOOL)hasTitle
{
//    UIColor *color = [[UINavigationBar appearance] tintColor];
    UIImage *image = nil;
    if (IS_AVAILABLE_NSSTRNG(imageName)) {
        image = [self _createNavigationItemImageForImage:[UIImage imageNamed:imageName]];
    }
    else {
        if (hasTitle) {
            image = [self _createLeftBackImageForColor:color width:0];
        }
        else {
            image = [self _createLeftBackImageForColor:color width:40];
        }
    }
    return image;
}


-(UIButton*)_createLeftBackButtonItemWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)selector
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    UIImage *image = [self _createNavigationItemImageWithImageName:imageName color:color hasTitle:IS_AVAILABLE_NSSTRNG(title)];
    UIButton *buttonItem = [self _createButtonItemWithImage:image title:title color:color target:target action:selector];
    return buttonItem;
}

-(UIButton*)_createLeftBackButtonItemWithImageName:(NSString*)imageName title:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    UIImage *image = [self _createNavigationItemImageWithImageName:imageName color:color hasTitle:IS_AVAILABLE_NSSTRNG(title)];
    UIButton *buttonItem = [self _createButtonItemWithImage:image title:title color:color actionBlock:actionBlock];
    return buttonItem;
}

-(NSArray<UIButton*>*)_createNavigationButtonItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (NSString *title in titles) {
        UIButton *btn = [self _createButtonItemWithImage:nil title:title color:color target:target action:selector];
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

-(NSArray<UIButton*>*)_createNavigationButtonItemsWithTitles:(NSArray<NSString*> *)titles actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (NSString *title in titles) {
        UIButton *btn = [self _createButtonItemWithImage:nil title:title color:color actionBlock:actionBlock];
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

-(NSArray<UIButton*>*)_createNavigationButtonItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    NSMutableArray *navigationButtonItems = [NSMutableArray array];

    for (NSString *imageName in imageNames) {
        UIImage *oldImage = [UIImage imageNamed:imageName];
        UIImage *image = [self _createNavigationItemImageForImage:oldImage];
        UIButton *btn = [self _createButtonItemWithImage:image title:nil color:color target:target action:selector];
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

-(NSArray<UIButton*>*)_createNavigationButtonItemsWithImageNames:(NSArray<NSString*> *)imageNames actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (NSString *imageName in imageNames) {
        UIImage *oldImage = [UIImage imageNamed:imageName];
        UIImage *image = [self _createNavigationItemImageForImage:oldImage];
        UIButton *btn = [self _createButtonItemWithImage:image title:nil color:color actionBlock:actionBlock];
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

-(NSArray<UIButton*>*)_createNavigationButtonItemsWithImages:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (UIImage *image in images) {
        UIImage *newImg = [self _createNavigationItemImageForImage:image];
        UIButton *btn = [self _createButtonItemWithImage:newImg title:nil color:color target:target action:selector];
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

-(NSArray<UIButton*>*)_createNavigationButtonItemsWithImages:(NSArray<UIImage*> *)images actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (UIImage *image in images) {
        UIImage *newImg = [self _createNavigationItemImageForImage:image];
        UIButton *btn = [self _createButtonItemWithImage:newImg title:nil color:color actionBlock:actionBlock];
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

-(NSArray<UIButton*>*)_createNavigationButtonItemsWithViews:(NSArray<UIView*>*)views target:(id)target action:(SEL)selector
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (UIView *view in views) {
        UIImage *viewImg = [self _createNavigationItemImageForView:view];
        UIImage *image = [self _createNavigationItemImageForImage:viewImg];
        UIButton *btn = [self _createButtonItemWithImage:image title:nil color:color target:target action:selector];
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

-(NSArray<UIButton*>*)_createNavigationButtonItemsWithViews:(NSArray<UIView*>*)views actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    for (UIView *view in views) {
        UIImage *viewImg = [self _createNavigationItemImageForView:view];
        UIImage *image = [self _createNavigationItemImageForImage:viewImg];
        UIButton *btn = [self _createButtonItemWithImage:image title:nil color:color actionBlock:actionBlock];
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

-(NSArray<UIButton*>*)_createNavigationButtonItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    NSInteger cnt = MAX(imageNames.count, titles.count);
    
    for (NSInteger i = 0; i < cnt; ++i) {
        UIImage *image = nil;
        NSString *title = nil;
        if (i < imageNames.count) {
            NSString *imageName = [imageNames objectAtIndex:i];
            UIImage *oldImage = [UIImage imageNamed:imageName];
            image = [self _createNavigationItemImageForImage:oldImage];
        }
        
        if (i < titles.count) {
            title = [titles objectAtIndex:i];
        }
        
        UIButton *btn = nil;
        if (target) {
            btn = [self _createButtonItemWithImage:image title:title color:color target:target action:selector];
        }
        else if (actionBlock) {
            btn = [self _createButtonItemWithImage:image title:title color:color actionBlock:actionBlock];
        }

        if (!btn) {
            btn = [self _createButtonItemWithImage:image title:title color:color target:target action:selector];
        }
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}

-(NSArray<UIButton*>*)_createNavigationButtonItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIColor *color = [[UINavigationBar appearance] tintColor];
    NSMutableArray *navigationButtonItems = [NSMutableArray array];
    
    NSInteger cnt = MAX(images.count, titles.count);
    
    for (NSInteger i = 0; i < cnt; ++i) {
        UIImage *image = nil;
        NSString *title = nil;
        if (i < images.count) {
            UIImage *oldImage = [images objectAtIndex:i];
            image = [self _createNavigationItemImageForImage:oldImage];
        }
        
        if (i < titles.count) {
            title = [titles objectAtIndex:i];
        }

        UIButton *btn = nil;
        if (target) {
            btn = [self _createButtonItemWithImage:image title:title color:color target:target action:selector];
        }
        else if (actionBlock) {
            btn = [self _createButtonItemWithImage:image title:title color:color actionBlock:actionBlock];
        }
        
        if (!btn) {
            btn = [self _createButtonItemWithImage:image title:title color:color target:target action:selector];
        }
        [navigationButtonItems addObject:btn];
    }
    return [navigationButtonItems copy];
}


-(void)_addNavigationItemWithButton:(UIButton*)button isReset:(BOOL)reset left:(BOOL)left
{
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        UINavigationControllerBarAndItemStyle barAndItemStyle = navigationController.navigationControllerBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle)) {
            if (left) {
                [self _clearOldNavigationItemLeftBarButtonItem];
                [navigationController addNavigationItemViewLeftButtonItems:@[button] isReset:reset forViewController:self];
            }
            else {
                [navigationController addNavigationItemViewRightButtonItems:@[button] isReset:reset forViewController:self];
            }
            return;
        }
        else if (IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle))
        {
            if (left) {
                [self _clearOldNavigationItemLeftBarButtonItem];
                [self.navigationItemView setLeftButtonItems:@[button] isReset:reset];
            }
            else {
                [self.navigationItemView setRightButtonItems:@[button] isReset:reset];
            }
            return;
        }
    }
    if (left) {
//        if (self.title == nil) {
//        }
        [self _clearOldNavigationItemLeftBarButtonItem];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
}

-(void)_addNavigationItemWithButtons:(NSArray<UIButton*>*)buttons isReset:(BOOL)reset left:(BOOL)left
{
//    if (buttons == nil) {
//        return;
//    }
    
    if ([self.navigationController isKindOfClass:[YZHUINavigationController class]]) {
        YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
        UINavigationControllerBarAndItemStyle barAndItemStyle = navigationController.navigationControllerBarAndItemStyle;
        if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle)) {
            if (left) {
                [navigationController addNavigationItemViewLeftButtonItems:buttons isReset:reset forViewController:self];
            }
            else {
                [navigationController addNavigationItemViewRightButtonItems:buttons isReset:reset forViewController:self];
            }
            return;
        }
        else if (IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_ITEM_STYLE(barAndItemStyle))
        {
            if (left) {
                [self.navigationItemView setLeftButtonItems:buttons isReset:reset];
            }
            else {
                [self.navigationItemView setRightButtonItems:buttons isReset:reset];
            }
            return;
        }
    }
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = SYSTEM_NAVIGATION_ITEM_VIEW_SUBVIEWS_ITEM_SPACE;
    
    NSMutableArray *systemItems = [NSMutableArray array];
    if (!reset) {
        if (left) {
            systemItems = [self.navigationItem.leftBarButtonItems mutableCopy];
        }
        else {
            systemItems = [self.navigationItem.rightBarButtonItems mutableCopy];

        }
        if (systemItems == nil) {
            systemItems = [NSMutableArray array];
        }
    }
    
    __block NSInteger tag = 0;
    [systemItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.customView && obj.customView.tag > 0) {
            tag = MAX(tag, obj.customView.tag);
        }
    }];
    
    for (UIButton *buttonItem in buttons) {
        buttonItem.tag = ++tag;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:buttonItem];
        [systemItems addObject:item];
//        [systemItems addObject:space];
    }
    if (left) {
        self.navigationItem.leftBarButtonItems = systemItems;
    }
    else {
        self.navigationItem.rightBarButtonItems = systemItems;
    }
}

//这个带<剪头的返回按钮
-(UIButton *)addNavigationFirstLeftBackItemWithTitle:(NSString*)title target:(id)target action:(SEL)selector
{
    UIButton *leftButtonItem = [self _createLeftBackButtonItemWithImageName:nil title:title target:target action:selector];
    [self _addNavigationItemWithButton:leftButtonItem isReset:YES left:YES];
    return leftButtonItem;
}

//这个带<剪头的返回按钮,这个是重置操作，清空原来所有的LeftButtonItems,block
-(UIButton *)addNavigationFirstLeftBackItemWithTitle:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIButton *leftButtonItem = [self _createLeftBackButtonItemWithImageName:nil title:title actionBlock:actionBlock];
    [self _addNavigationItemWithButton:leftButtonItem isReset:YES left:YES];
    return leftButtonItem;
}

//自定义第一个按钮（image，title）
-(UIButton *)addNavigationFirstLeftItemWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)selector
{
    UIButton *leftBtn = [self addNavigationLeftItemWithImageName:imageName title:title target:target action:selector isReset:YES];
    return leftBtn;
}

//自定义第一个按钮（image，title）block
-(UIButton *)addNavigationFirstLeftItemWithImageName:(NSString*)imageName title:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIButton *leftBtn = [self addNavigationLeftItemWithImageName:imageName title:title isReset:YES actionBlock:actionBlock];
    return leftBtn;
}

//自定义一个按钮（image，title）
-(UIButton *)addNavigationLeftItemWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [self addNavigationLeftItemWithImage:image title:title target:target action:selector isReset:reset];
}

//自定义一个按钮（image，title）block
-(UIButton *)addNavigationLeftItemWithImageName:(NSString*)imageName title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [self addNavigationLeftItemWithImage:image title:title isReset:reset actionBlock:actionBlock];
}

//自定义一个按钮（image，title）
-(UIButton *)addNavigationLeftItemWithImage:(UIImage*)image title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    image = [self _createNavigationItemImageForImage:image];
    UIButton *leftButtonItem = [self _createButtonItemWithImage:image title:title color:[[UINavigationBar appearance] tintColor] target:target action:selector];
    [self _addNavigationItemWithButton:leftButtonItem isReset:reset left:YES];
    return leftButtonItem;
}

//自定义一个按钮（image，title）block
-(UIButton *)addNavigationLeftItemWithImage:(UIImage*)image title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    image = [self _createNavigationItemImageForImage:image];
    UIButton *leftButtonItem = [self _createButtonItemWithImage:image title:title color:[[UINavigationBar appearance] tintColor] actionBlock:actionBlock];
    [self _addNavigationItemWithButton:leftButtonItem isReset:reset left:YES];
    return leftButtonItem;
}

//titles中的第一个NSString被用来作为第一个item的title
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = [self _createLeftBackButtonItemWithImageName:nil title:[titles firstObject] target:target action:selector];
    [leftButtonItems addObject:leftBackButton];
    
    if (titles.count > 1) {
        NSArray *sub = [titles subarrayWithRange:NSMakeRange(1, titles.count - 1)];
        NSArray *leftButtonItemsTmp = [self _createNavigationButtonItemsWithImageNames:nil titles:sub target:target action:selector actionBlock:nil];
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    [self _addNavigationItemWithButtons:leftButtonItems isReset:YES left:YES];
    
    return [leftButtonItems copy];
}

//titles中的第一个NSString被用来作为第一个item的title,block
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithTitles:(NSArray<NSString*> *)titles actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = [self _createLeftBackButtonItemWithImageName:nil title:[titles firstObject] actionBlock:actionBlock];
    [leftButtonItems addObject:leftBackButton];
    
    if (titles.count > 1) {
        NSArray *sub = [titles subarrayWithRange:NSMakeRange(1, titles.count - 1)];
        NSArray *leftButtonItemsTmp = [self _createNavigationButtonItemsWithImageNames:nil titles:sub target:nil action:NULL actionBlock:actionBlock];
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    [self _addNavigationItemWithButtons:leftButtonItems isReset:YES left:YES];
    
    return [leftButtonItems copy];
}

//imageNames中的第一个imageName是第二个item
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = [self _createLeftBackButtonItemWithImageName:nil title:nil target:target action:selector];
    [leftButtonItems addObject:leftBackButton];
    
    if (imageNames.count > 0) {
        NSArray *leftButtonItemsTmp = [self _createNavigationButtonItemsWithImageNames:imageNames target:target action:selector];
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    [self _addNavigationItemWithButtons:leftButtonItems isReset:YES left:YES];
    
    return [leftButtonItems copy];
}

//imageNames中的第一个imageName是第二个item,block
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImageNames:(NSArray<NSString*> *)imageNames actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = [self _createLeftBackButtonItemWithImageName:nil title:nil actionBlock:actionBlock];
    [leftButtonItems addObject:leftBackButton];
    
    if (imageNames.count > 0) {
        NSArray *leftButtonItemsTmp = [self _createNavigationButtonItemsWithImageNames:imageNames actionBlock:actionBlock];
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    [self _addNavigationItemWithButtons:leftButtonItems isReset:YES left:YES];
    
    return [leftButtonItems copy];
}

//images中的第一个image是第二个item
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImage:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = [self _createLeftBackButtonItemWithImageName:nil title:nil target:target action:selector];
    [leftButtonItems addObject:leftBackButton];
    if (images.count > 0) {
        NSArray *leftButtonItemsTmp = [self _createNavigationButtonItemsWithImages:images target:target action:selector];
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    [self _addNavigationItemWithButtons:leftButtonItems isReset:YES left:YES];
    return [leftButtonItems copy];
}

//images中的第一个image是第二个item,block
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImage:(NSArray<UIImage*> *)images actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSMutableArray *leftButtonItems = [NSMutableArray array];
    UIButton *leftBackButton = [self _createLeftBackButtonItemWithImageName:nil title:nil actionBlock:actionBlock];
    [leftButtonItems addObject:leftBackButton];
    if (images.count > 0) {
        NSArray *leftButtonItemsTmp = [self _createNavigationButtonItemsWithImages:images actionBlock:actionBlock];
        [leftButtonItems addObjectsFromArray:leftButtonItemsTmp];
    }
    [self _addNavigationItemWithButtons:leftButtonItems isReset:YES left:YES];
    return [leftButtonItems copy];
}

//添加leftButtonItem
-(NSArray<UIButton*> *)addNavigationLeftItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithTitles:titles target:target action:selector];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
    return leftButtonItems;
}

//添加leftButtonItem,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithTitles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithTitles:titles actionBlock:actionBlock];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
    return leftButtonItems;
}

//添加leftButtonItem
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithImageNames:imageNames target:target action:selector];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
    return leftButtonItems;
}

//添加leftButtonItem,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithImageNames:imageNames actionBlock:actionBlock];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
    return leftButtonItems;
}

//添加leftButtonItem
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithImages:images target:target action:selector];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
    return leftButtonItems;
}

//添加leftButtonItem,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithImages:images actionBlock:actionBlock];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
    return leftButtonItems;
}

//添加自定义的leftButtonItem
-(void)addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    if (!IS_AVAILABLE_NSSET_OBJ(leftItems)) {
        return;
    }
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithViews:leftItems target:target action:selector];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
}

//添加自定义的leftButtonItem,block
-(void)addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    if (!IS_AVAILABLE_NSSET_OBJ(leftItems)) {
        return;
    }
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithViews:leftItems actionBlock:actionBlock];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
}

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithImageNames:imageNames titles:titles target:target action:selector actionBlock:nil];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
    return leftButtonItems;
}

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithImageNames:imageNames titles:titles target:nil action:NULL actionBlock:actionBlock];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
    return leftButtonItems;
}

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithImages:images titles:titles target:target action:selector actionBlock:nil];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
    return leftButtonItems;
}

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSArray *leftButtonItems = [self _createNavigationButtonItemsWithImages:images titles:titles target:nil action:NULL actionBlock:actionBlock];
    [self _addNavigationItemWithButtons:leftButtonItems isReset:reset left:YES];
    return leftButtonItems;
}

//通过YZHUIGraphicsImageContext来添加leftButtonItem
-(UIButton *)addNavigationLeftItemWithGraphicsImageContext:(YZHUIGraphicsImageContext*)graphicsImageContext title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    UIButton *leftBtn = [self _createButtonItemWithGraphicsImageContext:graphicsImageContext title:title target:target action:selector];
    [self _addNavigationItemWithButton:leftBtn isReset:reset left:YES];
    return leftBtn;
}

//通过YZHUIGraphicsImageContext来添加leftButtonItem,block
-(UIButton *)addNavigationLeftItemWithGraphicsImageContext:(YZHUIGraphicsImageContext*)graphicsImageContext title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    UIButton *leftBtn = [self _createButtonItemWithGraphicsImageContext:graphicsImageContext title:title actionBlock:actionBlock];
    [self _addNavigationItemWithButton:leftBtn isReset:reset left:YES];
    return leftBtn;
}

//right
//添加（title）这样的按钮
-(NSArray<UIButton*> *)addNavigationRightItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    NSArray *rightButtonItems = [self _createNavigationButtonItemsWithTitles:titles target:target action:selector];
    [self _addNavigationItemWithButtons:rightButtonItems isReset:reset left:NO];
    return rightButtonItems;
}

//添加（title）这样的按钮，block
-(NSArray<UIButton*> *)addNavigationRightItemsWithTitles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSArray *rightButtonItems = [self _createNavigationButtonItemsWithTitles:titles actionBlock:actionBlock];
    [self _addNavigationItemWithButtons:rightButtonItems isReset:reset left:NO];
    return rightButtonItems;
}

//添加（image）这样的按钮
-(NSArray<UIButton*> *)addNavigationRightItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    NSArray *rightButtonItems = [self _createNavigationButtonItemsWithImageNames:imageNames target:target action:selector];
    [self _addNavigationItemWithButtons:rightButtonItems isReset:reset left:NO];
    return rightButtonItems;
}

//添加（image）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationRightItemsWithImageNames:(NSArray<NSString*> *)imageNames isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSArray *rightButtonItems = [self _createNavigationButtonItemsWithImageNames:imageNames actionBlock:actionBlock];
    [self _addNavigationItemWithButtons:rightButtonItems isReset:reset left:NO];
    return rightButtonItems;
}

//添加（image）这样的按钮
-(NSArray<UIButton*> *)addNavigationRightItemsWithImages:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    NSArray *rightButtonItems = [self _createNavigationButtonItemsWithImages:images target:target action:selector];
    [self _addNavigationItemWithButtons:rightButtonItems isReset:reset left:NO];
    return rightButtonItems;
}

//添加（image）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationRightItemsWithImages:(NSArray<UIImage*> *)images isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSArray *rightButtonItems = [self _createNavigationButtonItemsWithImages:images actionBlock:actionBlock];
    [self _addNavigationItemWithButtons:rightButtonItems isReset:reset left:NO];
    return rightButtonItems;
}

//添加（UIView）这样的按钮
-(void)addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    NSArray *rightButtonItems = [self _createNavigationButtonItemsWithViews:rightItems target:target action:selector];
    [self _addNavigationItemWithButtons:rightButtonItems isReset:reset left:NO];
}

//添加（UIView）这样的按钮,block
-(void)addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    NSArray *rightButtonItems = [self _createNavigationButtonItemsWithViews:rightItems actionBlock:actionBlock];
    [self _addNavigationItemWithButtons:rightButtonItems isReset:reset left:NO];
}

-(void)addNavigationBarCustomView:(UIView*)customView
{
    YZHUINavigationController *navigationController = (YZHUINavigationController*)self.navigationController;
    UINavigationControllerBarAndItemStyle barAndItemStyle = navigationController.navigationControllerBarAndItemStyle;
    if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_BAR_STYLE(barAndItemStyle)) {
        [navigationController addNavigationBarCustomView:customView];
    }
    else if (IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_BAR_STYLE(barAndItemStyle))
    {
        if (self.navigationBarView && customView) {
            [self.navigationBarView addSubview:customView];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
