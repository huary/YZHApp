//
//  TestMessageForwardViewController.m
//  YZHApp
//
//  Created by yuan on 2020/12/9.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "TestMessageForwardViewController.h"


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


@interface TestMessageForwardViewController ()

@end

@implementation TestMessageForwardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    Class cls = [BTest class];
    id instance = [cls new];
    if ([instance respondsToSelector:@selector(hello:to:)]) {
        [[cls new] hello:@{@"myName":@"yuanzh",
                           @"text":@"how are you",
        } to:@"zhang"];
    }
}


@end
