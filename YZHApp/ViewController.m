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
#import "TestHZRefreshViewController.h"
#import "TestMessageForwardViewController.h"
#import "TestDeallocProxyViewController.h"
#import "TestMemoryGraphViewController.h"

#import <SDWebImage/SDWebImage.h>

@interface Test : NSObject <NSCoding>

/* <#name#> */
@property (nonatomic, assign) NSInteger a;

/* <#注释#> */
@property (nonatomic, strong) NSString *b;

@end

@interface ImageView : UIView

/** <#注释#> */
@property (nonatomic, strong) UIImage *image;

@end

@implementation ImageView

- (void)setImage:(UIImage *)image {
//    if (_image != image) {
        _image = image;
        [self.layer setNeedsDisplay];
//    }
}

- (void)displayLayer:(CALayer *)layer
{
    self.layer.contents = (__bridge id)self.image.CGImage;
}

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

//@interface NSObject (dlc)
//
//@end
//
//@implementation NSObject (dlc)
//
//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self hz_exchangeInstanceMethodFrom:NSSelectorFromString(@"dealloc") to:@selector(hz_dealloc)];
//    });
//}
//
//- (void)hz_dealloc {
//    [self hz_dealloc];
//}
//
//@end

@interface TestDealloc : NSObject

@end

@implementation TestDealloc

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [TestDealloc hz_exchangeInstanceMethodFrom:NSSelectorFromString(@"dealloc") to:@selector(TD_dealloc)];
//    });
//}
//
//- (void)TD_dealloc {
//    if ([self isKindOfClass:[TestDealloc class]]) {
//        [self TD_dealloc];
//    }
//}

//- (void)dealloc {
//    NSLog(@"TestDealloc.dealloc=========")
//}

@end

@interface TestDealloc (A)

@end

@implementation TestDealloc (A)

//+ (void)load {
//
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self hz_exchangeInstanceMethodFrom:NSSelectorFromString(@"dealloc") to:@selector(hz_dealloc)];
//    });
//}
//
//- (void)hz_dealloc {
//    [self hz_dealloc];
//    NSLog(@"hz_dealloc=========");
//}


@end


@interface TD : TestDealloc

@end

@implementation TD

- (void)dealloc {
    NSLog(@"TD.dealloc");
}

@end

@interface TD (AB)

@end

@implementation TD (AB)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [TestDealloc hz_exchangeInstanceMethodFrom:NSSelectorFromString(@"dealloc") to:@selector(TD_AB_dealloc)];
//    });
//}
//
//- (void)TD_AB_dealloc {
////    if ([self isKindOfClass:[TestDealloc class]]) {
//        [self TD_AB_dealloc];
////    }
//}

@end

@interface AB : NSObject

@end

@implementation AB

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [AB hz_exchangeInstanceMethodFrom:NSSelectorFromString(@"dealloc") to:@selector(AB_dealloc)];
//    });
//}
//
//- (void)AB_dealloc {
//    if ([self isKindOfClass:[AB class]]) {
//        [self AB_dealloc];
//    }
//}

- (void)dealloc {
    NSLog(@"AB.dealloc=========");
}


@end


@interface CD : NSObject

@end

@implementation CD

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [CD hz_exchangeInstanceMethodFrom:NSSelectorFromString(@"dealloc") to:@selector(CD_dealloc)];
//    });
//}
//
//- (void)CD_dealloc {
//    if ([self isKindOfClass:[CD class]]) {
//        [self CD_dealloc];
//    }
//}

- (void)dealloc {
    NSLog(@"CD.dealloc=========");
}


@end

@interface UITextBGView : UIView

/** <#注释#> */
@property (nonatomic, strong) YZHUITextView *textView;

@end

@implementation UITextBGView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.textView) {
        return self.textView;
    }
    return [super hitTest:point withEvent:event];
}

@end



@interface ViewController ()

/**  */
@property (nonatomic, strong) YZHTaskManager *taskManager;

