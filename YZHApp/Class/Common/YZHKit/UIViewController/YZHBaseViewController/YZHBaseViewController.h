//
//  YZHBaseUIViewController.h
//  YXX
//
//  Created by yuan on 2017/4/24.
//  Copyright © 2017年 yuanzh. All rights reserved.
//

#import "YZHViewController.h"

@interface YZHBaseViewController : YZHViewController

@property (nonatomic, strong, readonly) UIView *contentView;

//@property (nonatomic, assign, readonly) CGSize contentViewSize;

+(CGSize)contentViewSize;

@end
