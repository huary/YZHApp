//
//  YZHTabBarController.h
//  YZHTabBarControllerDemo
//
//  Created by yuan on 17/2/7.
//  Copyright © 2017年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHTabBarView.h"
#if __has_include("YZHNavigationController.h")
#define HAVE_YZH_NAVIGATION_KIT 1
#import "YZHNavigationController.h"
#import "YZHNavigationTypes.h"
#import "UITabBarController+YZHTabBarView.h"
#import "UIViewController+YZHNavigationRootVCInitSetup.h"
#import "UINavigationController+YZHNavigation.h"
#endif

UIKIT_EXTERN NSString *const YZHTabBarItemTitleTextFontKey;
UIKIT_EXTERN NSString *const YZHTabBarItemTitleNormalColorKey;
UIKIT_EXTERN NSString *const YZHTabBarItemTitleSelectedColorKey;
UIKIT_EXTERN NSString *const YZHTabBarItemSelectedBackgroundColorKey;
UIKIT_EXTERN NSString *const YZHTabBarItemHighlightedBackgroundColorKey;
UIKIT_EXTERN NSString *const YZHTabBarTopLineHeightKey;

UIKIT_EXTERN NSString *const YZHTabBarItemActionUserInteractionKey;


@class YZHTabBarController;
@protocol YZHTabBarControllerDelegate <NSObject>

@optional

-(BOOL)tabBarController:(YZHTabBarController*)tabBarController shouldSelectFrom:(NSInteger)from to:(NSInteger)to;

-(BOOL)tabBarController:(YZHTabBarController *)tabBarController shouldSelectFrom:(NSInteger)from to:(NSInteger)to actionInfo:(NSDictionary*)actionInfo;

-(BOOL)tabBarController:(YZHTabBarController *)tabBarController shouldDoubleClickAtIndex:(NSInteger)index actionInfo:(NSDictionary*)actionInfo;
/*这个双击只有在第二次与第一次选中的是同一个的时候双击才起作用
 *调用顺序为上面的shouldSelectFrom:to->shouldSelectFrom:to->doubleClickAtIndex:
 */
-(void)tabBarController:(YZHTabBarController *)tabBarController doubleClickAtIndex:(NSInteger)index;

@end

/*
 *YZHTabBarController不是单例对象，提供了一个全局的对象shareTabBarController
 */
@interface YZHTabBarController : UITabBarController

//设置
@property (nonatomic, copy) NSDictionary *tabBarAttributes;

@property (nonatomic, weak) id<YZHTabBarControllerDelegate> tabBarDelegate;

/* doubleTapMaxTimeInterval 双击间隔的时间，以毫秒为单位，默认为180ms */
@property (nonatomic, assign) NSInteger doubleTapMaxTimeIntervalMS;

@property (nonatomic, strong, readonly) YZHTabBarView *tabBarView;

+(YZHTabBarController*)shareTabBarController;

-(void)doSelectTo:(NSInteger)toIndex;

#if HAVE_YZH_NAVIGATION_KIT
//childVC 不可以为nil
-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                                             title:(NSString*)title
                                             image:(UIImage*)image
                                     selectedImage:(UIImage*)selectedImage
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

//childVC 不可以为nil
-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                                             title:(NSString*)title
                                         imageName:(NSString*)imageName
                                 selectedImageName:(NSString*)selectedImageName
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                                    customItemView:(UIView *)customItemView
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;
#else
//childVC 不可以为nil
-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                                             title:(NSString*)title
                                             image:(UIImage*)image
                                     selectedImage:(UIImage*)selectedImage;

//childVC 不可以为nil
-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                                             title:(NSString*)title
                                         imageName:(NSString*)imageName
                                 selectedImageName:(NSString*)selectedImageName;

-(UINavigationController*)setupChildViewController:(UIViewController*)childVC
                                    customItemView:(UIView *)customItemView;

-(UINavigationController*)setupChildViewController:(UIViewController*)childVC;
#endif

-(void)setupChildNavigationController:(UINavigationController*)navigationController;

-(void)clear;

