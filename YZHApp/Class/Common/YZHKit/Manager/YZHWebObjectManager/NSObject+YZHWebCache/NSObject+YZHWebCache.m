//
//  NSObject+YZHWebCache.m
//  YZHApp
//
//  Created by yuan on 2019/1/13.
//  Copyright © 2019年 yuanzh. All rights reserved.
//

#import "NSObject+YZHWebCache.h"
#import <objc/runtime.h>
#import "NSMapTable+YZHAdd.h"

@implementation NSObject (YZHWebCache)

-(void)setLoadOperationMapTable:(NSMapTable<NSString *,YZHWebObjectLoadOperation *> *)loadOperationMapTable
{
    objc_setAssociatedObject(self, @selector(loadOperationMapTable), loadOperationMapTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMapTable<NSString *,YZHWebObjectLoadOperation *>*)loadOperationMapTable
{
    
    NSMapTable *mapTable = objc_getAssociatedObject(self, _cmd);
    if (mapTable == nil) {
        mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        self.loadOperationMapTable = mapTable;
    }
    return mapTable;
}

-(void)_cancelPrevAllOperation
{
    [self.loadOperationMapTable enumerateKeysAndObjectsUsingBlock:^(id key, YZHWebObjectLoadOperation *obj, BOOL *stop) {
        [obj cancelForURL:key];
    }];
    [self.loadOperationMapTable removeAllObjects];
}

-(void)loadObject:(NSString*)url
             type:(YZHLoadObjectType)type
           decode:(YZHDiskCacheDecodeBlock)decode
  cacheCompletion:(YZHWebObjectCacheLoadCompletionBlock)cacheCompletionBlock
         progress:(YZHWebObjectLoadProgressBlock)progressBlock
    webCompletion:(YZHWebObjectWebLoadCompletionBlock)webCompletionBlock
{
    YZHWebObjectLoadOperation *lastOperation = [self.loadOperationMapTable objectForKey:url];
//    [lastOperation cancelForURL:url];
    [self _cancelPrevAllOperation];
    
    YZHWebObjectLoader *loader = [[YZHWebObjectLoaderManager shareLoaderManager] loaderForKey:@(type)];
    if (!loader) {
        return;
    }
    
    YZHWebObjectLoadOperation *operation = [loader loadWebObject:url decode:decode cacheCompletion:cacheCompletionBlock progress:progressBlock webCompletion:webCompletionBlock];
    
    [self.loadOperationMapTable setObject:operation forKey:url];
}
@end
