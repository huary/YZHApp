//
//  YZHUINavigationItemView.m
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHUINavigationItemView.h"
#import "UIView+UIViewController.h"
#import "YZHKitType.h"

NSAttributedStringKey const NSTitleAttributesTextName = TYPE_STR(NSTitleAttributesTextName);

typedef NS_ENUM(NSInteger, UINavigationItemViewTag)
{
    UILeftItemViewTag    = 1,
    UICenterItemViewTag  = 2,
    UIRightItemViewTag   = 3,
};

typedef NS_ENUM(NSInteger, UICenterItemViewSubviewsTag)
{
    UICenterItemViewSubviewTitleLabelTag = 1,
};

@interface YZHUINavigationItemView ()

@property (nonatomic, strong) UIView *leftItemView;
@property (nonatomic, strong) UIView *centerItemView;
@property (nonatomic, strong) UIView *rightItemView;

//@property (nonatomic, strong) UIView *contentView;
@end

@implementation YZHUINavigationItemView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChildView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self _updatelayoutSubViews];
}

-(void)_updatelayoutSubViews
{
    [self _updateItemFrame];
    
    [self _layoutLeftItems];
    [self _layoutRightItems];
    
    [self _updateTitleFont:[self _titleFont]];
    [self _updateTitleColor:[self _titleTextColor]];
    [self _updateTitleBackgroundColor:[self _titleBackgroundColor]];
    
    [self _updateTitleTextAttributes:[self _titleTextAttributes]];
}

-(void)_updateItemFrame
{
    CGSize size = self.bounds.size;
    CGRect frame = CGRectMake(0, 0, size.width/2, size.height);
    if (!CGRectEqualToRect(self.leftItemView.frame, frame)) {
        self.leftItemView.frame = frame;
    }
    frame = CGRectMake(size.width/2, 0, size.width/2, size.height);
    if (!CGRectEqualToRect(self.rightItemView.frame, frame)) {
        self.rightItemView.frame = frame;
    }
    if (!CGSizeEqualToSize(self.centerItemView.frame.size, size)) {
        self.centerItemView.frame = self.bounds;
    }
}

-(void)setupChildView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.backgroundColor = CLEAR_COLOR;
    
    CGSize size = self.bounds.size;
    
    UIView *centerItemView = [[UIView alloc] init];
    centerItemView.frame = self.bounds;
    centerItemView.backgroundColor = self.backgroundColor;
    [self addSubview:centerItemView];
    self.centerItemView = centerItemView;
    
    UIView *leftItemView = [[UIView alloc] init];
    leftItemView.frame = CGRectMake(0, 0, size.width/2, size.height);
    leftItemView.backgroundColor = self.backgroundColor;
    [self addSubview:leftItemView];
    self.leftItemView = leftItemView;
    
    UIView *rightItemView  = [[UIView alloc] init];
    rightItemView.frame = CGRectMake(size.width/2, 0, size.width/2, size.height);
    rightItemView.backgroundColor = self.backgroundColor;
    [self addSubview:rightItemView];
    self.rightItemView = rightItemView;

    self.backgroundColor = CLEAR_COLOR;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    if (backgroundColor == nil) {
        backgroundColor = CLEAR_COLOR;
    }
    self.leftItemView.backgroundColor = backgroundColor;
    self.rightItemView.backgroundColor = backgroundColor;
    self.centerItemView.backgroundColor = backgroundColor;
}

-(void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];
    self.leftItemView.alpha = alpha;
    self.centerItemView.alpha = alpha;
    self.rightItemView.alpha = alpha;
}

-(void)setTitle:(NSString *)title
{
    _title = title;
    UILabel *titleLable = (UILabel*)[self.centerItemView viewWithTag:UICenterItemViewSubviewTitleLabelTag];
    if (titleLable == nil) {
        titleLable = [[UILabel alloc] init];
        titleLable.tag = UICenterItemViewSubviewTitleLabelTag;
        [self.centerItemView addSubview:titleLable];
    }
    titleLable.text = title;
    titleLable.font = [self _titleFont];
    
    UIColor *textColor = [self _titleTextColor];
    if (textColor) {
        titleLable.textColor = textColor;
    }
    
    UIColor *backgroundColor = [self _titleBackgroundColor];
    if (backgroundColor) {
        titleLable.backgroundColor = backgroundColor;
    }
    [titleLable sizeToFit];
    CGRect frame = titleLable.frame;
    CGFloat x = (self.bounds.size.width - frame.size.width)/2;
    CGFloat y = STATUS_BAR_HEIGHT;
    CGFloat w = frame.size.width;
    CGFloat h = self.bounds.size.height - STATUS_BAR_HEIGHT;
    titleLable.frame = CGRectMake(x, y, w, h);
}

-(UIFont*)_titleFont
{
    UIFont *font = [[[UINavigationBar appearance] titleTextAttributes] objectForKey:NSFontAttributeName];
    if ([self.titleTextAttributes objectForKey:NSFontAttributeName]) {
        font = [self.titleTextAttributes objectForKey:NSFontAttributeName];
    }
    return font;
}

