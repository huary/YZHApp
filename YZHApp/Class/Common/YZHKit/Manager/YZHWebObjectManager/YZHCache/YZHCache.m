//
//  YZHCache.m
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/5.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHCache.h"
#import "YZHUtil.h"

static YZHCache *shareCache_s = nil;

@interface YZHCache ()

/* <#注释#> */


@end

@implementation YZHCache

+(instancetype)shareCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareCache_s = [[YZHCache alloc] init];
    });
    return shareCache_s;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefault];
    }
    return self;
}

-(void)_setupDefault
{
    _memoryCache = [[YZHMemoryCache alloc] init];
    self.memoryCache.name = @"com.YZHCache.memoryCache";
    
    self.diskCache = [[YZHDiskCache alloc] initWithName:@"com.YZHCache.diskCache" directory:[YZHUtil applicationCachesDirectory:nil]];
}

-(void)saveObject:(id)object forKey:(NSString*)key toDisk:(BOOL)toDisk completion:(YZHCacheSaveCompletionBlock)completion
{
    [self saveObject:object data:nil forKey:key toDisk:toDisk completion:completion];
}

-(void)saveObject:(id)object data:(NSData*)data forKey:(NSString*)key toDisk:(BOOL)toDisk completion:(YZHCacheSaveCompletionBlock)completion
{
    [self.memoryCache setObject:object forKey:key];
    if (toDisk) {
        [self.diskCache saveObject:object data:data forFileName:key completion:^(YZHDiskCache *cache, id object, NSString *path, NSString *inFileName) {
            if (completion) {
                completion(self, object);
            }
        }];
    }
    else {
        if (completion) {
            completion(self, object);
        }
    }
}

-(id)queryObjectFromMemoryForKey:(NSString*)key
{
    return [self.memoryCache objectForKey:key];
}

-(NSOperation*)queryObjectForKey:(NSString*)key decode:(YZHDiskCacheDecodeBlock)decode completion:(YZHCacheQueryCompletionBlock)completion
{
    id object = [self.memoryCache objectForKey:key];
    if (object) {
        if (completion) {
            completion(self, object, nil, YZHCacheMemory);
        }
        return nil;
    }
    return [self.diskCache loadObjectForFileName:key decode:decode completion:^(YZHDiskCache *cache, NSData *data, id object, NSString *path, NSString *inFileName) {
        if (completion) {
            completion(self, object, data, YZHCacheDisk);
        }
    }];
}

-(NSOperation*)removeObjectForKey:(NSString*)key removeOnDisk:(BOOL)removeOnDisk completion:(YZHCacheRemoveCompletionBlock)completion
{
    [self.memoryCache removeObjectForKey:key];
    if (!removeOnDisk) {
        return nil;
    }
    return [self.diskCache removeObjectForFileName:key completion:^(YZHDiskCache *cache, NSString *path) {
        if (completion) {
            completion(self, key);
        }
    }];
}

@end
