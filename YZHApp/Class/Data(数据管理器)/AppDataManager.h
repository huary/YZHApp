//
//  AppDataManager.h
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppBSUser.h"

@interface AppDataManager : NSObject


+(instancetype)shareDataManager;

@property (nonatomic, strong, readonly) AppBSUser *lastLoginUser;

@property (nonatomic, strong) AppBSUser *currentUser;


-(void)save;

-(BOOL)isLogin;

-(void)doLogout;
@end
