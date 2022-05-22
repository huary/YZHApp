//
//  YZHTabBarController.m
//  YZHTabBarControllerDemo
//
//  Created by yuan on 17/2/7.
//  Copyright © 2017年 yzh. All rights reserved.
//

#import "YZHTabBarController.h"
#import "UIViewController+YZHTabBarButton.h"

NSString *const YZHTabBarItemTitleNormalColorKey = TYPE_STR(YZHTabBarItemTitleNormalColorKey);
NSString *const YZHTabBarItemTitleSelectedColorKey = TYPE_STR(YZHTabBarItemTitleSelectedColorKey);
NSString *const YZHTabBarItemTitleTextFontKey = TYPE_STR(YZHTabBarItemTitleTextFontKey);
NSString *const YZHTabBarItemSelectedBackgroundColorKey = TYPE_STR(YZHTabBarItemSelectedBackgroundColorKey);
NSString *const YZHTabBarItemHighlightedBackgroundColorKey = TYPE_STR(YZHTabBarItemHighlightedBackgroundColorKey);
NSString *const YZHTabBarTopLineHeightKey = TYPE_STR(YZHTabBarTopLineHeightKey);

NSString *const YZHTabBarItemActionUserInteractionKey = TYPE_STR(YZHTabBarItemActionUserInteractionKey);

/**************************************************************************
 *YZHTabBarController
 **************************************************************************/

@interface YZHTabBarController () <YZHTabBarViewDelegate>

@property (nonatomic, assign) NSInteger lastClickedIndex;
@property (nonatomic, assign) int64_t lastClickedIndexTimeMS;

@end

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
    static YZHTabBarController *sharedTabBarController_s = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTabBarController_s = [[YZHTabBarController alloc] init];
    });
    return sharedTabBarController_s;
}

-(void)_setupDefault
{
    self.doubleTapMaxTimeIntervalMS = 180;
}

-(void)_setupTabBar
{
    YZHTabBarView *tabBarView = [[YZHTabBarView alloc] init];
    tabBarView.delegate  = self;
    tabBarView.frame = self.tabBar.bounds;
    tabBarView.backgroundColor = WHITE_COLOR;
    
    [self _hiddenTabBarSubView];
    
    [self.tabBar addSubview:tabBarView];
    _tabBarView = tabBarView;
    
#if HAVE_YZH_NAVIGATION_KIT
    self.hz_tabBarView = tabBarView;
#endif
}

-(void)_hiddenTabBarSubView
{
    for (UIView *subView in self.tabBar.subviews) {
        if (![subView isKindOfClass:[YZHTabBarView class]]) {
            subView.hidden = YES;
        }
    }
}

#pragma mark YZHTabBarViewDelegate

-(BOOL)tabBarView:(YZHTabBarView *)tabBarView didSelectFrom:(NSInteger)from to:(NSInteger)to actionInfo:(NSDictionary *)actionInfo
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
        self.selectedIndex = to;
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
                [self tabBarView:self.tabBarView doubleClickAtIndex:self.selectedIndex];
            }
        }
    }
    self.lastClickedIndex = to;
    return shouldSelect;
}

-(void)tabBarView:(YZHTabBarView *)tabBarView doubleClickAtIndex:(NSInteger)index
{
    if ([self.tabBarDelegate respondsToSelector:@selector(tabBarController:doubleClickAtIndex:)]) {
        [self.tabBarDelegate tabBarController:self doubleClickAtIndex:index];
    }
}

#pragma mark end

-(void)doSelectTo:(NSInteger)toIndex
{
    [self.tabBarView doSelectTo:toIndex];
}

-(void)_updateChildVC:(UIViewController*)viewController atItemIndex:(NSInteger)itemIndex
{
    if (!viewController) {
        return;
    }
    NSMutableArray *VCS = [self.viewControllers mutableCopy];
    VCS[itemIndex] = viewController;
    self.viewControllers = VCS;
}

