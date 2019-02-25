//
//  YZHUINavigationController.h
//  YZHUINavigationController
//
//  Created by captain on 16/11/17.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUINavigationBarView.h"

#define IS_SYSTEM_DEFAULT_UINAVIGATIONCONTROLLER_BARITEM_STYLE(STYLE)       (STYLE ==UINavigationControllerBarAndItemDefaultStyle)

#define IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_BAR_STYLE(STYLE)            (STYLE ==UINavigationControllerBarAndItemGlobalBarWithDefaultItemStyle || STYLE == UINavigationControllerBarAndItemGlobalBarItemStyle)

#define IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_BAR_STYLE(STYLE)    (STYLE ==UINavigationControllerBarAndItemViewControllerBarItemStyle || STYLE == UINavigationControllerBarAndItemViewControllerBarWithDefaultItemStyle)

#define IS_SYSTEM_DEFAULT_UINAVIGATIONCONTROLLER_ITEM_STYLE(STYLE)          (STYLE == UINavigationControllerBarAndItemDefaultStyle || STYLE == UINavigationControllerBarAndItemGlobalBarWithDefaultItemStyle || STYLE == UINavigationControllerBarAndItemViewControllerBarWithDefaultItemStyle)

#define IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(STYLE)           (STYLE == UINavigationControllerBarAndItemGlobalBarItemStyle)

#define IS_CUSTOM_VIEWCONTROLLER_UINAVIGATIONCONTROLLER_ITEM_STYLE(STYLE)   (STYLE == UINavigationControllerBarAndItemViewControllerBarItemStyle)

#define IS_CUSTOM_UINAVIGATIONCONTROLLER_ITEM_STYLE(STYLE)                  (!IS_SYSTEM_DEFAULT_UINAVIGATIONCONTROLLER_ITEM_STYLE(STYLE))

#define MIN_ALPHA_TO_HIDDEN  (0.01)


UIKIT_EXTERN NSNotificationName const YZHUINavigationBarAttributeChangNotification;

UIKIT_EXTERN NSString * const YZHUINavigationBarBoundsKey;
UIKIT_EXTERN NSString * const YZHUINavigationBarCenterPointKey;

typedef NS_ENUM(NSInteger, UINavigationControllerBarAndItemStyle)
{
    //系统默认的导航栏和item
    UINavigationControllerBarAndItemDefaultStyle = 0,
    //自定义全局的导航栏和系统的item
    UINavigationControllerBarAndItemGlobalBarWithDefaultItemStyle = 1,
    //自定义全局的导航栏和item
    UINavigationControllerBarAndItemGlobalBarItemStyle = 2,
    //自定义的ViewController上的导航栏和Item
    UINavigationControllerBarAndItemViewControllerBarItemStyle = 3,
    //自定义的ViewController上的导航栏和系统的Item
    UINavigationControllerBarAndItemViewControllerBarWithDefaultItemStyle = 4,
};

@class YZHUINavigationController;

@protocol YZHUINavigationControllerDelegate <NSObject>

-(UIViewController*)YZHUINavigationController:(YZHUINavigationController*)navigationController pushNextViewControllerForViewController:(UIViewController*)viewController;

//需要push和pop的animate为YES才有回调
-(void)YZHUINavigationController:(YZHUINavigationController*)navigationController willPushViewController:(UIViewController*)viewController;
-(void)YZHUINavigationController:(YZHUINavigationController*)navigationController didPushViewController:(UIViewController*)viewController;

-(void)YZHUINavigationController:(YZHUINavigationController*)navigationController willPopViewController:(UIViewController*)viewController;
-(void)YZHUINavigationController:(YZHUINavigationController*)navigationController didPopViewController:(UIViewController*)viewController;


/*
 *此协议方法是为了完成从手势抬起到完成时所需要进行动画时间，是按线性变化来完成的，默认设置的transitionDuration来进行，
 *为了更好的体验，通过完成的比例（percent，0-1.0）来设置不同的值
 */
