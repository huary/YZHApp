//
//  YZHPaymentOrder+Private.h
//  YZHApp
//
//  Created by yuan on 2020/4/17.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "YZHPaymentOrder.h"

typedef NS_ENUM(NSInteger, YZHPaymentOrderState)
{
    YZHPaymentOrderStateRequest     = 0,
    YZHPaymentOrderStateSucceed     = 1,
    YZHPaymentOrderStateFailed      = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface YZHPaymentOrder () <NSCoding>

/** 订单Id */
@property (nonatomic, copy) NSString *orderId;

/** 外部传入的userId */
@property (nonatomic, copy) NSString *userId;

/** 外部传输的userId */
@property (nonatomic, copy) NSString *extraInfo;

/** productId */
@property (nonatomic, copy) NSString *productId;

/** 交易Id */
@property (nonatomic, copy) NSString *transactionId;

/** 添加到paymentQueue的时间，毫秒 */
@property (nonatomic, assign) int64_t orderTime;

/** 订单状态 */
@property (nonatomic, assign) YZHPaymentOrderState orderState;

- (instancetype)initWithOrderId:(NSString * _Nullable)orderId userId:(NSString * _Nullable)userId extraInfo:(NSString * _Nullable)extraInfo productId:(NSString * _Nullable)productId;


@end

NS_ASSUME_NONNULL_END
