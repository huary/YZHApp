//
//  UIViewController+YZHNavigationRootVCInitSetup.h
//  YZHApp
//
//  Created by bytedance on 2021/11/26.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHNavigationTypes.h"
#import "YZHNavigationConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (YZHNavigationRootVCInitSetup)

@property (nonatomic, strong, class) YZHNavigationConfig *hz_navigationConfig;

/*只会在viewDidLoad时调用一次，所有的UIViewController都有此属性，与hz_navigationEnable无关
 *是UINavigationController时，如果没有设置，会返回CGRectMake(SAFE_X, -STATUS_BAR_HEIGHT, SAFE_WIDTH, STATUS_NAV_BAR_HEIGHT);
 *
 *是UIViewController时，如果没有设置的话，会优先从viewController.navigationController上获取，
 *如果navigationController上没有，那么就默认返回CGRectMake(0, 0, SAFE_WIDTH, STATUS_NAV_BAR_HEIGHT);
 *
 *hz_navbarFrameBlock(UIViewController *viewController, CGFloat *itemViewLayoutHeight),
 *第一个参数代表当前viewController
 *第二个参数是需要返回给SDK的在ItemView上进行布局的高度（默认给的值：STATUS_NAV_BAR_HEIGHT - STATUS_BAR_HEIGHT = NAV_BAR_HEIGHT）
 */
@property (nonatomic, strong) YZHNavBarViewFrameBlock hz_navbarFrameBlock;

//在YZHNavigationCtroller/UINavigationCtroller用initRootViewController:xxx 初始化时，需要传递给的navigationBarAndItemStyle
@property (nonatomic, assign) YZHNavigationBarAndItemStyle hz_barAndItemStyleForRootVCInitSetToNavigation;

@property (nonatomic, assign) BOOL hz_navigationEnableForRootVCInitSetToNavigation;

@property (nonatomic, copy) YZHNavBarViewFrameBlock hz_navbarFrameBlockForRootVCInitSetToNavigation;

- (CGRect)hz_navbarFrame;
@end

NS_ASSUME_NONNULL_END
