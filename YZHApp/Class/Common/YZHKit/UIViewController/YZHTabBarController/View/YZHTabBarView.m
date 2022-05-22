//
//  UITabBarView.m
//  YZHTabBarControllerDemo
//
//  Created by yuan on 17/2/7.
//  Copyright © 2017年 yzh. All rights reserved.
//

#import <objc/runtime.h>
#import "YZHTabBarView.h"

#import "YZHTabBarButton.h"
#import "YZHTabBarButton+Internal.h"
#import "YZHTabBarController.h"
#import "UITabBarItem+UIButton.h"
#import "UIView+YZHAddForUIGestureRecognizer.h"

/**************************************************************************
 *YZHTabBarView
 **************************************************************************/
@interface YZHTabBarView ()

@property (nonatomic, strong) NSMutableArray *items;
/** <#注释#> */
@property (nonatomic, strong) NSMutableArray *singleTabBarItems;

@property (nonatomic, weak) YZHTabBarButton *lastSelectedBtn;

@property (nonatomic, assign) NSInteger lastSelectedBtnIdx;

@property (nonatomic, strong) CALayer *lineLayer;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation YZHTabBarView

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
    
    self.lineLayer.frame = CGRectMake(0, -[self _topLineHeight], self.bounds.size.width, [self _topLineHeight]);
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
    self.lineLayer.frame = CGRectMake(0, -[self _topLineHeight], self.bounds.size.width, [self _topLineHeight]);
    [self _updateLayout];
}

