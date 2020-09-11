//
//  YZHPaymentOrder.h
//  YZHApp
//
//  Created by yuan on 2020/4/17.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZHPaymentOrder : NSObject

/** 本地的订单Id */
@property (nonatomic, copy, readonly) NSString *orderId;

/** <#注释#> */
@property (nonatomic, copy, readonly) NSString *appUserId;

/** <#注释#> */
@property (nonatomic, copy, readonly) NSString *appExtraInfo;

@end

NS_ASSUME_NONNULL_END
