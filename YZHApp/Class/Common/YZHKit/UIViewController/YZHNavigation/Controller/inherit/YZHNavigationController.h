//
//  YZHNavigationController.h
//  YZHNavigationController
//
//  Created by yuan on 16/11/17.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHNavigationBarView.h"
#import "YZHNavigationTypes.h"


@interface YZHNavigationController : UINavigationController

//设置barViewStyle的style
@property (nonatomic, assign) YZHNavBarStyle navBarStyle;
//设置navigationBarView的backgroundColor
@property (nonatomic, strong) UIColor *navigationBarViewBackgroundColor;
//设置navigationBarView底部线条的颜色
@property (nonatomic, strong) UIColor *navigationBarBottomLineColor;
//barview的aplha
@property (nonatomic, assign) CGFloat navigationBarViewAlpha;
//pop事件是否允许，默认为YES
@property (nonatomic, assign) BOOL popGestureEnabled;
//动画时间,默认为0
@property (nonatomic, assign) NSTimeInterval transitionDuration;

//在push后是否隐藏tabBar，对第一个rootVC不生效，默认为YES
@property (nonatomic, assign) BOOL hidesTabBarAfterPushed;

//导航栏的事件代理
@property (nonatomic,weak) id<YZHNavigationControllerDelegate> navDelegate;

//导航栏和item的样式
@property (nonatomic, assign) YZHNavigationBarAndItemStyle navigationBarAndItemStyle;

//设置导航栏和item及其subView的frame
-(void)resetNavigationBarAndItemViewFrame:(CGRect)frame;

//带有完成的push,带有一个动画完成的回调
-(void)pushViewController:(UIViewController *)viewController
                 animated:(BOOL)animated
               completion:(YZHNavigationControllerAnimationCompletionBlock)completion;

-(void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
               completion:(YZHNavigationControllerAnimationCompletionBlock)completion;

-(void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
                 animated:(BOOL)animated
               completion:(YZHNavigationControllerAnimationCompletionBlock)completion;

//带有完成的pop，带有一个动画完成的回调
-(UIViewController*)popViewControllerAnimated:(BOOL)animated
                                   completion:(YZHNavigationControllerAnimationCompletionBlock)completion;

-(NSArray<UIViewController*>*)popToViewController:(UIViewController *)viewController
                                         animated:(BOOL)animated
                                       completion:(YZHNavigationControllerAnimationCompletionBlock)completion;

-(NSArray<UIViewController*>*)popToRootViewControllerAnimated:(BOOL)animated
                                                   completion:(YZHNavigationControllerAnimationCompletionBlock)completion;
@end
