//
//  YZHViewController.m
//  YZHNavigationController
//
//  Created by yuan on 16/11/17.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "YZHViewController.h"
#import "YZHViewController+Internal.h"
#import "YZHNavigationController.h"
#import "YZHVCUtils.h"
#import "YZHNavigationItnTypes.h"
#import "UIViewController+YZHNavigationRootVCInitSetup.h"

@implementation YZHViewController

- (void)pri_initSetupDefaultValue {
    YZHNavigationConfig *config = [UIViewController hz_navigationConfig];
    _leftEdgeSpace = config.navigationLeftEdgeSpace;
    _rightEdgeSpace = config.navigationRightEdgeSpace;
    _leftItemsSpace = config.navigationLeftItemsSpace;
    _rightItemsSpace = config.navigationRightItemsSpace;
    _popGestureEnabled = VCPopGestureEnabled_s;
    _navigationItemViewAlpha = VCNavigationItemViewAlpha_s;
    _navigationBarViewBackgroundColor = [[UINavigationBar appearance] barTintColor];
}

-(instancetype)init
{
    if (self = [super init]) {
        [self pri_initSetupDefaultValue];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self pri_initSetupDefaultValue];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self pri_initSetupDefaultValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    itn_viewDidLoad(self);
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    itn_viewWillLayoutSubviews(self);
}

-(void)setNavBarStyle:(YZHNavBarStyle)navBarStyle
{
    _navBarStyle = navBarStyle;
    itn_setNavBarStyle(self, navBarStyle);
}

-(void)setNavigationBarViewBackgroundColor:(UIColor *)navigationBarViewBackgroundColor
{
    _navigationBarViewBackgroundColor = navigationBarViewBackgroundColor;
    itn_setNavigationBarViewBackgroundColor(self, navigationBarViewBackgroundColor);
}

-(void)setNavigationBarBottomLineColor:(UIColor *)navigationBarBottomLineColor
{
    _navigationBarBottomLineColor = navigationBarBottomLineColor;
    itn_setNavigationBarBottomLineColor(self, navigationBarBottomLineColor);
}

-(void)setNavigationBarViewAlpha:(CGFloat)navigationBarViewAlpha
{
    _navigationBarViewAlpha = navigationBarViewAlpha;
    itn_setNavigationBarViewAlpha(self, navigationBarViewAlpha);
}

-(void)setNavigationItemViewAlpha:(CGFloat)navigationItemViewAlpha
{
    _navigationItemViewAlpha = navigationItemViewAlpha;
    itn_setNavigationBarViewAlpha(self, navigationItemViewAlpha);
}

-(void)setNavigationTitle:(NSString *)navigationTitle
{
    _navigationTitle = navigationTitle;
    itn_setNavigationTitle(self, navigationTitle);
}

-(void)setTitle:(NSString *)title
{
    super.title = title;
    _navigationTitle = title;
    itn_setNavigationTitle(self, title);
}

-(void)setTitleTextAttributes:(NSDictionary<NSAttributedStringKey,id> *)titleTextAttributes
{
    _titleTextAttributes = titleTextAttributes;
    itn_setTitleTextAttributes(self, titleTextAttributes);
}

//这个带<剪头的返回按钮
-(UIButton *)addNavigationFirstLeftBackItemWithTitle:(NSString*)title target:(id)target action:(SEL)selector
{
    return itn_addNavigationFirstLeftBackItemWithTitleTargetSelector(self, title, target, selector);
}

//这个带<剪头的返回按钮,这个是重置操作，清空原来所有的LeftButtonItems,block
-(UIButton *)addNavigationFirstLeftBackItemWithTitle:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationFirstLeftBackItemWithTitleActionBlock(self, title, actionBlock);
}

//自定义第一个按钮（image，title）
-(UIButton *)addNavigationFirstLeftItemWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)selector
{
    return itn_addNavigationFirstLeftItemWithImageNameTitleTargetSelector(self, imageName, title, target, selector);
}

//自定义第一个按钮（image，title）block
-(UIButton *)addNavigationFirstLeftItemWithImageName:(NSString*)imageName title:(NSString*)title actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationFirstLeftItemWithImageNameTitleActionBlock(self, imageName, title, actionBlock);
}

//自定义一个按钮（image，title）
-(UIButton *)addNavigationLeftItemWithImageName:(NSString*)imageName title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationLeftItemWithImageNameTitleTargetSelectorIsReset(self, imageName, title, target, selector, reset);
}

//自定义一个按钮（image，title）block
-(UIButton *)addNavigationLeftItemWithImageName:(NSString*)imageName title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationLeftItemWithImageNameTitleIsResetActionBlock(self, imageName, title, reset, actionBlock);
}

//自定义一个按钮（image，title）
-(UIButton *)addNavigationLeftItemWithImage:(UIImage*)image title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationLeftItemWithImageTitleTargetSelectorIsReset(self, image, title, target, selector, reset);
}

