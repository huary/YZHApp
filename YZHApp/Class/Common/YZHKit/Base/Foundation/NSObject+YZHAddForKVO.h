//
//  NSObject+YZHAddForKVO.h
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (YZHAddForKVO)

-(void)hz_addKVOObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

-(void)hz_removeKVOObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context;

@end
