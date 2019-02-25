//
//  UISideSlipViewController.h
//  UISideSlipViewControllerDemo
//
//  Created by yuan on 2018/1/1.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHKitType.h"

typedef NS_ENUM(NSInteger, NSSideShowVCType)
{
    NSSideShowVCTypeContentVC = 0,
    NSSideShowVCTypeLeftVC    = 1,
    NSSideShowVCTypeRightVC   = 2,
};

typedef NS_ENUM(NSInteger, NSSideShowVCViewAlignmentType)
{
    NSSideShowVCViewAlignmentTypeLeft   = 0,
    NSSideShowVCViewAlignmentTypeRight  = 1,
};

@class UISideSlipViewController;

@protocol UISideSlipViewControllerDelegate <NSObject>

-(void)sideSlipViewController:(UISideSlipViewController*)sideSlipViewController willBeginSlipFromViewController:(UIViewController*)fromViewController toViewController:(UIViewController*)toViewController;
-(void)sideSlipViewController:(UISideSlipViewController *)sideSlipViewController slipProgress:(CGFloat)progress fromViewController:(UIViewController*)fromViewController toViewController:(UIViewController*)toViewController;
-(void)sideSlipViewController:(UISideSlipViewController *)sideSlipViewController didEndSlipFromViewController:(UIViewController*)fromViewController toViewController:(UIViewController*)toViewController;;

@end


@interface UISideSlipViewController : UIViewController

@property (nonatomic, strong, readonly) UIViewController *contentViewController;
//左边的leftViewController.view上的subView应该以（1-maxShiftXRatio）* SCREEN_WIDTH开始布局
@property (nonatomic, strong, readonly) UIViewController *leftViewController;
//右边的rightViewController.view上的subView应该以0开始布局maxShiftXRatio* SCREEN_WIDTH这么宽度
@property (nonatomic, strong, readonly) UIViewController *rightViewController;

@property (nonatomic, assign) BOOL sideSlipEnabled;
//can be 0-1.0,best is 0.5-1.0
@property (nonatomic, assign) CGFloat maxShiftXRatio;
@property (nonatomic, assign, readonly) NSSideShowVCType showVCType;

@property (nonatomic, weak) id<UISideSlipViewControllerDelegate> delegate;

@property (nonatomic, assign) NSSideShowVCViewAlignmentType sideShowVCViewAlignmentType;

-(instancetype)initWithContentViewController:(nonnull UIViewController *)contentViewController
                          leftViewController:(nullable UIViewController *)leftViewController
                         rightViewController:(nullable UIViewController *)rightViewController;

-(void)presentLeftViewController:(BOOL)animated;
-(void)presentRightViewContrller:(BOOL)animated;
-(void)presentContentViewContrller:(BOOL)animated;

-(void)updateContentViewController:(nonnull UIViewController *)contentViewController;
-(void)updateLeftViewController:(nullable UIViewController *)leftViewController;
-(void)updateRightViewController:(nullable UIViewController *)rightViewController;

@end