-(void)_updateLayout
{
    if (self.items.count <= 0 && self.singleTabBarItems.count <= 0) {
        return;
    }
    __block NSInteger defaultItemCnt = 0;
    __block NSInteger customLayoutCnt = 0;
    [self.items enumerateObjectsUsingBlock:^(YZHTabBarButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tabBarButtonType == YZHTabBarButtonTypeDefault) {
            ++defaultItemCnt;
        }
        else if (obj.tabBarButtonType == YZHTabBarButtonTypeCustomLayout) {
            ++customLayoutCnt;
        }
    }];
    
    if (self.tabBarViewStyle == YZHTabBarViewStyleHorizontal) {
        CGFloat btnW = defaultItemCnt > 0 ? (self.frame.size.width / defaultItemCnt) : 0;
        CGFloat btnH = self.frame.size.height;
        if (self.tabBarViewUseFor == YZHTabBarViewUseForTabBar) {
            btnH = self.frame.size.height - SAFE_BOTTOM;
        }
        CGFloat btnX = 0;
        
        for (int i = 0; i < self.items.count; ++i) {
            YZHTabBarButton *btn = self.items[i];
            btn.tag = i;
            if (btn.tabBarButtonType == YZHTabBarButtonTypeDefault) {
                CGFloat w = btnW;
                CGFloat h = btnH;
                CGFloat maxW = self.frame.size.width - btnX;
                if (self.scrollContent) {
                    maxW = CGFLOAT_MAX;
                }
                if (btn.tabBarItem.hz_buttonItemSize.width > 0 && btn.tabBarItem.hz_buttonItemSize.width <= maxW) {
                    w = btn.tabBarItem.hz_buttonItemSize.width;
                }
                if (btn.tabBarItem.hz_buttonItemSize.height > 0 && btn.tabBarItem.hz_buttonItemSize.height <= btnH) {
                    h = btn.tabBarItem.hz_buttonItemSize.height;
                }
                btn.frame = CGRectMake(btnX, (btnH - h)/2, w, h);
            }
            else {
                btn.frame = CGRectMake( btn.tabBarItem.hz_buttonItemOrigin.x,  btn.tabBarItem.hz_buttonItemOrigin.y, btn.tabBarItem.hz_buttonItemSize.width, btn.tabBarItem.hz_buttonItemSize.height);
            }
            btnX = CGRectGetMaxX(btn.frame);
            btn.tabBarItem = btn.tabBarItem;
        }
        self.scrollView.contentSize = CGSizeMake(MAX(btnX, self.bounds.size.width), MAX(btnH, self.bounds.size.height));
    }
    else {
        CGFloat btnW = self.frame.size.width;
        CGFloat btnH = defaultItemCnt > 0 ? (self.frame.size.height  / defaultItemCnt) : 0;
        CGFloat btnY = 0;
        
        for (int i = 0; i < self.items.count; ++i) {
            YZHTabBarButton *btn = self.items[i];
            btn.tag = i;
            if (btn.tabBarButtonType == YZHTabBarButtonTypeDefault) {
                CGFloat w = btnW;
                CGFloat h = btnH;
                CGFloat maxH = self.frame.size.height - btnY;
                if (self.scrollContent) {
                    maxH = CGFLOAT_MAX;
                }
                if (btn.tabBarItem.hz_buttonItemSize.width > 0 && btn.tabBarItem.hz_buttonItemSize.width <= btnW) {
                    w = btn.tabBarItem.hz_buttonItemSize.width;
                }
                if (btn.tabBarItem.hz_buttonItemSize.height > 0 && btn.tabBarItem.hz_buttonItemSize.height <= maxH) {
                    h = btn.tabBarItem.hz_buttonItemSize.height;
                }
                btn.frame = CGRectMake((btnW - w)/2, btnY, w, h);
            }
            else {
                btn.frame = CGRectMake( btn.tabBarItem.hz_buttonItemOrigin.x,  btn.tabBarItem.hz_buttonItemOrigin.y, btn.tabBarItem.hz_buttonItemSize.width, btn.tabBarItem.hz_buttonItemSize.height);
            }
            btnY = CGRectGetMaxY(btn.frame);
            btn.tabBarItem = btn.tabBarItem;
        }
        self.scrollView.contentSize = CGSizeMake(MAX(btnW, self.bounds.size.width), MAX(btnY, self.bounds.size.height));
    }
    self.scrollView.frame = self.bounds;
    
    [self.singleTabBarItems enumerateObjectsUsingBlock:^(YZHTabBarButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

-(YZHTabBarButton*)addTabBarItem:(UITabBarItem *)tabBarItem
{
    return [self _createTabBarItem:tabBarItem tabBarItemType:YZHTabBarButtonTypeDefault forControlEvents:UIControlEventTouchUpInside actionBlock:nil atIndex:-1];
}

-(YZHTabBarButton*)addCustomLayoutTabBarItem:(UITabBarItem *)tabBarItem
{
    return [self _createTabBarItem:tabBarItem tabBarItemType:YZHTabBarButtonTypeCustomLayout forControlEvents:UIControlEventTouchUpInside actionBlock:nil atIndex:-1];
}

-(YZHTabBarButton*)createSingleTabBarItem:(UITabBarItem *)tabBarItem forControlEvents:(UIControlEvents)controlEvents actionBlock:(YZHButtonActionBlock)actionBlock
{
    return [self _createTabBarItem:tabBarItem tabBarItemType:YZHTabBarButtonTypeSingle forControlEvents:controlEvents actionBlock:actionBlock atIndex:-1];
}

-(YZHTabBarButton*)insertTabBarItem:(UITabBarItem *)tabBarItem atIndex:(NSInteger)index
{
    return [self _createTabBarItem:tabBarItem tabBarItemType:YZHTabBarButtonTypeDefault forControlEvents:UIControlEventTouchUpInside actionBlock:nil atIndex:index];
}

-(YZHTabBarButton*)_createTabBarItem:(UITabBarItem *)tabBarItem
                      tabBarItemType:(YZHTabBarButtonType)tabBarButtonType
                    forControlEvents:(UIControlEvents)controlEvents
                         actionBlock:(YZHButtonActionBlock)actionBlock
                             atIndex:(NSInteger)index
{
    YZHTabBarButton *btn = [[YZHTabBarButton alloc] init];
    btn.tabBarItem = tabBarItem;
    btn.tabBarButtonType = tabBarButtonType;
    WEAK_SELF(weakSelf);
    [btn hz_addControlEvent:controlEvents actionBlock:^(UIButton *button) {
        [weakSelf _tabBarClick:(YZHTabBarButton *)button];
    }];
    if (tabBarButtonType == YZHTabBarButtonTypeDefault || tabBarButtonType == YZHTabBarButtonTypeCustomLayout)
    {
        btn.tag = self.items.count;
#if ADD_DOUBLE_TAP_GESTURE
        [self _addGestureAtButton:btn];
#endif
        btn.tabBarView = self;
        if (index == -1) {
            [self.items addObject:btn];
        }
        else {
            [self.items insertObject:btn atIndex:index];
        }
        [self.scrollView addSubview:btn];
        NSInteger index = self.items.count - 1;
        if (index == self.defaultSelectIndex) {
            [self _tabBarClick:btn];
        }
        [self setNeedsLayout];
    }
    else {
        if (index == -1) {
            [self.singleTabBarItems addObject:btn];
        }
        else {
            [self.singleTabBarItems insertObject:btn atIndex:index];
        }
    }
    return btn;
}

-(YZHTabBarButton*)resetTabBarItem:(UITabBarItem *)tabBarItem atIndex:(NSInteger)index
{
    if (index < 0 || index >= self.items.count) {
        return nil;
    }
    YZHTabBarButton *btn = self.items[index];
    btn.tabBarItem = tabBarItem;
    [btn.customView removeFromSuperview];
    [self _updateLayout];
    return btn;
}

-(YZHTabBarButton*)addTabBarWithCustomView:(UIView*)customView
{
//    if (customView == nil) {
//        return nil;
//    }
    YZHTabBarButton *btn = [self addTabBarItem:nil];
    if (customView) {
        customView.userInteractionEnabled = NO;
        [btn addSubview:customView];
        btn.customView = customView;
    }
    return btn;
}

-(YZHTabBarButton*)insertTabBarWithCustomView:(UIView*)customView atIndex:(NSInteger)index
{
    YZHTabBarButton *btn = [self insertTabBarItem:nil atIndex:index];
    if (customView) {
        customView.userInteractionEnabled = NO;
        [btn addSubview:customView];
        btn.customView = customView;
    }
    return btn;
}

-(YZHTabBarButton*)resetTabBarWithCustomView:(UIView*)customView atIndex:(NSInteger)index
{
    if (index < 0 || index >= self.items.count) {
        return nil;
    }
//    if (customView == nil) {
//        return nil;
//    }
    YZHTabBarButton *btn = self.items[index];
    [btn.customView removeFromSuperview];
    if (customView) {
        customView.userInteractionEnabled = NO;
        [btn addSubview:customView];
    }
    return btn;
}

-(YZHTabBarButton*)addCustomLayoutTabBarWithCustomView:(UIView *)customView
{
    CGSize size = customView.frame.size;
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] init];
    tabBarItem.hz_buttonItemOrigin = customView.frame.origin;
    tabBarItem.hz_buttonItemSize = size;
    YZHTabBarButton *btn = [self addCustomLayoutTabBarItem:tabBarItem];
    customView.userInteractionEnabled = NO;
    customView.frame = CGRectMake(0, 0, size.width, size.height);
    [btn addSubview:customView];
    btn.customView = customView;
    return btn;
}

