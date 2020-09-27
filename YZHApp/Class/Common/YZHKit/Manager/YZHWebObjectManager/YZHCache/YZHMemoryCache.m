//
//  YZHMemoryCache.m
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/5.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHMemoryCache.h"
#import "YZHKitType.h"
#import "NSMapTable+YZHAdd.h"

#define MUTEX_LOCK(L)       dispatch_semaphore_wait(L, DISPATCH_TIME_FOREVER);
#define MUTEX_UNLOCK(L)     dispatch_semaphore_signal(L)


@interface YZHMemoryCacheObject : NSObject
//{
//
//    //缓存对象
//    id _target;
//    __weak id _key;
//}

/* <#注释#> */
@property (nonatomic, weak) YZHMemoryCacheObject *prev;
/* <#注释#> */
@property (nonatomic, weak) YZHMemoryCacheObject *next;

/* <#注释#> */
@property (nonatomic, strong, readonly) id target;

/* <#注释#> */
@property (nonatomic, weak, readonly) id key;

//消耗内存大小
@property (nonatomic, assign) NSUInteger cost;

//访问的次数
@property (nonatomic, assign) NSUInteger accessCnt;

@end


@implementation YZHMemoryCacheObject

-(instancetype)initWithTarget:(id)target forKey:(id)key
{
    if (!target) {
        return nil;
    }
    self = [super init];
    if (self) {
        [self _setupDefault];
        _target = target;
        _key = key;
    }
    return self;
}

-(void)_setupDefault
{
}

@end

static YZHMemoryCache *shareMemoryCache_s = nil;


@interface YZHMemoryCache <KeyType, ObjectType> ()
//UI
/* <#注释#> */
@property (nonatomic, strong) NSMapTable<KeyType, ObjectType> *cache;

/* <#注释#> */
@property (nonatomic, strong) dispatch_semaphore_t lock;

/* <#注释#> */
@property (nonatomic, weak) YZHMemoryCacheObject *head;
/* <#注释#> */
@property (nonatomic, weak) YZHMemoryCacheObject *tail;

/* <#name#> */
@property (nonatomic, assign) NSUInteger totalCost;

@end

@implementation YZHMemoryCache

+(instancetype)shareMemoryCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareMemoryCache_s = [[YZHMemoryCache alloc] init];
    });
    return shareMemoryCache_s;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefault];
    }
    return self;
}

-(void)_setupDefault
{
    self.name = @"com.YZHMemoryCache";
    self.cache = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    self.lock = dispatch_semaphore_create(1);
    
    [self _addNotification:YES];
}

-(void)_addNotification:(BOOL)add
{
    if (add) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_memoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
}

-(void)_memoryWarning:(NSNotification*)notification
{
    NSInteger cnt = MAX(self.cache.count/2, 1);
    NSArray *deleteList = [self _deleteLastObjects:cnt];
    [self _dispatchDeleteList:deleteList];
}

-(YZHMemoryCacheObject*)_getObjectForKey:(id)key
{
    MUTEX_LOCK(self.lock);
    YZHMemoryCacheObject *object = [self.cache objectForKey:key];
    if (!object) {
        MUTEX_UNLOCK(self.lock);
        return nil;
    }
    
    //增加访问次数
    ++object.accessCnt;
    //移动到最前面
    if (object == self.head || self.cache.count == 1) {
        MUTEX_UNLOCK(self.lock);
        return object;
    }

    //先取出
    YZHMemoryCacheObject *prev = object.prev;
    prev.next = object.next;
    object.next.prev = prev;
    //再插入头部
    object.next = self.head;
    object.prev = nil;
    
    self.head.prev = object;
    self.head = object;
    
    //尾部的next为nil
    self.tail.next = nil;
    
    MUTEX_UNLOCK(self.lock);
    return object;
}

-(YZHMemoryCacheObject*)_addObject:(id)object forKey:(id)key cost:(NSUInteger)cost
{
    YZHMemoryCacheObject *target = [[YZHMemoryCacheObject alloc] initWithTarget:object forKey:key];
    target.cost = cost;
    //存入cache
    MUTEX_LOCK(self.lock);
    
    self.totalCost += cost;
    [self.cache setObject:target forKey:key];
    
    if (!target) {
        MUTEX_UNLOCK(self.lock);
        return nil;
    }
    NSInteger cnt = self.cache.count;
    if (cnt <= 1) {
        self.head = self.tail = (cnt == 1) ? target : nil;
    }
    else {
        //存入最前面
        self.head.prev = target;
        target.next = self.head;
        self.head = target;
    }
    MUTEX_UNLOCK(self.lock);
    return target;
}

-(YZHMemoryCacheObject*)_deleteObjectForKey:(id)key
{
    MUTEX_LOCK(self.lock);
    YZHMemoryCacheObject *object = [self.cache objectForKey:key];
    self.totalCost = (self.totalCost > object.cost) ? self.totalCost - object.cost : 0;
    [self.cache removeObjectForKey:key];
    
    YZHMemoryCacheObject *prev = object.prev;
    YZHMemoryCacheObject *next = object.next;
    
    next.prev = prev;
    prev.next = next;
    
    if (object == self.head) {
        self.head = next;
        self.head.prev = nil;
    }
    
    if (object == self.tail) {
        self.tail = prev;
        self.tail.next = nil;
    }
    
    MUTEX_UNLOCK(self.lock);
    
    return object;
}

