//
//  NSObject+YZHRefreshView.m
//  YZHApp
//
//  Created by yuan on 2018/12/6.
//  Copyright © 2018年 yuanzh. All rights reserved.
//

#import "NSObject+YZHRefreshView.h"
#import <objc/runtime.h>


@implementation NSObject (YZHRefreshView)


-(void)setHz_bindRefreshViewTable:(NSMapTable<id,UIResponder<YZHUIRefreshViewProtocol> *> *)hz_bindRefreshViewTable
{
    objc_setAssociatedObject(self, @selector(hz_bindRefreshViewTable), hz_bindRefreshViewTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMapTable<id,UIResponder<YZHUIRefreshViewProtocol>*> *)hz_bindRefreshViewTable
{
    NSMapTable *table =  objc_getAssociatedObject(self, _cmd);
    if (table == nil) {
        table = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
        self.hz_bindRefreshViewTable = table;
    }
    return table;
}

-(void)setHz_registerViewTable:(NSMapTable<id,UIResponder *> *)hz_registerViewTable
{
    objc_setAssociatedObject(self, @selector(hz_registerViewTable), hz_registerViewTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMapTable<id, UIResponder *>*)hz_registerViewTable
{
    NSMapTable *table = objc_getAssociatedObject(self, _cmd);
    if (table == nil) {
        table = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
        self.hz_registerViewTable = table;
    }
    return table;
}

-(YZHUIRefreshConditionBlock)_defaultConditionBlock
{
    YZHUIRefreshConditionBlock condition = ^BOOL(UIResponder<YZHUIRefreshViewProtocol> *refreshView, id model) {
        if (refreshView.hz_refreshModel == nil || refreshView.hz_refreshModel == model) {
            return YES;
        }
        return NO;
    };
    return condition;
}


-(void)hz_addRefreshView:(UIResponder<YZHUIRefreshViewProtocol>*)refreshView forKey:(id)key
{
    [self.hz_bindRefreshViewTable setObject:refreshView forKey:key];
}

//刷新所有绑定的view
-(BOOL)hz_refresh
{
    return [self hz_refresh:nil];
}

//根据刷新条件刷新所有绑定的view
-(BOOL)hz_refresh:(YZHUIRefreshConditionBlock)condition
{
    NSEnumerator *valueEnumerator = self.hz_bindRefreshViewTable.objectEnumerator;
    UIResponder<YZHUIRefreshViewProtocol> *refreshView = nil;
    while (refreshView = [valueEnumerator nextObject]) {
        [self hz_refreshView:refreshView condition:condition];
    }
    return YES;
}


//根据绑定的Key对view进行刷新
-(BOOL)hz_refreshViewWithKey:(id)key
{
    UIResponder<YZHUIRefreshViewProtocol> *refreshView = [self.hz_bindRefreshViewTable objectForKey:key];
    return [self hz_refreshView:refreshView];
}

//通过指定View镜像刷新
-(BOOL)hz_refreshView:(UIResponder<YZHUIRefreshViewProtocol>*)refreshView
{
    return [self hz_refreshView:refreshView condition:nil];
}

//根据条件，对绑定的Key对view进行刷新
-(BOOL)hz_refreshViewWithKey:(id)key condition:(YZHUIRefreshConditionBlock)condition
{
    UIResponder<YZHUIRefreshViewProtocol> *refreshView = [self.hz_bindRefreshViewTable objectForKey:key];
    return [self hz_refreshView:refreshView condition:condition];
}

//根据条件，对view进行刷新
-(BOOL)hz_refreshView:(UIResponder<YZHUIRefreshViewProtocol>*)refreshView condition:(YZHUIRefreshConditionBlock)condition
{
    if (refreshView == nil) {
        return NO;
    }
    BOOL r = NO;

    if (!condition) {
        condition = [self _defaultConditionBlock];
    }
    r = condition(refreshView, self);

    if (r) {
        if ([refreshView respondsToSelector:@selector(hz_refreshViewWithModel:)]) {
            r = [refreshView hz_refreshViewWithModel:self];
        }
        else if (refreshView.hz_refreshBlock) {
            r = refreshView.hz_refreshBlock(refreshView, self);
        }
    }
    return r;
}

-(UIResponder<YZHUIRefreshViewProtocol>*)hz_refreshViewForKey:(id)key
{
    return [self.hz_bindRefreshViewTable objectForKey:key];
}

-(NSArray<UIResponder<YZHUIRefreshViewProtocol>*>*)hz_allRefreshView
{
    NSMutableArray<UIResponder<YZHUIRefreshViewProtocol> *> *refreshViewList = [NSMutableArray array];
    NSEnumerator *valueEnumerator = self.hz_bindRefreshViewTable.objectEnumerator;
    UIResponder<YZHUIRefreshViewProtocol> *refreshView = nil;
    while (refreshView = [valueEnumerator nextObject]) {
        [refreshViewList addObject:refreshView];
    }
    return [refreshViewList copy];
}

-(void)hz_clearRefreshView:(UIResponder<YZHUIRefreshViewProtocol>*)refreshView
{
    NSEnumerator *keyEnumerator = self.hz_bindRefreshViewTable.keyEnumerator;
    id key = nil;
    while (key = [keyEnumerator nextObject]) {
        UIResponder<YZHUIRefreshViewProtocol> *refreshViewTmp = [self.hz_bindRefreshViewTable objectForKey:key];
        if (refreshViewTmp == refreshView) {
            break;
        }
    }
    [self.hz_bindRefreshViewTable removeObjectForKey:key];
}

-(void)hz_clearRefreshViewForKey:(id)key
{
    [self.hz_bindRefreshViewTable removeObjectForKey:key];
}

-(void)hz_clearAllRefreshView
{
    [self.hz_bindRefreshViewTable removeAllObjects];
}


/*
 *这里是通过注册View,
 *有这个方法的原因是因为view绑定的model（弱应用）已经释放，而需要刷新这个view的模型是通过某一个Id（key）
 *来进行的，就可以通过那个id（key）找到对应刷新view，然后进行刷新。
 */
-(void)hz_registerView:(UIResponder*)view ForRegisterKey:(id)registerKey
{
    [self.hz_registerViewTable setObject:view forKey:registerKey];
}

//通过在View中进行registerRefreshViewForRegisterKey来注册的view时的registerKey找到对应的
-(UIResponder*)hz_viewForRegisterKey:(id)registerKey
{
    return [self.hz_registerViewTable objectForKey:registerKey];
}

//清除某一个注册的key
-(void)hz_clearRegisterViewForRegisterKey:(id)registerKey
{
    [self.hz_registerViewTable removeObjectForKey:registerKey];
}

//清除所有的注册的view
-(void)hz_clearRegisterView
{
    [self.hz_registerViewTable removeAllObjects];
}
@end
