//
//  YZHMemoryCache.h
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/5.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YZHMemoryCache;
@protocol YZHMemoryCacheDelegate <NSObject>
- (void)memoryCache:(YZHMemoryCache*)memoryCache willEvictObjects:(NSArray*)objects;
@end

@interface YZHMemoryCache <KeyType, ObjectType> : NSObject

/* <#注释#> */
@property (nonatomic, strong) NSString *name;

/* 默认为0,没有限制 */
@property (nonatomic, assign) NSUInteger totalCostLimit;

/* 默认为0,没有限制, 如果同时设置totalCostLimit和countLimit时，则检测最低满足时*/
@property (nonatomic, assign) NSUInteger countLimit;

/* <#name#> */
@property (nonatomic, weak) id<YZHMemoryCacheDelegate> delegate;

//非单例，定义一共享对象
+(instancetype)shareMemoryCache;

- (ObjectType)objectForKey:(KeyType)key;

- (void)setObject:(ObjectType)obj forKey:(KeyType)key;

- (void)setObject:(ObjectType)obj forKey:(KeyType)key cost:(NSUInteger)cost;

- (void)removeObjectForKey:(KeyType)key;

-(void)removeAllObjects;

-(NSArray*)allCacheValues;

-(NSArray*)allCacheKeys;

@end
