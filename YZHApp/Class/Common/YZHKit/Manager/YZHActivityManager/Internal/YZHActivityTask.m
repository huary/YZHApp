//
//  YZHActivityTask.m
//  YZHApp
//
//  Created by bytedance on 2021/7/15.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "YZHActivityTask.h"

@implementation YZHActivityTask

- (instancetype)initWithTaskBlock:(YZHActivityTaskBlock)taskBlock {
    self = [super  init];
    if (self) {
        self.taskBlock = taskBlock;
    }
    return self;
}

@end
