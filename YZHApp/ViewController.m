//
//  ViewController.m
//  YZHApp
//
//  Created by yuan on 2018/12/27.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "ViewController.h"
#import "YZHUtil.h"
#import "YZHKit.h"
#import "YZHAsyncTaskManager.h"
#import "YZHSyncTaskManager.h"


@interface Test : NSObject <NSCoding>

/* <#name#> */
@property (nonatomic, assign) NSInteger a;

/* <#注释#> */
@property (nonatomic, strong) NSString *b;

@end

@implementation Test

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.a = [aDecoder decodeIntegerForKey:@"a"];
        self.b = [aDecoder decodeObjectForKey:@"b"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.a forKey:@"a"];
    [aCoder encodeObject:self.b forKey:@"b"];
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"_a=%ld,\n_b=%@",self.a,self.b];
}

@end



@interface ViewController ()

/**  */
@property (nonatomic, strong) YZHTaskManager *taskManager;

/** <#注释#> */
@property (nonatomic, strong) YZHKeyboardManager *keyboardManager;

/** <#注释#> */
@property (nonatomic, strong) YZHTimer *timer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self _test];
    
//    [self _setupChildView];
    
    [self _test2];
}


-(void)_test
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:@"1" forKey:@"1"];
    
    NSArray *list = @[@"2",@"3",@"4",@"5"];
    [dict setObject:list forKey:@"list"];
    
    Test *t = [[Test alloc] init];
    t.a = 100;
    t.b = @"name";
    
    [dict setObject:t forKey:@"t"];
    
    
    NSString *path = [YZHUtil applicationCachesDirectory:@"1.dt"];
    
    BOOL ok = [dict writeToFile:path atomically:YES];
    NSLog(@"ok=%@",@(ok));
    
    NSDictionary *cp = [NSDictionary dictionaryWithContentsOfFile:path];
    NSLog(@"cp=%@",cp);
    
    self.taskManager = [[YZHSyncTaskManager alloc] init];
    WEAK_SELF(weakSelf);
    [self.taskManager addTaskBlock:^id(YZHTaskManager *taskManager) {
        [weakSelf _doTask];
        return nil;
    } forKey:@"1"];
    
    [self performSelector:@selector(cancelAction:) withObject:nil afterDelay:5];
}

- (void)cancelAction:(id)object
{
    NSLog(@"%s:%@",__FUNCTION__,object);
    [self.taskManager notifyTaskFinishForKey:@"1"];
}

- (void)_doTask
{
    dispatch_queue_t queue = dispatch_queue_create("123", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        for (int i = 0; i < 20; ++i) {
            NSLog(@"i=%d",i);
            [NSThread sleepForTimeInterval:1];
        }
    });
}


- (void)_setupChildView
{
    CGFloat w = 200;
    CGFloat h = 40;
    CGFloat x = (SCREEN_WIDTH - w)/2;
    CGFloat y = SCREEN_HEIGHT - 250;
    UITextField *textField = [UITextField new];
    textField.placeholder = @"text1";
    textField.frame = CGRectMake(x, y, w, h);
    textField.layer.borderWidth = 1.0;
    textField.layer.borderColor = [UIColor redColor].CGColor;
    [self.view addSubview:textField];
    
    UITextField *textField2 = [UITextField new];
    textField2.placeholder = @"text2";
    textField2.frame = CGRectMake(x, textField.bottom + 10, w, h);
    textField2.layer.borderWidth = 1.0;
    textField2.keyboardType = UIKeyboardTypeNumberPad;
    textField2.layer.borderColor = [UIColor purpleColor].CGColor;
    [self.view addSubview:textField2];
    self.keyboardManager = [[YZHKeyboardManager alloc] init];
    self.keyboardManager.keyboardMinTopToResponder = 40;
    self.keyboardManager.firstResponderShiftToKeyboardMinTop = YES;
    self.keyboardManager.relatedShiftView = self.view;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self.timer invalidate];
}

- (void)_test2 {
    self.timer = [[YZHTimer alloc] initWithTimeInterval:5.0 repeat:NO fireBlock:^(YZHTimer *timer) {
        [timer suspend];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