//自定义一个按钮（image，title）block
-(UIButton *)addNavigationLeftItemWithImage:(UIImage*)image title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationLeftItemWithImageTitleIsResetActionBlock(self, image, title, reset, actionBlock);
}

//titles中的第一个NSString被用来作为第一个item的title
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector
{
    return itn_addNavigationFirstLeftBackItemsWithTitlesTargetSelector(self, titles, target, selector);
}

//titles中的第一个NSString被用来作为第一个item的title,block
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithTitles:(NSArray<NSString*> *)titles actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationFirstLeftBackItemsWithTitlesActionBlock(self, titles, actionBlock);
}

//imageNames中的第一个imageName是第二个item
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector
{
    return itn_addNavigationFirstLeftBackItemsWithImageNamesTargetSelector(self, imageNames, target, selector);
}

//imageNames中的第一个imageName是第二个item,block
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImageNames:(NSArray<NSString*> *)imageNames actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationFirstLeftBackItemsWithImageNamesActionBlock(self, imageNames, actionBlock);
}

//images中的第一个image是第二个item
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImage:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector
{
    return itn_addNavigationFirstLeftBackItemsWithImageTargetSelector(self, images, target, selector);
}

//images中的第一个image是第二个item,block
-(NSArray<UIButton*> *)addNavigationFirstLeftBackItemsWithImage:(NSArray<UIImage*> *)images actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationFirstLeftBackItemsWithImageActionBlock(self, images, actionBlock);
}

//添加leftButtonItem
-(NSArray<UIButton*> *)addNavigationLeftItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationLeftItemsWithTitlesTargetSelectorIsReset(self, titles, target, selector, reset);
}

//添加leftButtonItem,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithTitles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationLeftItemsWithTitlesIsResetActionBlock(self, titles, reset, actionBlock);
}

//添加leftButtonItem
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationLeftItemsWithImageNamesTargetSelectorIsReset(self, imageNames, target, selector, reset);
}

//添加leftButtonItem,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationLeftItemsWithImageNamesIsResetActionBlock(self, imageNames, reset, actionBlock);
}

//添加leftButtonItem
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationLeftItemsWithImagesTargetSelectorIsReset(self, images, target, selector, reset);
}

//添加leftButtonItem,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationLeftItemsWithImagesIsResetActionBlock(self, images, reset, actionBlock);
}

//添加自定义的leftButtonItem
-(NSArray<UIButton*> *)addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationLeftItemsWithCustomViewTargetSelectorIsReset(self, leftItems, target, selector, reset);
}

//添加自定义的leftButtonItem,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithCustomView:(NSArray<UIView*> *)leftItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationLeftItemsWithCustomViewIsResetActionBlock(self, leftItems, reset, actionBlock);
}

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationLeftItemsWithImageNamesTitlesTargetSelectorIsReset(self, imageNames, titles, target, selector, reset);
}

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImageNames:(NSArray<NSString*> *)imageNames titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationLeftItemsWithImageNamesTitlesIsResetActionBlock(self, imageNames, titles, reset, actionBlock);
}

//添加（Image,title）这样的按钮
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationLeftItemsWithImagesTitlesTargetSelectorIsReset(self, images, titles, target, selector, reset);
}

//添加（Image,title）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationLeftItemsWithImages:(NSArray<UIImage*> *)images titles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationLeftItemsWithImagesTitlesIsResetActionBlock(self, images, titles, reset, actionBlock);
}

//通过YZHGraphicsContext来添加leftButtonItem
-(UIButton *)addNavigationLeftItemWithGraphicsImageContext:(YZHGraphicsContext*)graphicsImageContext title:(NSString*)title target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationLeftItemWithGraphicsImageContextTitleTargetSelectorIsReset(self, graphicsImageContext, title, target, selector, reset);
}

//通过YZHGraphicsContext来添加leftButtonItem,block
-(UIButton *)addNavigationLeftItemWithGraphicsImageContext:(YZHGraphicsContext*)graphicsImageContext title:(NSString*)title isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationLeftItemWithGraphicsImageContextTitleIsResetActionBlock(self, graphicsImageContext, title, reset, actionBlock);
}

//直接在Left添加UIView,UIView的subview可以是自动布局的
-(void)addNavigationLeftItemView:(UIView *)itemView target:(id)target action:(SEL)selector isReset:(BOOL)reset {
    itn_addNavigationLeftItemViewsWithTargetSelectorIsReset(self, @[itemView], target, selector, reset);
}

//直接在Left添加UIView,UIView的subview可以是自动布局的
-(void)addNavigationLeftItemView:(UIView *)itemView isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock {
    itn_addNavigationLeftItemViewsWithIsResetActionBlock(self, @[itemView], reset, actionBlock);
}

