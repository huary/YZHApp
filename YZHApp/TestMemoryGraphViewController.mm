//
//  TestMemoryGraphViewController.m
//  YZHApp
//
//  Created by yuan on 2021/4/3.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "TestMemoryGraphViewController.h"
#import "MMHeap.h"
#import "MMContext.h"

typedef struct Test {
    int i;
    int j;
    int k;
}TT;

class B {
private:
    int i;
public:
    B(){}
    ~B(){}
    int j;
protected:
    int k;
};

@interface TestMemoryGraphViewController ()

@property (nonatomic, strong) NSMutableDictionary *dict;


@property (nonatomic, strong) NSMutableArray *array;


@property (nonatomic, copy) NSDictionary *dic;


@property (nonatomic, copy) NSArray *arr;


@property (nonatomic, copy) NSString *text;


@property (nonatomic, assign) NSInteger itg;


@property (nonatomic, assign) CGFloat fl;


@property (nonatomic, strong) Class cls;


@property (nonatomic, assign) struct Test t;


@property (nonatomic, assign) TT *ptr_t;


@property (nonatomic, assign) uint8_t *ptr;


@property (nonatomic, assign) char *cptr;


@property (nonatomic, assign) uint16_t *sptr;

@property (nonatomic, assign) uint32_t *iptr;


@property (nonatomic, assign) B *bptr;


@property (nonatomic, assign) B b;


@property (nonatomic, strong) dispatch_queue_t graphQueue;


@property (nonatomic, assign) CFMutableDictionaryRef dictRef;
@end

@implementation TestMemoryGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}

- (dispatch_queue_t)graphQueue {
    if (!_graphQueue) {
        _graphQueue = dispatch_queue_create("graphQueu", DISPATCH_QUEUE_SERIAL);
    }
    return _graphQueue;
}

- (void)pri_test {
    MMContext::shareContext()->start();
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self pri_test];
    
//    readVMRegin();
    
//    mach_port_t thread = mach_thread_self();
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        vm_address_t sp = 0;
//        thread_stack_sp(thread, &sp);
//    });
    
//    while (1) {
//
//    };
//    vm_address_t sp = 0;
//    thread_stack_sp(mach_thread_self(), &sp);
//
//    NSLog(@"sp=%lu",sp);
//
//    vm_address_t fp = 0;
//
//    thread_stack_fp(mach_thread_self(), &fp, 0);

//    NSLog(@"fp=%@",@(fp));
//
//    NSLog(@"fp=%@,sp=%@",@(fp),@(sp));
    
    
    self.bptr = new B();
//    self.bptr = &_b;

    self.ptr_t = (TT*)calloc(1, sizeof(TT));

    self.ptr = (uint8_t*)malloc(100);
    memset(self.ptr, 0, 100);

    self.cptr = (char *)calloc(100, sizeof(char));

    self.sptr = (uint16_t*)calloc(100, sizeof(uint16_t));

    self.iptr = (uint32_t*)calloc(100, sizeof(uint32_t));

    NSLog(@"self.bptr=%p",self.bptr);


    self.dictRef = CFDictionaryCreateMutable(nullptr, 100, nullptr, nullptr);
//
//    CFDictionarySetValue(self.dictRef, (void*)1, (void*)2);
//
//    [self pri_test];

    [self pri_getIvar];

    
//    MMGraphTest();
}


- (void)pri_getIvar {
    
    
    unsigned int cnt;
    Ivar *ivars = class_copyIvarList([self class], &cnt);
    for (unsigned int i = 0; i < cnt; ++i) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        
//        id obj = ()object_getIvar(self, ivar);
        
        NSLog(@"name=%s,type=%s",name,type);
        if (type[0] == '@') {
            id obj = object_getIvar(self, ivar);
        }
        else if (type[0]=='#') {
            
        }
        else if (type[0] == '^') {
            void *ptr = (__bridge void *)object_getIvar(self, ivar);
            NSLog(@"ptr=%p",ptr);
        }
        else {
            
        }
    }
    
    free(self.ptr_t);
    free(self.ptr);
    free(self.iptr);
    free(self.cptr);
    free(self.sptr);
    
    CFRelease(self.dictRef);
    delete self.bptr;
}


@end
