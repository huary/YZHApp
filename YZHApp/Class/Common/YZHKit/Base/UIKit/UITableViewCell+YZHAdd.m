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

-(void)setIndexPath:(NSIndexPath *)indexPath
{
    [self addWeakReferenceObject:indexPath forKey:TYPE_STR(indexPath)];
}

-(NSIndexPath*)indexPath
{
    return [self weakReferenceObjectForKey:TYPE_STR(indexPath)];
}

-(void)setSeparatorLineInsets:(UIEdgeInsets)insets
{
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:insets];
    }
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:insets];
    }
}


@end
