//
//  NSData+YZHCoding.m
//  YZHApp
//
//  Created by yuan on 2019/1/14.
//  Copyright © 2019年 yuanzh. All rights reserved.
//

#import "NSData+YZHCoding.h"
#import <objc/runtime.h>

@implementation NSData (YZHCoding)

-(void)setHz_encodeBlock:(YZHDiskCacheEncodeBlock)hz_encodeBlock
{
    objc_setAssociatedObject(self, @selector(hz_encodeBlock), hz_encodeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHDiskCacheEncodeBlock)hz_encodeBlock
{
    YZHDiskCacheEncodeBlock encode = objc_getAssociatedObject(self, _cmd);
    if (encode == nil) {
        encode = ^NSData*(YZHDiskCache *cache, id object, NSString *path, NSString *inFileName) {
            return object;
        };
        self.hz_encodeBlock = encode;
    }
    return encode;
}

-(void)setHz_decodeBlock:(YZHDiskCacheDecodeBlock)hz_decodeBlock
{
    objc_setAssociatedObject(self, @selector(hz_decodeBlock), hz_decodeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHDiskCacheDecodeBlock)hz_decodeBlock
{
    YZHDiskCacheDecodeBlock decode = objc_getAssociatedObject(self, _cmd);
    if (decode) {
        decode = ^id(YZHDiskCache *cache, NSData *data, NSString *path, NSString *inFileName) {
            return data;
        };
        self.hz_decodeBlock = decode;
    }
    return decode;
}




@end
