//
//  AppDataManager.m
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "AppDataManager.h"

static AppDataManager *shareDataManager_s = nil;

@implementation AppDataManager

+(instancetype)shareDataManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareDataManager_s = [[super allocWithZone:NULL] init];
        [shareDataManager_s _setupDefaultValue];
    });
    return shareDataManager_s;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [AppDataManager shareDataManager];
}

-(id)copyWithZone:(struct _NSZone *)zone
{
    return [AppDataManager shareDataManager];
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
