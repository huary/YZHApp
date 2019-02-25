//
//  NSObject+YZHWebCache.m
//  contact
//
//  Created by yuan on 2019/1/13.
//  Copyright © 2019年 gdtech. All rights reserved.
//

#import "NSObject+YZHWebCache.h"
#import <objc/runtime.h>

@implementation NSObject (YZHWebCache)

-(void)setLoadOperationMapTable:(NSMapTable<NSString *,YZHWebObjectOperation *> *)loadOperationMapTable
{
    objc_setAssociatedObject(self, @selector(loadOperationMapTable), loadOperationMapTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMapTable<NSString *,YZHWebObjectOperation *>*)loadOperationMapTable
{
    
    NSMapTable *mapTable = objc_getAssociatedObject(self, _cmd);
    if (mapTable == nil) {
        mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        self.loadOperationMapTable = mapTable;
    }
    return mapTable;
}

-(void)loadObject:(NSString*)url
             type:(YZHLoadObjectType)type
           decode:(YZHDiskCacheDecodeBlock)decode
  cacheCompletion:(YZHWebObjectCacheLoadCompletionBlock)cacheCompletionBlock
         progress:(YZHWebObjectLoadProgressBlock)progressBlock
    webCompletion:(YZHWebObjectWebLoadCompletionBlock)webCompletionBlock
{
    YZHWebObjectOperation *lastOperation = [self.loadOperationMapTable objectForKey:url];
    [lastOperation cancelForURL:url];
    
    YZHWebObjectLoader *loader = [[YZHWebObjectLoaderManager shareLoaderManager] loaderForKey:@(type)];
    if (!loader) {
        return;
    }
    
    YZHWebObjectOperation *operation = [loader loadWebObject:url decode:decode cacheCompletion:cacheCompletionBlock progress:progressBlock webCompletion:webCompletionBlock];
    
    [self.loadOperationMapTable setObject:operation forKey:url];
}
@end
