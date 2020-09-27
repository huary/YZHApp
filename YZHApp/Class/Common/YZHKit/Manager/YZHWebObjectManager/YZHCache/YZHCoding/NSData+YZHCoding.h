//
//  NSData+YZHCoding.h
//  YZHApp
//
//  Created by yuan on 2019/1/14.
//  Copyright © 2019年 yuanzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHDiskCache.h"

@interface NSData (YZHCoding) <YZHDiskCacheObjectCodingProtocol>

/* <#注释#> */
@property (nonatomic, copy) YZHDiskCacheEncodeBlock hz_encodeBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHDiskCacheDecodeBlock hz_decodeBlock;

@end