- (void)_insertChildVC:(UIViewController*)viewController atItemIndex:(NSInteger)itemIndex
{
    if (!viewController) {
        return;
    }
    NSMutableArray *VCS = [self.viewControllers mutableCopy];
    [VCS insertObject:viewController atIndex:itemIndex];
    self.viewControllers = VCS;
}

-(void)_removeChildVCAtItemIndex:(NSInteger)itemIndex
{
    UIViewController *childVC = [self.viewControllers objectAtIndex:itemIndex];
    childVC.title = nil;
    childVC.tabBarItem.title = nil;
    childVC.tabBarItem.image = nil;
    childVC.tabBarItem.selectedImage = nil;
    [childVC removeFromParentViewController];
    [self.view setNeedsLayout];
//    [VCS removeObject:childVC];
//    self.viewControllers= VCS;
}

#if HAVE_YZH_NAVIGATION_KIT
-(UINavigationController*)setupChildViewController:(UIViewController *)childVC
                                             title:(NSString *)title
                                             image:(UIImage *)image
                                     selectedImage:(UIImage *)selectedImage
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UINavigationController *nav = [self createChildViewController:childVC
                                                            title:title
                                                            image:image
                                                    selectedImage:selectedImage
                                              useSystemNavigation:useSystemNavigation
                                        navigationBarAndItemStyle:barAndItemStyle];
    if (!nav) {
        return nil;
    }
    [self addChildViewController:nav];
    YZHTabBarButton *button = [self.tabBarView addTabBarItem:childVC.tabBarItem];
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    [self pri_clearTabBar];
    return nav;
}

-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                                             title:(NSString*)title
                                         imageName:(NSString*)imageName
                                 selectedImageName:(NSString*)selectedImageName
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *selectImage = [UIImage imageNamed:selectedImageName];
    return [self setupChildViewController:childVC
                                    title:title
                                    image:image
                            selectedImage:selectImage
                      useSystemNavigation:useSystemNavigation
                navigationBarAndItemStyle:barAndItemStyle];
}

-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                                    customItemView:(UIView*)customItemView
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UINavigationController *nav = [self createChildViewController:childVC
                                              useSystemNavigation:useSystemNavigation
                                        navigationBarAndItemStyle:barAndItemStyle];
    if (!nav) {
        return nil;
    }
    [self addChildViewController:nav];
    YZHTabBarButton *button = [self.tabBarView addTabBarWithCustomView:customItemView];
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    [self pri_clearTabBar];
    return nav;
}

-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UINavigationController *nav = [self createChildViewController:childVC
                                              useSystemNavigation:useSystemNavigation
                                        navigationBarAndItemStyle:barAndItemStyle];

    if (!nav) {
        return nil;
    }
    [self addChildViewController:nav];
    YZHTabBarButton *button = [self.tabBarView addTabBarItem:childVC.tabBarItem];
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    [self pri_clearTabBar];
    return nav;
}

#else
-(UINavigationController*)setupChildViewController:(UIViewController *)childVC
                                             title:(NSString *)title
                                             image:(UIImage *)image
                                     selectedImage:(UIImage *)selectedImage
{
    if (childVC == nil) {
        return nil;
    }
    childVC.title = title;
    childVC.tabBarItem.title = title;
    childVC.tabBarItem.image = image;
    childVC.tabBarItem.selectedImage = selectedImage;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVC];
    [self addChildViewController:nav];
    YZHTabBarButton *button = [self.tabBarView addTabBarItem:childVC.tabBarItem];
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    return nav;
}

-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                                             title:(NSString*)title
                                         imageName:(NSString*)imageName
                                 selectedImageName:(NSString*)selectedImageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *selectImage = [UIImage imageNamed:selectedImageName];
    return [self setupChildViewController:childVC title:title image:image selectedImage:selectImage];
}

