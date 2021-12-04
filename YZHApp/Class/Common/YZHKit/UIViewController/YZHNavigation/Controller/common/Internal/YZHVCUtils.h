//
//  YZHVCUtils.h
//  YZHApp
//
//  Created by bytedance on 2021/11/20.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHNavigationBarView.h"

//itn_xxx 是SDK的内部接口不开放给外面使用的，是internal的缩写
void itn_viewDidLoad(UIViewController *vc);

void itn_viewWillLayoutSubviews(UIViewController *vc);

//void itn_dealloc(UIViewController *vc);

void itn_setNavigationBarViewBackgroundColor(UIViewController *vc, UIColor *navigationBarViewBackgroundColor);

void itn_setNavigationBarBottomLineColor(UIViewController *vc, UIColor *navigationBarBottomLineColor);

void itn_setNavBarStyle(UIViewController *vc, YZHNavBarStyle navBarStyle);

void itn_setNavigationTitle(UIViewController *vc, NSString *navigationTitle);

void itn_setTitle(UIViewController *vc, NSString *title);

void itn_setNavigationBarViewAlpha(UIViewController *vc, CGFloat navigationBarViewAlpha);

void itn_setNavigationItemViewAlpha(UIViewController *vc, CGFloat navigationItemViewAlpha);

void itn_setTitleTextAttributes(UIViewController *vc, NSDictionary<NSAttributedStringKey,id> *titleTextAttributes);

//这个带<剪头的返回按钮
UIButton *itn_addNavigationFirstLeftBackItemWithTitleTargetSelector(UIViewController *vc, NSString *title, id target, SEL selector);

//这个带<剪头的返回按钮,这个是重置操作，清空原来所有的LeftButtonItems,block
UIButton *itn_addNavigationFirstLeftBackItemWithTitleActionBlock(UIViewController *vc, NSString *title, YZHNavigationItemActionBlock actionBlock);

//自定义第一个按钮（image，title）
UIButton *itn_addNavigationFirstLeftItemWithImageNameTitleTargetSelector(UIViewController *vc, NSString *imageName, NSString *title, id target, SEL selector);

//自定义第一个按钮（image，title）block
UIButton *itn_addNavigationFirstLeftItemWithImageNameTitleActionBlock(UIViewController *vc, NSString *imageName, NSString *title, YZHNavigationItemActionBlock actionBlock);

//自定义一个按钮（image，title）
UIButton *itn_addNavigationLeftItemWithImageNameTitleTargetSelectorIsReset(UIViewController *vc, NSString *imageName, NSString *title, id target, SEL selector, BOOL reset);

//自定义一个按钮（image，title）block
UIButton *itn_addNavigationLeftItemWithImageNameTitleIsResetActionBlock(UIViewController *vc, NSString *imageName, NSString *title, BOOL reset, YZHNavigationItemActionBlock actionBlock);

//自定义一个按钮（image，title）
UIButton *itn_addNavigationLeftItemWithImageTitleTargetSelectorIsReset(UIViewController *vc, UIImage *image, NSString *title, id target, SEL selector, BOOL reset);

//自定义一个按钮（image，title）block
UIButton *itn_addNavigationLeftItemWithImageTitleIsResetActionBlock(UIViewController *vc, UIImage *image, NSString *title, BOOL reset, YZHNavigationItemActionBlock actionBlock);

//titles中的第一个NSString被用来作为第一个item的title
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithTitlesTargetSelector(UIViewController *vc, NSArray<NSString*> *titles, id target, SEL selector);

//titles中的第一个NSString被用来作为第一个item的title,block
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithTitlesActionBlock(UIViewController *vc, NSArray<NSString*> *titles, YZHNavigationItemActionBlock actionBlock);

//imageNames中的第一个imageName是第二个item
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithImageNamesTargetSelector(UIViewController *vc, NSArray<NSString*> *imageNames, id target, SEL selector);

//imageNames中的第一个imageName是第二个item,block
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithImageNamesActionBlock(UIViewController *vc, NSArray<NSString*> *imageNames, YZHNavigationItemActionBlock actionBlock);

//images中的第一个image是第二个item
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithImageTargetSelector(UIViewController *vc, NSArray<UIImage*> *images, id target, SEL selector);

//images中的第一个image是第二个item,block
NSArray<UIButton*> *itn_addNavigationFirstLeftBackItemsWithImageActionBlock(UIViewController *vc, NSArray<UIImage*> *images, YZHNavigationItemActionBlock actionBlock);

//添加leftButtonItem
NSArray<UIButton*> *itn_addNavigationLeftItemsWithTitlesTargetSelectorIsReset(UIViewController *vc, NSArray<NSString*> *titles, id target, SEL selector, BOOL reset);

//添加leftButtonItem,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithTitlesIsResetActionBlock(UIViewController *vc, NSArray<NSString*> *titles, BOOL reset, YZHNavigationItemActionBlock actionBlock);

//添加leftButtonItem
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImageNamesTargetSelectorIsReset(UIViewController *vc, NSArray<NSString*> *imageNames, id target, SEL selector, BOOL reset);

