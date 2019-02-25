//
//  UITabBarView.m
//  YZHTabBarControllerDemo
//
//  Created by captain on 17/2/7.
//  Copyright © 2017年 yzh. All rights reserved.
//

#import <objc/runtime.h>
#import "UITabBarView.h"
#import "YZHKitType.h"
#import "YZHUITabBarButton.h"
#import "YZHTabBarController.h"
#import "UITabBarItem+UIButton.h"
#import "UIView+YZHAddForUIGestureRecognizer.h"

static const NSInteger customViewTag_s = 111;


typedef NS_ENUM(NSInteger, NSTabBarButtonType)
{
    //创建的TabBar按顺序加入到TabBarView中的
    NSTabBarButtonTypeDefault       = 0,
    //自定义Layout
    NSTabBarButtonTypeCustomLayout  = 1,
    //创建单个的TabBar
    NSTabBarButtonTypeSingle        = 2,
};

/**************************************************************************
 *UITabBarButton (TabBarButtonType)
 **************************************************************************/
@interface YZHUITabBarButton (TabBarButtonType)
@property (nonatomic, assign) NSTabBarButtonType tabBarButtonType;
//@property (nonatomic, copy) TabBarEventActionBlock eventActionBlock;
@end

@implementation YZHUITabBarButton (TabBarButtonType)

-(void)setTabBarButtonType:(NSTabBarButtonType)tabBarButtonType
{
    objc_setAssociatedObject(self, @selector(tabBarButtonType), @(tabBarButtonType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSTabBarButtonType)tabBarButtonType
{
    return (NSTabBarButtonType)[objc_getAssociatedObject(self, _cmd) integerValue];
}

//-(void)setEventActionBlock:(TabBarEventActionBlock)eventActionBlock
//{
//    objc_setAssociatedObject(self, @selector(eventActionBlock), eventActionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//-(TabBarEventActionBlock)eventActionBlock
//{
//    return objc_getAssociatedObject(self, _cmd);
//}

@end




/**************************************************************************
 *UITabBarView
 **************************************************************************/
@interface UITabBarView ()

@property (nonatomic, strong) NSMutableArray *items;
/** <#注释#> */
@property (nonatomic, strong) NSMutableArray *singleTabBarItems;

@property (nonatomic, weak) YZHUITabBarButton *lastSelectedBtn;

@property (nonatomic, strong) CALayer *lineLayer;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation UITabBarView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self _setupChildView];
    }
    return self;
}

-(void)_setupChildView
{
    self.lineLayer = [[CALayer alloc] init];
    
    self.lineLayer.frame = CGRectMake(0, -SINGLE_LINE_WIDTH, self.bounds.size.width, SINGLE_LINE_WIDTH);
    self.lineLayer.backgroundColor = RGBA_F(0, 0, 0, 0.3).CGColor;
    [self.layer addSublayer:self.lineLayer];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.bounces = NO;
    scrollView.backgroundColor = CLEAR_COLOR;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.layer.masksToBounds = NO;
    scrollView.delaysContentTouches = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    self.scrollContent = NO;
}

-(NSMutableArray*)items
{
    if (_items == nil) {
        _items =  [NSMutableArray array];
    }
    return _items;
}

-(NSMutableArray*)singleTabBarItems
{
    if (_singleTabBarItems == nil) {
        _singleTabBarItems = [NSMutableArray array];
    }
    return _singleTabBarItems;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.lineLayer.frame = CGRectMake(0, -SINGLE_LINE_WIDTH, self.bounds.size.width, SINGLE_LINE_WIDTH);
    [self _updateLayout];
}

