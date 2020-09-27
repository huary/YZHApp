//
//  NSMapTable+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMapTable (YZHAdd)

- (void)hz_enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block;

-(NSArray*)hz_allValues;

-(NSArray*)hz_allKeys;

@end
