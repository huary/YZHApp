//
//  YZHURLSessionUploader.m
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHURLSessionUploader.h"
#import "YZHAsyncTaskManager.h"
#import "YZHSyncTaskManager.h"

@interface YZHURLSessionUploader ()

@property (nonatomic, strong) YZHTaskManager *taskManager;

@end

@implementation YZHURLSessionUploader

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
    self.asyncUploadTask = NO;
}

-(YZHTaskManager*)taskManager
{
    if (_taskManager == nil) {
        if (self.asyncUploadTask) {
            _taskManager = [[YZHAsyncTaskManager alloc] init];
        }
        else {
            _taskManager = [[YZHSyncTaskManager alloc] init];
        }
    }
    return _taskManager;
}

#if YZHTTP
-(void)addPostFile:(NSString*)url
            params:(NSDictionary*)params
          fileData:(NSData*)fileData
          fileName:(NSString*)fileName
          mimeType:(NSString*)mimeType
          progress:(httpManagerProgressBlock)progressBlock
           success:(httpManagerSuccessBlock)successBlock
           failure:(httpManagerFailureBlock)failureBlcok
{
    WEAK_SELF(weakSelf);
    [self.taskManager addTaskBlock:^id(YZHTaskManager *taskManager) {
        return [weakSelf _httpPostFile:url params:params fileData:fileData fileName:fileName mimeType:mimeType progress:progressBlock success:successBlock failure:failureBlcok];
    } restartBlock:nil stopBlock:nil forKey:url cancelPrev:YES];
}

-(void)addUploadFile:(NSString*)url
            fromFile:(NSString*)filePath
            progress:(httpManagerProgressBlock)progressBlock
          completion:(httpManagerSuccessBlock)completionBlock
{
    WEAK_SELF(weakSelf);
    [self.taskManager addTaskBlock:^id(YZHTaskManager *taskManager) {
        return [weakSelf _httpUploadFile:url fromFile:filePath progress:progressBlock completion:completionBlock];
    } restartBlock:nil stopBlock:nil forKey:url cancelPrev:YES];
}


-(void)addUploadFile:(NSString*)url
            fromData:(NSData*)data
            progress:(httpManagerProgressBlock)progressBlock
          completion:(httpManagerSuccessBlock)completionBlock
{
    WEAK_SELF(weakSelf);
    [self.taskManager addTaskBlock:^id(YZHTaskManager *taskManager) {
        return [weakSelf _httpUploadFile:url fromData:data progress:progressBlock completion:completionBlock];
    } restartBlock:nil stopBlock:nil forKey:url cancelPrev:YES];
}




-(NSURLSessionTask*)_httpPostFile:(NSString*)url
                           params:(NSDictionary*)params
                         fileData:(NSData*)fileData
                         fileName:(NSString*)fileName
                         mimeType:(NSString*)mimeType
                         progress:(httpManagerProgressBlock)progressBlock
                          success:(httpManagerSuccessBlock)successBlock
                          failure:(httpManagerFailureBlock)failureBlcok
{
    return [[YZHttpManager httpManager] httpPostFile:url params:params fileData:fileData fileName:fileName mimeType:mimeType progress:progressBlock success:^(id result) {
        [self.taskManager notifyTaskFinishForKey:url cancelRetain:NO];
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        [self.taskManager notifyTaskFinishForKey:url cancelRetain:NO];
        if (failureBlcok) {
            failureBlcok(error);
        }
    }];
}

-(NSURLSessionTask*)_httpUploadFile:(NSString*)url
                           fromFile:(NSString*)filePath
                           progress:(httpManagerProgressBlock)progressBlock
                         completion:(httpManagerSuccessBlock)completionBlock
{
    return [[YZHttpManager httpManager] httpUpload:url fromFile:filePath progress:progressBlock completion:^(id result) {
        [self.taskManager notifyTaskFinishForKey:url cancelRetain:NO];
        if (completionBlock) {
            completionBlock(result);
        }
    }];
}

-(NSURLSessionTask*)_httpUploadFile:(NSString*)url
                           fromData:(NSData*)data
                           progress:(httpManagerProgressBlock)progressBlock
                         completion:(httpManagerSuccessBlock)completionBlock
{
    return [[YZHttpManager httpManager] httpUpload:url fromData:data progress:progressBlock completion:^(id result) {
        [self.taskManager notifyTaskFinishForKey:url cancelRetain:NO];
        if (completionBlock) {
            completionBlock(result);
        }
    }];
}
#endif

-(void)cancelDownloadFor:(NSString*)url
{
    [self.taskManager notifyTaskFinishForKey:url cancelRetain:NO];
}

-(void)cancelAllDownloadTask
{
    [self.taskManager cancelAllTask];
}


@end
