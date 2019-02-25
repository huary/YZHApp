//
//  YZHUIPopCollectionViewCell.m
//  YZHUIPopViewDemo
//
//  Created by yuan on 2018/9/10.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHUIPopCollectionViewCell.h"

@interface YZHUIPopCollectionViewCell ()

@property (nonatomic, strong) UIView *subContentView;

@end

@implementation YZHUIPopCollectionViewCell

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


#pragma mark protocol
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
