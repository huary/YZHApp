//
//  YZHPaymentRestoreInfo.h
//  YZHApp
//
//  Created by yuan on 2020/4/17.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHPaymentStore.h"

NS_ASSUME_NONNULL_BEGIN

//typedef NS_ENUM(NSInteger, YZHPaymentRestoreState)
//{
//    YZHPaymentRestoreStateRequest     = 0,
//    YZHPaymentRestoreStateSucceed     = 1,
//    YZHPaymentRestoreStateFailed      = 2,
//};


@interface YZHPaymentRestoreInfo : NSObject

@property (nonatomic, copy) NSString *userId;

//@property (nonatomic, assign) YZHPaymentRestoreState restoreState;
@property (nonatomic, strong) NSError *firstError;

@property (nonatomic, assign) BOOL restoreCompletedTransactionFinished;

@property (nonatomic, assign) NSInteger remainRestorePaymentTransactionCount;

@property (nonatomic, strong) NSMutableArray<SKPaymentTransaction *> *restoredPaymentTransactions;

@property (nonatomic, copy, nullable) YZHPaymentTransactionsRestoreCompletionBlock restoreCompletionBlock;

- (instancetype)initWithUserId:(NSString * _Nullable)userId
             restoreCompletion:(YZHPaymentTransactionsRestoreCompletionBlock _Nullable)restoreCompletionBlock;

@end

NS_ASSUME_NONNULL_END
