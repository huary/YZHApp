//
//  TestMemoryGraphViewController.m
//  YZHApp
//
//  Created by yuan on 2021/4/3.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "TestMemoryGraphViewController.h"
#import "MMGraph.h"

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
@end

@implementation TestMemoryGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    readVMRegin();
    
    self.bptr = new B();
    
    self.ptr_t = (TT*)calloc(1, sizeof(TT));
    
    self.ptr = (uint8_t*)malloc(100);
    memset(self.ptr, 0, 100);
    
    self.cptr = (char *)calloc(100, sizeof(char));
    
    self.sptr = (uint16_t*)calloc(100, sizeof(uint16_t));
    
    self.iptr = (uint32_t*)calloc(100, sizeof(uint32_t));
    
    NSLog(@"self.bptr=%p",self.bptr);

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
    delete self.bptr;
}


@end
