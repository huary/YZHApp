//
//  NSObject+YZHAddForDealloc.m
//  YZHApp
//
//  Created by yuan on 2020/12/16.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "NSObject+YZHAddForDealloc.h"
#import <objc/runtime.h>

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

- (YZHDeallocProxy *)deallocProxy {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDeallocProxy:(YZHDeallocProxy*)deallocProxy {
    objc_setAssociatedObject(self, @selector(deallocProxy), deallocProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addDeallocBlock:(YZHDeallocBlock)deallocBlock {
    @synchronized (self) {
        YZHDeallocProxy *proxy = [self deallocProxy];
        if (!proxy) {
            proxy = [[YZHDeallocProxy alloc] init];
            proxy.target = self;
            [self setDeallocProxy:proxy];
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