-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                                    customItemView:(UIView*)customItemView
{
    if (childVC == nil) {
        return nil;
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVC];
    [self addChildViewController:nav];
    YZHTabBarButton *button = [self.tabBarView addTabBarWithCustomView:customItemView];
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    return nav;
}

-(UINavigationController*)setupChildViewController:(UIViewController*)childVC {
    if (childVC == nil) {
        return nil;
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVC];
    [self addChildViewController:nav];
    YZHTabBarButton *button = [self.tabBarView addTabBarItem:childVC.tabBarItem];
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    return nav;
}
#endif

-(void)setupChildNavigationController:(UINavigationController*)navigationController {
    if (!navigationController) {
        return;
    }
    [self addChildViewController:navigationController];
    UIViewController *rootVC = navigationController.viewControllers.firstObject;
    YZHTabBarButton *button = [self.tabBarView addTabBarItem:rootVC.tabBarItem];
    button.tabBarController = self;
    rootVC.hz_tabBarButton = button;
    [self pri_clearTabBar];
}

-(void)clear
{
    [self.viewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    self.viewControllers = nil;
    [self.tabBarView clear];
    [self.view setNeedsLayout];
}

#if HAVE_YZH_NAVIGATION_KIT
-(UINavigationController*)resetChildViewController:(UIViewController*)childVC
                                           atIndex:(NSInteger)index
                                             title:(NSString*)title
                                             image:(UIImage*)image
                                     selectedImage:(UIImage*)selectedImage
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UINavigationController *nav = [self createChildViewController:childVC
                                                            title:title
                                                            image:image
                                                    selectedImage:selectedImage
                                              useSystemNavigation:useSystemNavigation
                                        navigationBarAndItemStyle:barAndItemStyle];
    if (!nav) {
        return nil;
    }
    YZHTabBarButton *button = nil;
    BOOL add = index == self.viewControllers.count;
    if (add) {
        [self addChildViewController:nav];
        button = [self.tabBarView addTabBarItem:childVC.tabBarItem];
        button.tabBarController = self;
        childVC.hz_tabBarButton = button;
    }
    else {
        if (!IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index)) {
            return nil;
        }
        [self _updateChildVC:nav atItemIndex:index];
        button = [self.tabBarView resetTabBarItem:childVC.tabBarItem atIndex:index];
    }
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    [self pri_clearTabBar];
    return nav;
}

-(UINavigationController*)resetChildViewController:(UIViewController*)childVC
                                           atIndex:(NSInteger)index
                                             title:(NSString*)title
                                         imageName:(NSString*)imageName
                                 selectedImageName:(NSString*)selectedImageName
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *selectImage = [UIImage imageNamed:selectedImageName];
    return [self resetChildViewController:childVC
                                  atIndex:index
                                    title:title
                                    image:image
                            selectedImage:selectImage
                      useSystemNavigation:useSystemNavigation
                navigationBarAndItemStyle:barAndItemStyle];
}

-(UINavigationController*)resetChildViewController:(UIViewController *)childVC
                                           atIndex:(NSInteger)index
                                    customItemView:(UIView*)customItemView
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UINavigationController *nav = [self createChildViewController:childVC
                                              useSystemNavigation:useSystemNavigation
                                        navigationBarAndItemStyle:barAndItemStyle];
    if (!nav) {
        return nil;
    }
    YZHTabBarButton *button = nil;
    BOOL add = index == self.viewControllers.count;
    if (add) {
        [self addChildViewController:nav];
        if (customItemView) {
            button = [self.tabBarView addTabBarWithCustomView:customItemView];
        }
        else {
            button = [self.tabBarView addTabBarItem:childVC.tabBarItem];
        }
    }
    else {
        if (!IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index)) {
            return nil;
        }
        [self _updateChildVC:nav atItemIndex:index];
        if (customItemView) {
            button = [self.tabBarView resetTabBarWithCustomView:customItemView atIndex:index];
        }
        else {
            button = [self.tabBarView resetTabBarItem:childVC.tabBarItem atIndex:index];
        }
    }
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    [self pri_clearTabBar];
    return nav;
}

