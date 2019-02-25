//
//  UIButton+YZHAdd.m
//  YZHUINavigationController
//
//  Created by yuan on 2018/12/8.
//  Copyright © 2018年 dlodlo. All rights reserved.
//

#import "UIButton+YZHAdd.h"
#import <objc/runtime.h>

/****************************************************
 *YZHUIButtonEventTarget
 ****************************************************/
@interface YZHUIButtonEventTarget : NSObject

/* <#注释#> */
@property (nonatomic, copy) YZHUIButtonActionBlock actionBlock;

@end

@implementation YZHUIButtonEventTarget

-(instancetype)initWithActionBlock:(YZHUIButtonActionBlock)actionBlock
{
    self = [super init];
    if (self) {
        self.actionBlock = actionBlock;
    }
    return self;
}

-(void)buttonAction:(UIButton*)button
{
    if (self.actionBlock) {
        self.actionBlock(button);
    }
}

@end




/****************************************************
 *UIButton (YZHAdd)
 ****************************************************/
@implementation UIButton (YZHAdd)
-(void)setEventTarget:(YZHUIButtonEventTarget*)eventTarget
{
    objc_setAssociatedObject(self, @selector(eventTarget), eventTarget, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(YZHUIButtonEventTarget*)eventTarget
{
    return objc_getAssociatedObject(self, _cmd);
}


-(void)addControlEvent:(UIControlEvents)controlEvents actionBlock:(YZHUIButtonActionBlock)actionBlock
{
    YZHUIButtonEventTarget *target = [[YZHUIButtonEventTarget alloc] initWithActionBlock:actionBlock];
    self.eventTarget = target;
    [self addTarget:target action:@selector(buttonAction:) forControlEvents:controlEvents];
}

-(YZHUIButtonActionBlock)actionBlock
{
    return self.eventTarget.actionBlock;
}

@end