/** <#注释#> */
@property (nonatomic, strong) YZHKeyboardManager *keyboardManager;

/** <#注释#> */
@property (nonatomic, strong) YZHTimer *timer;

/** <#注释#> */
@property (nonatomic, strong) YZHUITextView *textView;

/** <#注释#> */
@property (nonatomic, strong) UIImage *image;

/** <#注释#> */
@property (nonatomic, strong) ImageView *imgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self _test];
    
//    [self _setupChildView];
    
//    [self _test2];
    
//    [self pri_testTextView];
    
//    [self pri_testButton];
    
//    [self pri_testBezierPath];
    
//    [self pri_testImage];
    
//    [self pri_prepareLoadImage];
    
//    [self pri_setupTestImageView];
    
//    [self pri_testHZRefresh];
    
//    [self pri_testGCDTimer];
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
    textField2.frame = CGRectMake(x, textField.hz_bottom + 10, w, h);
    textField2.layer.borderWidth = 1.0;
    textField2.keyboardType = UIKeyboardTypeNumberPad;
    textField2.layer.borderColor = [UIColor purpleColor].CGColor;
    [self.view addSubview:textField2];
    self.keyboardManager = [[YZHKeyboardManager alloc] init];
    self.keyboardManager.keyboardMinTopToResponder = 40;
    self.keyboardManager.firstResponderShiftToKeyboardMinTop = YES;
    self.keyboardManager.relatedShiftView = self.view;
}

- (void)pri_testTextView
{
    CGFloat x = 20;
    CGFloat y = 100;
    CGFloat w = self.view.hz_width - 2 *x;
    CGFloat h = 60;
    
//    CGFloat X = SAFE_X;
    
//    int64_t start = MSEC_FROM_DATE_SINCE1970_NOW;
    YZHUITextView *textView = [[YZHUITextView alloc] initWithFrame:CGRectMake(x, y, w, h)];
//    textView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
//    textView.font = FONT(20);
//    textView.text = @"123";
    textView.font = FONT(17);
    textView.placeholder = @"123456789";
    textView.placeholderColor = BROWN_COLOR;
//    int64_t end = MSEC_FROM_DATE_SINCE1970_NOW;
//    NSLog(@"time.end=%@,diff=%@",@(end),@(end - start));
//    textView.textContainerInset = UIEdgeInsetsMake(8, 20, 8, 4);
//    textView.backgroundColor = RED_COLOR;
    textView.layer.borderWidth = 1.0;
    textView.layer.borderColor = BLACK_COLOR.CGColor;
    
//    textView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    textView.textContainerInset = UIEdgeInsetsZero;//UIEdgeInsetsMake(10, 10, 10, 10);
    
    
    
//    textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
//    UITextBGView *bgView = [UITextBGView new];
////    bgView.textView = textView;
//    bgView.frame = CGRectMake(0, 100, self.view.hz_width, 200);
//    bgView.backgroundColor = [UIColor purpleColor];
//    [bgView addSubview:textView];
//
//    NSString *a = @"a";
//    NSString *b = @"b";
//    NSLog(@"isEqual=%@",@([a isEqual:b]));
//    [self.view addSubview:bgView];
    
    [self.view addSubview:textView];
}

- (void)pri_testButton {
    YZHUIButton *btn = [YZHUIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 100, 200, 100);
    [btn setBackgroundColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor] forState:UIControlStateHighlighted];
//    [btn setBackgroundColor:[UIColor redColor] forState:UIControlStateHighlighted|UIControlStateSelected];
    [self.view addSubview:btn];
}