-(UINavigationController*)resetChildViewController:(UIViewController *)childVC
                                           atIndex:(NSInteger)index
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UINavigationController *nav = [self createChildViewController:childVC
                                              useSystemNavigation:useSystemNavigation
                                        navigationBarAndItemStyle:barAndItemStyle];
    if (!nav) {
        return nil;
    }
    YZHTabBarButton *button = nil;
    BOOL add = index == self.viewControllers.count;
    if (add) {
        [self addChildViewController:nav];
        button = [self.tabBarView addTabBarItem:childVC.tabBarItem];
    }
    else {
        if (!IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index)) {
            return nil;
        }
        [self _updateChildVC:nav atItemIndex:index];
        button = [self.tabBarView resetTabBarItem:childVC.tabBarItem atIndex:index];
    }
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    [self pri_clearTabBar];
    return nav;
}

-(UINavigationController*)insertChildViewController:(UIViewController*)childVC
                                            atIndex:(NSInteger)index
                                              title:(NSString*)title
                                              image:(UIImage*)image
                                      selectedImage:(UIImage*)selectedImage
                                useSystemNavigation:(BOOL)useSystemNavigation
                          navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UINavigationController *nav = [self createChildViewController:childVC
                                                            title:title
                                                            image:image
                                                    selectedImage:selectedImage
                                              useSystemNavigation:useSystemNavigation
                                        navigationBarAndItemStyle:barAndItemStyle];
    if (!nav || !IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index)) {
        return nil;
    }
    [self _insertChildVC:nav atItemIndex:index];
    
    YZHTabBarButton *button = [self.tabBarView insertTabBarItem:childVC.tabBarItem atIndex:index];
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    [self pri_clearTabBar];
    return nav;
}

-(UINavigationController*)insertChildViewController:(UIViewController*)childVC
                                            atIndex:(NSInteger)index
                                              title:(NSString*)title
                                          imageName:(NSString*)imageName
                                  selectedImageName:(NSString*)selectedImageName
                                useSystemNavigation:(BOOL)useSystemNavigation
                          navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *selectImage = [UIImage imageNamed:selectedImageName];
    return [self insertChildViewController:childVC
                            atIndex:index
                              title:title
                              image:image
                      selectedImage:selectImage
                useSystemNavigation:useSystemNavigation
          navigationBarAndItemStyle:barAndItemStyle];
}

-(UINavigationController*)insertChildViewController:(UIViewController *)childVC
                                            atIndex:(NSInteger)index
                                     customItemView:(UIView*)customItemView
                                useSystemNavigation:(BOOL)useSystemNavigation
                          navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UINavigationController *nav = [self createChildViewController:childVC
                                              useSystemNavigation:useSystemNavigation
                                        navigationBarAndItemStyle:barAndItemStyle];
    if (!nav || !IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index)) {
        return nil;
    }
    
    [self _insertChildVC:childVC atItemIndex:index];
    
    YZHTabBarButton *button = [self.tabBarView insertTabBarWithCustomView:customItemView atIndex:index];
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    [self pri_clearTabBar];
    return nav;
}

-(UINavigationController*)insertChildViewController:(UIViewController *)childVC
                                            atIndex:(NSInteger)index
                                useSystemNavigation:(BOOL)useSystemNavigation
                          navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    UINavigationController *nav = [self createChildViewController:childVC
                                              useSystemNavigation:useSystemNavigation
                                        navigationBarAndItemStyle:barAndItemStyle];
    if (!nav || !IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index)) {
        return nil;
    }
    
    [self _insertChildVC:childVC atItemIndex:index];
    
    YZHTabBarButton *button = [self.tabBarView insertTabBarItem:childVC.tabBarItem atIndex:index];
    button.tabBarController = self;
    childVC.hz_tabBarButton = button;
    [self pri_clearTabBar];
    return nav;
}


