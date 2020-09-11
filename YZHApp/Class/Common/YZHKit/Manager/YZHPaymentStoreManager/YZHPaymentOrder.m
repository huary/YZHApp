//
//  YZHPaymentOrder.m
//  YZHApp
//
//  Created by yuan on 2020/4/17.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "YZHPaymentOrder.h"
#import "YZHPaymentOrder+Private.h"

@implementation YZHPaymentOrder

- (instancetype)initWithOrderId:(NSString * _Nullable)orderId userId:(NSString * _Nullable)userId extraInfo:(NSString * _Nullable)extraInfo productId:(NSString * _Nullable)productId
{
    self = [super init];
    if (self) {
        self.orderId = orderId;
        self.userId = userId;
        self.extraInfo = extraInfo;
        self.productId = productId;
        self.orderState = YZHPaymentOrderStateRequest;
        self.orderTime = MSEC_FROM_DATE_SINCE1970_NOW;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.orderId = [coder decodeObjectForKey:@"orderId"];
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.extraInfo = [coder decodeObjectForKey:@"extraInfo"];
        self.productId = [coder decodeObjectForKey:@"productId"];
        self.transactionId = [coder decodeObjectForKey:@"transactionId"];
        self.orderTime = [coder decodeInt64ForKey:@"orderTime"];
        self.orderState = [coder decodeIntegerForKey:@"orderState"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:NSSTRING_SAFE_GET_NONULL_VAL(self.orderId) forKey:@"orderId"];
    [coder encodeObject:NSSTRING_SAFE_GET_NONULL_VAL(self.userId) forKey:@"userId"];
    [coder encodeObject:NSSTRING_SAFE_GET_NONULL_VAL(self.extraInfo) forKey:@"extraInfo"];
    [coder encodeObject:NSSTRING_SAFE_GET_NONULL_VAL(self.productId) forKey:@"productId"];
    [coder encodeObject:NSSTRING_SAFE_GET_NONULL_VAL(self.transactionId) forKey:@"transactionId"];
    [coder encodeInt64:self.orderTime forKey:@"orderTime"];
    [coder encodeInteger:self.orderState forKey:@"orderState"];
}

- (NSString *)orderId
{
    return _orderId;
}

- (NSString *)appUserId
{
    return self.userId;
}

- (NSString *)appExtraInfo
{
    return self.extraInfo;
}

@end
