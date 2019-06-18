//
//  YZHTabBarController.m
//  YZHTabBarControllerDemo
//
//  Created by yuan on 17/2/7.
//  Copyright © 2017年 yzh. All rights reserved.
//

#import "YZHTabBarController.h"
#import "UITabBarView.h"
#import "UIViewController+UITabBarButton.h"

#define USE_TABBAR_VIEW_TO_TABBAR_VC                 (0)

#if USE_TABBAR_VIEW_TO_TABBAR_VC
#import "UITabBarController+UITabBarView.h"
#endif

NSString *const YZHTabBarItemTitleNormalColorKey = TYPE_STR(YZHTabBarItemTitleNormalColorKey);
NSString *const YZHTabBarItemTitleSelectedColorKey = TYPE_STR(YZHTabBarItemTitleSelectedColorKey);
NSString *const YZHTabBarItemTitleTextFontKey = TYPE_STR(YZHTabBarItemTitleTextFontKey);
NSString *const YZHTabBarItemSelectedBackgroundColorKey = TYPE_STR(YZHTabBarItemSelectedBackgroundColorKey);
NSString *const YZHTabBarItemHighlightedBackgroundColorKey = TYPE_STR(YZHTabBarItemHighlightedBackgroundColorKey);

NSString *const YZHTabBarItemActionUserInteractionKey = TYPE_STR(YZHTabBarItemActionUserInteractionKey);



/**************************************************************************
 *NSItemChildVCInfo
 **************************************************************************/
@interface NSItemChildVCInfo : NSObject

/** item的Index，这个是在TabBarView上面的Index */
@property (nonatomic, assign) NSInteger itemIndex;

/** childVCIndex,这个是在TabBarController上面的Index*/
@property (nonatomic, assign) NSInteger childVCIndex;

/** ChildVC */
@property (nonatomic, weak) UIViewController *childVC;

@end

@implementation NSItemChildVCInfo
-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefaultValue];
    }
    return self;
}

-(instancetype)initWithItemIndex:(NSInteger)itemIndex childVC:(UIViewController*)childVC
{
    self = [super init];
    if (self) {
        [self _setupDefaultValue];
        self.itemIndex = itemIndex;
        self.childVC = childVC;
    }
    return self;
}

-(void)_setupDefaultValue
{
    self.childVCIndex = -1;
}
@end


/**************************************************************************
 *YZHTabBarController
 **************************************************************************/

@interface YZHTabBarController () <UITabBarViewDelegate>

@property (nonatomic, strong) UITabBarView *tabBarViewT;

@property (nonatomic, assign) NSInteger lastClickedIndex;
@property (nonatomic, assign) int64_t lastClickedIndexTimeMS;

@property (nonatomic, strong) NSMutableDictionary<NSNumber*, NSItemChildVCInfo*> *itemChildVCInfo;

@end

static YZHTabBarController *shareTabBarController_s = NULL;

@implementation YZHTabBarController

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefault];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupTabBar];
}

+(YZHTabBarController*)shareTabBarController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareTabBarController_s = [[YZHTabBarController alloc] init];
    });
    return shareTabBarController_s;
}

-(NSMutableDictionary<NSNumber*, NSItemChildVCInfo*>*)itemChildVCInfo
{
    if (_itemChildVCInfo == nil) {
        _itemChildVCInfo = [NSMutableDictionary dictionary];
    }
    return _itemChildVCInfo;
}

-(void)_setupDefault
{
    self.doubleTapMaxTimeIntervalMS = 180;
}

-(void)_setupTabBar
{
    UITabBarView *tabBarView = [[UITabBarView alloc] init];
    tabBarView.delegate  = self;
    tabBarView.frame = self.tabBar.bounds;
    tabBarView.backgroundColor = WHITE_COLOR;
    
    [self _hiddenTabBarSubView];
    
    [self.tabBar addSubview:tabBarView];
#if USE_TABBAR_VIEW_TO_TABBAR_VC
    self.tabBarView = tabBarView;
#endif
    self.tabBarViewT = tabBarView;
}

-(void)_hiddenTabBarSubView
{
    for (UIView *subView in self.tabBar.subviews) {
        if (![subView isKindOfClass:[UITabBarView class]]) {
            subView.hidden = YES;
        }
    }
}

#pragma mark UITabBarViewDelegate

