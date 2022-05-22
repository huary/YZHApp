//
//  UIViewController+YZHAdd.h
//  YZHNavigationKit
//
//  Created by bytedance on 2022/4/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (YZHAdd)
//用于TabBar的childVC的navigation
//+ (UINavigationController *)ecp_tabBarNavigationControllerForRootVCClass:(Class)rootVCClass;

//用于push方式的navigation
+ (UINavigationController *)ecp_navigationControllerForRootVCClass:(Class)rootVCClass;

//用于push方式的navigation
+ (UINavigationController *)ecp_navigationControllerForRootVC:(UIViewController *)rootVC;

//用于present（modal）方式的navigationController
+ (UINavigationController *)ecp_modalNavigationControllerForRootVCClass:(Class)rootVCClass;

//用于present（modal）方式的navigationController
+ (UINavigationController *)ecp_modalNavigationControllerForRootVC:(UIViewController *)rootVC;

@end

NS_ASSUME_NONNULL_END
