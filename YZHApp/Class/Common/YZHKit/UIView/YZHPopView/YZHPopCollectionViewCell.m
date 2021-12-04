//
//  YZHPopCollectionViewCell.m
//  YZHPopViewDemo
//
//  Created by yuan on 2018/9/10.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHPopCollectionViewCell.h"

@interface YZHPopCollectionViewCell ()

@property (nonatomic, strong) UIView *subContentView;

@end

@implementation YZHPopCollectionViewCell

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