#else
-(UINavigationController*)resetChildViewController:(UIViewController*)childVC
                                           atIndex:(NSInteger)index
                                             title:(NSString*)title
                                             image:(UIImage*)image
                                     selectedImage:(UIImage*)selectedImage
{
    if (childVC == nil) {
        return nil;
    }
    childVC.title = title;
    childVC.tabBarItem.title = title;
    childVC.tabBarItem.image = image;
    childVC.tabBarItem.selectedImage = selectedImage;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVC];
    [self _updateChildVC:nav atItemIndex:index];
    [self.tabBarView resetTabBarItem:childVC.tabBarItem atIndex:index];
    return nav;
}

-(UINavigationController*)resetChildViewController:(UIViewController*)childVC
                                           atIndex:(NSInteger)index
                                             title:(NSString*)title
                                         imageName:(NSString*)imageName
                                 selectedImageName:(NSString*)selectedImageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *selectImage = [UIImage imageNamed:selectedImageName];
    return [self resetChildViewController:childVC
                                  atIndex:index
                                    title:title
                                    image:image
                            selectedImage:selectImage];
}

-(UINavigationController*)resetChildViewController:(UIViewController *)childVC
                                    customItemView:(UIView*)customItemView
                                           atIndex:(NSInteger)index
{
    if (!childVC) {
        return nil;
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVC];
    [self _updateChildVC:nav atItemIndex:index];
    if (customItemView) {
        [self.tabBarView resetTabBarWithCustomView:customItemView atIndex:index];
    }
    else {
        [self.tabBarView resetTabBarItem:childVC.tabBarItem atIndex:index];
    }
    return nav;
}

-(UINavigationController*)resetChildViewController:(UIViewController *)childVC
                                           atIndex:(NSInteger)index {
    if (!childVC) {
        return nil;
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVC];
    [self _updateChildVC:nav atItemIndex:index];
    [self.tabBarView resetTabBarItem:childVC.tabBarItem atIndex:index];
    return nav;
}
#endif

-(UINavigationController *)createChildViewController:(UIViewController *)childVC
                                               title:(NSString *)title
                                               image:(UIImage *)image
                                       selectedImage:(UIImage *)selectedImage
                                 useSystemNavigation:(BOOL)useSystemNavigation
                           navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle {
    if (childVC == nil) {
        return nil;
    }
    childVC.title = title;
    childVC.tabBarItem.title = title;
    childVC.tabBarItem.image = image;
    childVC.tabBarItem.selectedImage = selectedImage;
    childVC.hz_barAndItemStyleForRootVCInitSetToNavigation = barAndItemStyle;
    UINavigationController *nav = nil;
    if (useSystemNavigation) {
        childVC.hz_navigationEnableForRootVCInitSetToNavigation = YES;
        nav = [[UINavigationController alloc] initWithRootViewController:childVC];
    }
    else {
        nav = [[YZHNavigationController alloc] initWithRootViewController:childVC];
    }
    return nav;
}

-(UINavigationController*)createChildViewController:(UIViewController*)childVC
                                useSystemNavigation:(BOOL)useSystemNavigation
                          navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle
{
    if (childVC == nil) {
        return nil;
    }
    childVC.hz_barAndItemStyleForRootVCInitSetToNavigation = barAndItemStyle;
    UINavigationController *nav = nil;
    if (useSystemNavigation) {
        childVC.hz_navigationEnableForRootVCInitSetToNavigation = YES;
        nav = [[UINavigationController alloc] initWithRootViewController:childVC];
    }
    else {
        nav = [[YZHNavigationController alloc] initWithRootViewController:childVC];
    }
    return nav;
}

