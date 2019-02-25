//
//  NSObject+YZHAddForKVO.m
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "NSObject+YZHAddForKVO.h"
#import <objc/runtime.h>

@implementation NSObject (YZHAddForKVO)

-(void)addKVOObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    if (![self _observerForObserver:observer KeyPath:keyPath]) {
        [self addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

-(void)removeKVOObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    if ([self _observerForObserver:observer KeyPath:keyPath]) {
        [self removeObserver:observer forKeyPath:keyPath context:context];
    }
}

-(BOOL)_observerForObserver:(id)observer KeyPath:(NSString*)keyPath
{
    id info = self.observationInfo;
    NSArray *array = [info valueForKey:@"_observances"];
    for (id objc in array) {
        id properties = [objc valueForKeyPath:@"_property"];
        id observerTmp = [objc valueForKeyPath:@"_observer"];
        
        NSString *keyPathTmp = [properties valueForKeyPath:@"_keyPath"];
        if ([keyPathTmp isEqualToString:keyPath] && [observerTmp isEqual:observer]) {
            return YES;
        }
    }
    return NO;
}

@end
