//
//  UIImage+YZHCoding.h
//  contact
//
//  Created by yuan on 2019/1/14.
//  Copyright © 2019年 gdtech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHDiskCache.h"

@interface UIImage (YZHCoding) <YZHDiskCacheObjectCodingProtocol>

@property (nonatomic, copy) YZHDiskCacheEncodeBlock encodeBlock;

//@property (nonatomic, copy) YZHDiskCacheDecodeBlock decodeBlock;

@end
