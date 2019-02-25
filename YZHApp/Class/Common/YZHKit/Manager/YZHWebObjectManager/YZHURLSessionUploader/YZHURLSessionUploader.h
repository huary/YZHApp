//
//  YZHURLSessionUploader.h
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/7.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#if YZHTTP
#import "YZHttpManager.h"
#endif

@interface YZHURLSessionUploader : NSObject

/*
 *异步上传任务还是同步上传任务，默认为NO、同步上传
 *异步上传是指任务异步上传的，
 *同步上传是指任务同步上传的，只能完成了一个再进行下一个任务，
 *但是此方法永远是异步方法，异步、同步只是针对上传提交的任务进行情况。
 */
@property (nonatomic, assign) BOOL asyncUploadTask;

#if YZHTTP
-(void)addPostFile:(NSString*)url
            params:(NSDictionary*)params
          fileData:(NSData*)fileData
          fileName:(NSString*)fileName
          mimeType:(NSString*)mimeType
          progress:(httpManagerProgressBlock)progressBlock
           success:(httpManagerSuccessBlock)successBlock
           failure:(httpManagerFailureBlock)failureBlcok;

-(void)addUploadFile:(NSString*)url
            fromFile:(NSString*)filePath
            progress:(httpManagerProgressBlock)progressBlock
          completion:(httpManagerSuccessBlock)completionBlock;


-(void)addUploadFile:(NSString*)url
            fromData:(NSData*)data
            progress:(httpManagerProgressBlock)progressBlock
          completion:(httpManagerSuccessBlock)completionBlock;
#endif
-(void)cancelDownloadFor:(NSString*)url;

-(void)cancelAllDownloadTask;
@end
