//
//  UIImage+YZHCoding.h
//  YZHApp
//
//  Created by yuan on 2019/1/14.
//  Copyright © 2019年 yuanzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHDiskCache.h"

@interface UIImage (YZHCoding) <YZHDiskCacheObjectCodingProtocol>

@property (nonatomic, copy) YZHDiskCacheEncodeBlock hz_encodeBlock;

@property (nonatomic, copy) YZHDiskCacheDecodeBlock hz_decodeBlock;

@end
