//
//  YZHOrderSet.h
//  YZHApp
//
//  Created by yuan on 2020/9/11.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZHOrderMap<KeyType, ObjectType> : NSObject

- (void)addObject:(ObjectType)object forKey:(KeyType)key;

- (void)replaceObject:(ObjectType)object forKey:(KeyType)key;

- (void)addOrReplaceObject:(ObjectType)object forKey:(KeyType)key;

- (void)insertObject:(ObjectType)object forKey:(KeyType)key atIndex:(NSUInteger)index;

- (void)removeObjectForKey:(KeyType)key;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (ObjectType)objectForKey:(KeyType)key;

- (ObjectType)objectAtIndex:(NSUInteger)index;

- (NSUInteger)count;

- (void)enumerateKeysAndObjectsUsingBlock:(void(^)(ObjectType obj, NSUInteger idx, BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
