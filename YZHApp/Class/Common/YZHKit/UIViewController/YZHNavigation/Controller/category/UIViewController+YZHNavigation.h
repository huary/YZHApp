//
//  UIViewController+YZHNavigation.h
//  YZHApp
//
//  Created by bytedance on 2021/11/20.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHNavigationBarView.h"
#import "YZHNavigationTypes.h"


@interface UIViewController (YZHNavigation)

//这个只能在初始化时设置一次有效，多次设置无效，只有第一次设置的有效，默认false（需要在ViewDidLoad之前设置）
@property (nonatomic, assign) BOOL hz_navigationEnable;

// 导航栏标题
@property (nonatomic, strong) NSString *hz_navigationTitle;

//设置barViewStyle的style
@property (nonatomic, assign) YZHNavBarStyle hz_navBarStyle;
//设置navigationBarView的backgroundColor
@property (nonatomic, copy) UIColor *hz_navigationBarViewBackgroundColor;
//设置navigationBar的底部横线的颜色
@property (nonatomic, copy) UIColor *hz_navigationBarBottomLineColor;
//barview的aplha，aplha=0
@property (nonatomic, assign) CGFloat hz_navigationBarViewAlpha;
//Item 的alpha
@property (nonatomic, assign) CGFloat hz_navigationItemViewAlpha;
//pop事件是否允许，默认为YES
@property (nonatomic, assign) BOOL hz_popGestureEnabled;
//动画时间,默认为0
@property (nonatomic, assign) NSTimeInterval hz_transitionDuration;

//导航栏的底部Y值（既是在view上进行布局开始的位置），默认为0
@property (nonatomic, assign) CGFloat hz_layoutTopY;
//设置title的属性
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *hz_titleTextAttributes;

//这个带<剪头的返回按钮
-(UIButton *)hz_addNavigationFirstLeftBackItemWithTitle:(NSString*)title target:(id)target action:(SEL)selector;

//这个带<剪头的返回按钮,这个是重置操作，清空原来所有的LeftButtonItems,block
-(UIButton *)hz_addNavigationFirstLeftBackItemWithTitle:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//自定义第一个按钮（image，title）
-(UIButton *)hz_addNavigationFirstLeftItemWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)selector;

//自定义第一个按钮（image，title）block
-(UIButton *)hz_addNavigationFirstLeftItemWithImageName:(NSString*)imageName title:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//自定义一个按钮（image，title）
-(UIButton *)hz_addNavigationLeftItemWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//自定义一个按钮（image，title）block
-(UIButton *)hz_addNavigationLeftItemWithImageName:(NSString*)imageName title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//自定义一个按钮（image，title）
-(UIButton *)hz_addNavigationLeftItemWithImage:(UIImage*)image title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//自定义一个按钮（image，title）block
-(UIButton *)hz_addNavigationLeftItemWithImage:(UIImage*)image title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//titles中的第一个NSString被用来作为第一个item的title
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector;

//titles中的第一个NSString被用来作为第一个item的title,block
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithTitles:(NSArray<NSString*> *)titles actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//imageNames中的第一个imageName是第二个item
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector;

//imageNames中的第一个imageName是第二个item,block
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithImageNames:(NSArray<NSString*> *)imageNames actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//images中的第一个image是第二个item
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithImage:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector;

//images中的第一个image是第二个item,block
-(NSArray<UIButton*> *)hz_addNavigationFirstLeftBackItemsWithImage:(NSArray<UIImage*> *)images actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加leftButtonItem
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加leftButtonItem,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithTitles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加leftButtonItem
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加leftButtonItem,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加leftButtonItem
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加leftButtonItem,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加自定义的leftButtonItem
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加自定义的leftButtonItem,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)hz_addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//通过YZHGraphicsContext来添加leftButtonItem
-(UIButton *)hz_addNavigationLeftItemWithGraphicsImageContext:(YZHGraphicsContext*)graphicsImageContext title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//通过YZHGraphicsContext来添加leftButtonItem,block
-(UIButton *)hz_addNavigationLeftItemWithGraphicsImageContext:(YZHGraphicsContext*)graphicsImageContext title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//直接在Left添加UIView,UIView的subview可以是自动布局的,target selector
-(void)hz_addNavigationLeftItemView:(UIView *)itemView target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//直接在Left添加UIView,UIView的subview可以是自动布局的,actionBlock
-(void)hz_addNavigationLeftItemView:(UIView *)itemView isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//直接在Left添加UIView,UIView的subview可以是自动布局的,itemViews, target selector
-(void)hz_addNavigationLeftItemViews:(NSArray<UIView*>*)itemViews target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//直接在Left添加UIView,UIView的subview可以是自动布局的,itemViews, actionBlock
-(void)hz_addNavigationLeftItemViews:(NSArray<UIView*>*)itemViews isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//right
//添加（title）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（title）这样的按钮，block
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithTitles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（image）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（image）这样的按钮,block
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithImageNames:(NSArray<NSString*> *)imageNames isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（image）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithImages:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（image）这样的按钮,block
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithImages:(NSArray<UIImage*> *)images isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（UIView）这样的按钮
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（UIView）这样的按钮,block
-(NSArray<UIButton*> *)hz_addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//直接在right添加UIView,UIView的subview可以是自动布局的,target selector
-(void)hz_addNavigationRightItemView:(UIView *)itemView target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//直接在right添加UIView,UIView的subview可以是自动布局的,action Block
-(void)hz_addNavigationRightItemView:(UIView *)itemView isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//直接在right添加UIView,UIView的subview可以是自动布局的, itemViews target selector
-(void)hz_addNavigationRightItemViews:(NSArray<UIView*> *)itemViews target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//直接在right添加UIView,UIView的subview可以是自动布局的, itemViews actionBlock
-(void)hz_addNavigationRightItemViews:(NSArray<UIView*> *)itemViews isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//设置items的间距
-(void)hz_setupItemsSpace:(CGFloat)itemsSpace left:(BOOL)left;

//本SDK计算公式为设置的大小
-(void)hz_setupItemEdgeSpace:(CGFloat)edgeSpace left:(BOOL)left;

//在导航栏上添加自定义的view
-(void)hz_addNavigationBarCustomView:(UIView*)customView;

//返回导航栏的view
- (UIView *)hz_navigationBar;

//返回导航栏的顶部开始Y值
- (CGFloat)hz_navigationBarTopLayout;

//此值默认为hz_navbarFrameBlock(viewController)-STATUS_BAR_HEIGHT
- (CGFloat)hz_itemViewLayoutHeight;
@end
