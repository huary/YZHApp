//
//  YZHUITabBarButton.h
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITabBarItem+UIButton.h"
#import "UIButton+YZHAdd.h"

//@class YZHUITabBarButton;
//typedef void(^TabBarEventActionBlock)(YZHUITabBarButton *button);

//返回需要显示的badgeValue和badgeType
//typedef NSString*(^TabBarBadgeBlock)(UITabBarButton *button, UIButton *badgeButton, NSString *badgeValue, NSBadgeType *badgeType);

@interface YZHUITabBarButton : UIButton

@property (nonatomic, strong) UITabBarItem *tabBarItem;

//同tabBarItem上的badgeValueUpdateBlock
//@property (nonatomic, copy) TabBarBadgeBlock badgeValueUpdateBlock;

@property (nonatomic, weak) UIView *tabBarView;

@property (nonatomic, weak) UITabBarController *tabBarController;

@end
