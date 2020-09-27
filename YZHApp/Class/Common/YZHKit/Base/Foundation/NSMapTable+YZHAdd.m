//
//  NSMapTable+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "NSMapTable+YZHAdd.h"

@implementation NSMapTable (YZHAdd)

- (void)hz_enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block
{
    if (!block) {
        return;
    }
    id key = nil;
    NSEnumerator *keyEnumerator = self.keyEnumerator;
    while (key = [keyEnumerator nextObject]) {
        id object = [self objectForKey:key];
        
        BOOL stop = NO;
        block(key, object, &stop);
        
        if (stop) {
            break;
        }
    }
}

-(NSArray*)hz_allValues
{
    NSMutableArray *valueList = [NSMutableArray array];
    [self hz_enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj) {
            [valueList addObject:obj];
        }
    }];
    return [valueList copy];
}

-(NSArray*)hz_allKeys
{
    NSMutableArray *keyList = [NSMutableArray array];
    [self hz_enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (key) {
            [keyList addObject:key];
        }
    }];
    return [keyList copy];
}

@end
