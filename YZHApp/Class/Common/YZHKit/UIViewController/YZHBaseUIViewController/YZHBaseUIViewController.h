//
//  YZHBaseUIViewController.h
//  YXX
//
//  Created by yuan on 2017/4/24.
//  Copyright © 2017年 gdtech. All rights reserved.
//

#import "YZHUIViewController.h"

@interface YZHBaseUIViewController : YZHUIViewController

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, assign, readonly) CGSize contentViewSize;

+(CGSize)contentViewSize;

@end
