//
//  YZHTabBarButton.h
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITabBarItem+UIButton.h"

@interface YZHTabBarButton : UIButton

//会KVO监听tabBarItem上的部分属性(image/selectedImage/title/badgeValue/badgeColor/badgeBackgroundColor)
@property (nonatomic, strong) UITabBarItem *tabBarItem;

@property (nonatomic, weak) UIView *tabBarView;

@property (nonatomic, weak) UITabBarController *tabBarController;

@end
