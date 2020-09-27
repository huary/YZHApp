//
//  YZHUITabBarButton.m
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHUITabBarButton.h"
#import "YZHTabBarController.h"
#import "YZHUIGraphicsImage.h"
#import "UITabBarView.h"

static float defautlTextFontSize = 12;

static float tabBarImageRatio = 0.65;

@interface YZHUITabBarButton ()

@property (nonatomic, assign) CGRange imageRange;
@property (nonatomic, assign) CGRange titleRange;
@property (nonatomic, assign) NSButtonImageTitleStyle buttonStyle;

@property (nonatomic, strong) UIButton *badgeButton;
@property (nonatomic, assign) CGRect graphicsImageFrame;

@end

@implementation YZHUITabBarButton

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = CLEAR_COLOR;
        [self _updateContentModel];
        
        [self _setupDefaultValue];
    }
    return self;
}

-(UITabBarView*)_tabBarView
{
    return (UITabBarView*)self.tabBarView;
}

-(CGRect)_getTabBarItemFrameForImageSize:(CGSize)imageSize graphicsSize:(CGSize*)graphicsSize
{
    if (imageSize.width == 0 || imageSize.height == 0 || self.bounds.size.height == 0) {
        return CGRectZero;
    }
    
    CGFloat height = self.bounds.size.height;
    CGFloat itemHeight = height * tabBarImageRatio;
    CGRange range = self.tabBarItem.hz_imageRange;
    if (!CGRangeEqualToZero(range)) {
        itemHeight = height * range.length;
    }
    CGFloat itemWidth = itemHeight;
    
    CGFloat imageRatio = imageSize.width/imageSize.height;
    CGFloat imageHeigth = itemHeight * 0.6;//height * 0.4;
    CGFloat imageWidth = imageHeigth * imageRatio;
    
    itemWidth = MAX(itemWidth, imageWidth);
    
    if (graphicsSize) {
        *graphicsSize = CGSizeMake(itemWidth, itemHeight);
    }
    
    return CGRectMake((itemWidth - imageWidth)/2, (itemHeight - imageHeigth)/2, imageWidth, imageHeigth);
}


-(UIImage*)_createTabBarItemImageForImage:(UIImage*)image imageFrame:(CGRect*)imageFrame
{
    if (!image) {
        return nil;
    }
    CGSize graphicsSize;
    CGRect frame = [self _getTabBarItemFrameForImageSize:image.size graphicsSize:&graphicsSize];
    if (CGRectIsEmpty(frame)) {
        return image;
    }
    YZHUIGraphicsImageContext *ctx = [[YZHUIGraphicsImageContext alloc] initWithBeginBlock:^(YZHUIGraphicsImageContext *context) {
        context.beginInfo = [[YZHUIGraphicsImageBeginInfo alloc] init];
        context.beginInfo.graphicsSize = graphicsSize;
    } runBlock:^(YZHUIGraphicsImageContext *context) {
        [image drawInRect:frame];
    } endPathBlock:nil];
    UIImage *newImage =[ctx createGraphicesImageWithStrokeColor:nil];
    if (imageFrame) {
        *imageFrame = frame;
    }
    return newImage;
}

