//
//  YZHViewController.h
//  YZHNavigationController
//
//  Created by yuan on 16/11/17.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHNavigationBarView.h"
#import "YZHGraphics.h"

@interface YZHViewController : UIViewController

// 导航栏标题
@property (nonatomic, strong) NSString *navigationTitle;

//设置barViewStyle的style
@property (nonatomic, assign) YZHNavBarStyle navBarStyle;
//设置navigationBarView的backgroundColor
@property (nonatomic, copy) UIColor *navigationBarViewBackgroundColor;
//设置navigationBarView底部线条的颜色
@property (nonatomic, copy) UIColor *navigationBarBottomLineColor;
//barview的aplha，aplha=0
@property (nonatomic, assign) CGFloat navigationBarViewAlpha;
//Item 的alpha
@property (nonatomic, assign) CGFloat navigationItemViewAlpha;
//pop事件是否允许，默认为YES
@property (nonatomic, assign) BOOL popGestureEnabled;
//动画时间,默认为0
@property (nonatomic, assign) NSTimeInterval transitionDuration;
//导航栏的底部Y值（既是在view上进行布局开始的位置），默认为0
@property (nonatomic, assign) CGFloat layoutTopY;
//设置title的属性
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes;

//left
//这个带<剪头的返回按钮,这个是重置操作，清空原来所有的LeftButtonItems
-(UIButton *)addNavigationFirstLeftBackItemWithTitle:(NSString*)title target:(id)target action:(SEL)selector;

//这个带<剪头的返回按钮,这个是重置操作，清空原来所有的LeftButtonItems,block
-(UIButton *)addNavigationFirstLeftBackItemWithTitle:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//自定义第一个按钮（image，title）
-(UIButton *)addNavigationFirstLeftItemWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)selector;

//自定义第一个按钮（image，title）block
-(UIButton *)addNavigationFirstLeftItemWithImageName:(NSString*)imageName title:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//自定义一个按钮（image，title）
-(UIButton *)addNavigationLeftItemWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//自定义一个按钮（image，title）block
-(UIButton *)addNavigationLeftItemWithImageName:(NSString*)imageName title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//自定义一个按钮（image，title）
-(UIButton *)addNavigationLeftItemWithImage:(UIImage*)image title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//自定义一个按钮（image，title）block
-(UIButton *)addNavigationLeftItemWithImage:(UIImage*)image title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//titles中的第一个NSString被用来作为第一个item的title
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector;

//titles中的第一个NSString被用来作为第一个item的title,block
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithTitles:(NSArray<NSString*> *)titles actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//imageNames中的第一个imageName是第二个item
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector;

//imageNames中的第一个imageName是第二个item,block
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImageNames:(NSArray<NSString*> *)imageNames actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//images中的第一个image是第二个item
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImage:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector;

//images中的第一个image是第二个item,block
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImage:(NSArray<UIImage*> *)images actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加leftButtonItem
-(NSArray<UIButton*> *)addNavigationLeftItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加leftButtonItem,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithTitles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加leftButtonItem
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加leftButtonItem,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加leftButtonItem
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加leftButtonItem,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加自定义的leftButtonItem
-(NSArray<UIButton*> *)addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加自定义的leftButtonItem,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//通过YZHGraphicsContext来添加leftButtonItem
-(UIButton *)addNavigationLeftItemWithGraphicsImageContext:(YZHGraphicsContext*)graphicsImageContext title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//通过YZHGraphicsContext来添加leftButtonItem,block
-(UIButton *)addNavigationLeftItemWithGraphicsImageContext:(YZHGraphicsContext*)graphicsImageContext title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//直接在Left添加UIView,UIView的subview可以是自动布局的,target selector
-(void)addNavigationLeftItemView:(UIView *)itemView target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//直接在Left添加UIView,UIView的subview可以是自动布局的,actionBlock
-(void)addNavigationLeftItemView:(UIView *)itemView isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//直接在Left添加UIView,UIView的subview可以是自动布局的,itemViews, target selector
-(void)addNavigationLeftItemViews:(NSArray<UIView*>*)itemViews target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//直接在Left添加UIView,UIView的subview可以是自动布局的,itemViews, actionBlock
-(void)addNavigationLeftItemViews:(NSArray<UIView*>*)itemViews isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//right
//添加（title）这样的按钮
-(NSArray<UIButton*> *)addNavigationRightItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（title）这样的按钮，block
-(NSArray<UIButton*> *)addNavigationRightItemsWithTitles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（image）这样的按钮
-(NSArray<UIButton*> *)addNavigationRightItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（image）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationRightItemsWithImageNames:(NSArray<NSString*> *)imageNames isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（image）这样的按钮
-(NSArray<UIButton*> *)addNavigationRightItemsWithImages:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（image）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationRightItemsWithImages:(NSArray<UIImage*> *)images isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（UIView）这样的按钮
-(NSArray<UIButton*> *)addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（UIView）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//直接在right添加UIView,UIView的subview可以是自动布局的,target selector
-(void)addNavigationRightItemView:(UIView *)itemView target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//直接在right添加UIView,UIView的subview可以是自动布局的,action Block
-(void)addNavigationRightItemView:(UIView *)itemView isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//直接在right添加UIView,UIView的subview可以是自动布局的, itemViews target selector
-(void)addNavigationRightItemViews:(NSArray<UIView*> *)itemViews target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//直接在right添加UIView,UIView的subview可以是自动布局的, itemViews actionBlock
-(void)addNavigationRightItemViews:(NSArray<UIView*> *)itemViews isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//设置items的间距
-(void)setupItemsSpace:(CGFloat)itemsSpace left:(BOOL)left;

//本SDK计算公式就是设置的
-(void)setupItemEdgeSpace:(CGFloat)edgeSpace left:(BOOL)left;

//在导航栏上添加自定义的view
-(void)addNavigationBarCustomView:(UIView*)customView;

//返回导航栏的view
- (UIView *)navigationBar;

//返回导航栏的顶部开始Y值
- (CGFloat)navigationBarTopLayout;
@end
