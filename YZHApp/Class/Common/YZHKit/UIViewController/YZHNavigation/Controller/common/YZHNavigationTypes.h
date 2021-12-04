//
//  YZHNavigationTypes.h
//  YZHApp
//
//  Created by bytedance on 2021/11/22.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSNotificationName const YZHNavigationBarAttributeChangedNotification;

UIKIT_EXTERN NSString * const YZHNavigationBarBoundsKey;
UIKIT_EXTERN NSString * const YZHNavigationBarCenterPointKey;

typedef void(^YZHNavigationItemActionBlock)(UIViewController *viewController, UIButton *button);
typedef void(^YZHNavigationControllerAnimationCompletionBlock)(UINavigationController *navigationController);

typedef NS_ENUM(NSInteger, YZHNavigationBarAndItemStyle)
{
    //系统默认的导航栏和item
    YZHNavigationBarAndItemStyleDefault                  = 0,
    //自定义全局的导航栏和系统的item
    YZHNavigationBarAndItemStyleGlobalBarDefaultItem     = 1,
    //自定义全局的导航栏和item
    YZHNavigationBarAndItemStyleGlobalBarItem            = 2,
    //自定义的ViewController上的导航栏和Item
    YZHNavigationBarAndItemStyleVCBarItem                = 3,
    //自定义的ViewController上的导航栏和系统的Item
    YZHNavigationBarAndItemStyleVCBarDefaultItem         = 4,
};

typedef NS_ENUM(NSInteger, YZHNavBarStyle)
{
    YZHNavBarStyleNone     = 0,
    YZHNavBarStyleDefault  = UIBarStyleDefault,
    YZHNavBarStyleBlack    = UIBarStyleBlack,
};

@protocol YZHNavigationControllerDelegate <NSObject>

-(UIViewController*)navigationController:(UINavigationController*)navigationController pushNextViewControllerForViewController:(UIViewController*)viewController;

//需要push和pop的animate为YES才有回调
-(void)navigationController:(UINavigationController*)navigationController willPushViewController:(UIViewController*)viewController;
-(void)navigationController:(UINavigationController*)navigationController didPushViewController:(UIViewController*)viewController;

-(void)navigationController:(UINavigationController*)navigationController willPopViewController:(UIViewController*)viewController;
-(void)navigationController:(UINavigationController*)navigationController didPopViewController:(UIViewController*)viewController;


/*
 *此协议方法是为了完成从手势抬起到完成时所需要进行动画时间，是按线性变化来完成的，默认设置的transitionDuration来进行，
 *为了更好的体验，通过完成的比例（percent，0-1.0）来设置不同的值
 */
-(CGFloat)navigationController:(UINavigationController *)navigationController doFinishInteractiveTransitionDurationForPercent:(CGFloat)percent operation:(UINavigationControllerOperation)operation;

/*
 *此协议方法是为了完成从手势抬起到完成时对UIPercentDrivenInteractiveTransition所需要进行的操作，
 *交由开发者更高级的定制合适自己的动画操作
 *completion返回YES表示进行了finishInteractiveTransition，
 *返回NO表示进行了cancelInteractiveTransition
 */
-(void)navigationController:(UINavigationController *)navigationController updateInteractiveTransition:(UIPercentDrivenInteractiveTransition*)transitioin forPanGesture:(UIPanGestureRecognizer*)panGesture operation:(UINavigationControllerOperation)operation completion:(void(^)(BOOL finish))completion;
@end
