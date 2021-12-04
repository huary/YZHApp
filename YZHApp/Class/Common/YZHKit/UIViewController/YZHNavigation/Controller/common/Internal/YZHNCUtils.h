//
//  YZHNCUtils.h
//  YZHApp
//
//  Created by bytedance on 2021/11/22.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHNavigationTypes.h"

void itn_nc_viewDidLoad(UINavigationController *nc);

void itn_nc_viewWillLayoutSubviews(UINavigationController *nc);

void itn_resetNavigationBarAndItemViewFrame(UINavigationController *nc, CGRect frame);

#pragma mark override
void itn_pushViewController(UINavigationController *nc, UIViewController *vc, BOOL animated);

//自定义
void itn_pushViewControllerCompletion(UINavigationController *nc, UIViewController *vc, YZHNavigationControllerAnimationCompletionBlock completion);

void itn_popViewControllerCompletion(UINavigationController *nc, YZHNavigationControllerAnimationCompletionBlock completion);

//void itn_popToViewController(UINavigationController *nc, UIViewController *vc, YZHNavigationControllerAnimationCompletionBlock completion);
//
//void itn_popToRootViewController(UINavigationController *nc, YZHNavigationControllerAnimationCompletionBlock completion);

id itn_getKeyFromVC(UIViewController *vc);

//在viewController初始化的时候调用，此函数仅仅是创建了一个NavigationItemView，在push的时候添加
void itn_createNewNavigationItemViewForViewController(UINavigationController *nc, UIViewController *vc);

void itn_addNewNavigationItemViewForViewController(UINavigationController *nc, UIViewController *vc);

void itn_removeNavigationItemViewForViewController(UINavigationController *nc, UIViewController *vc);

void itn_nc_setNavigationBarViewBackgroundColor(UINavigationController *nc, UIColor *navigationBarViewBackgroundColor);

void itn_nc_setNavigationBarBottomLineColor(UINavigationController *nc,UIColor *navigationBarBottomLineColor);

void itn_nc_setNavigationBarViewAlpha(UINavigationController *nc, CGFloat navigationBarViewAlpha);

void itn_nc_setNavBarStyle(UINavigationController *nc, YZHNavBarStyle navBarStyle);

//设置NavigationItemView相关
void itn_setNavigationItemViewAlphaMinToHiddenForVC(UINavigationController *nc,CGFloat alpha, BOOL minToHidden, UIViewController *vc);

void itn_setNavigationItemViewTransformForVC(UINavigationController *nc, CGAffineTransform transform, UIViewController *vc);

void itn_setNavigationItemTitleForVC(UINavigationController *nc, NSString *title, UIViewController *vc);

void itn_setNavigationItemTitleTextAttributesForVC(UINavigationController *nc, NSDictionary<NSAttributedStringKey, id> *textAttributes, UIViewController *vc);

void itn_addNavigationItemViewLeftButtonItemsIsResetForVC(UINavigationController *nc, NSArray *leftButtonItems, BOOL reset, UIViewController *vc);

void itn_addNavigationItemViewRightButtonItemsIsResetForVC(UINavigationController *nc, NSArray *rightButtonItems, BOOL reset, UIViewController *vc);

void itn_nc_setupItemsSpace(UINavigationController *nc, CGFloat itemsSpace, BOOL left, UIViewController *vc);

void itn_nc_setupItemEdgeSpace(UINavigationController *nc, CGFloat edgeSpace, BOOL left, UIViewController *vc);

void itn_nc_addNavigationBarCustomView(UINavigationController *nc, UIView *customView);

UIView * itn_nc_navigationBar(UINavigationController *nc);

CGFloat itn_nc_navigationBarTopLayout(UINavigationController *nc);
