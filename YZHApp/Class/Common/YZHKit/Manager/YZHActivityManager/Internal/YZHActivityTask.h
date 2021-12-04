//
//  YZHActivityTask.h
//  YZHApp
//
//  Created by bytedance on 2021/7/15.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHActivityTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZHActivityTask : NSObject

@property (nonatomic, strong) YZHActivityTaskBlock taskBlock;

- (instancetype)initWithTaskBlock:(YZHActivityTaskBlock)taskBlock;

@end

NS_ASSUME_NONNULL_END
