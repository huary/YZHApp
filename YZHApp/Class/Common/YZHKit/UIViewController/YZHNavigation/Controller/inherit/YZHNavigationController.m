//
//  YZHNavigationController.m
//  YZHNavigationController
//
//  Created by yuan on 16/11/17.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "YZHNavigationController.h"
#import "YZHNavigationController+Internal.h"
#import "YZHNavigationItemView.h"
#import "YZHBaseAnimatedTransition.h"
#import "YZHNCUtils.h"
#import "YZHNavigationItnTypes.h"
#import "UIViewController+YZHNavigationRootVCInitSetup.h"

@implementation YZHNavigationController
-(void)pri_setupDefaultValue
{
    self.popGestureEnabled = NCPopGestureEnabled_s;
    self.transitionDuration = NCTransitionDuration_s;
    self.hidesTabBarAfterPushed = NCHidesTabBarAfterPushed_s;
}

-(instancetype)init
{
    if (self = [super init]) {
        [self pri_setupDefaultValue];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self pri_setupDefaultValue];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self pri_setupDefaultValue];
    }
    return self;
}

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    _navigationBarAndItemStyle = rootViewController.hz_barAndItemStyleForRootVCInitSetToNavigation;
    if (self = [super initWithRootViewController:rootViewController]) {
        [self pri_setupDefaultValue];
    }
    return self;
}

-(void)setNavBarStyle:(YZHNavBarStyle)navBarStyle
{
    _navBarStyle = navBarStyle;
    itn_nc_setNavBarStyle(self, navBarStyle);
}

-(void)setNavigationBarViewBackgroundColor:(UIColor *)navigationBarViewBackgroundColor
{
    _navigationBarViewBackgroundColor = navigationBarViewBackgroundColor;
    itn_nc_setNavigationBarViewBackgroundColor(self, navigationBarViewBackgroundColor);
}

-(void)setNavigationBarBottomLineColor:(UIColor *)navigationBarBottomLineColor
{
    _navigationBarBottomLineColor = navigationBarBottomLineColor;
    itn_nc_setNavigationBarBottomLineColor(self, navigationBarBottomLineColor);
}

-(void)setNavigationBarViewAlpha:(CGFloat)navigationBarViewAlpha
{
    _navigationBarViewAlpha = navigationBarViewAlpha;
    itn_nc_setNavigationBarViewAlpha(self, navigationBarViewAlpha);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self hz_addStrongReferenceObject:@(YES) forKey:@"hz_isViewDidLoad"];
        
    itn_nc_viewDidLoad(self);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
        
    itn_nc_viewWillLayoutSubviews(self);
}

#pragma mark override
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    itn_pushViewController(self, viewController, animated);
    [super pushViewController:viewController animated:animated];
}

-(void)resetNavigationBarAndItemViewFrame:(CGRect)frame
{
    itn_resetNavigationBarAndItemViewFrame(self, frame);
}

//自定义
-(void)pushViewController:(UIViewController *)viewController
                 animated:(BOOL)animated
               completion:(YZHNavigationControllerAnimationCompletionBlock)completion
{
    itn_pushViewControllerCompletion(self, viewController, completion);
    [self pushViewController:viewController animated:animated];
}

-(void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
               completion:(YZHNavigationControllerAnimationCompletionBlock)completion {
    itn_pushViewControllerCompletion(self, viewControllers.lastObject, completion);
    self.viewControllers = viewControllers;
}

-(void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
                 animated:(BOOL)animated
               completion:(YZHNavigationControllerAnimationCompletionBlock)completion {
    itn_pushViewControllerCompletion(self, viewControllers.lastObject, completion);
    [self setViewControllers:viewControllers animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
                                     completion:(YZHNavigationControllerAnimationCompletionBlock)completion
{
    itn_popViewControllerCompletion(self, completion);
    UIViewController *vc = [super popViewControllerAnimated:animated];
    return vc;
}

- (NSArray<UIViewController*> *)popToViewController:(UIViewController *)viewController
                                           animated:(BOOL)animated
                                         completion:(YZHNavigationControllerAnimationCompletionBlock)completion
{
    itn_popViewControllerCompletion(self, completion);
    return [super popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController*> *)popToRootViewControllerAnimated:(BOOL)animated
                                                     completion:(YZHNavigationControllerAnimationCompletionBlock)completion
{
    itn_popViewControllerCompletion(self, completion);
    return [super popToRootViewControllerAnimated:animated];
}

//在viewController didLoad的时候调用，此函数仅仅是创建了一个NavigationItemView，在push的时候添加
-(void)itn_createNewNavigationItemViewForViewController:(UIViewController*)viewController
{
    itn_createNewNavigationItemViewForViewController(self, viewController);
}

-(void)itn_addNewNavigationItemViewForViewController:(UIViewController*)viewController
{
    itn_addNewNavigationItemViewForViewController(self, viewController);
}

//在viewController pop完成的时候调用，
-(void)itn_removeNavigationItemViewForViewController:(UIViewController*)viewController
{
    itn_removeNavigationItemViewForViewController(self, viewController);
}

//设置NavigationItemView相关
-(void)itn_setNavigationItemViewAlpha:(CGFloat)alpha minToHidden:(BOOL)minToHidden forViewController:(UIViewController*)viewController
{
    itn_setNavigationItemViewAlphaMinToHiddenForVC(self, alpha, minToHidden, viewController);
}

-(void)itn_setNavigationItemViewTransform:(CGAffineTransform)transform forViewController:(UIViewController*)viewController
{
    itn_setNavigationItemViewTransformForVC(self, transform, viewController);
}

-(void)itn_setNavigationItemTitle:(NSString*)title forViewController:(UIViewController*)viewController
{
    itn_setNavigationItemTitleForVC(self, title, viewController);
}

-(void)itn_setNavigationItemTitleTextAttributes:(NSDictionary<NSAttributedStringKey, id>*)textAttributes forViewController:(UIViewController*)viewController
{
    itn_setNavigationItemTitleTextAttributesForVC(self, textAttributes, viewController);
}

-(void)itn_addNavigationItemViewLeftButtonItems:(NSArray*)leftButtonItems isReset:(BOOL)reset forViewController:(UIViewController *)viewController
{
    itn_addNavigationItemViewLeftButtonItemsIsResetForVC(self, leftButtonItems, reset, viewController);
}

-(void)itn_addNavigationItemViewRightButtonItems:(NSArray*)rightButtonItems isReset:(BOOL)reset forViewController:(UIViewController *)viewController
{
    itn_addNavigationItemViewRightButtonItemsIsResetForVC(self, rightButtonItems, reset, viewController);
}

-(void)itn_setupItemsSpace:(CGFloat)itemsSpace left:(BOOL)left forViewController:(UIViewController *)viewController {
    itn_nc_setupItemsSpace(self, itemsSpace, left, viewController);
}

-(void)itn_setupItemEdgeSpace:(CGFloat)edgeSpace left:(BOOL)left forViewController:(UIViewController *)viewController {
    itn_nc_setupItemEdgeSpace(self, edgeSpace, left, viewController);
}

-(void)itn_addNavigationBarCustomView:(UIView*)customView
{
    itn_nc_addNavigationBarCustomView(self, customView);
}

- (UIView *)itn_navigationBar
{
    return itn_nc_navigationBar(self);
}

- (CGFloat)itn_navigationBarTopLayout
{
    return itn_nc_navigationBarTopLayout(self);
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
