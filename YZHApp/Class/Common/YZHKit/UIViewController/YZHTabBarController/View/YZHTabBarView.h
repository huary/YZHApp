//
//  UITabBarView.h
//  YZHTabBarControllerDemo
//
//  Created by yuan on 17/2/7.
//  Copyright © 2017年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHTabBarButton.h"

//不添加双击事件，双击事件会导致响应变慢，双击事件根据上层决定，
#define ADD_DOUBLE_TAP_GESTURE  (0)

typedef NS_ENUM(NSInteger, YZHTabBarViewStyle)
{
    YZHTabBarViewStyleHorizontal     = 0,
    YZHTabBarViewStyleVertical       = 1,
};

typedef NS_ENUM(NSInteger, YZHTabBarViewUseFor)
{
    //默认为TabBar来使用
    YZHTabBarViewUseForTabBar           = 0,
    //其他不适为TabBar来使用时
    YZHTabBarViewUseForCustom           = 1,
};

@class YZHTabBarView;

@protocol YZHTabBarViewDelegate <NSObject>

@optional
-(BOOL)tabBarView:(YZHTabBarView*)tabBarView didSelectFrom:(NSInteger)from to:(NSInteger)to actionInfo:(NSDictionary*)actionInfo;
#if ADD_DOUBLE_TAP_GESTURE
-(void)tabBarView:(YZHTabBarView*)tabBarView doubleClickAtIndex:(NSInteger)index;
#endif
@end

typedef void(^YZHTabBarViewExchangeTabBarButtonAnimationBlock)(YZHTabBarView *tabBarView, YZHTabBarButton *btn1, YZHTabBarButton *btn2);

@interface YZHTabBarView : UIView

@property (nonatomic, weak) id<YZHTabBarViewDelegate> delegate;

@property (nonatomic, assign) YZHTabBarViewStyle tabBarViewStyle;

@property (nonatomic, assign) YZHTabBarViewUseFor tabBarViewUseFor;

//default is NO
@property (nonatomic, assign) BOOL scrollContent;

/** defaultSelectIndex is 0 */
@property (nonatomic, assign) NSInteger defaultSelectIndex;

//创建UITabBarView的TabBarItem
-(YZHTabBarButton*)addTabBarItem:(UITabBarItem*)tabBarItem;
//创建了一个自定义的Layout的UITabBarButton,
-(YZHTabBarButton*)addCustomLayoutTabBarItem:(UITabBarItem *)tabBarItem;
//仅仅创建一个自定义的Single的button，但是不加入到UITabBarView中
-(YZHTabBarButton*)createSingleTabBarItem:(UITabBarItem *)tabBarItem forControlEvents:(UIControlEvents)controlEvents actionBlock:(YZHButtonActionBlock)actionBlock;


-(YZHTabBarButton*)resetTabBarItem:(UITabBarItem *)tabBarItem atIndex:(NSInteger)index;
//按照UITabBarButton的顺序加入的，大小由系统来计算
-(YZHTabBarButton*)addTabBarWithCustomView:(UIView*)customView;
-(YZHTabBarButton*)resetTabBarWithCustomView:(UIView*)customView atIndex:(NSInteger)index;

//按照UITabBarButton的frame加入的，大小和位置有customView.frame来决定
-(YZHTabBarButton*)addCustomLayoutTabBarWithCustomView:(UIView *)customView;

-(void)exchangeTabBarButtonAtIndex:(NSInteger)index1 withTabBarButtonAtIndex:(NSInteger)index2 animation:(BOOL)animation;

-(void)exchangeTabBarButtonAtIndex:(NSInteger)index1 withTabBarButtonAtIndex:(NSInteger)index2 animationBlock:(YZHTabBarViewExchangeTabBarButtonAnimationBlock)animationBlock;


-(void)removeTabBarAtIndex:(NSInteger)index;

-(void)clear;

-(void)doSelectTo:(NSInteger)to;

-(NSInteger)currentIndex;

-(UITabBarItem*)tabBarItemAtIndex:(NSInteger)index;

-(YZHTabBarButton*)tabBarButtonAtIndex:(NSInteger)index;

-(CALayer *)topLine;

@end
