//
//  YZHOrderSet.m
//  YZHApp
//
//  Created by yuan on 2020/9/11.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "YZHOrderSet.h"

@interface YZHOrderSet<KeyType, ObjectType> ()

/** <#注释#> */
@property (nonatomic, strong) NSMutableArray<ObjectType> *list;

/** <#注释#> */
@property (nonatomic, strong) NSMapTable<KeyType, ObjectType> *mapTable;

@end

@implementation YZHOrderSet

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

- (NSMutableArray*)list
{
    if (_list == nil) {
        _list = [NSMutableArray array];
    }
    return _list;
}

- (void)addObject:(id)object forKey:(id)key
{
    id old = [self.mapTable objectForKey:key];
    if (old) {
        return;
    }
    [self.list addObject:object];
    [self.mapTable setObject:object forKey:key];
}

- (void)replaceObject:(id)object forKey:(id)key
{
    id old = [self.mapTable objectForKey:key];
    if (!old) {
        return;
    }
    NSInteger idx = [self.list indexOfObject:old];
    [self.list replaceObjectAtIndex:idx withObject:object];
    [self.mapTable setObject:object forKey:key];
}

- (void)insertObject:(id)object forKey:(id)key atIndex:(NSUInteger)index
{
    id old = [self.mapTable objectForKey:key];
    if (old) {
        return;
    }
    [self.list insertObject:object atIndex:index];
    [self.mapTable setObject:object forKey:key];
}

- (void)removeObjectForKey:(id)key
{
    id old = [self.mapTable objectForKey:key];
    if (!old) {
        return;
    }
    [self.list removeObject:old];
    [self.mapTable removeObjectForKey:key];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    id old = [self.list objectAtIndex:index];
    if (!old) {
        return;
    }
    __block id findKey = nil;
    [self.mapTable enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == old) {
            findKey = key;
            *stop = YES;
        }
    }];
    [self.list removeObject:old];
    [self.mapTable removeObjectForKey:findKey];
}

- (id)objectForKey:(id)key
{
    return [self.mapTable objectForKey:key];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [self.list objectAtIndex:index];
}

- (NSUInteger)count
{
    return self.list.count;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void(^)(id obj, NSUInteger idx, BOOL *stop))block
{
    [self.list enumerateObjectsUsingBlock:block];
}
@end
