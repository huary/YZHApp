//
//  YZHTabBarButton+Internal.h
//  YZHNavigationKit
//
//  Created by bytedance on 2021/11/9.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YZHTabBarButtonType)
{
    //创建的TabBar按顺序加入到TabBarView中的
    YZHTabBarButtonTypeDefault       = 0,
    //自定义Layout
    YZHTabBarButtonTypeCustomLayout  = 1,
    //创建单个的TabBar
    YZHTabBarButtonTypeSingle        = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface YZHTabBarButton ()

//给tabbar添加的customView,外部不要重新置换，如果需要置换可以通过TabBarController的reset接口来操作。
@property (nonatomic, weak) UIView *customView;

@property (nonatomic, assign) CGRange imageRange;
@property (nonatomic, assign) CGRange titleRange;
@property (nonatomic, assign) YZHButtonImageTitleStyle buttonStyle;

@property (nonatomic, strong) UIButton *badgeButton;
@property (nonatomic, assign) CGRect graphicsImageFrame;

@property (nonatomic, assign) YZHTabBarButtonType tabBarButtonType;

@end

NS_ASSUME_NONNULL_END
