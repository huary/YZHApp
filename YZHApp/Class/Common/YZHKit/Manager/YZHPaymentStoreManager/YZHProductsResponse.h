//
//  YZHProductsResponse.h
//  YZHApp
//
//  Created by yuan on 2020/4/15.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZHProductsResponse : NSObject

/** <#注释#> */
@property (nonatomic, copy, readonly) NSArray<NSString *> *productIds;

/** <#注释#> */
@property (nonatomic, copy, readonly) NSArray<NSString *> *invalidProductIds;

- (instancetype)initWithSKProductsResponse:(SKProductsResponse *)response;

@end

NS_ASSUME_NONNULL_END
