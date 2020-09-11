//
//  YZHPaymentRestoreInfo.m
//  YZHApp
//
//  Created by yuan on 2020/4/17.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "YZHPaymentRestoreInfo.h"

@implementation YZHPaymentRestoreInfo

- (instancetype)initWithUserId:(NSString * _Nullable)userId
             restoreCompletion:(YZHPaymentTransactionsRestoreCompletionBlock _Nullable)restoreCompletionBlock;
{
    self = [super init];
    if (self) {
        self.userId = userId;
        self.remainRestorePaymentTransactionCount = 0;
        self.restoreCompletionBlock = restoreCompletionBlock;
    }
    return self;
}

- (NSMutableArray<SKPaymentTransaction *> *)restoredPaymentTransactions
{
    if (_restoredPaymentTransactions == nil) {
        _restoredPaymentTransactions = [NSMutableArray array];
    }
    return _restoredPaymentTransactions;
}



@end
