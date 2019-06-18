//
//  NSHashTable+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "NSHashTable+YZHAdd.h"

@implementation NSHashTable (YZHAdd)

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block
{
//    [self.allObjects enumerateObjectsUsingBlock:block];
    
    id obj = nil;
    NSUInteger idx = 0;
    NSEnumerator *enumerator = self.objectEnumerator;
    while (obj = [enumerator nextObject]) {
        BOOL stop = NO;
        if (block) {
            block(obj, idx, &stop);
        }
        if (stop) {
            break;
        }
        ++idx;
    }
}

@end
