//
//  AppDBManager.h
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CHECK_DB_QUEUE          NSAssert([[DBManager shareDBManager] isDBExecuteQueue], @"must execute in DBQueue")

typedef id(^DBExecuteBlock)(void);
typedef id(^DBExecuteDBBlock)(void *db);
typedef BOOL(^DBTransactionBlock)(void);
typedef void(^DBExecuteCompletionBlock)(id result);

@interface AppDBManager : NSObject

//@property (nonatomic, strong) id db;

+(instancetype)shareDBManager;

-(dispatch_queue_t)dbExecuteQueue;

-(void)addDBExecute:(DBExecuteBlock)executeBlock completionBlock:(DBExecuteCompletionBlock)completionBlock;

//-(void)addDBExecuteDB:(DBExecuteDBBlock)executeBlock completionBlock:(DBExecuteCompletionBlock)completionBlock;

-(void)addDBTransaction:(DBTransactionBlock)transactionBlock completionBlock:(DBExecuteCompletionBlock)completionBlock;

-(BOOL)isDBExecuteQueue;

@end
