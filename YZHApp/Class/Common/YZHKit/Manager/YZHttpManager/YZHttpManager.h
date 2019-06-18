//
//  YZHttpManager.h
//  YZHttpManager
//
//  Created by yuan on 16/12/22.
//  Copyright © 2016年 yzh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YZHTTP  (1)
#define AFN     (0)

typedef void (^httpManagerSuccessBlock)(id result);
//typedef void (^httpManagerSuccessBlock)(id result, id responseObject);
typedef void (^httpManagerFailureBlock)(NSError *error);
typedef void (^httpManagerProgressBlock)(NSProgress *progress);
typedef void (^httpManagerDownloadCompletionBlock)(NSString *filePath);


//这个是非严格的单例，可以alloc一个YZHttpManager的对象
@interface YZHttpManager : NSObject

#if AFN
@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;
@property (nonatomic, strong) AFHTTPSessionManager *httpsSessionManager;
#endif

+(instancetype)httpManager;

-(NSURLSessionDataTask*)httpGet:(NSString*)url
                         params:(NSDictionary*)params
                       progress:(httpManagerProgressBlock)progressBlock
                        success:(httpManagerSuccessBlock)successBlock
                        failure:(httpManagerFailureBlock)failureBlcok;

-(NSURLSessionDataTask*)httpPost:(NSString*)url
                          params:(NSDictionary*)params
                        progress:(httpManagerProgressBlock)progressBlock
                         success:(httpManagerSuccessBlock)successBlock
                         failure:(httpManagerFailureBlock)failureBlcok;

-(NSURLSessionDataTask*)httpPostFile:(NSString*)url
                              params:(NSDictionary*)params
                            fileData:(NSData*)fileData
                            fileName:(NSString*)fileName
                            mimeType:(NSString*)mimeType
                            progress:(httpManagerProgressBlock)progressBlock
                             success:(httpManagerSuccessBlock)successBlock
                             failure:(httpManagerFailureBlock)failureBlcok;

-(NSURLSessionDataTask*)httpPostImage:(NSString*)url
                               params:(NSDictionary*)params
                            imageData:(NSData*)imageData
                        imageFileName:(NSString*)imageFileName
                             progress:(httpManagerProgressBlock)progressBlock
                              success:(httpManagerSuccessBlock)successBlock
                              failure:(httpManagerFailureBlock)failureBlcok;

-(NSURLSessionDataTask*)httpPostAudioFile:(NSString*)url
                                   params:(NSDictionary*)params
                                audioData:(NSData*)audioData
                            audioFileName:(NSString*)audioFileName
                                 progress:(httpManagerProgressBlock)progressBlock
                                  success:(httpManagerSuccessBlock)successBlock
                                  failure:(httpManagerFailureBlock)failureBlcok;

-(NSURLSessionDataTask*)httpsGet:(NSString*)url
                          params:(NSDictionary*)params
                        progress:(httpManagerProgressBlock)progressBlock
                         success:(httpManagerSuccessBlock)successBlock
                         failure:(httpManagerFailureBlock)failureBlcok;

-(NSURLSessionDataTask*)httpsPost:(NSString*)url
                           params:(NSDictionary*)params
                         progress:(httpManagerProgressBlock)progressBlock
                          success:(httpManagerSuccessBlock)successBlock
                          failure:(httpManagerFailureBlock)failureBlcok;

-(NSURLSessionDataTask*)httpsPostFile:(NSString*)url
                               params:(NSDictionary*)params
                             fileData:(NSData*)fileData
                             fileName:(NSString*)fileName
                             mimeType:(NSString*)mimeType
                             progress:(httpManagerProgressBlock)progressBlock
                              success:(httpManagerSuccessBlock)successBlock
                              failure:(httpManagerFailureBlock)failureBlcok;

-(NSURLSessionDataTask*)httpsPostImage:(NSString*)url
                                params:(NSDictionary*)params
                             imageData:(NSData*)imageData
                         imageFileName:(NSString*)imageFileName
                              progress:(httpManagerProgressBlock)progressBlock
                               success:(httpManagerSuccessBlock)successBlock
                               failure:(httpManagerFailureBlock)failureBlcok;

-(NSURLSessionDataTask*)httpsPostAudioFile:(NSString*)url
                                    params:(NSDictionary*)params
                                 audioData:(NSData*)audioData
                             audioFileName:(NSString*)audioFileName
                                  progress:(httpManagerProgressBlock)progressBlock
                                   success:(httpManagerSuccessBlock)successBlock
                                   failure:(httpManagerFailureBlock)failureBlcok;

//download
-(NSURLSessionDownloadTask*)httpDownload:(NSString*)url
                          destinationDir:(NSString*)destinationDir
                                progress:(httpManagerProgressBlock)progressBlock
                              completion:(httpManagerDownloadCompletionBlock)completionBlock;

-(NSURLSessionDownloadTask*)httpResumeDownload:(NSData*)resumeData
                                destinationDir:(NSString*)destinationDir
                                      progress:(httpManagerProgressBlock)progressBlock
                                    completion:(httpManagerDownloadCompletionBlock)completionBlock;

-(NSURLSessionUploadTask*)httpUpload:(NSString*)url
                            fromFile:(NSString*)filePath
                            progress:(httpManagerProgressBlock)progressBlock
                          completion:(httpManagerSuccessBlock)completionBlock;

-(NSURLSessionUploadTask*)httpUpload:(NSString*)url
                            fromData:(NSData*)data
                            progress:(httpManagerProgressBlock)progressBlock
                          completion:(httpManagerSuccessBlock)completionBlock;
@end
