//
//  NSObject+YZHWebCache.h
//  YZHApp
//
//  Created by yuan on 2019/1/13.
//  Copyright © 2019年 yuanzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHWebObjectLoaderManager.h"

typedef NS_ENUM(NSInteger, YZHLoadObjectType)
{
    YZHLoadObjectTypeCommon     = 0,
    YZHLoadObjectTypePrivate    = 1,
};

@interface NSObject (YZHWebCache)

/* <#注释#> */
@property (nonatomic, strong) NSMapTable<NSString *, YZHWebObjectLoadOperation*> *hz_loadOperationMapTable;

-(void)hz_loadObject:(NSString*)url
                type:(YZHLoadObjectType)type
              decode:(YZHDiskCacheDecodeBlock)decode
     cacheCompletion:(YZHWebObjectCacheLoadCompletionBlock)cacheCompletionBlock
            progress:(YZHWebObjectLoadProgressBlock)progressBlock
       webCompletion:(YZHWebObjectWebLoadCompletionBlock)webCompletionBlock;

@end
