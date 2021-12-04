//
//  YZHCache.h
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/5.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHDiskCache.h"
#import "YZHMemoryCache.h"

typedef NS_ENUM(NSInteger, YZHCacheType)
{
    YZHCacheNone    = -1,
    YZHCacheMemory  = 0,
    YZHCacheDisk    = 1,
};


@class YZHCache;
typedef void(^YZHCacheSaveCompletionBlock)(YZHCache *cache, id object, NSString *filePath);
typedef void(^YZHCacheQueryCompletionBlock)(YZHCache *cache, id object, NSData *data, NSString *filePath, YZHCacheType cacheType);
typedef void(^YZHCacheRemoveCompletionBlock)(YZHCache *cache, NSString *key, NSString *filePath);


@interface YZHCache : NSObject

+(instancetype)sharedCache;

@property (nonatomic, strong, readonly) YZHMemoryCache *memoryCache;

/* <#注释#> */
@property (nonatomic, strong) YZHDiskCache *diskCache;

-(void)saveObject:(id)object forKey:(NSString*)key toDisk:(BOOL)toDisk completion:(YZHCacheSaveCompletionBlock)completion;

-(void)saveObject:(id)object data:(NSData*)data forKey:(NSString*)key toDisk:(BOOL)toDisk completion:(YZHCacheSaveCompletionBlock)completion;

-(id)queryObjectFromMemoryForKey:(NSString*)key;

-(NSOperation*)queryObjectForKey:(NSString*)key decode:(YZHDiskCacheDecodeBlock)decode completion:(YZHCacheQueryCompletionBlock)completion;

//-(NSOperation*)queryObjectForKey:(NSString*)key shouldLoad:(YZHDiskCacheShouldLoadToMemoryBlock)shouldLoad decode:(YZHDiskCacheDecodeBlock)decode completion:(YZHCacheQueryCompletionBlock)completion;

-(NSOperation*)removeObjectForKey:(NSString*)key removeOnDisk:(BOOL)removeOnDisk completion:(YZHCacheRemoveCompletionBlock)completion;

@end