-(void)_updateLayout
{
    if (self.items.count <= 0 && self.singleTabBarItems.count <= 0) {
        return;
    }
    __block NSInteger defaultItemCnt = 0;
    __block NSInteger customLayoutCnt = 0;
    [self.items enumerateObjectsUsingBlock:^(YZHUITabBarButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tabBarButtonType == NSTabBarButtonTypeDefault) {
            ++defaultItemCnt;
        }
        else if (obj.tabBarButtonType == NSTabBarButtonTypeCustomLayout) {
            ++customLayoutCnt;
        }
    }];
    
    if (self.tabBarViewStyle == UITabBarViewStyleHorizontal) {
        CGFloat btnW = defaultItemCnt > 0 ? (self.frame.size.width / defaultItemCnt) : 0;
        CGFloat btnH = self.frame.size.height;
        if (self.tabBarViewUseFor == UITabBarViewUseForTabBar) {
            btnH = self.frame.size.height - SAFE_BOTTOM;
        }
        CGFloat btnX = 0;
        
        for (int i = 0; i < self.items.count; ++i) {
            YZHUITabBarButton *btn = self.items[i];
            btn.tag = i;
            if (btn.tabBarButtonType == NSTabBarButtonTypeDefault) {
                CGFloat w = btnW;
                CGFloat h = btnH;
                CGFloat maxW = self.frame.size.width - btnX;
                if (self.scrollContent) {
                    maxW = CGFLOAT_MAX;
                }
                if (btn.tabBarItem.buttonItemSize.width > 0 && btn.tabBarItem.buttonItemSize.width <= maxW) {
                    w = btn.tabBarItem.buttonItemSize.width;
                }
                if (btn.tabBarItem.buttonItemSize.height > 0 && btn.tabBarItem.buttonItemSize.height <= btnH) {
                    h = btn.tabBarItem.buttonItemSize.height;
                }
                btn.frame = CGRectMake(btnX, (btnH - h)/2, w, h);
            }
            else {
                btn.frame = CGRectMake( btn.tabBarItem.buttonItemOrigin.x,  btn.tabBarItem.buttonItemOrigin.y, btn.tabBarItem.buttonItemSize.width, btn.tabBarItem.buttonItemSize.height);
            }
            btnX = CGRectGetMaxX(btn.frame);
            btn.tabBarItem = btn.tabBarItem;
        }
        self.scrollView.contentSize = CGSizeMake(btnX, btnH);
    }
    else {
        CGFloat btnW = self.frame.size.width;
        CGFloat btnH = defaultItemCnt > 0 ? (self.frame.size.height  / defaultItemCnt) : 0;
        CGFloat btnY = 0;
        
        for (int i = 0; i < self.items.count; ++i) {
            YZHUITabBarButton *btn = self.items[i];
            btn.tag = i;
            if (btn.tabBarButtonType == NSTabBarButtonTypeDefault) {
                CGFloat w = btnW;
                CGFloat h = btnH;
                CGFloat maxH = self.frame.size.height - btnY;
                if (self.scrollContent) {
                    maxH = CGFLOAT_MAX;
                }
                if (btn.tabBarItem.buttonItemSize.width > 0 && btn.tabBarItem.buttonItemSize.width <= btnW) {
                    w = btn.tabBarItem.buttonItemSize.width;
                }
                if (btn.tabBarItem.buttonItemSize.height > 0 && btn.tabBarItem.buttonItemSize.height <= maxH) {
                    h = btn.tabBarItem.buttonItemSize.height;
                }
                btn.frame = CGRectMake((btnW - w)/2, btnY, w, h);
            }
            else {
                btn.frame = CGRectMake( btn.tabBarItem.buttonItemOrigin.x,  btn.tabBarItem.buttonItemOrigin.y, btn.tabBarItem.buttonItemSize.width, btn.tabBarItem.buttonItemSize.height);
            }
            btnY = CGRectGetMaxY(btn.frame);
            btn.tabBarItem = btn.tabBarItem;
        }
        self.scrollView.contentSize = CGSizeMake(btnW, btnY);
    }
    self.scrollView.frame = self.bounds;
    
    [self.singleTabBarItems enumerateObjectsUsingBlock:^(YZHUITabBarButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.tabBarItem = obj.tabBarItem;
    }];
}

