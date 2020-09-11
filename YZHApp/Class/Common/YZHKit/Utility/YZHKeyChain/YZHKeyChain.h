//
//  YZHKeyChain.h
//  YZHApp
//
//  Created by yuan on 2020/4/14.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@class YZHKeyChain;
typedef NSData *_Nullable(^YZHKeyChainItemEncodeBlock)(YZHKeyChain *keyChain, id object);
typedef id _Nullable(^YZHKeyChainItemDecodeBlock)(YZHKeyChain *keyChain, NSData *data);

@interface YZHKeyChain : NSObject

//为了效率，为非线程安全的访问
- (instancetype)initWithAccount:(NSString *)account service:(NSString *)service;

- (instancetype)initWithAccount:(NSString *)account service:(NSString *)service accessGroup:(NSString * _Nullable)accessGroup;

- (BOOL)updateAccount:(NSString *)account;

- (NSData * _Nullable)queryItem;

- (BOOL)saveItem:(NSData * _Nullable)itemData;

- (BOOL)deleteItem;

@end


@interface YZHCodeKeyChain : YZHKeyChain

@property (nonatomic, copy, nullable) YZHKeyChainItemEncodeBlock encodeBlock;

@property (nonatomic, copy, nullable) YZHKeyChainItemDecodeBlock decodeBlock;

@end


@interface YZHDictKeyChain : YZHCodeKeyChain

- (NSDictionary * _Nullable)queryDictItem;

- (BOOL)saveDictItem:(NSDictionary * _Nullable)dictItem;

//如果object为nil，则移除，否则添加
- (BOOL)saveObject:(id _Nullable)object forKey:(id _Nonnull)key;

@end

NS_ASSUME_NONNULL_END
