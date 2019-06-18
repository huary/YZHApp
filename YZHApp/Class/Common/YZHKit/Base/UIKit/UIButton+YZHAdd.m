//
//  UIButton+YZHAdd.m
//  YZHUINavigationController
//
//  Created by yuan on 2018/12/8.
//  Copyright © 2018年 dlodlo. All rights reserved.
//

#import "UIButton+YZHAdd.h"
#import <objc/runtime.h>
#import "YZHKitType.h"
#import "NSObject+YZHAdd.h"

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


-(void)addControlEvent:(UIControlEvents)controlEvents actionBlock:(YZHUIButtonActionBlock)actionBlock
{
    NSMutableArray<YZHUIButtonEventTarget*> *targetList = [self strongReferenceObjectForKey:@(controlEvents)];
    if (targetList == nil) {
        targetList = [NSMutableArray array];
        [self addStrongReferenceObject:targetList forKey:@(controlEvents)];
    }
    YZHUIButtonEventTarget *target = [[YZHUIButtonEventTarget alloc] initWithActionBlock:actionBlock];
    [self addTarget:target action:@selector(buttonAction:) forControlEvents:controlEvents];

    [targetList addObject:target];
}

-(void)removeControlEvent:(UIControlEvents)controlEvents actionBlock:(YZHUIButtonActionBlock)actionBlock
{
    NSMutableArray<YZHUIButtonEventTarget*> *targetList = [self strongReferenceObjectForKey:@(controlEvents)];
    NSMutableArray *removeList = [NSMutableArray array];
    [targetList enumerateObjectsUsingBlock:^(YZHUIButtonEventTarget * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self removeTarget:obj action:@selector(buttonAction:) forControlEvents:controlEvents];
        [removeList addObject:obj];
    }];
    [targetList removeObjectsInArray:removeList];
}


-(YZHUIButtonActionBlock)actionBlockForControlEvent:(UIControlEvents)controlEvents
{
    NSMutableArray<YZHUIButtonEventTarget*> *targetList = [self strongReferenceObjectForKey:@(controlEvents)];
    if (IS_AVAILABLE_NSSET_OBJ(targetList)) {
        return [targetList firstObject].actionBlock;
    }
    return NULL;
}

@end
