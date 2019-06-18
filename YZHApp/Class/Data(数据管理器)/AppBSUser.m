//
//  AppBSUser.m
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "AppBSUser.h"
#import "YZHKitMacro.h"

@implementation AppBSUser

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.account = [aDecoder decodeObjectForKey:TYPE_STR(account)];
        self.password = [aDecoder decodeObjectForKey:TYPE_STR(password)];
//        self.appId = [aDecoder decodeObjectForKey:TYPE_STR(appId)];
        self.phone = [aDecoder decodeObjectForKey:TYPE_STR(phone)];
        self.email = [aDecoder decodeObjectForKey:TYPE_STR(email)];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:NSSTRING_SAFE_GET_NONULL_VAL(self.account) forKey:TYPE_STR(account)];
    [aCoder encodeObject:NSSTRING_SAFE_GET_NONULL_VAL(self.password) forKey:TYPE_STR(password)];
//    [aCoder encodeObject:NSSTRING_SAFE_GET_NONULL_VAL(self.appId) forKey:TYPE_STR(appId)];
    [aCoder encodeObject:NSSTRING_SAFE_GET_NONULL_VAL(self.phone) forKey:TYPE_STR(phone)];
    [aCoder encodeObject:NSSTRING_SAFE_GET_NONULL_VAL(self.email) forKey:TYPE_STR(email)];
}

@end