- (void)pri_testBezierPath {
    CGFloat x = 30;
    CGFloat y = 200;
    CGFloat w = 330;//self.view.frame.size.width - 2 * x;
    CGFloat h = 120;
    
    CGFloat lineWidth = 20;
    CGFloat cornerRadius = 40;
    UIView *testView =[UIView new];
    testView.frame = CGRectMake(x, y,w, h);
    testView.backgroundColor = [UIColor orangeColor];
    testView.layer.cornerRadius = cornerRadius;
    testView.layer.masksToBounds = YES;
    [self.view addSubview:testView];

//    CGRect rect = CGRectInset(testView.bounds, lineWidth/2, lineWidth/2);
    CGRect rect = testView.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
//    UIBezierPath *path = [UIBezierPath hz_bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadius:cornerRadius - 10];
    
//    lineWidth = 1.0;
    path = [UIBezierPath hz_borderBezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadius:cornerRadius borderWidth:lineWidth];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    shapeLayer.path = path.CGPath;
    shapeLayer.lineWidth = lineWidth;
//    shapeLayer.fillColor = [UIColor clearColor].CGColor;
//    shapeLayer.strokeColor = [UIColor purpleColor].CGColor;
    
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:0.8].CGColor;
    
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.frame = testView.frame;
    [self.view.layer addSublayer:shapeLayer];
    

    
}

- (ImageView*)imgView  {
    if (_imgView == nil) {
        _imgView = [ImageView new];
        _imgView.frame = CGRectMake(0, 0, self.view.hz_width, self.view.hz_height - 100);
    }
    return _imgView;
}

- (void)pri_prepareLoadImage {
    
    self.image = nil;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"IMG_1974" ofType:@"HEIC"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:data];
    
    image = [image hz_fixImageOrientation];
    
//    self.image = image;
    
    self.image = [UIImage sd_decodedImageWithImage:image];
    
//    UIImage *tmp = [[SDImageCodersManager sharedManager] decodedImageWithData:data options:nil];
//    self.image = [[UIImage alloc] initWithCGImage:tmp.CGImage scale:1.0 orientation:UIImageOrientationUp];
}

- (void)pri_setupTestImageView {
    
    [self.view addSubview:self.imgView];
}

- (void)pri_testImage
{
    NSDate *start = [NSDate date];
//    self.imgView.image = self.image;
//    self.imgView.layer.contents = (__bridge id)self.image.CGImage;
    self.imgView.image = self.image;

    NSDate *finish = [NSDate date];
//    self.imgView.image = nil;
//    self.imgView.layer.contents = nil;
    
    NSTimeInterval timeInterval = [finish timeIntervalSinceDate:start];
    NSLog(@"timeInterval=%@",@(timeInterval * 10000));
    
//    [self pri_prepareLoadImage];
    
//    NSData *dt=UIImageJPEGRepresentation(image, 1.0);
//    NSLog(@"dt=%@",@(dt.length));
//
//    UIImage *newImg = [[SDImageCodersManager sharedManager] decodedImageWithData:data options:nil];
//
//    NSData *imgData = UIImageJPEGRepresentation(newImg, 1.0);
//    NSLog(@"image=%@,lenth=%@",newImg,@(imgData.length));
}

- (void)_test2 {
    self.timer = [[YZHTimer alloc] initWithTimeInterval:5.0 repeat:NO fireBlock:^(YZHTimer *timer) {
        [timer suspend];
    }];
}


- (void)pri_testHZRefresh {
    
    YZHUIButton *btn = [YZHUIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 200, 80);
    [btn setBackgroundColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    WEAK_SELF(weakSelf);
    [btn hz_addControlEvent:UIControlEventTouchUpInside actionBlock:^(UIButton *button) {
        TestHZRefreshViewController *vc = [[TestHZRefreshViewController alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [weakSelf presentViewController:vc animated:YES completion:nil];
    }];
    
}

- (void)pri_testTransaction {
    NSString *tid = @"test1";
//    for (NSInteger i = 0; i < 100; ++i) {
//        [[YZHTransaction transactionWithTransactionId:tid currentData:@(i+1) handleData:^id _Nullable(YZHTransaction * _Nonnull transaction) {
//            NSMutableArray *data = transaction.preData;
//            if (!transaction.preData) {
//                data = [NSMutableArray array];
//            }
//            [data addObject:transaction.curData];
//            return data;
//        } action:^(YZHTransaction * _Nonnull transaction) {
//            NSLog(@"transaction.data=%@,preData=%@",transaction.curData,transaction.preData);
//        }] commit];
//    }
    
    for (NSInteger i = 0; i < 5; ++i) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[YZHTransaction transactionWithTransactionId:tid currentData:@(i+1) handleData:^id _Nullable(YZHTransaction * _Nonnull transaction) {
                NSMutableArray *data = transaction.preData;
                if (!transaction.preData) {
                    data = [NSMutableArray array];
                }
                [data addObject:transaction.curData];
                return data;
            } action:^(YZHTransaction * _Nonnull transaction) {
                NSLog(@"transaction.data=%@,preData=%@",transaction.curData,transaction.preData);
            }] commit];
        });
    }
    
    
}

