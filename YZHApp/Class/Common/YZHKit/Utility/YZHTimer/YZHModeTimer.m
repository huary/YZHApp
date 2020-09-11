//
//  YZHModeTimer.m
//  Action
//
//  Created by yuan on 2020/8/14.
//

#import "YZHModeTimer.h"


@interface YZHModeTimerTask : NSObject

/** taskId */
@property (nonatomic, assign) NSInteger taskId;

/** 任务 */
@property (nonatomic, copy) YZHModeTimerTaskBlock taskBlock;

@end


@implementation YZHModeTimerTask

@end

@interface YZHModeTimer ()

/** <#注释#> */
@property (nonatomic, strong) NSMutableArray<YZHModeTimerTask*> *taskList;

@end

@implementation YZHModeTimer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSRunLoopMode)mode
{
    if (!_mode) {
        _mode = NSDefaultRunLoopMode;
    }
    return _mode;
}

- (NSMutableArray<YZHModeTimerTask*>*)taskList
{
    if (_taskList == nil) {
        _taskList = [NSMutableArray array];
    }
    return _taskList;
}

- (void)start
{
    [self start:nil];
}

- (void)start:(YZHModeTimerTaskBlock)taskBlock
{
    [self startAfter:self.timeInterval taskBlock:taskBlock];
}

//在after后执行
- (void)startAfter:(NSTimeInterval)after taskBlock:(YZHModeTimerTaskBlock _Nullable)taskBlock
{
    if (self.taskList.count > 0) {
        [self.taskList removeAllObjects];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
    
    YZHModeTimerTask *task = [YZHModeTimerTask new];
    task.taskBlock = taskBlock;
    [self.taskList addObject:task];
    if (after > 0) {
        [self performSelector:@selector(pri_timerTaskAction:) withObject:task afterDelay:after inModes:@[self.mode]];
    }
    else {
        [self pri_timerTaskAction:task];
    }
}

- (void)stop
{
    if (self.taskList.count > 0) {
        [self.taskList removeAllObjects];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)pri_timerTaskAction:(YZHModeTimerTask *)task
{
    if (![self.taskList containsObject:task]) {
        return;
    }
    [self.taskList removeObject:task];
    
    YZHModeTimerTaskBlock taskBlock = task.taskBlock;
    if (!taskBlock) {
        taskBlock = self.defaultTaskBlock;
    }
    
    if (taskBlock) {
        taskBlock(self);
    }
    
    //如果没有taskBlock,不进行空转了
    if (self.repeat && taskBlock) {
        [self start:taskBlock];
    }
}

@end
