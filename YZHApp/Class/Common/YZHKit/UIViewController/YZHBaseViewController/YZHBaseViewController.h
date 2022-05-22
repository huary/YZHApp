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

//在contentView上进行布局的LayoutTopY值
@property (nonatomic, assign) CGFloat contentViewLayoutTopY;

+(CGSize)contentViewSize;

+(CGFloat)bottomSafeOffY;

@end
