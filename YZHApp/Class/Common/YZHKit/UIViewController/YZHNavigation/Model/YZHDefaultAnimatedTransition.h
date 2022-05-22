//
//  YZHDefaultAnimatedTransition.h
//  BaseDefaultUINavigationController
//
//  Created by yuan on 16/11/10.
//  Copyright © 2016年 yzh. All rights reserved.
//

#import "YZHBaseAnimatedTransition.h"

@interface YZHDefaultAnimatedTransition : YZHBaseAnimatedTransition

+ (void)updateTabBarForNavigationController:(UINavigationController *)navigationController fromVC:(UIViewController *)fromVC whenPushPopNoAnimatedTransition:(BOOL)push;
@end
