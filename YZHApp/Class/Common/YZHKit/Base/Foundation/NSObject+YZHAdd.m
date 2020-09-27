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

-(void)setHz_identity:(NSInteger)hz_identity
{
    objc_setAssociatedObject(self, @selector(hz_identity), @(hz_identity), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)hz_identity
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

-(void)setHz_identityString:(NSString *)hz_identityString
{
    objc_setAssociatedObject(self, @selector(hz_identityString), hz_identityString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)hz_identityString
{
    return objc_getAssociatedObject(self, _cmd);
}


//weak reference object
//single
-(void)setHz_weakReferenceObject:(id)hz_weakReferenceObject
{
    WEAK_NSOBJ(hz_weakReferenceObject, weakObject);
    WeakReferenceObjectBlock block = ^{
        return weakObject;
    };
    objc_setAssociatedObject(self, @selector(hz_weakReferenceObject), block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(id)hz_weakReferenceObject
{
    WeakReferenceObjectBlock block = objc_getAssociatedObject(self, _cmd);
    id weakObject = (block ? block() : nil);
    return weakObject;
}

//multi
-(void)setHz_weakReferenceObjectsTable:(NSMapTable *)hz_weakReferenceObjectsTable
{
    objc_setAssociatedObject(self, @selector(hz_weakReferenceObjectsTable), hz_weakReferenceObjectsTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMapTable*)hz_weakReferenceObjectsTable
{
    NSMapTable *mapTable = objc_getAssociatedObject(self, _cmd);
    if (!mapTable) {
        mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
        self.hz_weakReferenceObjectsTable = mapTable;
    }
    return mapTable;
}

-(void)setHz_strongReferenceObjectsTable:(NSMapTable *)hz_strongReferenceObjectsTable
{
    objc_setAssociatedObject(self, @selector(hz_strongReferenceObjectsTable), hz_strongReferenceObjectsTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMapTable*)hz_strongReferenceObjectsTable
{
    NSMapTable *table = objc_getAssociatedObject(self, _cmd);
    if (!table) {
        table = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        self.hz_strongReferenceObjectsTable = table;
    }
    return table;
}

-(id)hz_respondsAndPerformSelector:(SEL)selector
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

-(id)hz_respondsAndPerformSelector:(SEL)selector withObject:(id)object
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

+(id)hz_respondsToSelector:(SEL)selector forClass:(Class)cls
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

+(id)hz_respondsToSelector:(SEL)selector forClass:(Class)cls withObject:(id)object
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

-(void)hz_addWeakReferenceObject:(id)object forKey:(id)key
{
    [self.hz_weakReferenceObjectsTable setObject:object forKey:key];
}

-(id)hz_weakReferenceObjectForKey:(id)key
{
    return [self.hz_weakReferenceObjectsTable objectForKey:key];
}

-(void)hz_addStrongReferenceObject:(id)object forKey:(id)key
{
    [self.hz_strongReferenceObjectsTable setObject:object forKey:key];
}

-(id)hz_strongReferenceObjectForKey:(id)key
{
    return [self.hz_strongReferenceObjectsTable objectForKey:key];
}

-(BOOL)hz_exchangeInstanceMethodFrom:(SEL)from to:(SEL)to
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

-(BOOL)hz_exchangeClassMethodFrom:(SEL)from to:(SEL)to
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
