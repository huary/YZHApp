//
//  YZHWeakProxy.h
//  YZHApp
//
//  Created by yuan on 2019/1/14.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YZHWeakProxy : NSProxy

@property (nonatomic, weak, readonly) id target;

-(instancetype)initWithTarget:(id)target;

+(instancetype)proxyWithTarget:(id)target;

@end
