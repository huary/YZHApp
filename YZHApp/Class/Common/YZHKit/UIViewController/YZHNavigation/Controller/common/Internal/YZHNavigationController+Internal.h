//
//  YZHNavigationController+Internal.h
//  YZHApp
//
//  Created by bytedance on 2021/11/23.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "YZHNavigationController.h"
#import "YZHNavigationBarView.h"
#import "YZHNavigationItemView.h"
#import "YZHTimer.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZHNavigationController () <UIGestureRecognizerDelegate,UINavigationControllerDelegate>

//创建新的navigationBarView
@property (nonatomic, strong) YZHNavigationBarView *navigationBarView;

//创建新的NavigationItem，以后每个ViewController上的Item都是以此为根节点
@property (nonatomic, strong) YZHNavigationItemView *navigationItemView;

//ViewController上面NavigationItem对应表
@property (nonatomic, strong) NSMapTable *navigationItemViewWithVCMap;

//创建百分比驱动动画对象
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *transition;

//是否处在手势交互的状态
@property (nonatomic, assign) BOOL isInteractive;

//push的手势
@property (nonatomic, strong) UIPanGestureRecognizer *pushPan;

//pop的收拾
@property (nonatomic, strong) UIPanGestureRecognizer *popPan;

@property (nonatomic, strong) UIViewController *lastTopVC;

@property (nonatomic, assign) NSTimeInterval latestTransitionDuration;

@property (nonatomic, strong) YZHTimer *updateTransitionTimer;

//在viewController didLoad的时候调用，此函数仅仅是创建了一个NavigationItemView，在push的时候添加
-(void)itn_createNewNavigationItemViewForViewController:(UIViewController*)viewController;

-(void)itn_addNewNavigationItemViewForViewController:(UIViewController*)viewController;

//在viewController pop完成的时候调用，
-(void)itn_removeNavigationItemViewForViewController:(UIViewController*)viewController;

//设置NavigationItemView相关
-(void)itn_setNavigationItemViewAlpha:(CGFloat)alpha
                          minToHidden:(BOOL)minToHidden
                    forViewController:(UIViewController*)viewController;

-(void)itn_setNavigationItemViewTransform:(CGAffineTransform)transform
                        forViewController:(UIViewController*)viewController;

-(void)itn_setNavigationItemTitle:(NSString*)title
                forViewController:(UIViewController*)viewController;

-(void)itn_setNavigationItemTitleTextAttributes:(NSDictionary<NSAttributedStringKey, id>*)textAttributes
                              forViewController:(UIViewController*)viewController;

-(void)itn_addNavigationItemViewLeftButtonItems:(NSArray*)leftButtonItems
                                        isReset:(BOOL)reset
                              forViewController:(UIViewController *)viewController;

-(void)itn_addNavigationItemViewRightButtonItems:(NSArray*)rightButtonItems
                                         isReset:(BOOL)reset
                               forViewController:(UIViewController *)viewController;

-(void)itn_setupItemsSpace:(CGFloat)itemsSpace
                      left:(BOOL)left
         forViewController:(UIViewController *)viewController;

-(void)itn_setupItemEdgeSpace:(CGFloat)edgeSpace
                         left:(BOOL)left
            forViewController:(UIViewController *)viewController;

-(void)itn_addNavigationBarCustomView:(UIView*)customView;

- (UIView *)itn_navigationBar;

- (CGFloat)itn_navigationBarTopLayout;

@end

NS_ASSUME_NONNULL_END
