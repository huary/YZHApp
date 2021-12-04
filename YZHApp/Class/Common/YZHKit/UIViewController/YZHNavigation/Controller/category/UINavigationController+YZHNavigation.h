//
//  UINavigationController+YZHNavigation.h
//  YZHApp
//
//  Created by bytedance on 2021/11/22.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHNavigationTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (YZHNavigation)

//是否开启本SDK开发的功能，默认为NO
@property (nonatomic, assign) BOOL hz_navigationEnable;
//设置barViewStyle的style
@property (nonatomic, assign) YZHNavBarStyle hz_navBarStyle;
//设置navigationBarView的backgroundColor
@property (nonatomic, strong) UIColor *hz_navigationBarViewBackgroundColor;
//设置navigationBarView底部线条的颜色
@property (nonatomic, strong) UIColor *hz_navigationBarBottomLineColor;
//barview的aplha
@property (nonatomic, assign) CGFloat hz_navigationBarViewAlpha;
//pop事件是否允许，默认为YES
@property (nonatomic, assign) BOOL hz_popGestureEnabled;

//动画时间,默认为0
@property (nonatomic, assign) NSTimeInterval hz_transitionDuration;

/*
 *hidesTabBarWhenPushed
 *在navigationController后所有的push操作都会hidesTabBar,
 *在之前已经push的VC的hidesBottomBarWhenPushed都会设置为NO,以后的都会设置为YES
 *默认为YES
 */
@property (nonatomic, assign) BOOL hz_hidesTabBarAfterPushed;
//导航栏的事件代理
@property (nonatomic,weak) id<YZHNavigationControllerDelegate> hz_navDelegate;
//导航栏和item的样式
@property (nonatomic, assign) YZHNavigationBarAndItemStyle hz_navigationBarAndItemStyle;

//设置导航栏和item及其subView的frame
-(void)hz_resetNavigationBarAndItemViewFrame:(CGRect)frame;

//自定义
-(void)hz_pushViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
                  completion:(YZHNavigationControllerAnimationCompletionBlock)completion;

-(void)hz_setViewControllers:(NSArray<UIViewController *> *)viewControllers
                  completion:(YZHNavigationControllerAnimationCompletionBlock)completion;

-(void)hz_setViewControllers:(NSArray<UIViewController *> *)viewControllers
                    animated:(BOOL)animated
                  completion:(YZHNavigationControllerAnimationCompletionBlock)completion;

//带有完成的pop，和系统的只带有一个动画完成的回调


- (UIViewController *)hz_popViewControllerAnimated:(BOOL)animated
                                        completion:(YZHNavigationControllerAnimationCompletionBlock)completion;

- (NSArray<UIViewController*> *)hz_popToViewController:(UIViewController *)viewController
                                              animated:(BOOL)animated
                                            completion:(YZHNavigationControllerAnimationCompletionBlock)completion;

- (NSArray<UIViewController*> *)hz_popToRootViewControllerAnimated:(BOOL)animated
                                                        completion:(YZHNavigationControllerAnimationCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