-(UIButton*)_createUpdateBadgeButton:(UIButton*)badgeBtn badgeValue:(NSString*)badgeValue
{
    UIColor *titleColor = [self _badgeTitleColor];
    
    if (!badgeBtn) {
        badgeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    if (IS_AVAILABLE_NSSTRNG(badgeValue)) {
        [badgeBtn setTitle:badgeValue forState:UIControlStateNormal];
        [badgeBtn setTitle:badgeValue forState:UIControlStateSelected];
        [badgeBtn setTitle:badgeValue forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    badgeBtn.backgroundColor = [self _badgeColor];
    badgeBtn.titleLabel.font = [self _badgeTitleFont];
    badgeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [badgeBtn setTitleColor:titleColor forState:UIControlStateNormal];
    [badgeBtn setTitleColor:titleColor forState:UIControlStateSelected];
    [badgeBtn setTitleColor:titleColor forState:UIControlStateSelected | UIControlStateHighlighted];
    
    return badgeBtn;
}

-(void)_setupDefaultValue
{
    [self _updateTitleFontAndColor];
    
    self.imageRange = CGRangeMake(0, tabBarImageRatio);
    CGFloat off = tabBarImageRatio;
    self.titleRange = CGRangeMake(off, 1-off);
    self.buttonStyle = NSButtonImageTitleStyleVertical;
    
    self.badgeButton = [self _createUpdateBadgeButton:nil badgeValue:nil];
    [self _updateBadgeValue:nil];
    [self.imageView addSubview:self.badgeButton];
}

-(void)_updateTitleFontAndColor
{
    self.titleLabel.font = [self _tabBarButtonTextFont];
    [self setTitleColor:[self _tabBarButtonTitleNormalColor] forState:UIControlStateNormal];
    [self setTitleColor:[self _tabBarButtonTitleSelectedColor] forState:UIControlStateSelected];
    [self setTitleColor:[self _tabBarButtonTitleSelectedColor] forState:UIControlStateSelected | UIControlStateHighlighted];
}

-(void)_updateBadgeValue:(NSString*)badgeValue
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat h = 21;
    CGFloat w = 21;
    
    CGFloat wR = 6;
    CGFloat hR = 8;
    
    NSBadgeType badgeType = NSBadgeTypeDefault;
    CGRect oldFrame = self.badgeButton.frame;
    NSString *realShowValue = [self _badgeValueAndTypeForValue:badgeValue badgeType:&badgeType];
    if (CGRectEqualToRect(oldFrame, self.badgeButton.frame)) {
        if (badgeType == NSBadgeTypeDot) {
            h = 10;
            w = 10;
            wR = 3;
        }
        
        UIImage *image = self.tabBarItem.image;
        if (image) {
            CGSize size = self.graphicsImageFrame.size;
            CGRect imageRect = [self _getImageRectForContentRect:self.bounds];
            
            x = (imageRect.size.width - size.width)/2 + size.width - h/wR;
            y = (imageRect.size.height - size.height)/2 - h/hR;
        }
        if (realShowValue.length > 2 && badgeType == NSBadgeTypeDefault) {
            w = 32;
        }
        w = MIN(w, self.bounds.size.width - x);
        self.badgeButton.frame = CGRectMake(x, y, w, h);
    }
    
    self.badgeButton.layer.cornerRadius = self.badgeButton.bounds.size.height/2;
    self.badgeButton.layer.masksToBounds = YES;
    self.badgeButton.backgroundColor = [self _badgeColor];
    if (badgeType == NSBadgeTypeDefault) {
        [self _createUpdateBadgeButton:self.badgeButton badgeValue:realShowValue];
        self.badgeButton.hidden = !IS_AVAILABLE_NSSTRNG(realShowValue);
    }
    else if (badgeType == NSBadgeTypeDot) {
        self.badgeButton.hidden = NO;
    }
    else {
        self.badgeButton.hidden = YES;
    }
}

-(NSString*)_badgeValueAndTypeForValue:(NSString*)badgeValue badgeType:(NSBadgeType*)badgeType
{
    NSString *value = badgeValue;
    NSBadgeType type = NSBadgeTypeDefault;
    
    if (self.tabBarItem.hz_badgeValueUpdateBlock) {
        value = self.tabBarItem.hz_badgeValueUpdateBlock(self.badgeButton, badgeValue, &type);
    }
    //    if (self.badgeValueUpdateBlock) {
    //        value = self.badgeValueUpdateBlock(self, self.badgeButton, badgeValue, &type);
    //    }
    if (badgeType) {
        *badgeType = type;
    }
    return value;
}

-(UIColor*)_badgeColor
{
    UIColor *badgeColor = AVAILABLE_IOS_V_EXT_R(10.0, UIColor *, nil, self.tabBarItem.badgeColor);
    if (badgeColor == nil/*![self.tabBarItem respondsToSelector:@selector(badgeColor)] || self.tabBarItem.badgeColor == nil*/) {
        if (self.tabBarItem.hz_badgeBackgroundColor == nil) {
            UIColor *colorTmp = [[self _badgeTextAttributes] objectForKey:NSBackgroundColorAttributeName];
            if (colorTmp != nil) {
                return colorTmp;
            }
            return RED_COLOR;
        }
        return self.tabBarItem.hz_badgeBackgroundColor;
    }
    AVAILABLE_IOS_V_EXP(10.0, return self.tabBarItem.badgeColor;, return nil;);
}

-(NSDictionary<NSString*,id>*)_badgeTextAttributes
{
    NSDictionary *dict = nil;
    if ([self.tabBarItem respondsToSelector:@selector(badgeTextAttributesForState:)]) {
        if (@available(iOS 10.0, *)) {
            dict = [self.tabBarItem badgeTextAttributesForState:self.state];
            if (dict == nil) {
                dict = [self.tabBarItem badgeTextAttributesForState:UIControlStateNormal];
            }
            if (dict == nil) {
                dict = [self.tabBarItem badgeTextAttributesForState:UIControlStateSelected];
            }
            if (dict == nil) {
                dict = [self.tabBarItem badgeTextAttributesForState:UIControlStateHighlighted];
            }
            if (dict == nil) {
                dict = [self.tabBarItem badgeTextAttributesForState:UIControlStateSelected|UIControlStateHighlighted];
            }
        } else {
        }
    }
    else {
        dict = [self.tabBarItem.hz_badgeStateTextAttributes objectForKey:@(self.state)];
        if (dict == nil) {
            dict = [self.tabBarItem.hz_badgeStateTextAttributes objectForKey:@(UIControlStateNormal)];
        }
        if (dict == nil) {
            dict = [self.tabBarItem.hz_badgeStateTextAttributes objectForKey:@(UIControlStateSelected)];
        }
        if (dict == nil) {
            dict = [self.tabBarItem.hz_badgeStateTextAttributes objectForKey:@(UIControlStateHighlighted)];
        }
        if (dict == nil) {
            dict = [self.tabBarItem.hz_badgeStateTextAttributes objectForKey:@(UIControlStateSelected|UIControlStateHighlighted)];
        }
    }
    return dict;
}

-(NSDictionary<NSString*, id>*)_titleTextAttributes
{
    NSDictionary *dict = [self.tabBarItem titleTextAttributesForState:self.state];
    if (dict == nil) {
        dict = [self.tabBarItem titleTextAttributesForState:UIControlStateNormal];
    }
    if (dict == nil) {
        dict = [self.tabBarItem titleTextAttributesForState:UIControlStateSelected];
    }
    if (dict == nil) {
        dict = [self.tabBarItem titleTextAttributesForState:UIControlStateHighlighted];
    }
    if (dict == nil) {
        dict = [self.tabBarItem titleTextAttributesForState:UIControlStateSelected|UIControlStateHighlighted];
    }
    return dict;
}

-(UIFont*)_badgeTitleFont
{
    UIFont *font = [[self _badgeTextAttributes] objectForKey:NSFontAttributeName];
    if (font == nil) {
        return FONT(12);
    }
    return font;
}

-(UIColor*)_badgeTitleColor
{
    UIColor *color = [[self _badgeTextAttributes] objectForKey:NSForegroundColorAttributeName];
    if (color == nil) {
        return WHITE_COLOR;
    }
    return color;
}

-(UIViewContentMode)_imageViewContentModel
{
    return UIViewContentModeCenter;
}

-(NSTextAlignment)_textAlignment
{
    return NSTextAlignmentCenter;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect imageRect = [self _getImageRectForContentRect:self.bounds];
    self.imageView.frame = imageRect;
    CGRect titleRect = [self _getTitleRectForContentRect:self.bounds];
    self.titleLabel.frame = titleRect;
    
    [self _updateTitleFontAndColor];
    
    //这里不能更新image和title了
    
}

-(YZHTabBarController*)_tabBarVC
{
    if ([self.tabBarController isKindOfClass:[YZHTabBarController class]]) {
        return (YZHTabBarController*)self.tabBarController;
    }
    return nil;
}

-(UIFont*)_tabBarButtonTextFont
{
    if ([self _tabBarView] && [self _tabBarView].tabBarViewUseFor == UITabBarViewUseForTabBar) {
        if ([self _tabBarVC].tabBarAttributes) {
            UIFont *font = [[self _tabBarVC].tabBarAttributes objectForKey:YZHTabBarItemTitleTextFontKey];
            if (font) {
                return font;
            }
        }
    }
    else {
        UIFont *font = [[self.tabBarItem titleTextAttributesForState:UIControlStateNormal] objectForKey:NSFontAttributeName];
        if (font) {
            return font;
        }
    }
    return FONT(defautlTextFontSize);
}

-(UIColor*)_tabBarButtonTitleNormalColor
{
    if ([self _tabBarView] && [self _tabBarView].tabBarViewUseFor == UITabBarViewUseForTabBar) {
        if ([self _tabBarVC].tabBarAttributes) {
            UIColor *color = [[self _tabBarVC].tabBarAttributes objectForKey:YZHTabBarItemTitleNormalColorKey];
            if (color) {
                return color;
            }
        }
    }
    else {
        UIColor *color = [[self.tabBarItem titleTextAttributesForState:UIControlStateNormal] objectForKey:NSForegroundColorAttributeName];
        if (color) {
            return color;
        }
    }
    return RGB_WITH_INT_WITH_NO_ALPHA(0X808080);
}


-(UIColor*)_tabBarButtonTitleSelectedColor
{
    if ([self _tabBarView] && [self _tabBarView].tabBarViewUseFor == UITabBarViewUseForTabBar) {
        if ([self _tabBarVC].tabBarAttributes) {
            UIColor *color = [[self _tabBarVC].tabBarAttributes objectForKey:YZHTabBarItemTitleSelectedColorKey];
            if (color) {
                return color;
            }
        }
    }
    else {
        UIColor *color = [[self.tabBarItem titleTextAttributesForState:UIControlStateSelected] objectForKey:NSForegroundColorAttributeName];
        if (color) {
            return color;
        }
    }
    return RGB_WITH_INT_WITH_NO_ALPHA(0X0090ff);
}

-(UIColor*)_tabBarButtonNormalBackgroundColor
{
    if ([self _tabBarView] && [self _tabBarView].tabBarViewUseFor == UITabBarViewUseForTabBar) {
        return CLEAR_COLOR;
    }
    else {
        if (self.tabBarItem.hz_normalBackgroundColor) {
            return self.tabBarItem.hz_normalBackgroundColor;
        }
    }
    return CLEAR_COLOR;
}


-(UIColor*)_tabBarButtonSelectedBackgroundColor
{
    if ([self _tabBarView] && [self _tabBarView].tabBarViewUseFor == UITabBarViewUseForTabBar) {
        if ([self _tabBarVC].tabBarAttributes) {
            UIColor *color = [[self _tabBarVC].tabBarAttributes objectForKey:YZHTabBarItemSelectedBackgroundColorKey];
            if (color) {
                return color;
            }
        }
        if (self.tabBarController.tabBar.barTintColor) {
            return self.tabBarController.tabBar.barTintColor;
        }
    }
    else {
        if (self.tabBarItem.hz_selectedBackgroundColor) {
            return self.tabBarItem.hz_selectedBackgroundColor;
        }
    }
    return CLEAR_COLOR;
}

-(UIColor*)_tabBarButtonHighlightedBackgroundColor
{
    if ([self _tabBarView] && [self _tabBarView].tabBarViewUseFor == UITabBarViewUseForTabBar) {
        if ([self _tabBarVC].tabBarAttributes) {
            UIColor *color = [[self _tabBarVC].tabBarAttributes objectForKey:YZHTabBarItemHighlightedBackgroundColorKey];
            if (color) {
                return color;
            }
        }
        if (self.tabBarController.tabBar.barTintColor) {
            return self.tabBarController.tabBar.barTintColor;
        }
    }
    else {
        if (self.tabBarItem.hz_highlightedBackgroundColor) {
            return self.tabBarItem.hz_highlightedBackgroundColor;
        }
    }
    return CLEAR_COLOR;
}

-(void)_updateContentModel
{
    self.imageView.contentMode = [self _imageViewContentModel];
    self.titleLabel.textAlignment = [self _textAlignment];
}

-(void)_updateTarbarImageTitle:(UITabBarItem*)item
{
    CGRect frame = CGRectZero;
    UIImage *image = [self _createTabBarItemImageForImage:item.image imageFrame:&frame];
    UIImage *selectedImage = [self _createTabBarItemImageForImage:item.selectedImage imageFrame:NULL];
    
    self.graphicsImageFrame = frame;
    
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateHighlighted];
    [self setImage:selectedImage forState:UIControlStateSelected];
    [self setImage:selectedImage forState:UIControlStateSelected|UIControlStateHighlighted];
    
    [self setTitle:item.title forState:UIControlStateNormal];
    
    [self _updateBadgeValue:self.tabBarItem.badgeValue];
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = [self _tabBarButtonSelectedBackgroundColor];
    }
    else {
        self.backgroundColor = [self _tabBarButtonNormalBackgroundColor];
    }
}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.backgroundColor = [self _tabBarButtonHighlightedBackgroundColor];
    }
    //    else {
    //        self.backgroundColor = [self _tabBarButtonNormalBackgroundColor];
    //    }
}

