//
//  NSHashTable+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHashTable (YZHAdd)

- (void)hz_enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block;


@end