-(void)exchangeTabBarButtonAtIndex:(NSInteger)index1 withTabBarButtonAtIndex:(NSInteger)index2 animation:(BOOL)animation {
    
    YZHTabBarViewExchangeTabBarButtonAnimationBlock animationBlock = nil;
    if (animation) {
        animationBlock = ^(YZHTabBarView *tabBarView, YZHTabBarButton *btn1, YZHTabBarButton *btn2) {
                CGRect frame1 = btn1.frame;
                CGRect frame2 = btn2.frame;
            
                void (^block)(void) = ^{
                    btn1.frame = frame2;
                    btn2.frame = frame1;
                };
                if (animation) {
                    [UIView animateWithDuration:0.5 animations:block];
                }
                else{
                    block();
                }
        };
    }

    [self exchangeTabBarButtonAtIndex:index1 withTabBarButtonAtIndex:index2 animationBlock:animationBlock];
}

-(void)exchangeTabBarButtonAtIndex:(NSInteger)index1 withTabBarButtonAtIndex:(NSInteger)index2 animationBlock:(YZHTabBarViewExchangeTabBarButtonAnimationBlock)animationBlock {
    
    YZHTabBarButton *btn1 = [self.items objectAtIndex:index1];
    YZHTabBarButton *btn2 = [self.items objectAtIndex:index2];
    
    self.items[index1] = btn2;
    self.items[index2] = btn1;
    
    if (animationBlock) {
        animationBlock(self, btn1, btn2);
    }
    else {
        CGRect frame1 = btn1.frame;
        btn1.frame = btn2.frame;
        btn2.frame = frame1;
        
    }
}

