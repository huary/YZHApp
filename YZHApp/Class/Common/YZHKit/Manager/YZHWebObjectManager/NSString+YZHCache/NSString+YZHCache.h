//
//  NSString+YZHCache.h
//  YZHApp
//
//  Created by yuan on 2019/1/13.
//  Copyright © 2019年 yuanzh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString*(^YZHCacheKeyBlock)(NSString *url, id target);

@interface NSString (YZHCache)

@property (nonatomic, strong) NSString *cacheKey;

/* <#注释#> */
@property (nonatomic, copy) YZHCacheKeyBlock cacheKeyBlock;

@end
