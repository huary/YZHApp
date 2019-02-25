//
//  YZHUIHoverActionCell.m
//  YZHUIHoverViewDemo
//
//  Created by yuan on 2017/9/7.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIHoverActionCell.h"

@interface YZHUIHoverActionCell ()

@property (nonatomic, strong) YZHUIButton *actionBtn;

@end

@implementation YZHUIHoverActionCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setUpCellChildView];
    }
    return self;
}

-(void)_setUpCellChildView
{
    self.actionBtn = [[YZHUIButton alloc] init];
    self.actionBtn.userInteractionEnabled = NO;
    self.actionBtn.frame = self.bounds;
//    self.actionBtn.backgroundColor = RAND_COLOR;
    [self.contentView addSubview:self.actionBtn];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.actionBtn.frame = self.bounds;
}

-(void)setActionModel:(YZHHoverActionModel *)actionModel
{
    _actionModel = actionModel;
    actionModel.button = self.actionBtn;
    [self.actionBtn setImage:actionModel.hoverImage forState:UIControlStateNormal];
    [self.actionBtn setTitle:actionModel.hoverTitle forState:UIControlStateNormal];
    if (actionModel.updateBlock) {
        actionModel.updateBlock(actionModel, self.actionBtn);
    }
}

@end
