//
//  NSData+YZHCoding.h
//  contact
//
//  Created by yuan on 2019/1/14.
//  Copyright © 2019年 gdtech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHDiskCache.h"

@interface NSData (YZHCoding) <YZHDiskCacheObjectCodingProtocol>

/* <#注释#> */
@property (nonatomic, copy) YZHDiskCacheEncodeBlock encodeBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHDiskCacheDecodeBlock decodeBlock;

@end
