//
//  TestHostPatchViewController.m
//  YZHApp
//
//  Created by bytedance on 2021/12/7.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "TestHostPatchViewController.h"
#define BETTER_PATCH(x) __attribute__((annotate("better_patch_"#x)))

typedef struct CGNode {
    bool a;
    char b;
    short c;
    int d;
    long e;
    float f;
    double g;
}CGNode_S;


@interface OCTest : NSObject

@end

@implementation OCTest
#if 0
- (CGNode_S)testCGNode:(CGNode_S)node/* BETTER_PATCH(1.0.0) */{
    CGNode_S n;
    n.a = false;
    n.b = 1;
    n.c = 2;
    n.d = 3;
    n.e = 4;
    n.f = 5;
    n.g = 6;
    return n;
}
#endif

- (CGNode_S)testCGNode{
    CGNode_S n;
    n.a = false;
    n.b = 1;
    n.c = 2;
    n.d = 3;
    n.e = 4;
    n.f = 5;
    n.g = 6;
    return n;
}

//+ (CGNode_S)cls_testCGNode:(CGNode_S)node {
//    CGNode_S n;
//    n.a = false;
//    n.b = 1;
//    n.c = 2;
//    n.d = 3;
//    n.e = 4;
//    n.f = 5;
//    n.g = 6;
//    NSLog(@"self=%p,ret.n=%p,param.node=%p",self,&n,&node);
//    NSLog(@"ret.a=%d,b=%d,c=%d,d=%d,e=%ld,f=%f,g=%lf",n.a,n.b,n.c,n.d,n.e,n.f,n.g);
//    NSLog(@"param.a=%d,b=%d,c=%d,d=%d,e=%ld,f=%f,g=%lf",node.a,node.b,node.c,node.d,node.e,node.f,node.g);
//    return n;
//}

@end

@interface TestHostPatchViewController ()

@end

@implementation TestHostPatchViewController

#if 0
- (void)viewDidLoad/* BETTER_PATCH(1.0.0) */{
    [super viewDidLoad];
}
#endif

- (void)pri_testPatch BETTER_PATCH(1.0.0) {
//    TestHostPatchViewController *t = [TestHostPatchViewController new];
    OCTest *t = [OCTest new];
    CGNode_S node;
    CGNode_S ret;
    NSLog(@"ret=%p",&ret);
    ret = [t testCGNode];
    NSLog(@"tmp.g=%lf",ret.g);
}


@end
