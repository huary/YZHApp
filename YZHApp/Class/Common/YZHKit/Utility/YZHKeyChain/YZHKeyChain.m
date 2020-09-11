//
//  YZHKeyChain.m
//  YZHApp
//
//  Created by yuan on 2020/4/14.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "YZHKeyChain.h"
#import "YZHJSONDict.h"

@interface YZHKeyChain ()

/** <#注释#> */
@property (nonatomic, copy) NSString *account;

/** <#注释#> */
@property (nonatomic, copy) NSString *service;

/** <#注释#> */
@property (nonatomic, copy) NSString *accessGroup;

@end

@implementation YZHKeyChain

+ (NSMutableDictionary *)_keyChainQuery:(NSString *)account service:(NSString *)service accessGroup:(NSString *)accessGroup
{
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    //kSecAttrAccessible的默认为kSecAttrAccessibleWhenUnlocked
//    [query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    [query setObject:account forKey:(__bridge id)kSecAttrAccount];
    [query setObject:service forKey:(__bridge id)kSecAttrService];
    if (accessGroup.length > 0  ) {
        [query setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
    return query;
}

- (instancetype)initWithAccount:(NSString *)account service:(NSString *)service
{
    return [self initWithAccount:account service:service accessGroup:nil];
}

- (instancetype)initWithAccount:(NSString *)account service:(NSString *)service accessGroup:(NSString * _Nullable)accessGroup
{
    self = [super init];
    if (self) {
        self.account = account;
        self.service = service;
        self.accessGroup = accessGroup;
    }
    return self;
}

- (BOOL)updateAccount:(NSString *)account
{
    if (account == nil) {
        account = @"";
    }
    NSMutableDictionary *query = [[self class] _keyChainQuery:self.account service:self.service accessGroup:self.accessGroup];
    NSDictionary *updateAttr = @{(__bridge id)kSecAttrAccount:account};
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateAttr);
    if (status == noErr || status == errSecItemNotFound) {
        self.account = account;
        return YES;
    }
    return NO;
}


- (NSData *)queryItem
{
    NSMutableDictionary *query = [[self class] _keyChainQuery:self.account service:self.service accessGroup:self.accessGroup];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [query setObject:@(YES) forKey:(__bridge id)kSecReturnData];
    
    CFTypeRef dataTypeRef = NULL;
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataTypeRef);
    NSData *data = nil;
    if (status == errSecSuccess) {
        data = (__bridge_transfer NSData *)dataTypeRef;
    }
    return data;
}

- (BOOL)saveItem:(NSData * _Nullable)itemData
{
    if (itemData == nil) {
        return [self deleteItem];
    }
    NSData *old = [self queryItem];
    OSStatus status = errSecSuccess;
    NSMutableDictionary *query = [[self class] _keyChainQuery:self.account service:self.service accessGroup:self.accessGroup];
    if (old) {
        NSDictionary *updateAttr = @{(__bridge id)kSecValueData:itemData};
        status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updateAttr);
    }
    else {
        [query setObject:itemData forKey:(__bridge id)kSecValueData];
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    }
    return status;
}

- (BOOL)deleteItem
{
    NSMutableDictionary *query = [[self class] _keyChainQuery:self.account service:self.service accessGroup:self.accessGroup];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
    if (status == noErr || status == errSecItemNotFound) {
        return YES;
    }
    return NO;
}

@end


@implementation YZHCodeKeyChain

@end


@interface YZHDictKeyChain ()

@property (nonatomic, strong, readonly) dispatch_semaphore_t lock;

@end

@implementation YZHDictKeyChain

- (instancetype)initWithAccount:(NSString *)account service:(NSString *)service
{
    return [self initWithAccount:account service:service accessGroup:nil];
}

- (instancetype)initWithAccount:(NSString *)account service:(NSString *)service accessGroup:(NSString *)accessGroup
{
    self = [super initWithAccount:account service:service accessGroup:accessGroup];
    if (self) {
        [self pri_setupDefault];
    }
    return self;
}

- (void)pri_setupDefault
{
    _lock = dispatch_semaphore_create(1);
    self.encodeBlock = ^NSData * _Nullable(YZHKeyChain * _Nonnull keyChain, id  _Nonnull object) {
        return [YZHUtil encodeObject:object forKey:nil];
    };
    self.decodeBlock = ^id _Nullable(YZHKeyChain * _Nonnull keyChain, NSData * _Nonnull data) {
        return [YZHUtil decodeObjectForData:data forKey:nil];
    };
}

- (NSDictionary * _Nullable)queryDictItem
{
    __block NSData *data = nil;
    sync_lock(self.lock, ^{
        data = [self queryItem];
    });
    id obj = self.decodeBlock(self, data);
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary*)obj;
    }
    return nil;
}

- (BOOL)saveDictItem:(NSDictionary * _Nullable)dictItem
{
    __block BOOL r = NO;
    NSData *saveData = self.encodeBlock(self, dictItem);
    sync_lock(self.lock, ^{
        r = [self saveItem:saveData];
    });
    return r;
}

//如果object为nil，则移除，否则添加
- (BOOL)saveObject:(id _Nullable)object forKey:(id _Nonnull)key
{
    if (key == nil) {
        return NO;
    }
    __block BOOL r = NO;
    sync_lock(self.lock, ^{
        NSData *data = [self queryItem];
        id obj = self.decodeBlock(self, data);
        NSMutableDictionary *dict = nil;
        if ([obj isKindOfClass:[NSDictionary class]]) {
            dict = [(NSDictionary*)obj mutableCopy];
        }
        if (object) {
            [dict setObject:object forKey:key];
        }
        else {
            [dict removeObjectForKey:key];
        }
        NSData *saveData = self.encodeBlock(self, dict);
        r = [self saveItem:saveData];
    });
    return r;
}

@end
