//
//  YZHTransaction.h
//  YZHApp
//
//  Created by yuan on 2020/9/11.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YZHTransaction;
typedef void(^YZHTransactionActionBlock)(YZHTransaction *transaction);
typedef id _Nullable (^YZHTransactionHandleDataBlock)(YZHTransaction *transaction);

@interface YZHTransaction : NSObject


+ (YZHTransaction *)transactionWithTransactionId:(NSString *)transactionId action:(YZHTransactionActionBlock)actionBlock;

+ (YZHTransaction *)transactionWithTransactionId:(NSString *)transactionId
                                     currentData:(id)currentData
                                      handleData:(YZHTransactionHandleDataBlock)handleDataBlock
                                          action:(YZHTransactionActionBlock)actionBlock;

- (NSString *)transactionId;

//当前的数据
- (id)curData;

//前面累计的数据
- (id)preData;

- (void)commit;

- (void)rollback;

@end

NS_ASSUME_NONNULL_END
