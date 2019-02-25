//
//  YZHWeakProxy.m
//  YZHApp
//
//  Created by yuan on 2019/1/14.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHWeakProxy.h"

@implementation YZHWeakProxy

-(instancetype)initWithTarget:(id)target
{
    _target = target;
    return self;
}

+(instancetype)proxyWithTarget:(id)target
{
    return [[YZHWeakProxy alloc] initWithTarget:target];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return _target;
}

-(void)forwardInvocation:(NSInvocation *)invocation
{
    void *retValue = NULL;
    [invocation setReturnValue:&retValue];
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

-(BOOL)respondsToSelector:(SEL)aSelector
{
    return [_target respondsToSelector:aSelector];
}

-(BOOL)isEqual:(id)object
{
    return [_target isEqual:object];
}

-(NSUInteger)hash
{
    return [_target hash];
}

-(Class)superclass
{
    return [_target superclass];
}

-(Class)class
{
    return [_target class];
}

-(BOOL)isKindOfClass:(Class)aClass
{
    return [_target isKindOfClass:aClass];
}

-(BOOL)isMemberOfClass:(Class)aClass
{
    return [_target isMemberOfClass:aClass];
}

-(BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return [_target conformsToProtocol:aProtocol];
}

-(BOOL)isProxy
{
    return YES;
}

-(NSString*)description
{
    return [_target description];
}

@end