-(BOOL)tabBarView:(UITabBarView *)tabBarView didSelectFrom:(NSInteger)from to:(NSInteger)to actionInfo:(NSDictionary *)actionInfo
{
    BOOL shouldSelect = YES;
    
    int64_t lastClickedIndexTimeMS = self.lastClickedIndexTimeMS;
    //这里不对selectedIndex进行监听，故意放在这里进行,需要用户点击的行为，而不是代码操作的行为
    self.lastClickedIndexTimeMS = MSEC_FROM_DATE_SINCE1970_NOW;
    
    //single tap
    if ([self.tabBarDelegate respondsToSelector:@selector(tabBarController:shouldSelectFrom:to:)]) {
        shouldSelect = [self.tabBarDelegate tabBarController:self shouldSelectFrom:from to:to];
    }
    else if ([self.tabBarDelegate respondsToSelector:@selector(tabBarController:shouldSelectFrom:to:actionInfo:)]) {
        shouldSelect = [self.tabBarDelegate tabBarController:self shouldSelectFrom:from to:to actionInfo:actionInfo];
    }
    if (shouldSelect) {
        NSItemChildVCInfo *childVCInfo = [self.itemChildVCInfo objectForKey:@(to)];
        NSInteger childVCIndex = childVCInfo.childVCIndex;
        if (childVCIndex >= 0 && childVCIndex < self.childViewControllers.count) {
            self.selectedIndex = childVCIndex;
        }
    }
    //double tap
    if (self.lastClickedIndex == to) {
        int64_t diff = self.lastClickedIndexTimeMS - lastClickedIndexTimeMS;
        if (diff <= self.doubleTapMaxTimeIntervalMS) {
            BOOL should = YES;
            if ([self.tabBarDelegate respondsToSelector:@selector(tabBarController:shouldDoubleClickAtIndex:actionInfo:)]) {
                should = [self.tabBarDelegate tabBarController:self shouldDoubleClickAtIndex:to actionInfo:actionInfo];
            }
            if (should) {
                [self tabBarView:self.tabBarViewT doubleClickAtIndex:self.selectedIndex];
            }
        }
    }
    self.lastClickedIndex = to;
    return shouldSelect;
}

-(void)tabBarView:(UITabBarView *)tabBarView doubleClickAtIndex:(NSInteger)index
{
    if ([self.tabBarDelegate respondsToSelector:@selector(tabBarController:doubleClickAtIndex:)]) {
        [self.tabBarDelegate tabBarController:self doubleClickAtIndex:index];
    }
}

#pragma mark end

-(void)doSelectTo:(NSInteger)toIndex
{
    [self.tabBarViewT doSelectTo:toIndex];
}

-(void)_addChildVC:(UIViewController*)viewController atItemIndex:(NSInteger)itemIndex
{
    NSItemChildVCInfo *itemChildVCInfo = [[NSItemChildVCInfo alloc] initWithItemIndex:itemIndex childVC:viewController];
    [self.itemChildVCInfo setObject:itemChildVCInfo forKey:@(itemIndex)];
    if (viewController == nil) {
        return;
    }
    [self addChildViewController:viewController];
    itemChildVCInfo.childVCIndex = self.viewControllers.count - 1;
}

-(NSInteger)_getChildVCIndexAtItemIndex:(NSInteger)itemIndex
{
    NSItemChildVCInfo *childVCInfo = [self.itemChildVCInfo objectForKey:@(itemIndex)];
    if (childVCInfo.childVC) {
        return childVCInfo.childVCIndex;
    }
    return -1;
}

-(void)_updateChildVC:(UIViewController*)viewController atItemIndex:(NSInteger)itemIndex
{
    NSItemChildVCInfo *childVCInfo = [self.itemChildVCInfo objectForKey:@(itemIndex)];
    if (childVCInfo == nil) {
        return;
    }
    NSInteger findIndex = -1;
    NSMutableArray *VCS = [self.viewControllers mutableCopy];
    if (childVCInfo.childVC) {
        //重新再来求一遍childVCIndex
        findIndex = [self.viewControllers indexOfObject:childVCInfo.childVC];
    }
    else {
        __block NSInteger findIndex = -1;
        [self.itemChildVCInfo enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSItemChildVCInfo * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key integerValue] < itemIndex) {
                findIndex = MAX(findIndex, obj.childVCIndex);
            }
        }];
        findIndex += 1;
        if (findIndex < 0 || findIndex >= VCS.count) {
            [self.itemChildVCInfo removeObjectForKey:@(itemIndex)];
            return;
        }
    }
    if (viewController) {
        VCS[findIndex] = viewController;
    }
    else {
        [VCS removeObjectAtIndex:findIndex];
        findIndex = -1;
    }
    self.viewControllers = VCS;
    childVCInfo.childVCIndex = findIndex;
    childVCInfo.childVC = viewController;
}

-(void)_removeChildVCAtItemIndex:(NSInteger)itemIndex
{
    NSItemChildVCInfo *childVCInfo = [self.itemChildVCInfo objectForKey:@(itemIndex)];
    if (!childVCInfo) {
        return;
    }
    NSMutableArray *VCS = [self.viewControllers mutableCopy];
    UIViewController *childVC = childVCInfo.childVC;
    childVC.title = nil;
    childVC.tabBarItem.title = nil;
    childVC.tabBarItem.image = nil;
    childVC.tabBarItem.selectedImage = nil;
    [VCS removeObject:childVC];
    self.viewControllers= VCS;
    [self.itemChildVCInfo removeObjectForKey:@(itemIndex)];
}

