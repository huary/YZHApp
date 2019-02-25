//
//  UIButton+YZHAdd.h
//  YZHUINavigationController
//
//  Created by yuan on 2018/12/8.
//  Copyright © 2018年 dlodlo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^YZHUIButtonActionBlock)(UIButton *button);

@interface UIButton (YZHAdd)

-(void)addControlEvent:(UIControlEvents)controlEvents actionBlock:(YZHUIButtonActionBlock)actionBlock;

-(YZHUIButtonActionBlock)actionBlock;

@end