#if HAVE_YZH_NAVIGATION_KIT
-(UINavigationController*)resetChildViewController:(UIViewController*)childVC
                                           atIndex:(NSInteger)index
                                             title:(NSString*)title
                                             image:(UIImage*)image
                                     selectedImage:(UIImage*)selectedImage
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

-(UINavigationController*)resetChildViewController:(UIViewController*)childVC
                                           atIndex:(NSInteger)index
                                             title:(NSString*)title
                                         imageName:(NSString*)imageName
                                 selectedImageName:(NSString*)selectedImageName
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

-(UINavigationController*)resetChildViewController:(UIViewController *)childVC
                                           atIndex:(NSInteger)index
                                    customItemView:(UIView*)customItemView
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

-(UINavigationController*)resetChildViewController:(UIViewController *)childVC
                                           atIndex:(NSInteger)index
                               useSystemNavigation:(BOOL)useSystemNavigation
                         navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

//insert
-(UINavigationController*)insertChildViewController:(UIViewController*)childVC
                                            atIndex:(NSInteger)index
                                              title:(NSString*)title
                                              image:(UIImage*)image
                                      selectedImage:(UIImage*)selectedImage
                                useSystemNavigation:(BOOL)useSystemNavigation
                          navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

-(UINavigationController*)insertChildViewController:(UIViewController*)childVC
                                            atIndex:(NSInteger)index
                                              title:(NSString*)title
                                          imageName:(NSString*)imageName
                                  selectedImageName:(NSString*)selectedImageName
                                useSystemNavigation:(BOOL)useSystemNavigation
                          navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

-(UINavigationController*)insertChildViewController:(UIViewController *)childVC
                                            atIndex:(NSInteger)index
                                     customItemView:(UIView*)customItemView
                                useSystemNavigation:(BOOL)useSystemNavigation
                          navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

-(UINavigationController*)insertChildViewController:(UIViewController *)childVC
                                            atIndex:(NSInteger)index
                                useSystemNavigation:(BOOL)useSystemNavigation
                          navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;
#else

-(UINavigationController*)resetChildViewController:(UIViewController*)childVC
                                           atIndex:(NSInteger)index
                                             title:(NSString*)title
                                             image:(UIImage*)image
                                     selectedImage:(UIImage*)selectedImage;

-(UINavigationController*)resetChildViewController:(UIViewController*)childVC
                                           atIndex:(NSInteger)index
                                             title:(NSString*)title
                                         imageName:(NSString*)imageName
                                 selectedImageName:(NSString*)selectedImageName;

-(UINavigationController*)resetChildViewController:(UIViewController *)childVC
                                    customItemView:(UIView*)customItemView
                                           atIndex:(NSInteger)index;

-(UINavigationController*)resetChildViewController:(UIViewController *)childVC
                                           atIndex:(NSInteger)index;

#endif

//仅仅是创建，不添加到viewcontrollers，也不添加到tabbar中
-(UINavigationController *)createChildViewController:(UIViewController *)childVC
                                               title:(NSString *)title
                                               image:(UIImage *)image
                                       selectedImage:(UIImage *)selectedImage
                                 useSystemNavigation:(BOOL)useSystemNavigation
                           navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

//仅仅是创建，不添加到viewcontrollers，也不添加到tabbar中
-(UINavigationController*)createChildViewController:(UIViewController*)childVC
                                useSystemNavigation:(BOOL)useSystemNavigation
                          navigationBarAndItemStyle:(YZHNavigationBarAndItemStyle)barAndItemStyle;

-(void)resetupChildNavigationController:(UINavigationController*)navigationController atIndex:(NSInteger)index;

-(void)removeChildNavigationController:(UINavigationController*)navigationController;

-(void)removeChildViewControllerAtIndex:(NSInteger)index;

-(void)exchangeChildViewControllerAtIndex:(NSInteger)index1 withChildViewControllerAtIndex:(NSInteger)index2 animation:(BOOL)animation;

-(void)exchangeChildViewControllerAtIndex:(NSInteger)index1 withChildViewControllerAtIndex:(NSInteger)index2 animationBlock:(YZHTabBarViewExchangeTabBarButtonAnimationBlock)animationBlock;

@end
