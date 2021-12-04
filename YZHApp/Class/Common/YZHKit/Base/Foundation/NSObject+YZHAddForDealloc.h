//
//  NSObject+YZHAddForDealloc.h
//  YZHApp
//
//  Created by yuan on 2020/12/16.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^YZHDeallocBlock)(void *deallocTarget);


@interface NSObject (YZHAddForDealloc)

- (void)hz_addDeallocBlock:(YZHDeallocBlock)deallocBlock;

@end

NS_ASSUME_NONNULL_END
