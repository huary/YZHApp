//
//  YZHttpManager.m
//  YZHttpManager
//
//  Created by yuan on 16/12/22.
//  Copyright © 2016年 yzh. All rights reserved.
//

#import "YZHttpManager.h"
#if AFN
#import "AFHTTPSessionManager.h"
#endif

#define DEFAULT_HTTP_SESSION_REQUEST_TIME_OUT                    (8)
#define DEFAULT_HTTP_SESSION_REQUEST_TIME_OUT_KEY                @"NetWorkRequestTimeOutInterval"
#define DEFAULT_HTTPS_SIGNED_PUBLIC_KEY_CER_FILE_NAME            @"httpsSignedPublicKeyCer.cer"
#define DEFAULT_HTTPS_SIGNED_PUBLIC_KEY_CER_FILE_NAME_KEY        @"httpsSignedPublicKeyCerFileName"

@interface YZHttpManager () <NSCopying>

@end


static YZHttpManager *yzHttpManager_s = NULL;

@implementation YZHttpManager

+(instancetype)httpManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        yzHttpManager_s = [[super allocWithZone:NULL] init];
    });
    return yzHttpManager_s;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [YZHttpManager httpManager];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    return [YZHttpManager httpManager];
}

#if AFN
-(AFHTTPSessionManager*)createHttpSessionManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSTimeInterval timeOutInterval = [[[[NSBundle mainBundle] infoDictionary] objectForKey:DEFAULT_HTTP_SESSION_REQUEST_TIME_OUT_KEY] floatValue];
    if (timeOutInterval <= 0 ) {
        timeOutInterval = DEFAULT_HTTP_SESSION_REQUEST_TIME_OUT;
    }
    manager.requestSerializer.timeoutInterval = timeOutInterval;
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json",@"text/html", @"text/plain",nil];
    return manager;
}

-(AFHTTPSessionManager*)httpSessionManager
{
    if (_httpSessionManager == nil) {
        _httpSessionManager = [self createHttpSessionManager];
    }
    return _httpSessionManager;
}

-(AFHTTPSessionManager*)httpsSessionManager
{
    if (_httpsSessionManager == nil) {
        _httpsSessionManager = [self createHttpSessionManager];
        
        NSString *cerName = DEFAULT_HTTPS_SIGNED_PUBLIC_KEY_CER_FILE_NAME;
        if ([[[NSBundle mainBundle] infoDictionary] objectForKey:DEFAULT_HTTPS_SIGNED_PUBLIC_KEY_CER_FILE_NAME_KEY]) {
            cerName=[[[NSBundle mainBundle] infoDictionary] objectForKey:DEFAULT_HTTPS_SIGNED_PUBLIC_KEY_CER_FILE_NAME_KEY];
        }
        
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:cerName ofType:nil];
        NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
        NSSet *cerSet = [[NSSet alloc] initWithObjects:cerData, nil];
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        securityPolicy.pinnedCertificates = cerSet;
        _httpsSessionManager.securityPolicy = securityPolicy;
    }
    return _httpsSessionManager;
}


