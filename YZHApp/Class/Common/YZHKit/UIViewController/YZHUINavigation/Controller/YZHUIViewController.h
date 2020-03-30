//
//  YZHUIViewController.h
//  YZHUINavigationController
//
//  Created by yuan on 16/11/17.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUINavigationBarView.h"
#import "YZHUIGraphicsImage.h"

typedef void(^YZHNavigationItemActionBlock)(UIViewController *viewController, UIButton *button);

@interface YZHUIViewController : UIViewController

/** 注释 */
@property (nonatomic, strong) NSString *navigationTitle;

//设置navigationBarView的backgroundColor
@property (nonatomic, copy) UIColor *navigationBarViewBackgroundColor;
@property (nonatomic, copy) UIColor *navigationBarBottomLineColor;
//设置barViewStyle的style
@property (nonatomic, assign) UIBarViewStyle barViewStyle;
//barview的aplha，aplha=0
@property (nonatomic, assign) CGFloat navigationBarViewAlpha;
//Item 的alpha
@property (nonatomic, assign) CGFloat navigationItemViewAlpha;
//pop事件是否允许，默认为YES
@property (nonatomic, assign) BOOL popGestureEnabled;
//设置title的属性
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes;
//default is 0,
@property (nonatomic, assign) CGFloat layoutTopY;
/** 动画时间,默认为0 */
@property (nonatomic, assign) NSTimeInterval transitionDuration;

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
-(void)addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加自定义的leftButtonItem,block
-(void)addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

//通过YZHUIGraphicsImageContext来添加leftButtonItem
-(UIButton *)addNavigationLeftItemWithGraphicsImageContext:(YZHUIGraphicsImageContext*)graphicsImageContext title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//通过YZHUIGraphicsImageContext来添加leftButtonItem,block
-(UIButton *)addNavigationLeftItemWithGraphicsImageContext:(YZHUIGraphicsImageContext*)graphicsImageContext title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

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
-(void)addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems target:(id)target action:(SEL)selector isReset:(BOOL)reset;

//添加（UIView）这样的按钮,block
-(void)addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock;

-(void)addNavigationBarCustomView:(UIView*)customView;

- (UIView *)navBarView;

- (CGFloat)navBarTopLayout;
@end
