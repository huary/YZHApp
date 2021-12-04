//
//  AppDataManager.m
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "AppDataManager.h"


@implementation AppDataManager

+(instancetype)sharedDataManager
{
    static AppDataManager *sharedDataManager_s = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataManager_s = [[super allocWithZone:NULL] init];
        [sharedDataManager_s _setupDefaultValue];
    });
    return sharedDataManager_s;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [AppDataManager sharedDataManager];
}

-(id)copyWithZone:(struct _NSZone *)zone
{
    return [AppDataManager sharedDataManager];
}

-(void)_setupDefaultValue
{
}

-(void)save
{
}

-(BOOL)isLogin
{
    return self.currentUser ? YES : NO;
}

@end
