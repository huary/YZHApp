//
//  YZHJSONDict.m
//  YZHApp
//
//  Created by yuan on 2020/4/14.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "YZHJSONDict.h"

@interface YZHJSONDict ()

/** Json */
@property (nonatomic, strong) NSMutableDictionary *dict;

/** 线程安全访问的锁 */
@property (nonatomic, strong, readonly) dispatch_semaphore_t lock;

@end

@implementation YZHJSONDict

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}


/**
 用字典直接初始化
 
 @param dictionary 输入字典
 @return 示例对象
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        if (dictionary) {
            if ([NSJSONSerialization isValidJSONObject:dictionary] && [dictionary isKindOfClass:NSDictionary.class]) {
                sync_lock(self.lock, ^{
                    [self.dict addEntriesFromDictionary:dictionary];
                });
            }
        }
    }
    return self;
}


/**
 从Json字符串化初始化转换成dictionary
 
 @param JSONString Json序列化后转为的字符串
 @return 示例对象
 */
- (instancetype)initWithJSONString:(NSString *)JSONString
{
    self = [self init];
    if (self && JSONString.length > 0) {
        NSData *data = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!error) {
            if ([dict isKindOfClass:NSDictionary.class]) {
                sync_lock(self.lock, ^{
                    self.dict = [dict mutableCopy];
                });
            } else {
                NSLog(@"JSONObjectWithData data type error:%@", error);
            }
        } else {
            NSLog(@"JSONObjectWithData error:%@", error);
        }
    }
    return self;
}

/**
 从JsonData初始化转换成dictionary
 
 @param JSONData Json序列化后转为的字符串
 @return 示例对象
 */
- (instancetype)initWithJSONData:(NSData *)JSONData
{
    self = [self init];
    if (self && JSONData.length > 0) {
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
        if (!error) {
            if ([dict isKindOfClass:NSDictionary.class]) {
                sync_lock(self.lock, ^{
                    self.dict = [dict mutableCopy];
                });
            } else {
                NSLog(@"JSONObjectWithData data type error:%@", error);
            }
        } else {
            NSLog(@"JSONObjectWithData error:%@", error);
        }
    }
    return self;
}


- (NSMutableDictionary *)dict
{
    if (_dict == nil) {
        _dict = [NSMutableDictionary dictionary];
    }
    return _dict;
}

/**
 通过key获取对象
 
 @param key key
 @return key对应的对象
 */
- (id)objectForKey:(id)key
{
    if (!key) {
        return nil;
    }
    __block id object = nil;
    sync_lock(self.lock, ^{
        object = [self.dict objectForKey:key];
    });
    return object;
}

/**
 设置key对应的object对象
 @param object object对象
 @param key 关键值
 @return 是否成功，成功为YES,失败为NO
 */
- (BOOL)setObject:(id)object forKey:(id)key
{
    if (key == nil) {
        return NO;
    }
    if (object) {
        if (![NSJSONSerialization isValidJSONObject:@{key : object}]) {
            return NO;
        }
        sync_lock(self.lock, ^{
            [self.dict setObject:object forKey:key];
        });
    }
    else {
        sync_lock(self.lock, ^{
            [self.dict removeObjectForKey:key];
        });
    }
    return YES;
}



/**
 返回dictionary
 
 @return NSDictionary
 */
- (NSDictionary *)dictionary
{
    __block NSDictionary *dict = nil;
    sync_lock(self.lock, ^{
        dict = [self.dict copy];
    });
    return dict;
}



/**
 进行Json序列化，
 @return  返回Json编码后的字符串
 */
- (NSString *)encodeToJSONString
{
    __block NSData *jsonData = nil;
    sync_lock(self.lock, ^{
        jsonData = [NSJSONSerialization dataWithJSONObject:self.dict options:0 error:NULL];
    });
    if (jsonData == nil) {
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"dict:%@",self.dict];
}


@end