-(void)setTabBarItem:(UITabBarItem *)tabBarItem
{
    [self _removeObserver];
    _tabBarItem = tabBarItem;
    [_tabBarItem addObserver:self forKeyPath:@"image" options:0 context:nil];
    [_tabBarItem addObserver:self forKeyPath:@"selectedImage" options:0 context:nil];
    [_tabBarItem addObserver:self forKeyPath:@"title" options:0 context:nil];
    [_tabBarItem addObserver:self forKeyPath:@"badgeValue" options:0 context:nil];
    [_tabBarItem addObserver:self forKeyPath:@"badgeColor" options:0 context:nil];
    [_tabBarItem addObserver:self forKeyPath:@"badgeBackgroundColor" options:0 context:nil];
    
    if (CGRangeEqualToZero(tabBarItem.hz_imageRange) ) {
        _tabBarItem.hz_imageRange = self.imageRange;
    }
    if (CGRangeEqualToZero(tabBarItem.hz_titleRange)) {
        _tabBarItem.hz_titleRange = self.titleRange;
    }
    
    [self _updateTarbarImageTitle:_tabBarItem];
    [self _updateTitleFontAndColor];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self _updateTarbarImageTitle:self.tabBarItem];
}

-(CGRect)_getRectForContentRect:(CGRect)contentRect range:(CGRange)range buttonStyle:(NSButtonImageTitleStyle)buttonStyle
{
    CGSize size = contentRect.size;
    if (buttonStyle == NSButtonImageTitleStyleVertical) {
        CGFloat x = 0;
        CGFloat y = size.height * range.offset;
        CGFloat w = size.width;
        CGFloat h = size.height * range.length;
        return CGRectMake(x, y, w, h);
    }
    else {
        CGFloat x = size.width * range.offset;
        CGFloat y = 0;
        CGFloat w = size.width * range.length;
        CGFloat h = size.height;
        return CGRectMake(x, y, w, h);
    }
    return CGRectZero;
}

