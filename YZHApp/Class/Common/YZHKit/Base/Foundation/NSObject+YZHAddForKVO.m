//
//  NSObject+YZHAddForKVO.m
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "NSObject+YZHAddForKVO.h"
#import <objc/runtime.h>

@interface YZHKVOObserver : NSObject


@property (nonatomic, weak) id target;

@property (nonatomic, assign) BOOL OFF;

@property (nonatomic, copy) NSString *keyPath;

//@property (nonatomic, copy) YZHKVOObserverBlock block;

@property (nonatomic, strong) NSMutableArray<YZHKVOObserverBlock> *blockList;

@end

@implementation YZHKVOObserver

- (instancetype)initWithTarget:(id)target keyPath:(NSString *)keyPath block:(YZHKVOObserverBlock)block {
    self = [super init];
    if (self) {
        self.target = target;
        self.keyPath = keyPath;
        [self.blockList addObject:block];
    }
    return self;
}

- (NSMutableArray<YZHKVOObserverBlock>*)blockList {
    if (!_blockList) {
        _blockList = [NSMutableArray array];
    }
    return _blockList;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (self.OFF) {
        return;
    }
    WEAK_SELF(weakSelf);
    [self.blockList enumerateObjectsUsingBlock:^(YZHKVOObserverBlock  _Nonnull block, NSUInteger idx, BOOL * _Nonnull stop) {
        block(weakSelf.target,keyPath, object, change, context);
    }];
}

- (void)removeKVOObserver {
    [self.target hz_removeKVOObserver:self forKeyPath:self.keyPath];
}

- (void)dealloc {
    NSLog(@"self.target=%p",self.target);
    [self.target hz_removeKVOObserver:self forKeyPath:self.keyPath];
}

@end

@implementation NSObject (YZHAddForKVO)

-(void)hz_addKVOObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
    if (![self pri_observerForObserver:observer KeyPath:keyPath]) {
        [self addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

-(void)hz_removeKVOObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context
{
    if ([self pri_observerForObserver:observer KeyPath:keyPath]) {
        [self removeObserver:observer forKeyPath:keyPath context:context];
    }
}

-(void)hz_removeKVOObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    if ([self pri_observerForObserver:observer KeyPath:keyPath]) {
        [self removeObserver:observer forKeyPath:keyPath];
    }
}

-(BOOL)pri_observerForObserver:(id)observer KeyPath:(NSString*)keyPath
{
    id info = self.observationInfo;
    NSArray *array = [info valueForKey:@"_observances"];
    for (id objc in array) {
        id properties = [objc valueForKeyPath:@"_property"];
        id observerTmp = [objc valueForKeyPath:@"_observer"];
        
        NSString *keyPathTmp = [properties valueForKeyPath:@"_keyPath"];
        if ([keyPathTmp isEqualToString:keyPath] && [observerTmp isEqual:observer]) {
            return YES;
        }
    }
    return NO;
}

-(void)hz_addKVOForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context block:(YZHKVOObserverBlock)observerBlock {
    if (!observerBlock) {
        return;
    }
    @synchronized (self) {
        @autoreleasepool {
            NSString *key = [NSString stringWithFormat:@"YZHKVOObserver.%@",keyPath];
            YZHKVOObserver *observer = [self hz_strongReferenceObjectForKey:key];
            if (observer) {
                [observer.blockList addObject:observerBlock];
                return;
            }
            
            observer = [[YZHKVOObserver alloc] initWithTarget:self keyPath:keyPath block:observerBlock];
            [self hz_addKVOObserver:observer forKeyPath:keyPath options:options context:context];
            [self hz_addStrongReferenceObject:observer forKey:key];
        }
    }
}

-(void)hz_removeKVOObserverBlockForKeyPath:(NSString *)keyPath {
    @synchronized (self) {
        @autoreleasepool {
            NSString *key = [NSString stringWithFormat:@"YZHKVOObserver.%@",keyPath];
            YZHKVOObserver *observer = [self hz_strongReferenceObjectForKey:key];
            if (!observer) {
                return;
            }
            [observer removeKVOObserver];
            [self hz_removeStrongReferenceObjectForKey:key];
        }
    }
}

-(void)hz_switchKVOForKeyPath:(NSString *)keyPath OFF:(BOOL)OFF {
    @synchronized (self) {
        NSString *key = [NSString stringWithFormat:@"YZHKVOObserver.%@",keyPath];
        @autoreleasepool {
            YZHKVOObserver *observer = [self hz_strongReferenceObjectForKey:key];
            if (!observer) {
                return;
            }
            observer.OFF = OFF;
        }
    }
}

@end
