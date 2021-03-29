//
//  TestDeallocProxyViewController.m
//  YZHApp
//
//  Created by yuan on 2020/12/16.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "TestDeallocProxyViewController.h"
#import "YZHKit.h"

#import <objc/message.h>

@interface B : NSObject

@end

@implementation B

- (void)dealloc {
    NSLog(@"B ======= dealloc,%p",self);
}

@end


@interface ATestProxy : B

@end



@implementation ATestProxy



- (void)pri_print:(NSString *)text {
    NSLog(@"ATestProxy.text=%@",text);
}

- (void)dealloc {
    NSLog(@"ATestProxy ======= dealloc,%p",self);
//    ON_RETURN{
//        NSLog(@"after dealloc");
//    };
//
//
//    onExit({
//        NSLog(@"after dealloc 2");
//    })

}

@end

@interface ATestProxy (A)

@end

@implementation ATestProxy (A)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self hz_exchangeInstanceMethodFrom:NSSelectorFromString(@"dealloc") to:@selector(proxy_dealloc)];
//    });
//}

//- (void)proxy_dealloc {
//    [self proxy_dealloc];
//    NSLog(@"dealloc");
//}

@end


static IMP imp = NULL;


static Class dealloc_class(id self, SEL _cmd)
{
    return class_getSuperclass(object_getClass(self));
}

static void dealloc_func(id self, SEL _cmd) {
    NSLog(@"%p.cls=%@.%@",self,NSStringFromClass(object_getClass(self)),NSStringFromSelector(_cmd));
    
//    void (*ptr)(id, SEL) = imp;
//    ptr(self, _cmd);
    
    
//    struct objc_super superclazz = {
//        .receiver = self,
//        .super_class = class_getSuperclass(object_getClass(self))
//    };
//
//    // cast our pointer so the compiler won't complain
//    void (*objc_msgSendSuperCasted)(void *, SEL) = (void *)objc_msgSendSuper;
//
//    // call super's setter, which is original class's setter method
//    objc_msgSendSuperCasted(&superclazz, _cmd);
}


@interface NSObject (DeallocHandler)

@end



@implementation NSObject (DeallocHandler)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
////        Class originalClazz = object_getClass(self);
////
////        NSString *clsName = [NSString stringWithFormat:@"%@_dealloc",NSStringFromClass(originalClazz)];
////
////        Class deallocCls = objc_allocateClassPair(originalClazz, clsName.UTF8String, 0);
////
////        SEL deallocSelector = NSSelectorFromString(@"dealloc");
////        const char *types = "v@:";
////        BOOL OK = class_addMethod(deallocCls, deallocSelector, (IMP)dealloc_func, types);
////        objc_registerClassPair(deallocCls);
//        
//        [self hz_exchangeClassMethodFrom:@selector(allocWithZone:) to:@selector(hz_allocWithZone:)];
//    });
//}

//+ (id)hz_allocWithZone:(struct _NSZone *)zone {
//
//    Class originalClazz = object_getClass(self);
//
//    NSString *orgClsName = NSStringFromClass(originalClazz);
//    NSLog(@"orgCls=%@",orgClsName);
////    if ([orgClsName ]) {
////        <#statements#>
////    }
//
//    NSString *clsName = [NSString stringWithFormat:@"%@_dealloc",NSStringFromClass(originalClazz)];
//
//    Class cls = NSClassFromString(clsName);
//
//    return [self hz_allocWithZone:zone];
//}



- (Class)pri_makeDeallocClass {
    Class originalClazz = object_getClass(self);

    NSString *clsName = [NSString stringWithFormat:@"%@_dealloc",NSStringFromClass(originalClazz)];
    
//    Class deallocCls = NSClassFromString(clsName);
    
    Class deallocCls = objc_allocateClassPair(originalClazz, clsName.UTF8String, 0);
    
//    Method clazzMethod = class_getInstanceMethod(originalClazz, @selector(class));
//    const char *types = method_getTypeEncoding(clazzMethod);
//    class_addMethod(deallocCls, @selector(class), (IMP)dealloc_class, types);
    
//    objc_registerClassPair(deallocCls);
    
    return deallocCls;

}

- (void)hz_addDeallocHander:(YZHDeallocBlock)deallocBlock {
    
    SEL deallocSelector = NSSelectorFromString(@"dealloc");
    
    Method delMethod = class_getInstanceMethod([self class], deallocSelector);
    IMP old = method_getImplementation(delMethod);
    imp = old;
//
//    if (!delMethod) {
//        NSLog(@"delMethod is null");
//        return;
//    }
    
//    Class clazz = object_getClass(self);
//    NSString *clazzName = NSStringFromClass(clazz);
    
    Class cls = [self pri_makeDeallocClass];
    object_setClass(self, cls);
    
    NSLog(@"superClas=%@",NSStringFromClass([cls superclass]));
    
    
//    Method delMethod = class_getInstanceMethod(cls, deallocSelector);
//    IMP old = method_getImplementation(delMethod);
//    if (old) {
//        NSLog(@"old have");
//    }
//
//    if (!delMethod) {
//        NSLog(@"delMethod is null");
//        return;
//    }
    
//    const char *types = method_getTypeEncoding(delMethod);
//    const char *types = "v@:";
//    BOOL OK = class_addMethod(cls, deallocSelector, (IMP)dealloc_func, types);
    
//    method_setImplementation(delMethod, old);

//    NSLog(@"OK=%@",OK ? @"YES":@"NO");
    
    
    objc_registerClassPair(cls);
    
//    id obj = [cls new];
//
//    NSLog(@"obj=%p",obj);
    
//    Method delMethod = class_getInstanceMethod(cls, deallocSelector);
//    IMP old = method_getImplementation(delMethod);
//    if (old) {
//        NSLog(@"old have");
//    }
}

@end




@interface TestDeallocProxyViewController ()

/** <#注释#> */
@property (nonatomic, strong) ATestProxy *t;

@end

@implementation TestDeallocProxyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)pri_test {
    ATestProxy *t = [ATestProxy new];
    
        
    [t addDeallocBlock:^(void * _Nonnull deallocTarget) {
        [(__bridge id)deallocTarget pri_print:@"start"];
    }];
    
    [t addDeallocBlock:^(void * _Nonnull deallocTarget) {
        NSLog(@"deallocated=%p,%d",deallocTarget, __LINE__);
    }];
    
    [t addDeallocBlock:^(void * _Nonnull deallocTarget) {
        NSLog(@"deallocated=%p,%d",deallocTarget, __LINE__);
    }];
    
    [t addDeallocBlock:^(void * _Nonnull deallocTarget) {
        NSLog(@"deallocated=%p,%d",deallocTarget, __LINE__);
    }];
    
    [t addDeallocBlock:^(void * _Nonnull deallocTarget) {
        NSLog(@"deallocated=%p,%d",deallocTarget, __LINE__);
    }];
    
    [t addDeallocBlock:^(void * _Nonnull deallocTarget) {
        [(__bridge id)deallocTarget pri_print:@"end"];
    }];
    
    self.t = t;
    NSLog(@"value.p=%p",t);
}

- (void)pri_test2 {
    ATestProxy *t = [ATestProxy new];
    [t hz_addDeallocHander:^(void * _Nonnull deallocTarget) {
        NSLog(@"=========deallloc");
    }];
    
    NSLog(@"cls=%@",NSStringFromClass([t class]));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self pri_test];
    
    
//    [self pri_test2];

}

@end
