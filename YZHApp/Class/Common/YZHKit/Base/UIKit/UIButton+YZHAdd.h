//
//  UIButton+YZHAdd.h
//  YZHNavigationController
//
//  Created by yuan on 2018/12/8.
//  Copyright © 2018年 dlodlo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^YZHButtonActionBlock)(UIButton *button);

@interface UIButton (YZHAdd)

-(void)hz_addControlEvent:(UIControlEvents)controlEvents actionBlock:(YZHButtonActionBlock)actionBlock;

-(void)hz_removeControlEvent:(UIControlEvents)controlEvents actionBlock:(YZHButtonActionBlock)actionBlock;

-(YZHButtonActionBlock)hz_actionBlockForControlEvent:(UIControlEvents)controlEvents;
@end
