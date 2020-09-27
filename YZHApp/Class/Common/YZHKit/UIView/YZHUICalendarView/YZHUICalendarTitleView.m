//
//  YZHUICalendarTitleView.m
//  YZHUICalendarViewDemo
//
//  Created by yuan on 2018/8/8.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHUICalendarTitleView.h"
#import "YZHUIButton.h"
#import "YZHKitType.h"
#import "YZHUIGraphicsImage.h"
#import "UIView+YZHAdd.h"
#import "UIButton+YZHAdd.h"

@interface YZHUICalendarTitleView ()
/*  */
@property (nonatomic, strong) YZHUIButton *prevBtn;

/* <#注释#> */
@property (nonatomic, strong) UILabel *titleLabel;

/* <#注释#> */
@property (nonatomic, strong) YZHUIButton *nextBtn;

/* <#注释#> */
@property (nonatomic, strong) YZHUIButton *rightBtn;

@end



@implementation YZHUICalendarTitleView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupChildView];
    }
    return self;
}

-(void)_setupChildView
{
//    self.backgroundColor = PURPLE_COLOR;
    WEAK_SELF(weakSelf);
    CGFloat w = 8;
    CGFloat h = 12;
    CGFloat lineWidth = 2;
    UIImage *image = [YZHUIGraphicsImageContext createBackImageWithSize:CGSizeMake(w, h) lineWidth:lineWidth backgroundColor:nil strokeColor:RGB_WITH_INT_WITH_NO_ALPHA(0xdddddd)];
    self.prevBtn = [YZHUIButton buttonWithType:UIButtonTypeCustom];
    [self.prevBtn setImage:image forState:UIControlStateNormal];
    [self addSubview:self.prevBtn];
    [self.prevBtn hz_addControlEvent:UIControlEventTouchUpInside actionBlock:^(UIButton *button) {
        if ([weakSelf.delegate respondsToSelector:@selector(calendarTitleView:didClickPrevAction:)]) {
            [weakSelf.delegate calendarTitleView:weakSelf didClickPrevAction:weakSelf.titleModel];
        }
    }];
    
    image = [YZHUIGraphicsImageContext createForwardImageWithSize:CGSizeMake(w, h) lineWidth:lineWidth backgroundColor:nil strokeColor:RGB_WITH_INT_WITH_NO_ALPHA(0xdddddd)];
    self.nextBtn = [YZHUIButton buttonWithType:UIButtonTypeCustom];
    [self.nextBtn setImage:image forState:UIControlStateNormal];
    [self addSubview:self.nextBtn];
    [self.nextBtn hz_addControlEvent:UIControlEventTouchUpInside actionBlock:^(UIButton *button) {
        if ([weakSelf.delegate respondsToSelector:@selector(calendarTitleView:didClickNextAction:)]) {
            [weakSelf.delegate calendarTitleView:weakSelf didClickNextAction:weakSelf.titleModel];
        }
    }];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.font = FONT(12);
    self.titleLabel.textColor = BLACK_COLOR;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"2018年05月";
    [self addSubview:self.titleLabel];
    
    w = 5;
    image = [YZHUIGraphicsImageContext createImageWithSize:CGSizeMake(w, w) cornerRadius:w/2 borderWidth:0 borderColor:nil backgroundColor:RGB_WITH_INT_WITH_NO_ALPHA(0x388CFF)];
    self.rightBtn = [YZHUIButton buttonWithType:UIButtonTypeCustom];
    self.rightBtn.layoutStyle = NSButtonLayoutStyleLR | NSButtonLayoutStyleCustomSpace;
    self.rightBtn.imageTitleSpace = 4;
    self.rightBtn.titleLabel.font = FONT(12);
    [self.rightBtn setImage:image forState:UIControlStateNormal];
    [self.rightBtn setTitle:@"有课" forState:UIControlStateNormal];
    [self.rightBtn setTitleColor:BLACK_COLOR forState:UIControlStateNormal];
    self.rightBtn.userInteractionEnabled = NO;
    [self addSubview:self.rightBtn];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self _updateLayout];
}

-(void)_updateLayout
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = self.hz_width;
    CGFloat h = self.hz_height;
    
    [self.titleLabel sizeToFit];
    x = (w - self.titleLabel.hz_width)/2;
    w = self.titleLabel.hz_width;
    self.titleLabel.frame = CGRectMake(x, y, w, h);
    
    w = 36;
    x = x - w;
    self.prevBtn.frame = CGRectMake(x, 0, w, h);
    
    x = CGRectGetMaxX(self.titleLabel.frame);
    self.nextBtn.frame = CGRectMake(x, 0, w, h);
    
    [self.rightBtn sizeToFit];
    w = self.rightBtn.hz_width;
    x = self.hz_width - w - 14;
    self.rightBtn.frame = CGRectMake(x, y, w, h);
}

-(void)setTitleModel:(YZHUICalendarTitleModel *)titleModel
{
    _titleModel = titleModel;
    self.titleLabel.text = titleModel.title;
    [self _updateLayout];
//    [self.rightBtn setTitle:titleModel.rightTitle forState:UIControlStateNormal];
}

@end
