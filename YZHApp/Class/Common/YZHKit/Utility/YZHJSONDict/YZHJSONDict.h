//
//  YZHJSONDict.h
//  YZHApp
//
//  Created by yuan on 2020/4/14.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
是一个线程安全访问的对象
*/
@interface YZHJSONDict : NSObject

/**
 用字典直接初始化
 
 @param dictionary 输入字典
 @return 示例对象
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 从Json字符串化初始化转换成dictionary
 
 @param JSONString Json序列化后转为的字符串
 @return 示例对象
 */
- (instancetype)initWithJSONString:(NSString *)JSONString;

/**
 从JsonData初始化转换成dictionary
 
 @param JSONData Json序列化后转为的字符串
 @return 示例对象
 */
- (instancetype)initWithJSONData:(NSData *)JSONData;

/**
 通过key获取对象

 @param key key
 @return key对应的对象
 */
- (id)objectForKey:(id)key;

/**
 设置key对应的object对象
 @param object object对象
 @param key 关键值
 @return 是否成功，成功为YES,失败为NO
 */
- (BOOL)setObject:(id)object forKey:(id)key;

/**
 返回dictionary

 @return NSDictionary
 */
- (NSDictionary *)dictionary;


/**
 进行Json序列化，
 @return  返回Json编码后的字符串
 */
- (NSString *)encodeToJSONString;


@end

NS_ASSUME_NONNULL_END
