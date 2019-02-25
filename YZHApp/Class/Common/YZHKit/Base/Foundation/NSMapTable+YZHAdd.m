//
//  NSMapTable+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "NSMapTable+YZHAdd.h"

@implementation NSMapTable (YZHAdd)

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block
{
    if (!block) {
        return;
    }
    id key = nil;
    while (key = [self.keyEnumerator nextObject]) {
        id object = [self objectForKey:key];
        
        BOOL stop = NO;
        
        block(key, object, &stop);
        
        if (stop) {
            break;
        }
    }
}

@end
