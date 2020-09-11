//
//  YZHPaymentInfoBag.m
//  YZHApp
//
//  Created by yuan on 2020/4/17.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "YZHPaymentInfoBag.h"
#import "YZHPaymentInfoBag+Private.h"

@implementation YZHPaymentInfoBag

- (instancetype)initWithError:(NSError *)error
{
    self = [super init];
    if (self) {
        self.error = error;
    }
    return self;
}

- (instancetype)initWithProductsRequestResp:(YZHProductsResponse *)productsRequestResp
{
    self = [super init];
    if (self) {
        self.productsRequestResp = productsRequestResp;
    }
    return self;
}

- (instancetype)initWithPaymentTransaction:(SKPaymentTransaction *)paymentTransaction
{
    self = [super init];
    if (self) {
        self.paymentTransaction = paymentTransaction;
    }
    return self;
}

- (instancetype)initWithPaymentTransactions:(NSArray<SKPaymentTransaction *> * _Nullable)paymentTransactions
{
    self = [super init];
    if (self) {
        self.paymentTransactions = paymentTransactions;
    }
    return self;
}

- (instancetype)initWithDownload:(SKDownload *)download
{
    self = [super init];
    if (self) {
        self.download = download;
    }
    return self;
}

@end
