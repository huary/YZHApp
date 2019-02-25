//
//  YZHWebObjectLoaderManager.m
//  contact
//
//  Created by yuan on 2019/1/14.
//  Copyright © 2019年 gdtech. All rights reserved.
//

#import "YZHWebObjectLoaderManager.h"

static YZHWebObjectLoaderManager *shareLoaderManager_s = nil;

@interface YZHWebObjectLoaderManager ()

/* <#注释#> */
@property (nonatomic, strong) NSMapTable<id, YZHWebObjectLoader*> *loaderMapTable;

@end

@implementation YZHWebObjectLoaderManager

+(instancetype)shareLoaderManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareLoaderManager_s = [[super allocWithZone:NULL] init];
    });
    return shareLoaderManager_s;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [YZHWebObjectLoaderManager shareLoaderManager];
}

-(id)copyWithZone:(struct _NSZone *)zone
{
    return [YZHWebObjectLoaderManager shareLoaderManager];
}

-(NSMapTable<id, YZHWebObjectLoader*>*)loaderMapTable
{
    if (_loaderMapTable == nil) {
        _loaderMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return _loaderMapTable;
}

-(void)addLoader:(YZHWebObjectLoader*)loader forKey:(id)key
{
    [self.loaderMapTable setObject:loader forKey:key];
}

-(YZHWebObjectLoader*)loaderForKey:(id)key
{
    return [self.loaderMapTable objectForKey:key];
}

@end
