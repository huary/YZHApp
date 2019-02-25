//
//  YZHDiskCache.h
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/5.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YZHDiskCache;

//下面的path是存储路径，inFileName是输入的fileName，不一定是存储的fileName
typedef NSData*(^YZHDiskCacheEncodeBlock)(YZHDiskCache *cache, id object, NSString *path, NSString *inFileName);
typedef id(^YZHDiskCacheDecodeBlock)(YZHDiskCache *cache, NSData *data, NSString *path, NSString *inFileName);

typedef void(^YZHDiskCacheSaveCompletionBlock)(YZHDiskCache *cache, id object, NSString *path, NSString *inFileName);
typedef void(^YZHDiskCacheLoadCompletionBlock)(YZHDiskCache *cache, NSData *data, id object, NSString *path, NSString *inFileName);

typedef void(^YZHDiskCacheRemoveCompletionBlock)(YZHDiskCache *cache, NSString *path);
typedef void(^YZHDiskCacheDirectoryEnumeratorBlock)(YZHDiskCache *cache, NSDirectoryEnumerator *directoryEnumerator);
typedef void(^YZHDiskCacheCheckExistsCompletionBlock)(YZHDiskCache *cache, NSString *path, BOOL exists);


/****************************************************
 *YZHDiskCacheObjectCodingProtocol
 ****************************************************/
@protocol YZHDiskCacheObjectCodingProtocol <NSObject>

/* <#注释#> */
@property (nonatomic, copy) YZHDiskCacheEncodeBlock encodeBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHDiskCacheDecodeBlock decodeBlock;

@end

@interface YZHDiskCache : NSObject

-(instancetype)initWithName:(NSString*)name;

-(instancetype)initWithName:(NSString *)name directory:(NSString*)directory;

/* <#注释#> */
@property (nonatomic, strong, readonly) NSString *name;

/* <#name#> */
@property (nonatomic, assign) BOOL syncDoCompletion;

-(NSString*)fullCacheDirectory;

-(void)createCacheDirectory;

-(void)saveObject:(id)object forFileName:(NSString*)fileName completion:(YZHDiskCacheSaveCompletionBlock)completion;

-(void)saveObject:(id)object data:(NSData*)data forFileName:(NSString*)fileName completion:(YZHDiskCacheSaveCompletionBlock)completion;

-(void)moveItemAtPath:(NSString*)path toPath:(NSString*)toPath;

//默认异步返回,可以被cancel的
-(NSOperation*)addExecuteBlock:(id(^)(YZHDiskCache *cache))block completion:(void(^)(YZHDiskCache *cache, id retObj))completion;

-(NSOperation*)addExecuteBlock:(id(^)(YZHDiskCache *cache))block syncCompletion:(BOOL)sync completion:(void(^)(YZHDiskCache *cache, id retObj))completion;

//可以cancel
-(NSOperation*)loadObjectForFileName:(NSString*)fileName decode:(YZHDiskCacheDecodeBlock)decode completion:(YZHDiskCacheLoadCompletionBlock)completion;

//可以cancel
-(NSOperation*)removeObjectForFileName:(NSString*)fileName completion:(YZHDiskCacheRemoveCompletionBlock)completion;

@end
