//
//  YZHActivityItem.h
//  YZHApp
//
//  Created by bytedance on 2021/7/15.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHActivityTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZHActivityItem : NSObject

@property (nonatomic, assign) CFRunLoopMode mode;

@property (nonatomic, assign) CFRunLoopActivity activity;

@property (nonatomic, assign, nullable) CFRunLoopObserverRef observer;


@property (nonatomic, strong) NSMutableArray<YZHActivityTask*> *taskLit;

@end

NS_ASSUME_NONNULL_END