-(void)resetupChildNavigationController:(UINavigationController*)navigationController atIndex:(NSInteger)index {
    if (!navigationController) {
        return;
    }
    UIViewController *rootVC = navigationController.viewControllers.firstObject;

    BOOL add = index == self.viewControllers.count;

    YZHTabBarButton *button = nil;
    if (add) {
        [self addChildViewController:navigationController];
        button = [self.tabBarView addTabBarItem:rootVC.tabBarItem];
    }
    else {
        if (!IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index)) {
            return;
        }
        [self _updateChildVC:navigationController atItemIndex:index];
        button = [self.tabBarView resetTabBarItem:rootVC.tabBarItem atIndex:index];
    }
    [self pri_clearTabBar];
    button.tabBarController = self;
    rootVC.hz_tabBarButton = button;
}

-(void)removeChildNavigationController:(UINavigationController*)navigationController {
    if (!navigationController) {
        return;
    }
    NSInteger index = [self.viewControllers indexOfObject:navigationController];
    NSLog(@"remove.chld.index=%ld",index);
    if (index != NSNotFound) {
        [self removeChildViewControllerAtIndex:index];        
    }
    [self pri_clearTabBar];
}

-(void)removeChildViewControllerAtIndex:(NSInteger)index {
    if (!IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index)) {
        return;
    }
    [self _removeChildVCAtItemIndex:index];
    [self.tabBarView removeTabBarAtIndex:index];
    [self pri_clearTabBar];
}

-(void)exchangeChildViewControllerAtIndex:(NSInteger)index1 withChildViewControllerAtIndex:(NSInteger)index2 animation:(BOOL)animation {
    if (!IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index1) || !IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index2)) {
        return;
    }
    NSMutableArray *VCS = self.viewControllers.mutableCopy;
    UIViewController *VC1 = VCS[index1];
    UIViewController *VC2 = VCS[index2];
    VCS[index1] = VC2;
    VCS[index2] = VC1;
    self.viewControllers = VCS.copy;
    [self.tabBarView exchangeTabBarButtonAtIndex:index1 withTabBarButtonAtIndex:index2 animation:animation];
    [self pri_clearTabBar];
}

-(void)exchangeChildViewControllerAtIndex:(NSInteger)index1 withChildViewControllerAtIndex:(NSInteger)index2 animationBlock:(YZHTabBarViewExchangeTabBarButtonAnimationBlock)animationBlock {
    if (!IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index1) || !IS_IN_ARRAY_FOR_INDEX(self.viewControllers, index2)) {
        return;
    }
    NSMutableArray *VCS = self.viewControllers.mutableCopy;
    UIViewController *VC1 = VCS[index1];
    UIViewController *VC2 = VCS[index2];
    VCS[index1] = VC2;
    VCS[index2] = VC1;
    self.viewControllers = VCS.copy;
    [self.tabBarView exchangeTabBarButtonAtIndex:index1 withTabBarButtonAtIndex:index2 animationBlock:animationBlock];
    [self pri_clearTabBar];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self pri_clearTabBar];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self pri_layoutTabBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self pri_layoutTabBar];
}

-(void)pri_layoutTabBar {
    [self _hiddenTabBarSubView];
    self.tabBarView.frame = self.tabBar.bounds;
    if (self.tabBarView.superview != self.tabBar) {
        [self.tabBar addSubview:self.tabBarView];        
    }
    UIColor *barTintColor = self.tabBar.barTintColor;
    if (!barTintColor) {
        barTintColor = WHITE_COLOR;
    }
    self.tabBarView.backgroundColor = barTintColor;
    [self pri_clearTabBar];
}

-(void)pri_clearTabBar
{
    [self.tabBar.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIControl class]] || [obj isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [obj removeFromSuperview];
        }
    }];
}


- (BOOL)shouldAutorotate
{
    return self.selectedViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.selectedViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.selectedViewController.preferredInterfaceOrientationForPresentation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
