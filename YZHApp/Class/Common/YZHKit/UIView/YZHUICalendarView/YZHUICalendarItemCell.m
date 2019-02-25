//
//  YZHUICalendarItemCell.m
//  YZHUICalendarViewDemo
//
//  Created by yuan on 2018/8/8.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHUICalendarItemCell.h"
#import "YZHUIButton.h"
#import "YZHKitType.h"
#import "UIView+YZHAdd.h"
#import "YZHUIGraphicsImage.h"

const static CGFloat dotH_s = 5.0;

@interface YZHUICalendarItemCell ()

/* <#注释#> */
@property (nonatomic, strong) YZHUIButton *item;

@end

@implementation YZHUICalendarItemCell

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
    CGFloat w = 30;
    CGFloat h = w;
    CGFloat x = (self.width - w)/2;
    CGFloat y = (self.height - h)/2;
    CGFloat dotH = dotH_s;
    
    UIImage *bgImage = [YZHUIGraphicsImageContext createImageWithSize:CGSizeMake(w, h) cornerRadius:h/2 borderWidth:0 borderColor:nil backgroundColor:RGB_WITH_INT_WITH_NO_ALPHA(0x388CFF)];
    
    self.item = [YZHUIButton buttonWithType:UIButtonTypeCustom];
    self.item.userInteractionEnabled = NO;
    self.item.layoutStyle = NSButtonLayoutStyleCustomInset;
    self.item.titleEdgeInsetsRatio = UIEdgeInsetsMake(dotH, 0, dotH, 0);
    self.item.imageEdgeInsetsRatio = UIEdgeInsetsMake(h - dotH, 0, 0, 0);
    
    self.item.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.item.imageView.contentMode = UIViewContentModeCenter;
    [self.item setBackgroundImage:bgImage forState:UIControlStateSelected];
    self.item.frame = CGRectMake(x, y, w, h);
    [self.contentView addSubview:self.item];
}

-(void)_updateDot
{
    if (self.itemModel.haveBottomDot) {
        CGFloat dotH = dotH_s;
        UIImage *image = [YZHUIGraphicsImageContext createImageWithSize:CGSizeMake(dotH, dotH) cornerRadius:dotH/2 borderWidth:0 borderColor:nil backgroundColor:RGB_WITH_INT_WITH_NO_ALPHA(0x388CFF)];
         [self.item setImage:image forState:UIControlStateNormal];
    }
    else {
        [self.item setImage:nil forState:UIControlStateNormal];
    }
}

-(void)setItemModel:(YZHCalendarItemModel *)itemModel
{
    _itemModel = itemModel;
    self.item.titleLabel.font = itemModel.textModel.font;
    [self.item setTitle:itemModel.textModel.text forState:UIControlStateNormal];
    [self.item setTitleColor:itemModel.textModel.textColor forState:UIControlStateNormal];
    [self.item setTitleColor:itemModel.textModel.selectedTextColor forState:UIControlStateSelected];
    self.item.selected = itemModel.isSelected;
    [self _updateDot];
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (self.itemModel.canSelected) {
        self.item.selected = selected;
    }
}

@end
