//
//  YZHTransaction.m
//  YZHApp
//
//  Created by yuan on 2020/9/11.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "YZHTransaction.h"
#import "YZHOrderSet.h"

static YZHOrderSet<NSString*, YZHTransaction*> *transactionSet_s = nil;

static void pri_setupTransaction(void);

@interface YZHTransaction ()

/** <#注释#> */
@property (nonatomic, strong) id curData;

/** preData */
@property (nonatomic, strong) id preData;

//transactionId
@property (nonatomic, copy) NSString *transactionId;

/** 执行的任务 */
@property (nonatomic, copy) YZHTransactionActionBlock actionBlock;

/** 处理数据的block */
@property (nonatomic, copy) YZHTransactionHandleDataBlock handleDataBlock;

@end

@implementation YZHTransaction

+ (YZHTransaction *)transactionWithTransactionId:(NSString *)transactionId action:(YZHTransactionActionBlock)actionBlock
{
    if (transactionId.length == 0 || actionBlock == nil) {
        return nil;
    }
    YZHTransaction *transaction = [YZHTransaction new];
    transaction.transactionId = transactionId;
    transaction.actionBlock = actionBlock;
    return transaction;
}

+ (YZHTransaction *)transactionWithTransactionId:(NSString *)transactionId
                                     currentData:(id)currentData
                                      handleData:(YZHTransactionHandleDataBlock)handleDataBlock
                                          action:(YZHTransactionActionBlock)actionBlock;
{
    if (transactionId.length == 0 || actionBlock == nil) {
        return nil;
    }
    YZHTransaction *transaction = [YZHTransaction new];
    transaction.curData = currentData;
    transaction.transactionId = transactionId;
    transaction.actionBlock = actionBlock;
    transaction.handleDataBlock = handleDataBlock;
    return transaction;
}

//当前的数据
- (id)curData {
    return _curData;
}

//前面累计的数据
- (id)preData {
    return _preData;
}

- (void)commit
{
    if (self.transactionId.length == 0 || self.actionBlock == nil) {
        return;
    }
    pri_setupTransaction();
    
    if (self.handleDataBlock) {
        YZHTransaction *transaction = [transactionSet_s objectForKey:self.transactionId];
        if (!transaction) {
            transaction = self;
        }
        transaction.curData = self.curData;
        self.preData = transaction.preData;
        transaction.preData = self.handleDataBlock(self);
    }
    [transactionSet_s addObject:self forKey:self.transactionId];
}

- (void)rollback
{
    [transactionSet_s removeObjectForKey:self.transactionId];
}

- (void)dealloc
{
    NSLog(@"transactionDealloc");
}

@end



static void pri_runloopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {

    if (transactionSet_s.count == 0) {
        return;
    }
    
    YZHOrderSet<NSString*, YZHTransaction*> *tmp = transactionSet_s;
    transactionSet_s = [YZHOrderSet new];
    [tmp enumerateKeysAndObjectsUsingBlock:^(YZHTransaction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.actionBlock(obj);
    }];
}

static void pri_setupTransaction(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet_s = [YZHOrderSet new];
        CFRunLoopRef runloop = CFRunLoopGetMain();
        CFRunLoopObserverRef observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                                                kCFRunLoopBeforeWaiting |
                                                                kCFRunLoopExit,
                                                                true,
                                                                0xFFFFFF,
                                                                pri_runloopObserverCallback,
                                                                NULL);
        
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}

