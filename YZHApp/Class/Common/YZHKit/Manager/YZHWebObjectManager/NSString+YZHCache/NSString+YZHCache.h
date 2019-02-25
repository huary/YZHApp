//
//  NSString+YZHCache.h
//  contact
//
//  Created by yuan on 2019/1/13.
//  Copyright © 2019年 gdtech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString*(^YZHCacheKeyBlock)(NSString *url);

@interface NSString (YZHCache)

@property (nonatomic, strong) NSString *cacheKey;

/* <#注释#> */
@property (nonatomic, copy) YZHCacheKeyBlock cacheKeyBlock;

@end
