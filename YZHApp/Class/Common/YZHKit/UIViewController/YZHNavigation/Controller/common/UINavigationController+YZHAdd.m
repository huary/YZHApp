//
//  UIViewController+YZHAdd.m
//  YZHNavigationKit
//
//  Created by bytedance on 2022/4/22.
//

#import "UINavigationController+YZHAdd.h"
#import "UIViewController+YZHNavigation.h"
#import "UINavigationController+YZHNavigation.h"
#import "UIViewController+YZHNavigationRootVCInitSetup.h"
#import "YZHBaseViewController.h"

@implementation UINavigationController (YZHAdd)

//+ (UINavigationController *)ecp_tabBarNavigationControllerForRootVCClass:(Class)rootVCClass {
//    UIViewController *rootVC = [rootVCClass new];
//    rootVC.hz_navbarFrameBlock = ^CGRect(UIViewController *viewController, CGFloat *itemViewLayoutHeight) {
//        CGFloat h = STATUS_NAV_BAR_HEIGHT;
//        CGRect frame = CGRectMake(0, 0, SAFE_WIDTH, h);
//        *itemViewLayoutHeight = NAV_BAR_HEIGHT;
//        return frame;
//    };
//    return [self ecp_navigationControllerForRootVC:rootVC];
//}

//用于push方式的navigationController
+ (UINavigationController *)ecp_navigationControllerForRootVCClass:(Class)rootVCClass {
    UIViewController *rootVC = [rootVCClass new];
    return [self ecp_navigationControllerForRootVC:rootVC];
}

//用于push方式的navigationController
+ (UINavigationController *)ecp_navigationControllerForRootVC:(UIViewController *)rootVC {
    if (![rootVC isKindOfClass:[YZHViewController class]]) {
        rootVC.hz_navigationEnable = YES;
    }
    rootVC.hz_navigationEnableForRootVCInitSetToNavigation = YES;
    rootVC.hz_barAndItemStyleForRootVCInitSetToNavigation = YZHNavigationBarAndItemStyleVCBarItem;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    return nvc;
}

//用于present（modal）方式的navigationController
+ (UINavigationController *)ecp_modalNavigationControllerForRootVCClass:(Class)rootVCClass {
    UIViewController *rootVC = [rootVCClass new];
    return [self ecp_modalNavigationControllerForRootVC:rootVC];
}

//用于present（modal）方式的navigationController
+ (UINavigationController *)ecp_modalNavigationControllerForRootVC:(UIViewController *)rootVC {
    if (![rootVC isKindOfClass:[YZHViewController class]]) {
        rootVC.hz_navigationEnable = YES;
    }
    rootVC.hz_navigationEnableForRootVCInitSetToNavigation = YES;
    rootVC.hz_barAndItemStyleForRootVCInitSetToNavigation = YZHNavigationBarAndItemStyleVCBarItem;
    rootVC.hz_navbarFrameBlockForRootVCInitSetToNavigation = ^CGRect(UIViewController *viewController, CGFloat *itemViewLayoutHeight) {
        CGRect frame = CGRectZero;
        CGFloat itemH = 0;
        if (@available(iOS 13.0, *)) {
            frame = CGRectMake(0, 0, viewController.view.hz_width, 60);
            itemH = NAV_BAR_HEIGHT;
        }
        else {
            frame = CGRectMake(0, 0, SAFE_WIDTH, STATUS_NAV_BAR_HEIGHT);
            itemH = frame.size.height - STATUS_BAR_HEIGHT;
        }
        if (itemViewLayoutHeight) {
            *itemViewLayoutHeight = itemH;
        }
        return frame;
    };
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:rootVC];
    return nvc;
}


@end
