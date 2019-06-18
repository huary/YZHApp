//
//  NSString+YZHCache.m
//  YZHApp
//
//  Created by yuan on 2019/1/13.
//  Copyright © 2019年 yuanzh. All rights reserved.
//

#import "NSString+YZHCache.h"
#import <objc/runtime.h>

@implementation NSString (YZHCache)

-(void)setCacheKey:(NSString *)cacheKey
{
    objc_setAssociatedObject(self, @selector(cacheKey), cacheKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)cacheKey
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setCacheKeyBlock:(YZHCacheKeyBlock)cacheKeyBlock
{
    objc_setAssociatedObject(self, @selector(cacheKeyBlock), cacheKeyBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHCacheKeyBlock)cacheKeyBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
