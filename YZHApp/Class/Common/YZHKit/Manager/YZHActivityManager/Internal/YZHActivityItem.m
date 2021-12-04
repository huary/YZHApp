//
//  YZHActivityItem.m
//  YZHApp
//
//  Created by bytedance on 2021/7/15.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "YZHActivityItem.h"

@implementation YZHActivityItem

- (NSMutableArray<YZHActivityTask*>*)taskLit {
    if (_taskLit == nil) {
        _taskLit = [NSMutableArray array];
    }
    return _taskLit;
}

@end
