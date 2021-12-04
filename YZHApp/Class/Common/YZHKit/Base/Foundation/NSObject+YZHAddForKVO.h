//
//  NSObject+YZHAddForKVO.h
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^YZHKVOObserverBlock)(id target, NSString *keyPath, id object, NSDictionary<NSKeyValueChangeKey,id> *change, void *context);

@interface NSObject (YZHAddForKVO)

-(void)hz_addKVOObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

-(void)hz_removeKVOObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;

-(void)hz_removeKVOObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

//通过这种方式进行add的block，既可以调用hz_removeKVOObserverBlockForKeyPath:的方法，也可以不用调用,不调用移除的时候，同调用者的生命周期
-(void)hz_addKVOForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context block:(YZHKVOObserverBlock)observerBlock;

//暂时关闭,OFF=YES 关闭，NO开启
-(void)hz_switchKVOForKeyPath:(NSString *)keyPath OFF:(BOOL)OFF;

//这种值针对添加block的方式的移除
-(void)hz_removeKVOObserverBlockForKeyPath:(NSString *)keyPath;

@end
