//
//  YZHWebObjectLoader.m
//  contact
//
//  Created by yuan on 2019/1/13.
//  Copyright © 2019年 gdtech. All rights reserved.
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
@implementation YZHWebObjectOperation

-(void)cancelForURL:(NSString*)url
{
    [self.cacheOperation cancel];
    [self.webTaskManager notifyTaskFinishForKey:url cancelRetain:NO];
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
        YZHTaskOperationManager *operationManager = [[YZHTaskOperationManager alloc] initWithExecutionOrder:YZHTaskOperationExecutionOrderFIFO];
        operationManager.maxConcurrentOperationCount = 6;
        YZHTaskManager *taskManager = [[YZHTaskManager alloc] initWithOperationManager:operationManager sync:YES];
        taskManager.maxConcurrentRunningTaskCnt = operationManager.maxConcurrentOperationCount;
        _taskManager = taskManager;
    }
}


-(YZHWebObjectOperation*)loadWebObject:(NSString*)url
                                decode:(YZHDiskCacheDecodeBlock)decode
                       cacheCompletion:(YZHWebObjectCacheLoadCompletionBlock)cacheCompletionBlock
                              progress:(YZHWebObjectLoadProgressBlock)progressBlock
                         webCompletion:(YZHWebObjectWebLoadCompletionBlock)webCompletionBlock
{
    WEAK_SELF(weakSelf);
    
    YZHWebObjectOperation *loadOperation = [[YZHWebObjectOperation alloc] init];
    
    NSString *key = [self _cacheKeyFor:url];
    NSOperation *operation = [self.cache queryObjectForKey:key decode:decode completion:^(YZHCache *cache, id object, NSData *data, YZHCacheType cacheType) {
        BOOL continueWebLoad = YES;
        if (cacheCompletionBlock) {
            continueWebLoad = cacheCompletionBlock(weakSelf, url, object, data, cacheType);
        }
        if (!continueWebLoad) {
            return ;
        }
        [weakSelf.taskManager addTaskBlock:^id(YZHTaskManager *taskManager) {
            return [weakSelf _httpGet:url progress:progressBlock completion:webCompletionBlock];
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
            key = url.cacheKey;
        }
        if (!IS_AVAILABLE_NSSTRNG(key)) {
            key = url;
        }
    }
    return [YZHUtil MD5ForText:key lowercase:YES];
}

-(NSURLSessionTask*)_httpGet:(NSString*)url
                    progress:(YZHWebObjectLoadProgressBlock)progressBlock
                  completion:(YZHWebObjectWebLoadCompletionBlock)completionBlock
{
#if YZHTTP
    return [[YZHttpManager httpManager] httpGet:url params:nil progress:^(NSProgress *progress) {
        if (progressBlock) {
            progressBlock(self, url, progress);
        }
    } success:^(id result) {
        [self _webLoad:url data:result completion:completionBlock];
    } failure:^(NSError *error) {
        [self _webLoad:url data:nil completion:completionBlock];
    }];
#else
    return nil;
#endif
}

-(void)_webLoad:(NSString*)url data:(NSData*)data completion:(YZHWebObjectWebLoadCompletionBlock)completionBlock
{
    [self.taskManager notifyTaskFinishForKey:url cancelRetain:NO];
    //这里按原来的url来计算key，不用回调里面的url
    NSString *key = [self _cacheKeyFor:url];
    YZHWebObjectWebLoadCompletionCallbackBlock callback = ^(NSString *url, id object, NSData *data) {
        [self.cache saveObject:object data:data forKey:key toDisk:YES completion:nil];
    };
    
    //回传进行某种转换
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        if (completionBlock) {
            completionBlock(self, url, data, callback);
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


//-(NSString*)saveDataPathForURL:(NSString*)url
//{
//    NSString *key = [self _cacheKeyFor:url];
//    NSString *directory = [self.cache.diskCache fullCacheDirectory];
//    [Utils checkAndCreateDirectory:directory];
//    return [directory stringByAppendingPathComponent:key];
//}

@end
