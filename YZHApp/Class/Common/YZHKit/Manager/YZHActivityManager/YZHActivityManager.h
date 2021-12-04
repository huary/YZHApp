//
//  YZHActivityManager.h
//  YZHApp
//
//  Created by bytedance on 2021/7/15.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHActivityTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZHActivityManager : NSObject

+ (void)addActivity:(CFRunLoopActivity)activity taskBlock:(YZHActivityTaskBlock)taskBlock;

+ (void)stop;
@end

NS_ASSUME_NONNULL_END
