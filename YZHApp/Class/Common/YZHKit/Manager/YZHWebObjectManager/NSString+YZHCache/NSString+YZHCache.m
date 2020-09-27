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

-(void)setHz_cacheKey:(NSString *)hz_cacheKey
{
    objc_setAssociatedObject(self, @selector(hz_cacheKey), hz_cacheKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)hz_cacheKey
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setHz_cacheKeyBlock:(YZHCacheKeyBlock)hz_cacheKeyBlock
{
    objc_setAssociatedObject(self, @selector(hz_cacheKeyBlock), hz_cacheKeyBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHCacheKeyBlock)hz_cacheKeyBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