-(CGRect)_getImageRectForContentRect:(CGRect)contentRect
{
    if (self.tabBarItem) {
        return [self _getRectForContentRect:contentRect range:self.tabBarItem.hz_imageRange buttonStyle:self.tabBarItem.hz_buttonStyle];
    }
    else {
        return [self _getRectForContentRect:contentRect range:self.imageRange buttonStyle:self.buttonStyle];
    }
}

-(CGRect)_getTitleRectForContentRect:(CGRect)contentRect
{
    if (self.tabBarItem) {
        return [self _getRectForContentRect:contentRect range:self.tabBarItem.hz_titleRange buttonStyle:self.tabBarItem.hz_buttonStyle];
    }
    else {
        return [self _getRectForContentRect:contentRect range:self.titleRange buttonStyle:self.buttonStyle];
    }
    return CGRectZero;
}

-(void)_removeObserver
{
    [self.tabBarItem removeObserver:self forKeyPath:@"image"];
    [self.tabBarItem removeObserver:self forKeyPath:@"selectedImage"];
    [self.tabBarItem removeObserver:self forKeyPath:@"title"];
    [self.tabBarItem removeObserver:self forKeyPath:@"badgeValue"];
    [self.tabBarItem removeObserver:self forKeyPath:@"badgeColor"];
    
    [self.tabBarItem removeObserver:self forKeyPath:@"badgeBackgroundColor"];
}

-(void)dealloc
{
    //    [self _removeObserver];
    self.tabBarItem = nil;
}

@end
