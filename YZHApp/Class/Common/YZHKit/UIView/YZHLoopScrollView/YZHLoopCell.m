//
//  YZHLoopCell.m
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/5.
//  Copyright © 2019 yuan. All rights reserved.
//

#import "YZHLoopCell.h"



@implementation YZHLoopCell

@synthesize contentView = _contentView;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self pri_setupLoopCellChildView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = CGRectInset(self.bounds, self.contentInsets.x, self.contentInsets.y);
}

- (UIView*)contentView
{
    if (_contentView == nil) {
        _contentView = [UIView new];
    }
    return _contentView;
}

-(void)pri_setupLoopCellChildView
{
    [self addSubview:self.contentView];    
    self.contentView.frame = CGRectInset(self.bounds, self.contentInsets.x, self.contentInsets.y);
}


- (void)setModel:(id<YZHLoopCellModelProtocol>)model
{
    _model = model;
}


@end
