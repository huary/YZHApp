//
//  YZHURLSessionnDownloader.m
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHURLSessionnDownloader.h"
#import "YZHAsyncTaskManager.h"
#import "YZHSyncTaskManager.h"

@interface YZHURLSessionnDownloader ()

/* <#注释#> */
@property (nonatomic, strong) YZHTaskManager *taskManager;


@end

@implementation YZHURLSessionnDownloader

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
}

-(YZHTaskManager*)taskManager
{
    if (_taskManager == nil) {
        if (self.asyncDownloadTask) {
            _taskManager = [[YZHAsyncTaskManager alloc] init];
        }
        else {
            _taskManager = [[YZHSyncTaskManager alloc] init];
        }
    }
    return _taskManager;
}

#if YZHTTP
-(void)addDownload:(NSString*)url
    destinationDir:(NSString*)destinationDir
          progress:(httpManagerProgressBlock)progressBlock
        completion:(httpManagerDownloadCompletionBlock)completionBlock
{
    WEAK_SELF(weakSelf);
    [self.taskManager addTaskBlock:^id(YZHTaskManager *taskManager) {
        return [weakSelf _httpDownload:url destinationDir:destinationDir progress:progressBlock completion:completionBlock];
    } restartBlock:nil stopBlock:nil forKey:url cancelPrev:YES];
}

-(void)addGetData:(NSString *)url
         progress:(httpManagerProgressBlock)progressBlock
       completion:(httpManagerSuccessBlock)completionBlock
{
    WEAK_SELF(weakSelf);
    [self.taskManager addTaskBlock:^id(YZHTaskManager *taskManager) {
        return [weakSelf _httpGet:url progress:progressBlock completion:completionBlock];
    } restartBlock:nil stopBlock:nil forKey:url cancelPrev:YES];
}

-(NSURLSessionDownloadTask*)_httpDownload:(NSString*)url
                           destinationDir:(NSString*)destinationDir
                                 progress:(httpManagerProgressBlock)progressBlock
                               completion:(httpManagerDownloadCompletionBlock)completionBlock
{
    return [[YZHttpManager httpManager] httpDownload:url destinationDir:destinationDir progress:progressBlock completion:^(NSString *filePath) {
        //下载完成通知operation完成，继续下一个下载任务
        [self.taskManager notifyTaskFinishForKey:url cancelRetain:NO];
        if (completionBlock) {
            completionBlock(filePath);
        }
    }];
}

-(NSURLSessionTask*)_httpGet:(NSString*)url progress:(httpManagerProgressBlock)progressBlock completion:(httpManagerSuccessBlock)completionBlock
{
    void (^block)(id data) = ^(id data){
        [self.taskManager notifyTaskFinishForKey:url cancelRetain:NO];
        if (completionBlock) {
            completionBlock(data);
        }
    };
    
    return [[YZHttpManager httpManager] httpGet:url params:nil progress:progressBlock success:^(id result) {
        block(result);
    } failure:^(NSError *error) {
        block(nil);
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