#if ADD_DOUBLE_TAP_GESTURE
-(void)_addGestureAtButton:(UITabBarButton*)button
{
    WEAK_SELF(weakSelf);
    [button addDoubleTapGestureRecognizerBlock:^(UIGestureRecognizer *gesture) {
        [weakSelf _tapAction:gesture];
    }];
}

-(void)_tapAction:(UIGestureRecognizer*)gesture
{
    if ([self.delegate respondsToSelector:@selector(tabBarView:doubleClickAtIndex:)]) {
        [self.delegate tabBarView:self doubleClickAtIndex:gesture.view.tag];
    }
}
#endif

-(YZHUITabBarButton*)addTabBarItem:(UITabBarItem *)tabBarItem
{
    return [self _createTabBarItem:tabBarItem tabBarItemType:NSTabBarButtonTypeDefault forControlEvents:UIControlEventTouchUpInside actionBlock:nil];
}

-(YZHUITabBarButton*)addCustomLayoutTabBarItem:(UITabBarItem *)tabBarItem
{
    return [self _createTabBarItem:tabBarItem tabBarItemType:NSTabBarButtonTypeCustomLayout forControlEvents:UIControlEventTouchUpInside actionBlock:nil];
}

-(YZHUITabBarButton*)createSingleTabBarItem:(UITabBarItem *)tabBarItem forControlEvents:(UIControlEvents)controlEvents actionBlock:(YZHUIButtonActionBlock)actionBlock
{
    return [self _createTabBarItem:tabBarItem tabBarItemType:NSTabBarButtonTypeSingle forControlEvents:controlEvents actionBlock:actionBlock];
}

-(YZHUITabBarButton*)_createTabBarItem:(UITabBarItem *)tabBarItem tabBarItemType:(NSTabBarButtonType)tabBarButtonType forControlEvents:(UIControlEvents)controlEvents actionBlock:(YZHUIButtonActionBlock)actionBlock
{
    YZHUITabBarButton *btn = [[YZHUITabBarButton alloc] init];
    btn.tabBarItem = tabBarItem;
    btn.tabBarButtonType = tabBarButtonType;
//    [btn addTarget:self action:@selector(_tabBarClick:) forControlEvents:controlEvents];
    WEAK_SELF(weakSelf);
    [btn addControlEvent:controlEvents actionBlock:^(UIButton *button) {
        [weakSelf _tabBarClick:button];
    }];
    if (tabBarButtonType == NSTabBarButtonTypeDefault || tabBarButtonType == NSTabBarButtonTypeCustomLayout)
    {
        btn.tag = self.items.count;
#if ADD_DOUBLE_TAP_GESTURE
        [self _addGestureAtButton:btn];
#endif
        btn.tabBarView = self;
        [self.items addObject:btn];
        [self.scrollView addSubview:btn];
        NSInteger index = self.items.count - 1;
        if (index == self.defaultSelectIndex) {
            [self _tabBarClick:btn];
        }
        [self setNeedsLayout];
        //或者
//        [self _updateLayout];
    }
    else {
//        btn.eventActionBlock = actionBlock;
        [self.singleTabBarItems addObject:btn];
    }
    return btn;
}

-(YZHUITabBarButton*)resetTabBarItem:(UITabBarItem *)tabBarItem atIndex:(NSInteger)index
{
    if (index < 0 || index >= self.items.count) {
        return nil;
    }
    YZHUITabBarButton *btn = self.items[index];
    btn.tabBarItem = tabBarItem;
    [self _removeCustomViewAtView:btn];
    [self _updateLayout];
    return btn;
}

-(void)_removeCustomViewAtView:(UIView*)view
{
    UIView *old = [view viewWithTag:customViewTag_s];
    [old removeFromSuperview];
}

