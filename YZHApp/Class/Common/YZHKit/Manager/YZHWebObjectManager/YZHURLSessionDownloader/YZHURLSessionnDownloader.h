//
//  YZHURLSessionnDownloader.h
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#if YZHTTP
#import "YZHttpManager.h"
#endif


@interface YZHURLSessionnDownloader : NSObject

/*
 *异步下载任务还是同步下载任务，默认为NO、同步下载
 *异步下载是指任务异步下载的，
 *同步下载是指任务同步下载的，只能完成了一个再进行下一个任务，
 *但是此方法永远是异步方法，异步、同步只是针对下载提交的任务进行情况。
 */
@property (nonatomic, assign) BOOL asyncDownloadTask;

#if YZHTTP
-(void)addDownload:(NSString*)url
    destinationDir:(NSString*)destinationDir
          progress:(httpManagerProgressBlock)progressBlock
        completion:(httpManagerDownloadCompletionBlock)completionBlock;

-(void)addGetData:(NSString *)url
         progress:(httpManagerProgressBlock)progressBlock
       completion:(httpManagerSuccessBlock)completionBlock;
#endif
-(void)cancelDownloadFor:(NSString*)url;

-(void)cancelAllDownloadTask;
@end
