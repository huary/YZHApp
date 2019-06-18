//
//  YZHWebObjectLoaderManager.h
//  YZHApp
//
//  Created by yuan on 2019/1/14.
//  Copyright © 2019年 yuanzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHWebObjectLoader.h"

@interface YZHWebObjectLoaderManager : NSObject

+(instancetype)shareLoaderManager;

-(void)addLoader:(YZHWebObjectLoader*)loader forKey:(id)key;

-(YZHWebObjectLoader*)loaderForKey:(id)key;

-(void)clear;

-(void)clearAllMemoryCache;
@end