- (void)pri_testABC {
    NSString *classStr = @"ABC";
    Class cls = NSClassFromString(classStr);

    id instance = [cls new];
    NSLog(@"instance=%@",instance);
}

- (void)pri_testMessageForward {
    TestMessageForwardViewController *testMFVC = [TestMessageForwardViewController new];
    [self presentViewController:testMFVC animated:YES completion:nil];
}

- (void)pri_testDeallocProxy {
//    TD *t = [[TD alloc] init];
    
    TestDeallocProxyViewController *testProxyVC = [TestDeallocProxyViewController new];
    [self presentViewController:testProxyVC animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self pri_testABC];
//    [self pri_testTransaction];
    
//    [self pri_testMessageForward];
    
//    [self pri_testImage];
//    CGFloat t = (arc4random() & 7) * 1.0 / 8;
//    [self pri_ATask:t];
//
//    return;
//    [self.view endEditing:YES];
//    [self.timer invalidate];
    
//    YZHUIAlertView *alertView = [[YZHUIAlertView alloc] initWithTitle:@"提示" alertMessage:@"提示信息" alertViewStyle:YZHUIAlertViewStyleAlertForce];
//
//    [alertView alertShowInView:nil animated:NO];
//
//    UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"提示" message:@"提示信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alertView2 show];
    
//    [YZHToast toastWithText:@"请稍后..."];
    
//    [self pri_testDeallocProxy];
    
//    [self pri_testGCDTimer];
    
    
    [self pri_getIvar];
    
    [self pri_testMMGraph];
}

- (void)pri_getIvar {
    unsigned int cnt;
    Ivar *ivars = class_copyIvarList([self class], &cnt);
    for (unsigned int i = 0; i < cnt; ++i) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        const char *type = ivar_getTypeEncoding(ivar);
        id obj = object_getIvar(self, ivar);
        
        NSLog(@"name=%s,type=%s,obj=%@",name,type,obj);
        if (type[0] == '@') {
            
        }
        else if (type[0]=='#') {
            
        }
        else {
            
        }
    }
}

- (void)pri_testMMGraph {
    TestMemoryGraphViewController *testMMGrapVC = [TestMemoryGraphViewController new];
    [self presentViewController:testMMGrapVC animated:YES completion:nil];
}


- (void)pri_testGCDTimer {
    

    
    [self.timer invalidate];
//    self.timer = [YZHTimer timerWithTimeInterval:1.0 repeat:YES fireBlock:^(YZHTimer *timer) {
//        NSLog(@"timer.elase=%@",@(timer.elapseTime));
//    }];
    
    dispatch_queue_t q = dispatch_queue_create("1", DISPATCH_QUEUE_SERIAL);
    [YZHTimer timerWithFireTimeAfter:0 interval:1.0 repeat:YES queue:q userInfo:nil fireBlock:^(YZHTimer *timer) {
        NSLog(@"timer.elase=%@",@(timer.elapseTime));
    }];
    
    
    while (1) {
        [NSThread sleepForTimeInterval:2];
    };
    NSLog(@"finish");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
