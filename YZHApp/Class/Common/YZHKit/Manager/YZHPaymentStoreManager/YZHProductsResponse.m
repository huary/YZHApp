//
//  YZHProductsResponse.m
//  YZHApp
//
//  Created by yuan on 2020/4/15.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "YZHProductsResponse.h"

@implementation YZHProductsResponse

- (instancetype)initWithSKProductsResponse:(SKProductsResponse *)response
{
    self = [super init];
    if (self) {
        NSMutableArray *array = [NSMutableArray array];
        for (SKProduct *p in response.products) {
            [array addObject:p.productIdentifier];
        }
        _productIds = [array copy];
        _invalidProductIds = response.invalidProductIdentifiers;
    }
    return self;
}

@end