-(CGFloat)YZHUINavigationController:(YZHUINavigationController *)navigationController doFinishInteractiveTransitionDurationForPercent:(CGFloat)percent operation:(UINavigationControllerOperation)operation;

/*
 *此协议方法是为了此协议方法是为了完成从手势抬起到完成时对UIPercentDrivenInteractiveTransition所需要进行的操作，
 *交由开发者更高级的定制合适自己的动画操作
 *completion返回YES表示进行了finishInteractiveTransition，
 *返回NO表示进行了cancelInteractiveTransition
 */
-(void)YZHUINavigationController:(YZHUINavigationController *)navigationController updateInteractiveTransition:(UIPercentDrivenInteractiveTransition*)transitioin forPanGesture:(UIPanGestureRecognizer*)panGesture operation:(UINavigationControllerOperation)operation completion:(void(^)(BOOL finish))completion;
@end


@interface YZHUINavigationController : UINavigationController

@property (nonatomic, assign) UIBarViewStyle barViewStyle;
@property (nonatomic, strong) UIColor *navigationBarViewBackgroundColor;
@property (nonatomic, strong) UIColor *navigationBarBottomLineColor;
@property (nonatomic, assign) CGFloat navigationBarViewAlpha;

@property (nonatomic,weak) id<YZHUINavigationControllerDelegate> navDelegate;

@property (nonatomic, assign) UINavigationControllerBarAndItemStyle navigationControllerBarAndItemStyle;

//默认是YES
@property (nonatomic, assign) BOOL popGestureEnabled;

/** transitionDuration */
@property (nonatomic, assign) NSTimeInterval transitionDuration;

/*
 *hidesTabBarWhenPushed
 *在navigationController后所有的push操作都会hidesTabBar,
 *在之前已经push的VC的hidesBottomBarWhenPushed都会设置为NO,以后的都会设置为YES
 *默认为YES
 */
@property (nonatomic, assign) BOOL hidesTabBarAfterPushed;

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle;

-(void)resetNavigationBarAndItemViewFrame:(CGRect)frame;

//在viewController初始化的时候调用，此函数仅仅是创建了一个NavigationItemView，在push的时候添加
-(void)createNewNavigationItemViewForViewController:(UIViewController*)viewController;
//在上面完成的createNewNavigationItemViewForViewController后添加添加上去
-(void)addNewNavigationItemViewForViewController:(UIViewController*)viewController;
//从父类中移除并且释放pop掉的ViewController的Item
-(void)removeNavigationItemViewForViewController:(UIViewController*)viewController;
//从父类移除后指定最后的Item,先禁用
//-(void)setNewTopNavigationItemViewForViewController:(UIViewController*)viewController;

-(void)setNavigationItemViewAlpha:(CGFloat)alpha minToHidden:(BOOL)minToHidden forViewController:(UIViewController*)viewController;

-(void)setNavigationItemViewTransform:(CGAffineTransform)transform forViewController:(UIViewController*)viewController;

-(void)setNavigationItemTitle:(NSString*)title forViewController:(UIViewController*)viewController;

-(void)setNavigationItemTitleTextAttributes:(NSDictionary<NSAttributedStringKey, id>*)textAttributes forViewController:(UIViewController*)viewController;

-(void)addNavigationItemViewLeftButtonItems:(NSArray*)leftButtonItems isReset:(BOOL)reset forViewController:(UIViewController*)viewController;

-(void)addNavigationItemViewRightButtonItems:(NSArray*)rightButtonItems isReset:(BOOL)reset forViewController:(UIViewController*)viewController;

-(void)addNavigationBarCustomView:(UIView*)customView;

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)(YZHUINavigationController *navigationController))completion;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(void(^)(YZHUINavigationController *navigationController))completion;

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)(YZHUINavigationController *navigationController))completion;

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated completion:(void(^)(YZHUINavigationController *navigationController))completion;
@end
