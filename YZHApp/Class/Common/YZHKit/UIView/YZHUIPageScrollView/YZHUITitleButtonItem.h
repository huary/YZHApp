//
//  YZHUITitleButtonItem.h
//  YZHUIPageScrollViewDemo
//
//  Created by yuan on 16/12/8.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YZHUITitleButtonItem : UIControl

+(id)buttonItemWithTitle:(NSString*)title;

@property (nonatomic, strong,readonly) UILabel *titleLabel;

@end
