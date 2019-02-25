//
//  YZHTabBarController.h
//  YZHTabBarControllerDemo
//
//  Created by captain on 17/2/7.
//  Copyright © 2017年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUINavigationController.h"

UIKIT_EXTERN NSString *const YZHTabBarItemTitleTextFontKey;
UIKIT_EXTERN NSString *const YZHTabBarItemTitleNormalColorKey;
UIKIT_EXTERN NSString *const YZHTabBarItemTitleSelectedColorKey;
UIKIT_EXTERN NSString *const YZHTabBarItemSelectedBackgroundColorKey;
UIKIT_EXTERN NSString *const YZHTabBarItemHighlightedBackgroundColorKey;

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

@property (nonatomic, copy) NSDictionary *tabBarAttributes;
@property (nonatomic, weak) id<YZHTabBarControllerDelegate> tabBarDelegate;

/* doubleTapMaxTimeInterval 双击间隔的时间，以毫秒为单位，默认为180ms */
@property (nonatomic, assign) NSInteger doubleTapMaxTimeIntervalMS;

+(YZHTabBarController*)shareTabBarController;

-(void)doSelectTo:(NSInteger)toIndex;

-(void)setupChildViewController:(UIViewController*)childVC
                      withTitle:(NSString*)title
                          image:(UIImage*)image
                  selectedImage:(UIImage*)selectedImage
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle;

-(void)setupChildViewController:(UIViewController*)childVC
                      withTitle:(NSString*)title
                      imageName:(NSString*)imageName
              selectedImageName:(NSString*)selectedImageName
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle;

-(void)setupChildViewController:(UIViewController *)childVC
                 customItemView:(UIView*)customItemView
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle;

-(void)clear;

-(void)resetChildViewController:(UIViewController*)childVC
                      withTitle:(NSString*)title
                          image:(UIImage*)image
                  selectedImage:(UIImage*)selectedImage
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle
                          atIndex:(NSInteger)index;

-(void)resetChildViewController:(UIViewController*)childVC
                        withTitle:(NSString*)title
                        imageName:(NSString*)imageName
                selectedImageName:(NSString*)selectedImageName
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle
                          atIndex:(NSInteger)index;

-(void)resetChildViewController:(UIViewController *)childVC
                 customItemView:(UIView*)customItemView
navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle
                        atIndex:(NSInteger)index;
@end
