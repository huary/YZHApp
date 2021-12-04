//
//  UINavigationController+YZHNavigationItn.h
//  YZHApp
//
//  Created by bytedance on 2021/11/22.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHNavigationBarView.h"
#import "YZHNavigationItemView.h"
#import "YZHTimer.h"

#define PREV_NC_CHECK(ret)   if (!self.hz_navigationEnable || ![self isKindOfClass:[UINavigationController class]]) return ret;


NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (YZHNavigationItn)

//创建新的navigationBarView
@property (nonatomic, strong) YZHNavigationBarView *hz_itn_nc_navigationBarView;

//创建新的NavigationItem，以后每个ViewController上的Item都是以此为根节点
@property (nonatomic, strong) YZHNavigationItemView *hz_itn_nc_navigationItemView;

//ViewController上面NavigationItem对应表
@property (nonatomic, strong) NSMapTable *hz_itn_navigationItemViewWithVCMap;

//创建百分比驱动动画对象
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *hz_itn_transition;

//是否处在手势交互的状态
@property (nonatomic, assign) BOOL hz_itn_isInteractive;

//push的手势
@property (nonatomic, strong) UIPanGestureRecognizer *hz_itn_pushPan;

//pop的收拾
@property (nonatomic, strong) UIPanGestureRecognizer *hz_itn_popPan;

@property (nonatomic, strong, nullable) UIViewController *hz_itn_lastTopVC;

@property (nonatomic, assign) NSTimeInterval hz_itn_latestTransitionDuration;

@property (nonatomic, strong, nullable) YZHTimer *hz_itn_updateTransitionTimer;


//在viewController初始化的时候调用，此函数仅仅是创建了一个NavigationItemView，在push的时候添加
-(void)hz_itn_createNewNavigationItemViewForViewController:(UIViewController*)viewController;

-(void)hz_itn_addNewNavigationItemViewForViewController:(UIViewController*)viewController;

//在viewController pop完成的时候调用，
-(void)hz_itn_removeNavigationItemViewForViewController:(UIViewController*)viewController;

//设置NavigationItemView相关
-(void)hz_itn_setNavigationItemViewAlpha:(CGFloat)alpha
                             minToHidden:(BOOL)minToHidden
                       forViewController:(UIViewController*)viewController;

-(void)hz_itn_setNavigationItemViewTransform:(CGAffineTransform)transform
                           forViewController:(UIViewController*)viewController;

-(void)hz_itn_setNavigationItemTitle:(NSString*)title
                   forViewController:(UIViewController*)viewController;

-(void)hz_itn_setNavigationItemTitleTextAttributes:(NSDictionary<NSAttributedStringKey, id>*)textAttributes
                                 forViewController:(UIViewController*)viewController;

-(void)hz_itn_addNavigationItemViewLeftButtonItems:(NSArray*)leftButtonItems
                                           isReset:(BOOL)reset
                                 forViewController:(UIViewController *)viewController;

-(void)hz_itn_addNavigationItemViewRightButtonItems:(NSArray*)rightButtonItems
                                            isReset:(BOOL)reset
                                  forViewController:(UIViewController *)viewController;

-(void)hz_itn_setupItemsSpace:(CGFloat)itemsSpace
                         left:(BOOL)left
            forViewController:(UIViewController *)viewController;

-(void)hz_itn_setupItemEdgeSpace:(CGFloat)edgeSpace
                            left:(BOOL)left
               forViewController:(UIViewController *)viewController;

-(void)hz_itn_addNavigationBarCustomView:(UIView*)customView;

- (UIView *)hz_itn_navigationBar;

- (CGFloat)hz_itn_navigationBarTopLayout;

@end

NS_ASSUME_NONNULL_END
