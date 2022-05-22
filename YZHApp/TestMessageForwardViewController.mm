//
//  TestMessageForwardViewController.m
//  YZHApp
//
//  Created by yuan on 2020/12/9.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "TestMessageForwardViewController.h"

#import <objc/runtime.h>
#import <objc/message.h>


@interface NSObject (MethodSignature)

@end

@implementation NSObject (MethodSignature)


+ (BOOL)sig_exchangeInstanceMethod:(SEL)orgSelector with:(SEL)newSelector {
    Method orgMethod = class_getInstanceMethod(self, orgSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    if (!orgMethod || !newMethod) {
        return NO;
    }
    
//    Class cls = [self class];
    BOOL add = class_addMethod(self, orgSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (add) {
        class_replaceMethod(self, newSelector, method_getImplementation(orgMethod), method_getTypeEncoding(orgMethod));
    }
    else {
        method_exchangeImplementations(orgMethod, newMethod);
    }
    
    return YES;
}

+ (BOOL)sig_exchangeClassMethod:(SEL)orgSelector with:(SEL)newSelector {
    Method orgMethod = class_getClassMethod(self, orgSelector);
    Method newMethod = class_getClassMethod(self, newSelector);
    if (!orgMethod || !newMethod) {
        return NO;
    }
    
    Class metaCls = object_getClass(self);

    BOOL add = class_addMethod(metaCls, orgSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (add) {
        class_replaceMethod(metaCls, newSelector, method_getImplementation(orgMethod), method_getTypeEncoding(orgMethod));
    }
    else {
        method_exchangeImplementations(orgMethod, newMethod);
    }
    
    return YES;
}


//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//
//        [self sig_exchangeInstanceMethod:@selector(methodSignatureForSelector:) with:@selector(sig_methodSignatureForSelector:)];
//
//        [self sig_exchangeInstanceMethod:@selector(forwardInvocation:) with:@selector(sig_forwardInvocation:)];
//        
//        
//        [self sig_exchangeClassMethod:@selector(methodSignatureForSelector:) with:@selector(sig_class_methodSignatureForSelector:)];
//        
//        [self sig_exchangeClassMethod:@selector(forwardInvocation:) with:@selector(sig_class_forwardInvocation:)];
//    });
//}

//+ (void)exchange {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//
//        method_exchangeImplementations(class_getInstanceMethod([NSObject class], @selector(forwardInvocation:)), class_getInstanceMethod([self class], @selector(sig_forwardInvocation:)));
//
//        method_exchangeImplementations(class_getInstanceMethod([NSObject class], @selector(methodSignatureForSelector:)), class_getInstanceMethod([self class], @selector(sig_methodSignatureForSelector:)));
//
////        [self sig_exchangeInstanceMethod:@selector(methodSignatureForSelector:) with:@selector(sig_methodSignatureForSelector:)];
////
////        [self sig_exchangeInstanceMethod:@selector(forwardInvocation:) with:@selector(sig_forwardInvocation:)];
//    });
//}


- (NSMethodSignature *)sig_methodSignatureForSelector:(SEL)aSelector {
//    SEL regSel = sel_getUid(sel_getName(aSelector));
//    if (regSel != aSelector) {
//        NSLog(@"regSel=%p,aSel=%p,regSel.name=%s,aSel.name=%s",regSel,aSelector,sel_getName(regSel),sel_getName(aSelector));
//        NSMethodSignature *sig = [NSString instanceMethodSignatureForSelector:aSelector];
//        return sig;
    
    NSMethodSignature *sig = [NSString methodSignatureForSelector:aSelector];
    return sig;
//    }
//    return [self sig_methodSignatureForSelector:aSelector];
}

- (void)sig_forwardInvocation:(NSInvocation *)anInvocation {
//    NSLog(@"inv.sel=%p,name=%s",anInvocation.selector,sel_getName(anInvocation.selector));
//    SEL aSel = anInvocation.selector;
//    SEL regSel = sel_getUid(sel_getName(aSel));
//    if (regSel != aSel) {
//        anInvocation.selector = regSel;
//        NSLog(@"target=self=%d",self==anInvocation.target);
    
//    NSString *arg1 = nil;
//    NSString *arg2 = nil;
//    NSString *arg3 = nil;
//    NSString *arg4 = nil;
//
//    [anInvocation getArgument:&arg1 atIndex:0];
//    [anInvocation getArgument:&arg2 atIndex:1];
//    [anInvocation getArgument:&arg3 atIndex:2];
//
//    NSString *t = [NSString new];
//    [anInvocation setArgument:&t atIndex:0];
//    [anInvocation getArgument:&arg4 atIndex:3];
    
//    NSLog(@"arg1=%@,arg2=%@,arg3=%@",arg1, arg2, arg3);
    
//    NSString *text = @"";
        
        [anInvocation invokeWithTarget:[NSString class]];
//    }
//    else {
//        [self sig_forwardInvocation:anInvocation];
//    }
}




- (NSMethodSignature *)sig_class_methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig = [NSString methodSignatureForSelector:aSelector];
    return sig;
}

- (void)sig_class_forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:[NSString class]];
}