//添加leftButtonItem,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImageNamesIsResetActionBlock(UIViewController *vc, NSArray<NSString*> *imageNames,  BOOL reset, YZHNavigationItemActionBlock actionBlock);

//添加leftButtonItem
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImagesTargetSelectorIsReset(UIViewController *vc, NSArray<UIImage*> *images, id target, SEL selector, BOOL reset);

//添加leftButtonItem,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImagesIsResetActionBlock(UIViewController *vc, NSArray<UIImage*> *images, BOOL reset, YZHNavigationItemActionBlock actionBlock);

//添加自定义的leftButtonItem
NSArray<UIButton*> *itn_addNavigationLeftItemsWithCustomViewTargetSelectorIsReset(UIViewController *vc, NSArray<UIView*> *leftItems, id target,  SEL selector, BOOL reset);

//添加自定义的leftButtonItem,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithCustomViewIsResetActionBlock(UIViewController *vc, NSArray<UIView*> *leftItems, BOOL reset, YZHNavigationItemActionBlock actionBlock);

//添加（Image,title）这样的按钮
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImageNamesTitlesTargetSelectorIsReset(UIViewController *vc, NSArray<NSString*> *imageNames, NSArray<NSString*> *titles, id target, SEL selector, BOOL reset);

//添加（Image,title）这样的按钮,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImageNamesTitlesIsResetActionBlock(UIViewController *vc, NSArray<NSString*> *imageNames, NSArray<NSString*>* titles, BOOL reset, YZHNavigationItemActionBlock actionBlock);

//添加（Image,title）这样的按钮
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImagesTitlesTargetSelectorIsReset(UIViewController *vc, NSArray<UIImage*> *images, NSArray<NSString*> *titles, id target, SEL selector, BOOL reset);

//添加（Image,title）这样的按钮,block
NSArray<UIButton*> *itn_addNavigationLeftItemsWithImagesTitlesIsResetActionBlock(UIViewController *vc, NSArray<UIImage*> *images, NSArray<NSString*> *titles, BOOL reset, YZHNavigationItemActionBlock actionBlock);

//通过YZHGraphicsContext来添加leftButtonItem
UIButton *itn_addNavigationLeftItemWithGraphicsImageContextTitleTargetSelectorIsReset(UIViewController *vc, YZHGraphicsContext *graphicsImageContext, NSString *title, id target, SEL selector, BOOL reset);

//通过YZHGraphicsContext来添加leftButtonItem,block
UIButton *itn_addNavigationLeftItemWithGraphicsImageContextTitleIsResetActionBlock(UIViewController *vc,YZHGraphicsContext *graphicsImageContext, NSString *title, BOOL reset, YZHNavigationItemActionBlock actionBlock);

//right
//添加（title）这样的按钮
NSArray<UIButton*> *itn_addNavigationRightItemsWithTitlesTargetSelectorIsReset(UIViewController *vc, NSArray<NSString*> *titles, id target, SEL selector, BOOL reset);

//添加（title）这样的按钮，block
NSArray<UIButton*> *itn_addNavigationRightItemsWithTitlesIsResetActionBlock(UIViewController *vc, NSArray<NSString*> *titles, BOOL reset, YZHNavigationItemActionBlock actionBlock);

//添加（image）这样的按钮
NSArray<UIButton*> *itn_addNavigationRightItemsWithImageNamesTargetSelectorIsReset(UIViewController *vc, NSArray<NSString*> *imageNames, id target, SEL selector, BOOL reset);

//添加（image）这样的按钮,block
NSArray<UIButton*> *itn_addNavigationRightItemsWithImageNamesIsResetActionBlock(UIViewController *vc, NSArray<NSString*> *imageNames, BOOL reset, YZHNavigationItemActionBlock actionBlock);

//添加（image）这样的按钮
NSArray<UIButton*> *itn_addNavigationRightItemsWithImagesTargetSelectorIsReset(UIViewController *vc, NSArray<UIImage*> *images,  id target, SEL selector, BOOL reset);

//添加（image）这样的按钮,block
NSArray<UIButton*> *itn_addNavigationRightItemsWithImagesIsResetActionBlock(UIViewController *vc, NSArray<UIImage*> *images, BOOL reset, YZHNavigationItemActionBlock actionBlock);

//添加（UIView）这样的按钮
NSArray<UIButton*> *itn_addNavigationRightItemsWithCustomViewTargetSelectorIsReset(UIViewController *vc, NSArray<UIView*> *rightItems, id target, SEL selector, BOOL reset);

//添加（UIView）这样的按钮,block
NSArray<UIButton*> *itn_addNavigationRightItemsWithCustomViewIsResetActionBlock(UIViewController *vc, NSArray<UIView*> * rightItems, BOOL reset, YZHNavigationItemActionBlock actionBlock);

void itn_setupItemsSpace(UIViewController *vc, CGFloat itemsSpace, BOOL left);

void itn_setupItemEdgeSpace(UIViewController *vc, CGFloat edgeSpace, BOOL left);

void itn_addNavigationBarCustomView(UIViewController *vc, UIView *customView);

UIView *itn_navigationBar(UIViewController *vc);

CGFloat itn_navigationBarTopLayout(UIViewController *vc);
