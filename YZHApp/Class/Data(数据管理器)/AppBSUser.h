//
//  AppBSUser.h
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppBSUser : NSObject<NSCoding>

/* 账号 */
@property (nonatomic, strong) NSString *account;

/* 密码 */
@property (nonatomic, strong) NSString *password;

/* 手机号 */
@property (nonatomic, strong) NSString *phone;

/* 邮箱号 */
@property (nonatomic, strong) NSString *email;

@end
