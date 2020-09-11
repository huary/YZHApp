//
//  YZHPaymentInfoBag+Private.h
//  YZHApp
//
//  Created by yuan on 2020/4/20.
//  Copyright © 2020 yuan. All rights reserved.
//
#import "YZHPaymentInfoBag.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZHPaymentInfoBag ()

/** <#注释#> */
@property (nonatomic, strong) YZHProductsResponse *productsRequestResp;

/** <#注释#> */
@property (nonatomic, strong) SKPaymentTransaction *paymentTransaction;

/** <#注释#> */
@property (nonatomic, copy) NSArray<SKPaymentTransaction *> *paymentTransactions;

/** <#name#> */
@property (nonatomic, assign) float downloadProgress;

/** <#注释#> */
@property (nonatomic, strong) SKDownload *download;

/** <#注释#> */
@property (nonatomic, strong) NSError *error;

- (instancetype)initWithError:(NSError *)error;

- (instancetype)initWithProductsRequestResp:(YZHProductsResponse *)productsRequestResp;

- (instancetype)initWithPaymentTransaction:(SKPaymentTransaction *)paymentTransaction;

- (instancetype)initWithPaymentTransactions:(NSArray<SKPaymentTransaction *> * _Nullable)paymentTransactions;

- (instancetype)initWithDownload:(SKDownload *)download;


@end

NS_ASSUME_NONNULL_END
