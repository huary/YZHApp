//
//  NSObject+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "NSObject+YZHAdd.h"
#import <objc/runtime.h>
#import "YZHKitMacro.h"

typedef id(^WeakReferenceObjectBlock)(void);

@implementation NSObject (YZHAdd)

-(void)setIdentity:(NSInteger)identity
{
    objc_setAssociatedObject(self, @selector(identity), @(identity), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)identity
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

-(void)setIdentityString:(NSString *)identityString
{
    objc_setAssociatedObject(self, @selector(identityString), identityString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)identityString
{
    return objc_getAssociatedObject(self, _cmd);
}


//weak reference object
//single
-(void)setWeakReferenceObject:(id)weakReferenceObject
{
    WEAK_NSOBJ(weakReferenceObject, weakObject);
    WeakReferenceObjectBlock block = ^{
        return weakObject;
    };
    objc_setAssociatedObject(self, @selector(weakReferenceObject), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(id)weakReferenceObject
{
    WeakReferenceObjectBlock block = objc_getAssociatedObject(self, _cmd);
    id weakObject = (block ? block() : nil);
    return weakObject;
}

//multi
-(void)setWeakReferenceObjectsTable:(NSMapTable *)weakReferenceObjectsTable
{
    objc_setAssociatedObject(self, @selector(weakReferenceObjectsTable), weakReferenceObjectsTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMapTable*)weakReferenceObjectsTable
{
    NSMapTable *mapTable = objc_getAssociatedObject(self, _cmd);
    if (!mapTable) {
        mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
        self.weakReferenceObjectsTable = mapTable;
    }
    return mapTable;
}

-(void)setStrongReferenceObjectsTable:(NSMapTable *)strongReferenceObjectsTable
{
    objc_setAssociatedObject(self, @selector(strongReferenceObjectsTable), strongReferenceObjectsTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMapTable*)strongReferenceObjectsTable
{
    NSMapTable *table = objc_getAssociatedObject(self, _cmd);
    if (!table) {
        table = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        self.strongReferenceObjectsTable = table;
    }
    return table;
}

-(id)respondsAndPerformSelector:(SEL)selector;
{
    if (selector == NULL) {
        return nil;
    }
    id obj = nil;
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        obj = [self performSelector:selector];
#pragma clang diagnostic pop
    }
    return obj;
}

-(id)respondsAndPerformSelector:(SEL)selector withObject:(id)object
{
    if (selector == NULL) {
        return nil;
    }
    id obj = nil;
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        obj = [self performSelector:selector withObject:object];
#pragma clang diagnostic pop
    }
    return obj;
}

+(id)respondsToSelector:(SEL)selector forClass:(Class)cls
{
    if (selector == NULL || cls == NULL) {
        return nil;
    }
    id obj = nil;
    if([cls respondsToSelector:selector]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        obj = [cls performSelector:selector];
#pragma clang diagnostic pop
    }
    return obj;
}

+(id)respondsToSelector:(SEL)selector forClass:(Class)cls withObject:(id)object
{
    if (selector == NULL || cls == NULL) {
        return nil;
    }
    id obj = nil;
    if ([cls respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        obj = [cls performSelector:selector withObject:object];
#pragma clang diagnostic pop
    }
    return obj;
}

-(void)addWeakReferenceObject:(id)object forKey:(id)key
{
    [self.weakReferenceObjectsTable setObject:object forKey:key];
}

-(id)weakReferenceObjectForKey:(id)key
{
    return [self.weakReferenceObjectsTable objectForKey:key];
}

-(void)addStrongReferenceObject:(id)object forKey:(id)key
{
    [self.strongReferenceObjectsTable setObject:object forKey:key];
}

-(id)strongReferenceObjectForKey:(id)key
{
    return [self.strongReferenceObjectsTable objectForKey:key];
}

-(BOOL)exchangeInstanceMethodFrom:(SEL)from to:(SEL)to
{
    Class cls = [self class];
    Method fromMethod = class_getInstanceMethod(cls, from);
    Method toMethod = class_getInstanceMethod(cls, to);
    if (fromMethod == NULL || toMethod == NULL) {
        return NO;
    }
//    class_addMethod(cls, from, class_getMethodImplementation(cls, from), method_getTypeEncoding(fromMethod));
//    class_addMethod(cls, to, class_getMethodImplementation(cls, to), method_getTypeEncoding(toMethod));
    method_exchangeImplementations(fromMethod, toMethod);
    return YES;
}

-(BOOL)exchangeClassMethodFrom:(SEL)from to:(SEL)to
{
    Class cls = [self class];
    Method fromMethod = class_getClassMethod(cls, from);
    Method toMethod = class_getClassMethod(cls, to);
    if (fromMethod == NULL || toMethod == NULL) {
        return NO;
    }
    method_exchangeImplementations(fromMethod, toMethod);
    return YES;
}
@end
