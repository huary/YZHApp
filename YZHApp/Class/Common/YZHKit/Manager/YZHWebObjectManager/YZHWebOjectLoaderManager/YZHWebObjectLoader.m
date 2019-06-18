//
//  YZHWebObjectLoader.m
//  YZHApp
//
//  Created by yuan on 2019/1/13.
//  Copyright © 2019年 yuanzh. All rights reserved.
//


#import "YZHWebObjectLoader.h"
#import "YZHKitMacro.h"
#import "YZHUtil.h"
#if YZHTTP
#import "YZHttpManager.h"
#endif

/****************************************************
 *YZHWebObjectOperation
 ****************************************************/
@interface YZHWebObjectLoadOperation ()

/* <#注释#> */
@property (nonatomic, strong) NSMutableDictionary<NSString*,NSNumber *> *cancelInfo;

@end

@implementation YZHWebObjectLoadOperation

-(NSMutableDictionary<NSString*,NSNumber *>*)cancelInfo
{
    if (_cancelInfo == nil) {
        _cancelInfo = [NSMutableDictionary dictionary];
    }
    return _cancelInfo;
}

-(void)cancelForURL:(NSString*)url
{
    [self.cacheOperation cancel];
    [self.task cancel];
    self.task = nil;
    [self.webTaskManager notifyTaskFinishForKey:url cancelRetain:NO];
    if (url) {
        [self.cancelInfo setObject:@(YES) forKey:url];
    }
}

-(BOOL)isCancelForURL:(NSString*)url
{
    if (url) {
        return [self.cancelInfo objectForKey:url] ? YES : NO;
    }
    return NO;
}

@end

@implementation YZHWebObjectLoader

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefault];
    }
    return self;
}

-(instancetype)initWithCache:(YZHCache*)cache taskManager:(YZHTaskManager*)taskManager
{
    self = [super init];
    if (self) {
        _cache = cache;
        _taskManager = taskManager;
    }
    return self;
}

-(void)_setupDefault
{
    if (_cache == nil) {
        YZHCache *cache = [[YZHCache alloc] init];
        cache.diskCache = [[YZHDiskCache alloc] initWithName:@"com.YZHWebObjectLoader.diskcache"];
        _cache = cache;
    }
    if (_taskManager == nil) {
        YZHOperationManager *operationManager = [[YZHOperationManager alloc] initWithExecutionOrder:YZHOperationExecutionOrderFIFO];
        operationManager.maxConcurrentOperationCount = 6;
        YZHTaskManager *taskManager = [[YZHTaskManager alloc] initWithOperationManager:operationManager sync:YES];
        taskManager.maxConcurrentRunningTaskCnt = operationManager.maxConcurrentOperationCount;
        _taskManager = taskManager;
    }
}


-(YZHWebObjectLoadOperation*)loadWebObject:(NSString*)url
                                decode:(YZHDiskCacheDecodeBlock)decode
                       cacheCompletion:(YZHWebObjectCacheLoadCompletionBlock)cacheCompletionBlock
                              progress:(YZHWebObjectLoadProgressBlock)progressBlock
                         webCompletion:(YZHWebObjectWebLoadCompletionBlock)webCompletionBlock
{
    WEAK_SELF(weakSelf);
    
    YZHWebObjectLoadOperation *loadOperation = [[YZHWebObjectLoadOperation alloc] init];
    
    NSString *key = [self _cacheKeyFor:url];
    
    NSOperation *operation = [self.cache queryObjectForKey:key decode:decode completion:^(YZHCache *cache, id object, NSData *data, NSString *filePath, YZHCacheType cacheType) {
        BOOL continueWebLoad = YES;
        if (cacheCompletionBlock) {
            continueWebLoad = cacheCompletionBlock(weakSelf, loadOperation, url, object, data, filePath, cacheType);
        }
        if (!continueWebLoad) {
            return ;
        }
        [weakSelf.taskManager addTaskBlock:^id(YZHTaskManager *taskManager) {
            NSURLSessionTask *task = [weakSelf _httpLoad:url
                                           loadOperation:loadOperation
                                                progress:progressBlock
                                              completion:webCompletionBlock];
            loadOperation.task = task;
            return task;
        } restartBlock:nil stopBlock:nil forKey:url cancelPrev:YES];
    }];
    loadOperation.cacheOperation = operation;
    loadOperation.webTaskManager = self.taskManager;
    
    return loadOperation;
}

//统一进行一次md5
-(NSString*)_cacheKeyFor:(NSString*)url
{
    NSString *key = nil;
    if (IS_AVAILABLE_NSSTRNG(url.cacheKey)) {
        key = url.cacheKey;
    }
    else {
        if (url.cacheKeyBlock) {
            key = url.cacheKeyBlock(url, self);
        }
        if (!IS_AVAILABLE_NSSTRNG(key)) {
            key = [YZHUtil MD5ForText:key lowercase:YES];
        }
    }
    return key;
}


-(NSURLSessionTask*)_httpLoad:(NSString*)url
                loadOperation:(YZHWebObjectLoadOperation*)loadOperation
                     progress:(YZHWebObjectLoadProgressBlock)progressBlock
                   completion:(YZHWebObjectWebLoadCompletionBlock)completionBlock
{
#if YZHTTP
    return [[YZHttpManager httpManager] httpDownload:url destinationDir:nil progress:^(NSProgress *progress) {
        if (progressBlock) {
            progressBlock(self, loadOperation, url, progress);
        }
    } completion:^(NSString *filePath) {
        NSLog(@"filePath=%@",filePath);
        NSData *data = nil;
        [self _webLoad:url loadOperation:loadOperation data:data filePath:filePath completion:completionBlock];
    }];
#else
    return nil;
#endif
}

-(void)_webLoad:(NSString*)url
  loadOperation:(YZHWebObjectLoadOperation*)loadOperation
           data:(NSData*)data
       filePath:(NSString*)filePath
     completion:(YZHWebObjectWebLoadCompletionBlock)completionBlock
{
    [self.taskManager notifyTaskFinishForKey:url cancelRetain:NO];
    //这里按原来的url来计算key，不用回调里面的url
    NSString *key = [self _cacheKeyFor:url];
    
    NSString *fromPath = filePath;
    
    YZHWebObjectWebLoadCompletionCacheBlock cacheBlock = ^(YZHWebObjectLoader *webObjectLoader, YZHWebObjectLoadOperation *loadOperation, NSString *url, id object, NSData *data, NSString *filePath) {
        if (object || data) {
            [self.cache saveObject:object data:data forKey:key toDisk:YES completion:nil];
        }
        else if ([filePath isAbsolutePath]) {
            [self.cache.diskCache addExecuteBlock:^id(YZHDiskCache *cache) {
                [YZHUtil checkAndCreateDirectory:[filePath stringByDeletingLastPathComponent]];
                [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:filePath error:NULL];
                return nil;
            } completion:nil];
        }
    };
    
    //回传进行某种转换
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        if (completionBlock) {
            NSData *newData = data;
            if (!IS_AVAILABLE_DATA(newData) && [filePath isAbsolutePath]) {
                newData = [NSData dataWithContentsOfFile:filePath];
            }
            completionBlock(self, loadOperation, url, newData, filePath, cacheBlock);
        }
    });
}

-(NSString*)cacheKeyForUrl:(NSString*)url
{
    return [self _cacheKeyFor:url];
}

-(void)saveObject:(id)object data:(NSData*)data forUrl:(NSString*)url
{
    NSString *key = [self _cacheKeyFor:url];
    [self.cache saveObject:object data:data forKey:key toDisk:YES completion:nil];
}

@end