-(NSURLSessionDataTask*)httpGet:(NSString*)url
                         params:(NSDictionary*)params
                       progress:(httpManagerProgressBlock)progressBlock
                        success:(httpManagerSuccessBlock)successBlock
                        failure:(httpManagerFailureBlock)failureBlcok
{
    dispatch_in_main_queue(^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    return  [self.httpSessionManager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            dispatch_in_main_queue(^{
                progressBlock(downloadProgress);
            });
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            if (result == nil) {
                result = responseObject;
            }
            dispatch_in_main_queue(^{
                successBlock(result);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlcok) {
            dispatch_in_main_queue(^{
                failureBlcok(error);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }];
}

-(NSURLSessionDataTask*)httpPost:(NSString*)url
                          params:(NSDictionary*)params
                        progress:(httpManagerProgressBlock)progressBlock
                         success:(httpManagerSuccessBlock)successBlock
                         failure:(httpManagerFailureBlock)failureBlcok
{
    dispatch_in_main_queue(^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    return [self.httpSessionManager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            dispatch_in_main_queue(^{
                progressBlock(uploadProgress);
            });
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            if (result == nil) {
                result = responseObject;
            }
            dispatch_in_main_queue(^{
                successBlock(result);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlcok) {
            dispatch_in_main_queue(^{
                failureBlcok(error);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }];
}

-(NSURLSessionDataTask*)httpPostFile:(NSString*)url
                              params:(NSDictionary*)params
                            fileData:(NSData*)fileData
                            fileName:(NSString*)fileName
                            mimeType:(NSString*)mimeType
                            progress:(httpManagerProgressBlock)progressBlock
                             success:(httpManagerSuccessBlock)successBlock
                             failure:(httpManagerFailureBlock)failureBlcok
{
    dispatch_in_main_queue(^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    return [self.httpSessionManager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        if (fileData) {
            [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:mimeType];            
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            dispatch_in_main_queue(^{
                progressBlock(uploadProgress);
            });
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            if (result == nil) {
                result = responseObject;
            }
            dispatch_in_main_queue(^{
                successBlock(result);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlcok) {
            dispatch_in_main_queue(^{
                failureBlcok(error);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }];
}

-(NSURLSessionDataTask*)httpPostImage:(NSString*)url
                               params:(NSDictionary*)params
                            imageData:(NSData*)imageData
                        imageFileName:(NSString*)imageFileName
                             progress:(httpManagerProgressBlock)progressBlock
                              success:(httpManagerSuccessBlock)successBlock
                              failure:(httpManagerFailureBlock)failureBlcok
{
    return [self httpPostFile:url params:params fileData:imageData fileName:imageFileName mimeType:@"image/png" progress:progressBlock success:successBlock failure:failureBlcok];
}

-(NSURLSessionDataTask*)httpPostAudioFile:(NSString*)url
                                   params:(NSDictionary*)params
                                audioData:(NSData*)audioData
                            audioFileName:(NSString*)audioFileName
                                 progress:(httpManagerProgressBlock)progressBlock
                                  success:(httpManagerSuccessBlock)successBlock
                                  failure:(httpManagerFailureBlock)failureBlcok
{
    return [self httpPostFile:url params:params fileData:audioData fileName:audioFileName mimeType:@"audio/wav" progress:progressBlock success:successBlock failure:failureBlcok];
}

-(NSURLSessionDataTask*)httpsGet:(NSString*)url
                          params:(NSDictionary*)params
                        progress:(httpManagerProgressBlock)progressBlock
                         success:(httpManagerSuccessBlock)successBlock
                         failure:(httpManagerFailureBlock)failureBlcok
{
    dispatch_in_main_queue(^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;        
    });
    return [self.httpsSessionManager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            dispatch_in_main_queue(^{
                progressBlock(downloadProgress);
            });
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            if (result == nil) {
                result = responseObject;
            }
            dispatch_in_main_queue(^{
                successBlock(result);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlcok) {
            dispatch_in_main_queue(^{
                failureBlcok(error);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }];
}

-(NSURLSessionDataTask*)httpsPost:(NSString*)url
                           params:(NSDictionary*)params
                         progress:(httpManagerProgressBlock)progressBlock
                          success:(httpManagerSuccessBlock)successBlock
                          failure:(httpManagerFailureBlock)failureBlcok
{
    dispatch_in_main_queue(^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    return [self.httpsSessionManager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            dispatch_in_main_queue(^{
                progressBlock(uploadProgress);
            });
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            if (result == nil) {
                result = responseObject;
            }
            dispatch_in_main_queue(^{
                successBlock(result);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlcok) {
            dispatch_in_main_queue(^{
                failureBlcok(error);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }];
}

-(NSURLSessionDataTask*)httpsPostFile:(NSString*)url
                               params:(NSDictionary*)params
                             fileData:(NSData*)fileData
                             fileName:(NSString*)fileName
                             mimeType:(NSString*)mimeType
                             progress:(httpManagerProgressBlock)progressBlock
                              success:(httpManagerSuccessBlock)successBlock
                              failure:(httpManagerFailureBlock)failureBlcok
{
    dispatch_in_main_queue(^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
    return [self.httpsSessionManager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            dispatch_in_main_queue(^{
                progressBlock(uploadProgress);
            });
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            id result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            if (result == nil) {
                result = responseObject;
            }
            dispatch_in_main_queue(^{
                successBlock(result);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlcok) {
            dispatch_in_main_queue(^{
                failureBlcok(error);
            });
        }
        dispatch_in_main_queue(^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    }];
}

-(NSURLSessionDataTask*)httpsPostImage:(NSString*)url
                                params:(NSDictionary*)params
                             imageData:(NSData*)imageData
                         imageFileName:(NSString*)imageFileName
                              progress:(httpManagerProgressBlock)progressBlock
                               success:(httpManagerSuccessBlock)successBlock
                               failure:(httpManagerFailureBlock)failureBlcok
{
    return [self httpsPostFile:url params:params fileData:imageData fileName:imageFileName mimeType:@"image/png" progress:progressBlock success:successBlock failure:failureBlcok];
}

-(NSURLSessionDataTask*)httpsPostAudioFile:(NSString*)url
                                    params:(NSDictionary*)params
                                 audioData:(NSData*)audioData
                             audioFileName:(NSString*)audioFileName
                                  progress:(httpManagerProgressBlock)progressBlock
                                   success:(httpManagerSuccessBlock)successBlock
                                   failure:(httpManagerFailureBlock)failureBlcok
{
    return [self httpsPostFile:url params:params fileData:audioData fileName:audioFileName mimeType:@"audio/wav" progress:progressBlock success:successBlock failure:failureBlcok];
}

-(NSURLSessionDownloadTask*)httpDownload:(NSString*)url
                          destinationDir:(NSString*)destinationDir
                                progress:(httpManagerProgressBlock)progressBlock
                              completion:(httpManagerDownloadCompletionBlock)completionBlock
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSString *destionation = destinationDir;
    if (!IS_AVAILABLE_NSSTRNG(destionation)) {
        destionation = [YZHUtil applicationTmpDirectory:nil];
    }
    
    NSURLSessionDownloadTask *downloadTask = [self.httpSessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            dispatch_in_main_queue(^{
                progressBlock(downloadProgress);
            });
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *storePath = [destionation stringByAppendingPathComponent:response.suggestedFilename];
        return NSURL_FROM_FILE_PATH(storePath);
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSString *retFilePath = [filePath path];
        if (error) {
            retFilePath = nil;
        }
        
        if (completionBlock) {
            dispatch_in_main_queue(^{
                completionBlock(retFilePath);
            });
        }
    }];
    
    [downloadTask resume];
    return downloadTask;
}

-(NSURLSessionDownloadTask*)httpResumeDownload:(NSData*)resumeData
                                destinationDir:(NSString*)destinationDir
                                      progress:(httpManagerProgressBlock)progressBlock
                                    completion:(httpManagerDownloadCompletionBlock)completionBlock
{    
    NSString *destionation = destinationDir;
    if (!IS_AVAILABLE_NSSTRNG(destionation)) {
        destionation = [YZHUtil applicationTmpDirectory:nil];
    }
    NSURLSessionDownloadTask *downloadTask =  [self.httpSessionManager downloadTaskWithResumeData:resumeData progress:progressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *storePath = [destionation stringByAppendingPathComponent:response.suggestedFilename];
        return NSURL_FROM_FILE_PATH(storePath);
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSString *retFilePath = [filePath path];
        if (error) {
            retFilePath = nil;
        }
        
        if (completionBlock) {
            dispatch_in_main_queue(^{
                completionBlock(retFilePath);
            });
        }
    }];
    
    [downloadTask resume];
    
    return downloadTask;
}

-(NSURLSessionUploadTask*)httpUpload:(NSString*)url
                            fromFile:(NSString*)filePath
                            progress:(httpManagerProgressBlock)progressBlock
                          completion:(httpManagerSuccessBlock)completionBlock
{
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    
    NSURLSessionUploadTask *uploadTask = [self.httpSessionManager uploadTaskWithRequest:request fromFile:fileURL progress:progressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        dispatch_in_main_queue(^{
            if (completionBlock) {
                completionBlock(responseObject);
            }
        });
    }];
    
    [uploadTask resume];
    
    return uploadTask;
}

-(NSURLSessionUploadTask*)httpUpload:(NSString*)url
                            fromData:(NSData*)data
                            progress:(httpManagerProgressBlock)progressBlock
                          completion:(httpManagerSuccessBlock)completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    
    NSURLSessionUploadTask *uploadTask = [self.httpSessionManager uploadTaskWithRequest:request fromData:data progress:progressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        dispatch_in_main_queue(^{
            if (completionBlock) {
                completionBlock(responseObject);
            }
        });
    }];
    
    [uploadTask resume];
    
    return uploadTask;
}
#endif

@end
