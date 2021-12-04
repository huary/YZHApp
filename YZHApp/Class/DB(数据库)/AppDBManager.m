//
//  AppDBManager.m
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "AppDBManager.h"

#define DBQUEUE_KEY "DBQueue_Key"


@interface AppDBManager ()

@property (nonatomic, strong) NSString *DBPath;

@property (nonatomic, strong) dispatch_queue_t dbQueue;


@end

@implementation AppDBManager

+(instancetype)sharedDBManager
{
    static AppDBManager *sharedDBManager_s = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDBManager_s = [[super allocWithZone:NULL] init];
    });
    return sharedDBManager_s;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [AppDBManager sharedDBManager];
}

-(id)copyWithZone:(struct _NSZone *)zone
{
    return [AppDBManager sharedDBManager];
}

-(NSString*)DBPath
{
    if (_DBPath == nil) {
        NSString *suffix = @"";
        NSString *path = [YZHUtil applicationDocumentsDirectory:NEW_STRING_WITH_FORMAT(@"%@/DB",suffix)];
        [YZHUtil checkAndCreateDirectory:path];
        _DBPath = path;
    }
    return _DBPath;
}

-(dispatch_queue_t)dbQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dbQueue = dispatch_queue_create("dbQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_dbQueue, DBQUEUE_KEY, (__bridge void *)self, NULL);
    });
    return _dbQueue;
}

-(void)_addDBExecute:(DBExecuteBlock)executeBlock inQueue:(dispatch_queue_t)queue completionBlock:(DBExecuteCompletionBlock)completionBlock
{
    dispatch_async(queue, ^{
        id retObj = nil;
        if (executeBlock) {
            retObj = executeBlock();
        }
        if (completionBlock) {
            dispatch_async_in_main_queue(^{
                completionBlock(retObj);
            });
        }
    });
}

//-(void)_addDBExecuteDB:(DBExecuteDBBlock)executeBlock inQueue:(dispatch_queue_t)queue completionBlock:(DBExecuteCompletionBlock)completionBlock
//{
//    WEAK_SELF(weakSelf);
//    dispatch_async(queue, ^{
//        id retObj = nil;
//        if (executeBlock) {
//            retObj = executeBlock(weakSelf.db);
//        }
//        if (completionBlock) {
//            dispatch_async_in_main_queue(^{
//                completionBlock(retObj);
//            });
//        }
//    });
//}

-(dispatch_queue_t)dbExecuteQueue
{
    return self.dbQueue;
}

-(void)addDBExecute:(DBExecuteBlock)executeBlock completionBlock:(DBExecuteCompletionBlock)completionBlock
{
    [self _addDBExecute:executeBlock inQueue:self.dbQueue completionBlock:completionBlock];
}

//-(void)addDBExecuteDB:(DBExecuteDBBlock)executeBlock completionBlock:(DBExecuteCompletionBlock)completionBlock
//{
//    [self _addDBExecuteDB:executeBlock inQueue:self.dbQueue completionBlock:completionBlock];
//}

-(void)addDBTransaction:(DBTransactionBlock)transactionBlock completionBlock:(DBExecuteCompletionBlock)completionBlock
{
    if (!transactionBlock) {
        return;
    }
    [self _addDBExecute:^id{
        BOOL result = transactionBlock();
        return @(result);
    } inQueue:self.dbQueue completionBlock:completionBlock];
}

-(BOOL)isDBExecuteQueue
{
    void *ptr = dispatch_get_specific(DBQUEUE_KEY);
    return (ptr == (__bridge void *)self);
}




@end
