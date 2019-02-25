//
//  YZHUIPopTableViewCell.m
//  YZHUIPopViewDemo
//
//  Created by yuan on 2018/8/27.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHUIPopTableViewCell.h"

@interface YZHUIPopTableViewCell ()

/* <#注释#> */
@property (nonatomic, strong) UIView *subContentView;

@end

@implementation YZHUIPopTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupChildView];
    }
    return self;
}

-(void)_setupChildView
{
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self _layoutSubContentView];
}

-(void)_layoutSubContentView
{
    if (self.subContentView) {
        self.subContentView.frame = self.bounds;
    }
}

#pragma mark YZHUIPopCellProtocol
-(UIView*)subContentView
{
    return _subContentView;
}

-(void)addSubContentView:(UIView*)subContentView
{
    if (self.subContentView != subContentView) {
        [self.subContentView removeFromSuperview];
        self.subContentView = subContentView;
        if (subContentView) {
            [self.contentView addSubview:subContentView];
        }
    }
}

@end