-(void)removeTabBarAtIndex:(NSInteger)index {
    UIButton *removeBtn = [self.items objectAtIndex:index];
    [self.items removeObjectAtIndex:index];
    [removeBtn removeFromSuperview];
    if (removeBtn == self.lastSelectedBtn) {
        self.lastSelectedBtnIdx = index;
        NSInteger selectIndex = index < self.items.count ? index : self.items.count - 1;
        [self doSelectTo:selectIndex];
    }
    [self _updateLayout];
}

-(void)setLastSelectedBtn:(YZHTabBarButton *)lastSelectedBtn {
    _lastSelectedBtn = lastSelectedBtn;
    _lastSelectedBtnIdx = 0;
    if (lastSelectedBtn) {
        _lastSelectedBtnIdx = [self.items indexOfObject:lastSelectedBtn];
    }
    
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

-(void)_tabBarClick:(YZHTabBarButton*)selectedBtn
{
    [self _tabBarClickAction:selectedBtn userInteraction:YES];
}

-(void)_tabBarClickAction:(YZHTabBarButton*)selectedBtn userInteraction:(BOOL)userInteraction
{
    NSDictionary *actionInfo = @{YZHTabBarItemActionUserInteractionKey:@(userInteraction)};
    if (selectedBtn.tabBarButtonType == YZHTabBarButtonTypeDefault || selectedBtn.tabBarButtonType == YZHTabBarButtonTypeCustomLayout) {
        BOOL shouldSelect = YES;
        if ([self.delegate respondsToSelector:@selector(tabBarView:didSelectFrom:to:actionInfo:)]) {
            NSInteger fromIdx = [self.items indexOfObject:self.lastSelectedBtn];
            if (fromIdx == NSNotFound) {
                fromIdx = self.lastSelectedBtnIdx;
            }
            NSInteger toIdx = [self.items indexOfObject:selectedBtn];
            shouldSelect = [self.delegate tabBarView:self didSelectFrom:fromIdx to:toIdx actionInfo:actionInfo];
        }
        if (shouldSelect) {
            self.lastSelectedBtn.selected = NO;
            selectedBtn.selected = YES;
            self.lastSelectedBtn = selectedBtn;
        }
    }
    else {
        YZHButtonActionBlock actionBlock = [selectedBtn hz_actionBlockForControlEvent:UIControlEventTouchUpInside];
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
    YZHTabBarButton *btn = [self.items objectAtIndex:to];
    if (btn == nil) {
        return;
    }
    [self _tabBarClickAction:btn userInteraction:NO];
}

-(NSInteger)itemCount
{
    return self.items.count;
}

-(NSInteger)currentSelectedIndex {
    if (self.lastSelectedBtn) {
        return [self.items indexOfObject:self.lastSelectedBtn];
    }
    return -1;
}

-(void)updateSelectIndex:(NSInteger)index {
    YZHTabBarButton *selectedBtn = [self.items objectAtIndex:index];
    if (selectedBtn) {
        self.lastSelectedBtn.selected = NO;
        selectedBtn.selected = YES;
        self.lastSelectedBtn = selectedBtn;
    }
}

-(UITabBarItem*)tabBarItemAtIndex:(NSInteger)index
{
//    if (!IS_IN_ARRAY_FOR_INDEX(self.items, index)) {
//        return nil;
//    }
    YZHTabBarButton *btn = self.items[index];
    return btn.tabBarItem;
}

-(YZHTabBarButton*)tabBarButtonAtIndex:(NSInteger)index {
    return self.items[index];
}

-(CALayer *)topLine {
    return self.lineLayer;
}

- (CGFloat)_topLineHeight {
    UIViewController *vc = self.hz_viewController;
    if ([vc isKindOfClass:[YZHTabBarController class]]) {
        NSDictionary *attr = ((YZHTabBarController *)vc).tabBarAttributes;
        if ([attr objectForKey: YZHTabBarTopLineHeightKey]) {
            return [[attr objectForKey: YZHTabBarTopLineHeightKey] floatValue];
        }
        else {
            return SINGLE_LINE_WIDTH;
        }
    }
    return SINGLE_LINE_WIDTH;
}


@end
