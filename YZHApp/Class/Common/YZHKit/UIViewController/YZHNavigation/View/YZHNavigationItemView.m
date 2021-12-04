//
//  YZHNavigationItemView.m
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHNavigationItemView.h"
#import "YZHNavigationItnTypes.h"
#import "UIView+YZHAdd.h"
#import "YZHKitType.h"

NSAttributedStringKey const YZHTitleAttributesTextName = TYPE_STR(YZHTitleAttributesTextName);

@interface YZHNavigationItemCenterView : UIView

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation YZHNavigationItemCenterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLab];
    }
    return self;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [UILabel new];
    }
    return _titleLab;
}


@end

@interface YZHNavigationItemView ()

@property (nonatomic, strong) UIView *leftItemView;
@property (nonatomic, strong) YZHNavigationItemCenterView *centerItemView;
@property (nonatomic, strong) UIView *rightItemView;

@end

@implementation YZHNavigationItemView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _leftEdgeSpace = navigationDefaultEdgeSpace_s + navigationLeftEdgeSpace_s;
        _rightEdgeSpace = navigationDefaultEdgeSpace_s + navigationRightEdgeSpace_s;
        _leftItemsSpace = navigationLeftItemsSpace_s;
        _rightItemsSpace = navigationRightItemsSpace_s;
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
    
    self.centerItemView.titleLab.font = [self _titleFont];
    self.centerItemView.titleLab.textColor = [self _titleTextColor];
    self.centerItemView.titleLab.backgroundColor = [self _titleBackgroundColor];
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
    
    YZHNavigationItemCenterView *centerItemView = [[YZHNavigationItemCenterView alloc] init];
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
    UILabel *titleLable = self.centerItemView.titleLab;
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
    CGFloat o = STATUS_BAR_HEIGHT;    
    CGFloat w = frame.size.width;
//    CGFloat h = self.centerItemView.bounds.size.height - STATUS_BAR_HEIGHT;
    CGFloat h = frame.size.height;
    CGFloat x = (self.centerItemView.bounds.size.width - w)/2;
    CGFloat y = o + (self.centerItemView.bounds.size.height - o - h)/2;
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
    return [self.titleTextAttributes objectForKey:YZHTitleAttributesTextName];
}

-(void)_updateTitleTextAttributes:(NSDictionary *)titleTextAttributes
{
    NSString *text = self.centerItemView.titleLab.text ?: @"";
    self.centerItemView.titleLab.attributedText = [[NSAttributedString alloc] initWithString:text attributes:titleTextAttributes];
}

-(void)setT:(CGAffineTransform)t
{
    _t = t;
    self.centerItemView.transform = t;
}

-(void)setLeftItemsSpace:(CGFloat)leftItemsSpace {
    _leftItemsSpace = leftItemsSpace;
    [self _transactionLayout:[NSString stringWithFormat:@"%p.leftItemsSpace",self] left:YES];
}

-(void)setRightItemsSpace:(CGFloat)rightItemsSpace {
    _rightItemsSpace = rightItemsSpace;
    [self _transactionLayout:[NSString stringWithFormat:@"%p.rightItemsSpace",self] left:NO];
}

-(void)setLeftEdgeSpace:(CGFloat)leftEdgeSpace {
    _leftEdgeSpace = navigationDefaultEdgeSpace_s + MAX(leftEdgeSpace, navigationLeftEdgeSpace_s);
    [self _transactionLayout:[NSString stringWithFormat:@"%p.leftEdgeSpace",self] left:YES];
}

-(void)setRightEdgeSpace:(CGFloat)rightEdgeSpace {
    _rightEdgeSpace = navigationDefaultEdgeSpace_s + MAX(rightEdgeSpace, navigationRightEdgeSpace_s);
    [self _transactionLayout:[NSString stringWithFormat:@"%p.rightEdgeSpace",self] left:NO];
}

- (void)_transactionLayout:(NSString*)tid left:(BOOL)left {
    WEAK_SELF(weakSelf);
    [[YZHTransaction transactionWithTransactionId:tid action:^(YZHTransaction * _Nonnull transaction) {
        if (left) {
            [weakSelf _layoutLeftItems];
        }
        else {
            [weakSelf _layoutRightItems];
        }
    }] commit];
}


