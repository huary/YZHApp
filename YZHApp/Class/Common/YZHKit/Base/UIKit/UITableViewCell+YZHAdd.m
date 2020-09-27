//
//  UITableViewCell+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UITableViewCell+YZHAdd.h"
#import <objc/runtime.h>
#import "NSObject+YZHAdd.h"
#import "YZHKitType.h"


@implementation UITableViewCell (YZHAdd)

-(void)setHz_indexPath:(NSIndexPath *)hz_indexPath
{
    [self hz_addWeakReferenceObject:hz_indexPath forKey:TYPE_STR(hz_indexPath)];
}

-(NSIndexPath*)hz_indexPath
{
    return [self hz_weakReferenceObjectForKey:TYPE_STR(hz_indexPath)];
}

-(void)hz_setSeparatorLineInsets:(UIEdgeInsets)insets
{
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:insets];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:insets];
    }
}


@end
