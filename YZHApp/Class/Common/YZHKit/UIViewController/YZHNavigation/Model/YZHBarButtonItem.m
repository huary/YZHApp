//
//  YZHBarButtonItem.m
//  yzy
//
//  Created by yuan on 2018/2/7.
//  Copyright © 2018年 yuan. All rights reserved.
//

#if 0
#import "YZHBarButtonItem.h"
#import <objc/message.h>

@interface YZHBarButtonItem()
@property (nonatomic, weak) id customTarget;
@property (nonatomic, assign) SEL customAction;
@end

@implementation YZHBarButtonItem

-(instancetype)initWithCustomView:(UIView *)customView target:(id)target action:(SEL)action;
{
    self = [super initWithCustomView:customView];
    if (self) {
        self.target = self;
        self.action = @selector(_barButtonAction:);
        
        self.customTarget = target;
        self.customAction = action;
    }
    return self;
}

-(void)_barButtonAction:(UIBarButtonItem*)barButtonItem
{
    UIView *customView = barButtonItem.customView;
    ((void (*)(id, SEL, UIView *))(void *) objc_msgSend)(self.customTarget, self.customAction, customView);
}

@end
#endif
