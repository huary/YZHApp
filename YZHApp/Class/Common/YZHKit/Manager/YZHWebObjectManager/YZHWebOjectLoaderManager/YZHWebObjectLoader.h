//
//  YZHWebObjectLoader.h
//  contact
//
//  Created by yuan on 2019/1/13.
//  Copyright © 2019年 gdtech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHCache.h"
#import "YZHTaskManager.h"
#import "NSString+YZHCache.h"

/****************************************************
 *YZHWebObjectOperation
 ****************************************************/
@interface YZHWebObjectOperation : NSObject

@property (nonatomic, strong) NSOperation *cacheOperation;

@property (nonatomic, strong) YZHTaskManager *webTaskManager;

-(void)cancelForURL:(NSString*)url;

@end



@class YZHWebObjectLoader;
typedef void(^YZHWebObjectLoadProgressBlock)(YZHWebObjectLoader *webObjectLoader, NSString *url, NSProgress *progress);
//从cache完成后返回是否继续,YES表示在继续从网络下载，否则不进行
typedef BOOL(^YZHWebObjectCacheLoadCompletionBlock)(YZHWebObjectLoader *webObjectLoader, NSString *url, id object, NSData *data, YZHCacheType cacheType);

//这个YZHWebObjectWebLoadCompletionCallBackBlock是从网络上获取到数据后，完成数据转换为object（cacheObject）时需要回调回来的
typedef void(^YZHWebObjectWebLoadCompletionCallbackBlock)(NSString *url, id object, NSData *data);
//这个是从网络上获取到数据后交由上面，完成数据转换的功能，数据转换完成后调用callBack函数，在callback函数里面主要是进行缓存对象。
typedef void(^YZHWebObjectWebLoadCompletionBlock)(YZHWebObjectLoader *webObjectLoader, NSString *url, NSData *data, YZHWebObjectWebLoadCompletionCallbackBlock callbackBlock);



/****************************************************
 *YZHWebObjectLoader
 ****************************************************/
@interface YZHWebObjectLoader : NSObject
//默认的cache的diskcache就是在cache目录下
@property (nonatomic, strong, readonly) YZHCache *cache;
/*
 *默认的taskManager为同步任务，最大任务数为6个
 */
@property (nonatomic, strong, readonly) YZHTaskManager *taskManager;

-(instancetype)initWithCache:(YZHCache*)cache taskManager:(YZHTaskManager*)taskManager;

-(YZHWebObjectOperation*)loadWebObject:(NSString*)url
                                decode:(YZHDiskCacheDecodeBlock)decode
                       cacheCompletion:(YZHWebObjectCacheLoadCompletionBlock)cacheCompletionBlock
                              progress:(YZHWebObjectLoadProgressBlock)progressBlock
                         webCompletion:(YZHWebObjectWebLoadCompletionBlock)webCompletionBlock;


-(NSString*)cacheKeyForUrl:(NSString*)url;

-(void)saveObject:(id)object data:(NSData*)data forUrl:(NSString*)url;
//-(NSString*)saveDataPathForURL:(NSString*)url;

@end
