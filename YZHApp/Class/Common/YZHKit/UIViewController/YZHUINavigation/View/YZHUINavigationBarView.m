//
//  YZHUINavigationBarView.m
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHUINavigationBarView.h"
#import "YZHKitType.h"

@interface YZHUINavigationBarView ()

@property (nonatomic, strong) UIToolbar *blurView;

@property (nonatomic, strong) UIView *contentView;

@end

@implementation YZHUINavigationBarView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpChildView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.blurView.frame = self.bounds;
    self.contentView.frame = self.bounds;
    self.bottomLine.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, SINGLE_LINE_WIDTH);
}

-(void)setUpChildView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.backgroundColor = CLEAR_COLOR;
    
    UIToolbar *blurView = [[UIToolbar alloc] init];
    blurView.barStyle = UIBarStyleDefault;
    [self addSubview:blurView];
    self.blurView = blurView;
    
    UIView *barView = [[UIView alloc] init];
    barView.backgroundColor = [[UINavigationBar appearance] barTintColor];
    [self addSubview:barView];
    self.contentView = barView;
    
    self.style = UIBarViewStyleNone;
    
    _bottomLine = [[UIImageView alloc] init];
    //    _bottomLine.autoresizingMask = self.autoresizingMask;
    self.bottomLine.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, SINGLE_LINE_WIDTH);
    self.bottomLine.backgroundColor = RGBA_F(0, 0, 0, 0.3);
    [self.contentView addSubview:self.bottomLine];
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.contentView.backgroundColor = backgroundColor;
    if (self.style != UIBarViewStyleNone) {
        self.blurView.alpha = ALPHA_FROM_RGB_COLOR(backgroundColor);
    }
}

-(void)setStyle:(UIBarViewStyle)style
{
    _style = style;
    if (style == UIBarViewStyleNone) {
        self.blurView.alpha = 0;
        self.blurView.hidden = YES;
    }
    else
    {
        self.blurView.hidden = NO;
        self.blurView.alpha = ALPHA_FROM_RGB_COLOR(self.contentView.backgroundColor);
        self.blurView.barStyle = (UIBarStyle)style;
    }
}

@end
