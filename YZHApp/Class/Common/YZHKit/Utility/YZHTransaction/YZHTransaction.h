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

@interface YZHTransaction : NSObject


+ (YZHTransaction *)transactionWithTransactionId:(NSString *)transactionId action:(YZHTransactionActionBlock)actionBlock;

- (NSString *)transactionId;

- (void)commit;

@end

NS_ASSUME_NONNULL_END