@end


@interface ATest : NSObject



@end

@implementation ATest

- (void)hello:(NSDictionary *)info to:(NSString *)name {
    NSLog(@"name：%@, info=%@",name,info);
}

- (void)sayHello:(NSDictionary *)info to:(NSString *)name {
    NSLog(@"sayHello.name：%@, info=%@",name,info);
}


@end

@interface BTest : NSObject

/** <#注释#> */
@property (nonatomic, strong) ATest *atest;

@end

@implementation BTest

- (BOOL)respondsToSelector:(SEL)aSelector {
    return YES;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig = [ATest instanceMethodSignatureForSelector:@selector(sayHello:to:)];
    return sig;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if (!self.atest) {
        self.atest = [ATest new];
    }
    [anInvocation invokeWithTarget:self.atest];
}

@end


@interface CTest : NSObject

@property (nonatomic, strong) NSString *target;


@end

@implementation CTest

//- (BOOL)respondsToSelector:(SEL)aSelector {
//    return YES;
//}

//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    NSMethodSignature *sig = [NSString instanceMethodSignatureForSelector:@selector(initWithFormat:)];
//    return sig;
//}
//
//- (void)forwardInvocation:(NSInvocation *)anInvocation {
//    if (!self.target) {
//        self.target = [NSString alloc];
//    }
//    NSLog(@"target=%@",anInvocation.target);
//
//    [anInvocation invokeWithTarget:self.target];
//}

@end

@interface TestMessageForwardViewController ()

@end

@implementation TestMessageForwardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    
//    [NSObject exchange];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
//    Class cls = [BTest class];
//    id instance = [cls new];
//    if ([instance respondsToSelector:@selector(hello:to:)]) {
//        [[cls new] hello:@{@"myName":@"yuanzh",
//                           @"text":@"how are you",
//        } to:@"zhang"];
//    }
    
//    id instance = [CTest new];
//    NSLog(@"target=%@",instance);
//    [instance initWithFormat:@"%@",@"hello world"];
    
//    NSString *b = [instance stringByAppendingFormat:@"%d", 1234];
    
    id instance = [NSString class];
    NSString *b = [instance stringWithFormat:@"%@",@"hello world"];
    
    NSLog(@"b=%@",b);
    
//    NSString *target = [NSString stringWithFormat:@"%@",@"hello world"];
//    NSString *(*appendFormat)(id,SEL, NSString* ...) = (NSString*(*)(id,SEL, NSString *,...))objc_msgSend;
//    target = appendFormat(target, @selector(stringByAppendingFormat:), @"%@", @" yuanzh");
//    NSLog(@"target=%@",target);
}


@end
