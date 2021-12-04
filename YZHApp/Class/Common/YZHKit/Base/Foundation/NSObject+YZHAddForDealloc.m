//
//  NSObject+YZHAddForDealloc.m
//  YZHApp
//
//  Created by yuan on 2020/12/16.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "NSObject+YZHAddForDealloc.h"
#import "NSObject+YZHAdd.h"

@interface YZHDeallocProxy : NSObject
{
    void *_internalTarget;
}

/** <#注释#> */
@property (nonatomic, weak) id target;

/** <#注释#> */
@property (nonatomic, copy) YZHDeallocBlock deallocBlock;

@end

@implementation YZHDeallocProxy

- (void)setTarget:(id)target {
    _target = target;
    _internalTarget = (__bridge void *)target;
}


- (void)dealloc {
    if (self.deallocBlock) {
        self.deallocBlock(_internalTarget);
    }
}

@end


@implementation NSObject (YZHAddForDealloc)

- (void)hz_addDeallocBlock:(YZHDeallocBlock)deallocBlock {
    @synchronized (self) {
        NSString *key = @"hz_deallocProxy";
        YZHDeallocProxy *proxy = [self hz_strongReferenceObjectForKey:key];
        if (!proxy) {
            proxy = [[YZHDeallocProxy alloc] init];
            proxy.target = self;
            [self hz_addStrongReferenceObject:proxy forKey:key];
        }
        
        YZHDeallocBlock oldBlock = proxy.deallocBlock;
        if (!oldBlock) {
            proxy.deallocBlock = deallocBlock;
        }
        else {
            proxy.deallocBlock = ^(void * _Nonnull deallocTarget) {
                oldBlock(deallocTarget);
                if (deallocBlock) {
                    deallocBlock(deallocTarget);
                }
            };
        }
    }
}

@end
