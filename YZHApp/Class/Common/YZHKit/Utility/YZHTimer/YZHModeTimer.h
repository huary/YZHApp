//
//  YZHModeTimer.h
//  Action
//
//  Created by yuan on 2020/8/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class YZHModeTimer;
typedef void(^YZHModeTimerTaskBlock)(YZHModeTimer *timer);

//这个是需要在主线程运行的timer
@interface YZHModeTimer : NSObject

/** 是否循环执行 */
@property (nonatomic, assign) BOOL repeat;

/** 运行模式 */
@property (nonatomic, strong) NSRunLoopMode mode;

/** 时间间隔 */
@property (nonatomic, assign) NSTimeInterval timeInterval;

/** 默认的taskBlock，默认为空 */
@property (nonatomic, copy, nullable) YZHModeTimerTaskBlock defaultTaskBlock;

- (void)start;

//用这个taskBlock来开启定时,在repeat的时候，用这个taskBlock去执行下一轮，如果这个为空，就取defaultTaskBlock
- (void)start:(YZHModeTimerTaskBlock _Nullable)taskBlock;

//在after后执行
- (void)startAfter:(NSTimeInterval)after taskBlock:(YZHModeTimerTaskBlock _Nullable)taskBlock;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
