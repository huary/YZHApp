//
//  UIViewController+YZHNavigationRootVCInitSetup.h
//  YZHApp
//
//  Created by bytedance on 2021/11/26.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHNavigationTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (YZHNavigationRootVCInitSetup)

//在YZHNavigationCtroller/UINavigationCtroller用initRootViewController:xxx 初始化时，需要传递给的navigationBarAndItemStyle
@property (nonatomic, assign) YZHNavigationBarAndItemStyle hz_barAndItemStyleForRootVCInitSetToNavigation;

@property (nonatomic, assign) BOOL hz_navigationEnableForRootVCInitSetToNavigation;

@end

NS_ASSUME_NONNULL_END
