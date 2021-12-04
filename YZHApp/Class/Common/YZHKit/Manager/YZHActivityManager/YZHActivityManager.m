//
//  YZHActivityManager.m
//  YZHApp
//
//  Created by bytedance on 2021/7/15.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "YZHActivityManager.h"
#import "YZHActivityItem.h"

#define _YZH_ACTIVITY_CNT_MAX   8

static inline NSString* getThreadKey() {
    return [NSString stringWithFormat:@"activity.thread.key-%p",[NSThread currentThread]];
}


@interface YZHActivityManager ()

@property (nonatomic, copy) NSArray<YZHActivityItem*> *activitys;

@end

@implementation YZHActivityManager

- (NSArray<YZHActivityItem*>*)activitys {
    if (!_activitys) {
        NSMutableArray *list = [NSMutableArray arrayWithCapacity:_YZH_ACTIVITY_CNT_MAX];
        for (int i = 0; i < _YZH_ACTIVITY_CNT_MAX; ++i) {
            list[i] = [YZHActivityItem new];
        }
        _activitys = [list copy];
    }
    return _activitys;
}

- (void)addActivity:(CFRunLoopActivity)activity taskBlock:(YZHActivityTaskBlock)taskBlock {
    if (activity == kCFRunLoopAllActivities || taskBlock == nil) {
        return;
    }
    for (int i = 0; i < _YZH_ACTIVITY_CNT_MAX; ++i) {
        if (activity & (1ULL << i)) {
            YZHActivityItem *item = self.activitys[i];
            item.activity = activity;
            [item.taskLit addObject:[[YZHActivityTask alloc] initWithTaskBlock:taskBlock]];
            [self pri_checkInitActivityItem:item ];
        }
        //发现高位为0时立即终止，避免没有必要的循环
        if (i+1 < _YZH_ACTIVITY_CNT_MAX && (activity & (~((1ULL << (i+1)) - 1))) == 0 ) {
            break;
        }
    }
}

- (void)pri_checkInitActivityItem:(YZHActivityItem *)item  {
    if (item.observer) {
        return;
    }
    item.observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, item.activity, true, 0xFFFFFF, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
//        NSLog(@"activity=%@",@(activity));
        if (item.taskLit.count > 0) {
            YZHActivityTask *task = [item.taskLit firstObject];
            [item.taskLit removeObject:task];
            task.taskBlock(activity);
            [item performSelector:@selector(hash) withObject:nil afterDelay:0];
        }
    });
//    [item performSelector:@selector(hash) withObject:nil afterDelay:0];
    item.mode = kCFRunLoopDefaultMode;
    CFRunLoopRef rl = CFRunLoopGetCurrent();
    CFRunLoopAddObserver(rl, item.observer, item.mode);
    if (rl != CFRunLoopGetMain()) {
        CFRunLoopRun();
    }
}

- (void)dealloc {
    for (YZHActivityItem *item in self.activitys) {
        if (item.observer) {
            CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), item.observer, item.mode);
            item.observer = NULL;
        }
    }
}

+ (void)addActivity:(CFRunLoopActivity)activity taskBlock:(YZHActivityTaskBlock)taskBlock {
    NSThread *thread = [NSThread currentThread];
    NSString *key = getThreadKey();
    YZHActivityManager *manager = [thread.threadDictionary objectForKey:key];
    if (!manager) {
        manager = [[YZHActivityManager alloc] init];
        [thread.threadDictionary setObject:manager forKey:key];
    }
    [manager addActivity:activity taskBlock:taskBlock];
}

+ (void)stop {
    CFRunLoopRef rl = CFRunLoopGetCurrent();
    if (rl != CFRunLoopGetMain()) {
        CFRunLoopStop(rl);
    }
    [[NSThread currentThread].threadDictionary removeObjectForKey:getThreadKey()];
}

@end