- (void)_addKVOForItemView:(UIView *)itemView left:(BOOL)left {
    
    WEAK_SELF(weakSelf);
    if ([itemView isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)itemView;
        [btn.titleLabel hz_addKVOForKeyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *)btn block:^(id target,NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey,id> *change, void *context) {
            
            NSString *newT = [change objectForKey:NSKeyValueChangeNewKey];
            NSString *oldT = [change objectForKey:NSKeyValueChangeOldKey];
            if (oldT && [newT isEqualToString:oldT]) {
                return;
            }
            
            UIButton *btn = (__bridge UIButton*)context;
            [btn sizeToFit];

            NSString *tid = [NSString stringWithFormat:@"%p.text",btn];
            [weakSelf _transactionLayout:tid left:left];
        }];
        
        [btn.imageView hz_addKVOForKeyPath:@"image" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *)btn block:^(id target,NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey,id> *change, void *context) {
            
            UIImage *oldImage = [change objectForKey:NSKeyValueChangeNewKey];
            UIImage *newImage = [change objectForKey:NSKeyValueChangeOldKey];
            if (oldImage == newImage) {
                return;
            }

            UIButton *btn = (__bridge UIButton*)context;
            [btn sizeToFit];

            NSString *tid = [NSString stringWithFormat:@"%p.image",btn];
            [weakSelf _transactionLayout:tid left:left];
        }];
    }
    [itemView hz_addKVOForKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil block:^(id target, NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey,id> *change, void *context) {
        CGRect newR = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        CGRect oldR = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        if (CGRectEqualToRect(newR, oldR)) {
            return;
        }
        NSString *tid = [NSString stringWithFormat:@"%p.frame",target];
        [weakSelf _transactionLayout:tid left:left];
    }];
    [itemView hz_addKVOForKeyPath:@"bounds" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil block:^(id target, NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey,id> *change, void *context) {

        CGRect newR = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        CGRect oldR = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        if (CGRectEqualToRect(newR, oldR)) {
            return;
        }
        NSString *tid = [NSString stringWithFormat:@"%p.bounds",target];
        [weakSelf _transactionLayout:tid left:left];
    }];
}

-(void)setLeftButtonItems:(NSArray *)leftButtonItems isReset:(BOOL)reset
{
    if (reset) {
        [self.leftItemView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }

    for (UIView *view in leftButtonItems) {
        [self.leftItemView addSubview:view];
        [self _addKVOForItemView:view left:YES];
    }
    
    [self _layoutLeftItems];
}

-(void)_layoutLeftItems
{
    NSInteger tag = 0;
    CGFloat height = self.leftItemView.bounds.size.height;
    CGFloat offsetX = self.leftEdgeSpace;
    for (UIView *item in self.leftItemView.subviews) {
        [item hz_switchKVOForKeyPath:@"frame" OFF:YES];
        CGRect frame = item.frame;
        frame.origin = CGPointMake(offsetX, (height + STATUS_BAR_HEIGHT - frame.size.height)/2);
        item.tag = ++tag;
        item.frame = frame;
        offsetX = CGRectGetMaxX(frame) + self.leftItemsSpace;
        [item hz_switchKVOForKeyPath:@"frame" OFF:NO];
    }
}

-(void)setRightButtonItems:(NSArray *)rightButtonItems isReset:(BOOL)reset
{
    if (reset) {
        [self.rightItemView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    for (UIView *view in rightButtonItems) {
        [self.rightItemView addSubview:view];
        [self _addKVOForItemView:view left:NO];
    }
    [self _layoutRightItems];
}

-(void)_layoutRightItems
{
    NSInteger tag = 0;
    CGFloat height = self.rightItemView.bounds.size.height;
    CGFloat offsetX = self.rightItemView.bounds.size.width -  self.rightEdgeSpace;
    for (UIView *item in self.rightItemView.subviews) {
        [item hz_switchKVOForKeyPath:@"frame" OFF:YES];
        CGRect frame = item.frame;
        frame.origin = CGPointMake(offsetX - frame.size.width, (height + STATUS_BAR_HEIGHT - frame.size.height)/2);
        item.tag = ++tag;
        item.frame = frame;
        offsetX = CGRectGetMinX(frame) - self.rightItemsSpace;
        [item hz_switchKVOForKeyPath:@"frame" OFF:NO];
    }
}

@end