-(YZHUITabBarButton*)addTabBarWithCustomView:(UIView*)customView
{
    if (customView == nil) {
        return nil;
    }
    YZHUITabBarButton *btn = [self addTabBarItem:nil];
    customView.tag = customViewTag_s;
    customView.userInteractionEnabled = NO;
    [btn addSubview:customView];
    return btn;
}

-(YZHUITabBarButton*)resetTabBarWithCustomView:(UIView*)customView atIndex:(NSInteger)index
{
    if (index < 0 || index >= self.items.count) {
        return nil;
    }
    if (customView == nil) {
        return nil;
    }
    YZHUITabBarButton *btn = self.items[index];
    [self _removeCustomViewAtView:btn];
    customView.tag = customViewTag_s;
    customView.userInteractionEnabled = NO;
    [btn addSubview:customView];
    return btn;
}

-(YZHUITabBarButton*)addCustomLayoutTabBarWithCustomView:(UIView *)customView
{
    CGSize size = customView.frame.size;
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] init];
    tabBarItem.buttonItemOrigin = customView.frame.origin;
    tabBarItem.buttonItemSize = size;
    YZHUITabBarButton *btn = [self addCustomLayoutTabBarItem:tabBarItem];
    customView.tag = customViewTag_s;
    customView.userInteractionEnabled = NO;
    customView.frame = CGRectMake(0, 0, size.width, size.height);
    [btn addSubview:customView];
    return btn;
}

-(void)clear
{
    [self.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.items removeAllObjects];
    self.items = nil;
    
    [self.singleTabBarItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.singleTabBarItems removeAllObjects];
    self.singleTabBarItems = nil;
    
    self.lastSelectedBtn = nil;
    self.scrollView.contentSize = self.bounds.size;
}

-(void)_tabBarClick:(YZHUITabBarButton*)selectedBtn
{
    [self _tabBarClickAction:selectedBtn userInteraction:YES];
}

-(void)_tabBarClickAction:(YZHUITabBarButton*)selectedBtn userInteraction:(BOOL)userInteraction
{
    NSDictionary *actionInfo = @{YZHTabBarItemActionUserInteractionKey:@(userInteraction)};
    if (selectedBtn.tabBarButtonType == NSTabBarButtonTypeDefault || selectedBtn.tabBarButtonType == NSTabBarButtonTypeCustomLayout) {
        BOOL shouldSelect = YES;
        if ([self.delegate respondsToSelector:@selector(tabBarView:didSelectFrom:to:actionInfo:)]) {
            shouldSelect = [self.delegate tabBarView:self didSelectFrom:self.lastSelectedBtn.tag to:selectedBtn.tag actionInfo:actionInfo];
        }
        if (shouldSelect) {
            self.lastSelectedBtn.selected = NO;
            selectedBtn.selected = YES;
            self.lastSelectedBtn = selectedBtn;
        }
    }
    else {
        YZHUIButtonActionBlock actionBlock = [selectedBtn actionBlock];
        if (actionBlock) {
            actionBlock(selectedBtn);
        }
    }
}

-(void)doSelectTo:(NSInteger)to
{
    if (to < 0) {
        self.lastSelectedBtn.selected = NO;
        self.lastSelectedBtn = nil;
    }
    if (to < 0 || to >= self.items.count) {
        return;
    }
    YZHUITabBarButton *btn = [self.items objectAtIndex:to];
    if (btn == nil) {
        return;
    }
    [self _tabBarClickAction:btn userInteraction:NO];
}

-(NSInteger)currentIndex
{
    return self.items.count;
}

-(UITabBarItem*)tabBarItemAtIndex:(NSInteger)index
{
    if (!IS_IN_ARRAY_FOR_INDEX(self.items, index)) {
        return nil;
    }
    YZHUITabBarButton *btn = self.items[index];
    return btn.tabBarItem;
}
@end
