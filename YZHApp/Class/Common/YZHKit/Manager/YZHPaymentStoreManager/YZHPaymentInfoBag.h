//
//  YZHPaymentInfoBag.h
//  YZHApp
//
//  Created by yuan on 2020/4/17.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHProductsResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZHPaymentInfoBag : NSObject

- (YZHProductsResponse *)productsRequestResp;

- (SKPaymentTransaction *)paymentTransaction;

- (float)downloadProgress;

- (SKDownload *)download;

- (NSError *)error;

@end

NS_ASSUME_NONNULL_END