-(NSArray<YZHMemoryCacheObject*>*)_deleteLastObjects:(NSInteger)cnt
{
    if (cnt == 0) {
        return nil;
    }
    NSMutableArray<YZHMemoryCacheObject*> *deleteList = [NSMutableArray array];
    MUTEX_LOCK(self.lock);
    NSInteger i = 0;
    NSUInteger deleteCost = 0;
    for (i = 0; i < cnt; ++i) {
        YZHMemoryCacheObject *object = self.tail;
        if (!object) {
            break;
        }
        deleteCost += object.cost;
        [deleteList addObject:object];
        
        if (self.tail == self.head) {
            self.head = nil;
        }
        self.tail = self.tail.prev;
        self.tail.next = nil;
    }
    
    self.totalCost = (self.totalCost > deleteCost) ? self.totalCost - deleteCost : 0;
    
    [deleteList enumerateObjectsUsingBlock:^(YZHMemoryCacheObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.cache removeObjectForKey:obj.key];
    }];
    
    if (self.cache.count == 0) {
        self.head = self.tail = nil;
    }
    
    MUTEX_UNLOCK(self.lock);
    return deleteList;
}


- (id)objectForKey:(id)key
{
    YZHMemoryCacheObject *object = [self _getObjectForKey:key];
    return object.target;
}

- (void)setObject:(id)obj forKey:(id)key
{
    [self setObject:obj forKey:key cost:0];
}

- (void)setObject:(id)obj forKey:(id)key cost:(NSUInteger)cost
{
    //方法1不严谨
//    [self _addObject:obj forKey:key cost:cost];
//    //在这里进行检测的时候不太严谨
//    if (self.totalCostLimit > 0) {
//
//    }
//    if (self.countLimit > 0 && self.countLimit < self.cache.count) {
//        NSInteger deleteCnt = self.cache.count - self.countLimit;
//        NSArray *deleteList = [self _deleteLastObjects:deleteCnt];
//        [self _dispatchDeleteList:deleteList];
//    }
    //方法2
    YZHMemoryCacheObject *object = [[YZHMemoryCacheObject alloc] initWithTarget:obj forKey:key];
    object.cost = cost;
    //存入cache
    MUTEX_LOCK(self.lock);
    
    self.totalCost += cost;
    [self.cache setObject:object forKey:key];
    
    if (object) {
        NSInteger cnt = self.cache.count;
        if (cnt <= 1) {
            self.head = self.tail = (cnt == 1) ? object : nil;
        }
        else {
            //存入最前面
            self.head.prev = object;
            object.next = self.head;
            self.head = object;
        }
    }
    //从head开始检测totalCostLimit、countLimit
    NSMutableArray<YZHMemoryCacheObject*> *deleteList = [NSMutableArray array];
    
    if (self.countLimit > 0 || self.totalCostLimit > 0) {
        NSUInteger totalCost = 0;
        NSUInteger cnt = 0;
        YZHMemoryCacheObject *step = self.head;
        while (step) {
            ++cnt;
            totalCost += step.cost;
            step = step.next;
            if ((self.countLimit > 0 && cnt >= self.countLimit) || (self.totalCostLimit > 0 && totalCost >= self.totalCostLimit)) {
                break;
            }
        }
        //如果有找到的话，后面的所有object全部需要delete
        if (step != self.head && step) {
            self.tail = step.prev;
            self.tail.next = nil;
            step.prev = nil;
            while (step) {
                [deleteList addObject:step];
                step = step.next;
            }
        }
    }
    
    //删除
    __block NSUInteger deleteCost = 0;
    [deleteList enumerateObjectsUsingBlock:^(YZHMemoryCacheObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        deleteCost += obj.cost;
        [self.cache removeObjectForKey:obj.key];
    }];
    self.totalCost = (self.totalCost > deleteCost) ? self.totalCost - deleteCost : 0;
    
    MUTEX_UNLOCK(self.lock);
    
    //发送删除的信息
    [self _dispatchDeleteList:deleteList];
}

- (void)removeObjectForKey:(id)key
{
    YZHMemoryCacheObject *obj = [self _deleteObjectForKey:key];
    if (obj) {
        [self _dispatchDeleteList:@[obj]];
    }
}

-(void)removeAllObjects
{
    MUTEX_LOCK(self.lock);
    NSArray *allValues = [self.cache hz_allValues];
    [self.cache removeAllObjects];
    MUTEX_UNLOCK(self.lock);
    [self _dispatchDeleteList:allValues];
}

-(NSArray*)allCacheValues
{
    MUTEX_LOCK(self.lock);
    
    NSArray *allValues = [self.cache hz_allValues];

    MUTEX_UNLOCK(self.lock);
    
    return allValues;
}

-(NSArray*)allCacheKeys
{
    MUTEX_LOCK(self.lock);
    
    NSArray *allKeys = [self.cache hz_allKeys];
    
    MUTEX_UNLOCK(self.lock);
    
    return allKeys;
}

#pragma mark dispath delegate
-(void)_dispatchDeleteList:(NSArray<YZHMemoryCacheObject*>*)deleteList
{
    if (!IS_AVAILABLE_NSSET_OBJ(deleteList)) {
        return;
    }
    dispatch_async_in_main_queue(^{
        if ([self.delegate respondsToSelector:@selector(memoryCache:willEvictObjects:)]) {
            [self.delegate memoryCache:self willEvictObjects:deleteList];
        }
    });
}

-(void)dealloc
{
    [self.cache removeAllObjects];
    [self _addNotification:NO];
}


@end