//直接在Left添加UIView,UIView的subview可以是自动布局的
-(void)addNavigationLeftItemViews:(NSArray<UIView*>*)itemViews target:(id)target action:(SEL)selector isReset:(BOOL)reset {
    itn_addNavigationLeftItemViewsWithTargetSelectorIsReset(self, itemViews, target, selector, reset);
}

//直接在Left添加UIView,UIView的subview可以是自动布局的
-(void)addNavigationLeftItemViews:(NSArray<UIView*>*)itemViews isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock {
    itn_addNavigationLeftItemViewsWithIsResetActionBlock(self, itemViews, reset, actionBlock);
}


//right
//添加（title）这样的按钮
-(NSArray<UIButton*> *)addNavigationRightItemsWithTitles:(NSArray<NSString*> *)titles target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationRightItemsWithTitlesTargetSelectorIsReset(self, titles, target, selector, reset);
}

//添加（title）这样的按钮，block
-(NSArray<UIButton*> *)addNavigationRightItemsWithTitles:(NSArray<NSString*> *)titles isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationRightItemsWithTitlesIsResetActionBlock(self, titles, reset, actionBlock);
}

//添加（image）这样的按钮
-(NSArray<UIButton*> *)addNavigationRightItemsWithImageNames:(NSArray<NSString*> *)imageNames target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationRightItemsWithImageNamesTargetSelectorIsReset(self, imageNames, target, selector, reset);
}

//添加（image）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationRightItemsWithImageNames:(NSArray<NSString*> *)imageNames isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationRightItemsWithImageNamesIsResetActionBlock(self, imageNames, reset, actionBlock);
}

//添加（image）这样的按钮
-(NSArray<UIButton*> *)addNavigationRightItemsWithImages:(NSArray<UIImage*> *)images target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationRightItemsWithImagesTargetSelectorIsReset(self, images, target, selector, reset);
}

//添加（image）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationRightItemsWithImages:(NSArray<UIImage*> *)images isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationRightItemsWithImagesIsResetActionBlock(self, images, reset, actionBlock);
}

//添加（UIView）这样的按钮
-(NSArray<UIButton*> *)addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems target:(id)target action:(SEL)selector isReset:(BOOL)reset
{
    return itn_addNavigationRightItemsWithCustomViewTargetSelectorIsReset(self, rightItems, target, selector, reset);
}

//添加（UIView）这样的按钮,block
-(NSArray<UIButton*> *)addNavigationRightItemsWithCustomView:(NSArray<UIView*> *)rightItems isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock
{
    return itn_addNavigationRightItemsWithCustomViewIsResetActionBlock(self, rightItems, reset, actionBlock);
}

//直接在right添加UIView,UIView的subview可以是自动布局的,target selector
-(void)addNavigationRightItemView:(UIView *)itemView target:(id)target action:(SEL)selector isReset:(BOOL)reset {
    itn_addNavigationRightItemViewsWithTargetSelectorIsReset(self, @[itemView], target, selector, reset);
}

//直接在right添加UIView,UIView的subview可以是自动布局的,action Block
-(void)addNavigationRightItemView:(UIView *)itemView isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock {
    itn_addNavigationRightItemViewsWithIsResetActionBlock(self, @[itemView], reset, actionBlock);
}

//直接在right添加UIView,UIView的subview可以是自动布局的, itemViews target selector
-(void)addNavigationRightItemViews:(NSArray<UIView*> *)itemViews target:(id)target action:(SEL)selector isReset:(BOOL)reset {
    itn_addNavigationRightItemViewsWithTargetSelectorIsReset(self, itemViews, target, selector, reset);
}

//直接在right添加UIView,UIView的subview可以是自动布局的, itemViews actionBlock
-(void)addNavigationRightItemViews:(NSArray<UIView*> *)itemViews isReset:(BOOL)reset actionBlock:(YZHNavigationItemActionBlock)actionBlock {
    itn_addNavigationRightItemViewsWithIsResetActionBlock(self, itemViews, reset, actionBlock);
}


-(void)setupItemsSpace:(CGFloat)itemsSpace left:(BOOL)left {
    if (left) {
        self.leftItemsSpace = itemsSpace;
    }
    else {
        self.rightItemsSpace = itemsSpace;
    }
    itn_setupItemsSpace(self, itemsSpace, left);
}

-(void)setupItemEdgeSpace:(CGFloat)edgeSpace left:(BOOL)left {
    if (left) {
        self.leftEdgeSpace = edgeSpace;
    }
    else {
        self.rightEdgeSpace = edgeSpace;
    }
    itn_setupItemEdgeSpace(self, edgeSpace, left);
}

-(void)addNavigationBarCustomView:(UIView*)customView
{
    itn_addNavigationBarCustomView(self,customView);
}

- (UIView *)navigationBar
{
    return itn_navigationBar(self);
}

- (CGFloat)navigationBarTopLayout
{
    return itn_navigationBarTopLayout(self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
@end