-(UIColor*)_titleTextColor
{
    UIColor *textColor = [[[UINavigationBar appearance] titleTextAttributes] objectForKey:NSForegroundColorAttributeName];
    if ([self.titleTextAttributes objectForKey:NSForegroundColorAttributeName]) {
        textColor = [self.titleTextAttributes objectForKey:NSForegroundColorAttributeName];
    }
    return textColor;
}

-(UIColor*)_titleBackgroundColor
{
    UIColor *titleBGColor = [[[UINavigationBar appearance] titleTextAttributes] objectForKey:NSBackgroundColorAttributeName];
    if ([self.titleTextAttributes objectForKey:NSBackgroundColorAttributeName]) {
        titleBGColor = [self.titleTextAttributes objectForKey:NSBackgroundColorAttributeName];
    }
    if (titleBGColor == nil) {
        titleBGColor = CLEAR_COLOR;
    }
    return titleBGColor;
}

-(NSDictionary*)_titleTextAttributes
{
    return [self.titleTextAttributes objectForKey:NSTitleAttributesTextName];
}


-(void)_updateTitleFont:(UIFont*)titleFont
{
    UILabel *titleLable = (UILabel*)[self.centerItemView viewWithTag:UICenterItemViewSubviewTitleLabelTag];
    if (titleLable) {
        titleLable.font = titleFont;
    }
}

-(void)_updateTitleColor:(UIColor *)titleColor
{
    UILabel *titleLable = (UILabel*)[self.centerItemView viewWithTag:UICenterItemViewSubviewTitleLabelTag];
    if (titleLable) {
        titleLable.textColor = titleColor;
    }
}

-(void)_updateTitleBackgroundColor:(UIColor *)titleBackgroundColor
{
    UILabel *titleLable = (UILabel*)[self.centerItemView viewWithTag:UICenterItemViewSubviewTitleLabelTag];
    if (titleLable) {
        titleLable.backgroundColor = titleBackgroundColor;
    }
}

-(void)_updateTitleTextAttributes:(NSDictionary *)titleTextAttributes
{
    UILabel *titleLable = (UILabel*)[self.centerItemView viewWithTag:UICenterItemViewSubviewTitleLabelTag];
    if (titleLable && titleLable.text != nil) {
        titleLable.attributedText = [[NSAttributedString alloc] initWithString:titleLable.text attributes:titleTextAttributes];
    }
}

-(void)setT:(CGAffineTransform)t
{
    _t = t;
    self.centerItemView.transform = t;
}

-(UIView*)getLeftItemViewLastSubView
{
    UIView *lastView = [self.leftItemView.subviews lastObject];
    return lastView;
}

-(UIView*)getRightItemViewLastSubView
{
    UIView *lastView = [self.rightItemView.subviews lastObject];
    return lastView;
}

-(void)setLeftButtonItems:(NSArray *)leftButtonItems isReset:(BOOL)reset
{
    NSInteger tag = 0;
    if (reset) {
        [self.leftItemView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    else
    {
        UIView *lastView = [self getLeftItemViewLastSubView];
        tag = lastView.tag;
    }
    
    for (UIView *view in leftButtonItems) {
        view.tag = ++tag;
        [self.leftItemView addSubview:view];
    }
    
    [self _layoutLeftItems];
}

-(void)_layoutLeftItems
{
    NSInteger tag = 1;
    CGFloat height = self.leftItemView.bounds.size.height;
    CGFloat offsetX = NAVIGATION_ITEM_VIEW_SUBVIEWS_LEFT_SPACE;
    for (tag = 1; tag <= self.leftItemView.subviews.count; ++tag) {
        UIView *item = [self.leftItemView viewWithTag:tag];
        CGRect frame = item.frame;
        frame.origin = CGPointMake(offsetX, (height + STATUS_BAR_HEIGHT - frame.size.height)/2);
        item.frame = frame;
        offsetX = CGRectGetMaxX(frame) + CUSTOM_NAVIGATION_ITEM_VIEW_SUBVIEWS_ITEM_SPACE;
    }
}

-(void)setRightButtonItems:(NSArray *)rightButtonItems isReset:(BOOL)reset
{
    NSInteger tag = 0;
    if (reset) {
        [self.rightItemView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    else
    {
        UIView *lastView = [self getRightItemViewLastSubView];
        tag = lastView.tag;
    }
    
    for (UIView *view in rightButtonItems) {
        view.tag = ++tag;
        [self.rightItemView addSubview:view];
    }
    [self _layoutRightItems];
}

-(void)_layoutRightItems
{
    NSInteger tag = 1;
    CGFloat height = self.rightItemView.bounds.size.height;
    CGFloat offsetX = self.rightItemView.bounds.size.width - NAVIGATION_ITEM_VIEW_SUBVIEWS_RIGHT_SPACE;;
    for (tag = 1; tag <= self.rightItemView.subviews.count; ++tag) {
        UIView *item = [self.rightItemView viewWithTag:tag];
        CGRect frame = item.frame;
        frame.origin = CGPointMake(offsetX - frame.size.width, (height + STATUS_BAR_HEIGHT - frame.size.height)/2);
        item.frame = frame;
        offsetX = CGRectGetMinX(frame) - CUSTOM_NAVIGATION_ITEM_VIEW_SUBVIEWS_ITEM_SPACE;
    }
}

@end
