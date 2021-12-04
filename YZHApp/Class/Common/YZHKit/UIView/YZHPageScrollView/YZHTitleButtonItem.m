//
//  YZHTitleButtonItem.m
//  YZHPageScrollViewDemo
//
//  Created by yuan on 16/12/8.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "YZHTitleButtonItem.h"

@interface YZHTitleButtonItem ()
{
    UILabel *_titleLabel;
}
@end

@implementation YZHTitleButtonItem

+(id)buttonItemWithTitle:(NSString*)title
{
    YZHTitleButtonItem *buttonItem = [[YZHTitleButtonItem alloc] init];
    buttonItem.titleLabel.text = title;
    return buttonItem;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.titleLabel.frame = self.bounds;
}

-(UILabel*)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
