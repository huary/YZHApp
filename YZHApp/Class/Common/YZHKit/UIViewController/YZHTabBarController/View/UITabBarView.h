//
//  UITabBarView.h
//  YZHTabBarControllerDemo
//
//  Created by yuan on 17/2/7.
//  Copyright © 2017年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUITabBarButton.h"

//不添加双击事件，双击事件会导致响应变慢，双击事件根据上层决定，
#define ADD_DOUBLE_TAP_GESTURE  (0)

typedef NS_ENUM(NSInteger, UITabBarViewStyle)
{
    UITabBarViewStyleHorizontal     = 0,
    UITabBarViewStyleVertical       = 1,
};

typedef NS_ENUM(NSInteger, UITabBarViewUseFor)
{
    //默认为TabBar来使用
    UITabBarViewUseForTabBar           = 0,
    //其他不适为TabBar来使用时
    UITabBarViewUseForCustom           = 1,
};

@class UITabBarView;

@protocol UITabBarViewDelegate <NSObject>

@optional
-(BOOL)tabBarView:(UITabBarView*)tabBarView didSelectFrom:(NSInteger)from to:(NSInteger)to actionInfo:(NSDictionary*)actionInfo;
#if ADD_DOUBLE_TAP_GESTURE
-(void)tabBarView:(UITabBarView*)tabBarView doubleClickAtIndex:(NSInteger)index;
#endif
@end

@interface UITabBarView : UIView

@property (nonatomic, weak) id<UITabBarViewDelegate> delegate;

@property (nonatomic, assign) UITabBarViewStyle tabBarViewStyle;

@property (nonatomic, assign) UITabBarViewUseFor tabBarViewUseFor;

//default is NO
@property (nonatomic, assign) BOOL scrollContent;

/** defaultSelectIndex is 0 */
@property (nonatomic, assign) NSInteger defaultSelectIndex;

//创建UITabBarView的TabBarItem
-(YZHUITabBarButton*)addTabBarItem:(UITabBarItem*)tabBarItem;
//创建了一个自定义的Layout的UITabBarButton,
-(YZHUITabBarButton*)addCustomLayoutTabBarItem:(UITabBarItem *)tabBarItem;
//仅仅创建一个自定义的Single的button，但是不加入到UITabBarView中
-(YZHUITabBarButton*)createSingleTabBarItem:(UITabBarItem *)tabBarItem forControlEvents:(UIControlEvents)controlEvents actionBlock:(YZHUIButtonActionBlock)actionBlock;


-(YZHUITabBarButton*)resetTabBarItem:(UITabBarItem *)tabBarItem atIndex:(NSInteger)index;
//按照UITabBarButton的顺序加入的，大小由系统来计算
-(YZHUITabBarButton*)addTabBarWithCustomView:(UIView*)customView;
-(YZHUITabBarButton*)resetTabBarWithCustomView:(UIView*)customView atIndex:(NSInteger)index;

//按照UITabBarButton的frame加入的，大小和位置有customView.frame来决定
-(YZHUITabBarButton*)addCustomLayoutTabBarWithCustomView:(UIView *)customView;

-(void)clear;

-(void)doSelectTo:(NSInteger)to;

-(NSInteger)currentIndex;

-(UITabBarItem*)tabBarItemAtIndex:(NSInteger)index;

@end