-(void)setupChildViewController:(UIViewController *)childVC
                      withTitle:(NSString *)title
                          image:(UIImage *)image
                  selectedImage:(UIImage *)selectedImage
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle
{
    if (childVC == nil) {
        return;
    }
    childVC.title = title;
    childVC.tabBarItem.image = image;
    childVC.tabBarItem.selectedImage = selectedImage;
    YZHUINavigationController *nav = [[YZHUINavigationController alloc] initWithRootViewController:childVC navigationControllerBarAndItemStyle:barAndItemStyle];
    NSInteger index = [self.tabBarViewT currentIndex];
    [self _addChildVC:nav atItemIndex:index];
    YZHUITabBarButton *button = [self.tabBarViewT addTabBarItem:childVC.tabBarItem];
    button.tabBarController = self;
    childVC.tabBarButton = button;
}

-(void)setupChildViewController:(UIViewController*)childVC
                      withTitle:(NSString*)title
                      imageName:(NSString*)imageName
              selectedImageName:(NSString*)selectedImageName
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *selectImage = [UIImage imageNamed:selectedImageName];
    [self setupChildViewController:childVC withTitle:title image:image selectedImage:selectImage navigationControllerBarAndItemStyle:barAndItemStyle];
}

-(void)setupChildViewController:(UIViewController *)childVC
                 customItemView:(UIView*)customItemView
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle
{
    if (customItemView == nil) {
        return;
    }
    if (childVC) {
        YZHUINavigationController *nav = [[YZHUINavigationController alloc] initWithRootViewController:childVC navigationControllerBarAndItemStyle:barAndItemStyle];
        NSInteger itemIndex = [self.tabBarViewT currentIndex];
        [self _addChildVC:nav atItemIndex:itemIndex];
    }
    YZHUITabBarButton *button = [self.tabBarViewT addTabBarWithCustomView:customItemView];
    button.tabBarController = self;
    childVC.tabBarButton = button;
}

-(void)clear
{
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.title = nil;
        obj.tabBarItem.title = nil;
        obj.tabBarItem.image = nil;
        obj.tabBarItem.selectedImage = nil;
        [obj removeFromParentViewController];
        obj.tabBarButton = nil;
    }];
    [self.tabBarViewT clear];
    self.itemChildVCInfo = nil;
    [self.view setNeedsLayout];
}

-(void)resetChildViewController:(UIViewController*)childVC
                        withTitle:(NSString*)title
                            image:(UIImage*)image
                    selectedImage:(UIImage*)selectedImage
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle
                          atIndex:(NSInteger)index
{
//    if (index < 0 || index >= self.viewControllers.count) {
//        return;
//    }
    if (childVC == nil) {
        return;
    }
    childVC.title = title;
    childVC.tabBarItem.title = title;
    childVC.tabBarItem.image = image;
    childVC.tabBarItem.selectedImage = selectedImage;
    YZHUINavigationController *nav = [[YZHUINavigationController alloc] initWithRootViewController:childVC navigationControllerBarAndItemStyle:barAndItemStyle];
    [self _updateChildVC:nav atItemIndex:index];
    [self.tabBarViewT resetTabBarItem:childVC.tabBarItem atIndex:index];
}

-(void)resetChildViewController:(UIViewController*)childVC
                      withTitle:(NSString*)title
                      imageName:(NSString*)imageName
              selectedImageName:(NSString*)selectedImageName
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle
                        atIndex:(NSInteger)index
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *selectImage = [UIImage imageNamed:selectedImageName];
    [self resetChildViewController:childVC withTitle:title image:image selectedImage:selectImage navigationControllerBarAndItemStyle:barAndItemStyle atIndex:index];
}

-(void)resetChildViewController:(UIViewController *)childVC
                 customItemView:(UIView*)customItemView
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle
                        atIndex:(NSInteger)index
{
//    if (index < 0 || index >= self.viewControllers.count) {
//        return;
//    }
    if (childVC) {
        YZHUINavigationController *nav = [[YZHUINavigationController alloc] initWithRootViewController:childVC navigationControllerBarAndItemStyle:barAndItemStyle];
        [self _updateChildVC:nav atItemIndex:index];
    }
    else {
        [self _removeChildVCAtItemIndex:index];
    }
    [self.tabBarViewT resetTabBarWithCustomView:customItemView atIndex:index];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _clearTabBar];
//    [self.tabBar.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[UIControl class]]) {
//            [obj removeFromSuperview];
//        }
//    }];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self _hiddenTabBarSubView];
    self.tabBarViewT.frame = self.tabBar.bounds;
    UIColor *barTintColor = self.tabBar.barTintColor;
    if (!barTintColor) {
        barTintColor = WHITE_COLOR;
    }
    self.tabBarViewT.backgroundColor = barTintColor;
    [self _clearTabBar];
//    for (UIView *child in self.tabBar.subviews) {
//        if ([child isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
//            [child removeFromSuperview];
//        }
//    }
}

-(void)_clearTabBar
{
    [self.tabBar.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIControl class]] || [obj isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [obj removeFromSuperview];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
