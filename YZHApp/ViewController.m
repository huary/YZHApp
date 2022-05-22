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

#import <dlfcn.h>

#import "YZHActivityManager.h"


typedef void(*RegisterEntryFunc)(void);

typedef struct {
    const char *entryName;
    const char *entryKey;
    RegisterEntryFunc func;
    void *entryCtx;
}Register_Entry_s;

#define REGISTER_SEGMENT    "__DATA"
#define REGISTER_SECTION    "_Register_entry"
#define REGISTER_METHOD     CONCAT(_REGISTER_ENTRY_FUNC_,__LINE__)


#define RegisterFunc(NAME,KEY) \
static void REGISTER_METHOD(void); \
__attribute((used, section(REGISTER_SEGMENT "," REGISTER_SECTION))) static Register_Entry_s entry = { \
.entryName = NAME, \
.entryKey = KEY, \
.func = REGISTER_METHOD, \
}; \
static void REGISTER_METHOD(void)


#ifndef  __LP64__
typedef struct mach_header MACH_HEADER;
#else
typedef struct mach_header_64 MACH_HEADER;
#endif


RegisterFunc("A","B") {
    NSLog(@"hello world");
}

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

#include <mach-o/dyld.h>
#include <mach-o/getsect.h>

static void _image_add_func(const struct mach_header *mhp, intptr_t slide) {
    
    unsigned long size = 0;
    
    uintptr_t *regdata = (uintptr_t*)getsectiondata(mhp, REGISTER_SEGMENT, REGISTER_SECTION, &size);
    if (regdata && size > 0) {
        unsigned long cnt = size / sizeof(Register_Entry_s);
        Register_Entry_s *entryList = (Register_Entry_s*)regdata;
        for (int idx = 0; idx < cnt; ++idx) {
            Register_Entry_s *entry = &entryList[idx];
            NSLog(@"entry.name=%s,entry.key=%s",entry->entryName, entry->entryKey);
            entry->func();
        }
    }
}

@interface RegsterEnterManager : NSObject

@end

@implementation RegsterEnterManager

+ (void)loadSegmentInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dyld_register_func_for_add_image(_image_add_func);
    });
}

@end

@interface UITextBGView : UIView

/** <#注释#> */
@property (nonatomic, strong) YZHTextView *textView;

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
@property (nonatomic, strong) YZHTextView *textView;

/** <#注释#> */
@property (nonatomic, strong) UIImage *image;

/** <#注释#> */
@property (nonatomic, strong) ImageView *imgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [RegsterEnterManager loadSegmentInfo];
    
    self.view.backgroundColor = [UIColor orangeColor];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [self _test];
    
//    [self _setupChildView];
    
//    [self _test2];
    
    [self pri_testTextView];
    
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
    YZHTextView *textView = [[YZHTextView alloc] initWithFrame:CGRectMake(x, y, w, h)];
//    textView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
//    textView.font = FONT(20);
//    textView.text = @"123";
    textView.font = SYS_FONT(17);
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
    YZHButton *btn = [YZHButton buttonWithType:UIButtonTypeCustom];
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
    
    YZHButton *btn = [YZHButton buttonWithType:UIButtonTypeCustom];
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
//    ViewController *next = [ViewController new];
//    [self.navigationController pushViewController:next animated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
    return;
//    [self pri_testABC];
//    [self pri_testTransaction];
    
//    [self pri_testMessageForward];
//    [self pri_testDeallocProxy];
    return;
    
//    [self pri_testImage];
//    CGFloat t = (arc4random() & 7) * 1.0 / 8;
//    [self pri_ATask:t];
//
//    return;
//    [self.view endEditing:YES];
//    [self.timer invalidate];
    
//    YZHAlertView *alertView = [[YZHAlertView alloc] initWithTitle:@"提示" alertMessage:@"提示信息" alertViewStyle:YZHAlertViewStyleAlertForce];
//
//    [alertView alertShowInView:nil animated:NO];
//
//    UIAlertView *alertView2 = [[UIAlertView alloc] initWithTitle:@"提示" message:@"提示信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alertView2 show];
    
//    [YZHToast toastWithText:@"请稍后..."];
    
//    [self pri_testDeallocProxy];
    
//    [self pri_testGCDTimer];
    
    
//    [self pri_getIvar];
    
//    [self pri_testMMGraph];
    
//    [self pri_testAppClass];
    
//    [self pri_testRunLoopFreeEvent];
    
    static BOOL start = NO;
    if (!start) {
        start=YES;
        [self pri_threadTest];
    }
    else {
        NSLog(@"touch ===============================");
    }
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

- (void)pri_testAppClass {
    Class cls = [NSOperation class];
    NSTimeInterval t1 = [[NSDate date] timeIntervalSince1970] * 1000;
    
    NSBundle *bdl = [NSBundle bundleForClass:cls];
    if (bdl == [NSBundle mainBundle]) {
        NSLog(@"is custom class");
    }
    else {
        NSLog(@"system class");
    }
    NSTimeInterval t2 = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"diff=%@ms",@(t2-t1));
    
    Dl_info info;
    if (dladdr((__bridge void *)cls, &info) != 0) {
        if (info.dli_fname) {
            NSString *clsBundlePath = [NSString stringWithUTF8String:info.dli_fname];
            // 在应用bundle中，且不为dylib（Swift库）
            if (clsBundlePath && [clsBundlePath hasPrefix:NSBundle.mainBundle.bundlePath] && ![clsBundlePath hasSuffix:@".dylib"]) { //App集成的Frameworks都在App目录的Frameworks文件夹下面
                NSLog(@"custom class");
            }
        }
    }

    NSTimeInterval t3 = [[NSDate date] timeIntervalSince1970] * 1000;
    NSLog(@"diff.dladdr=%@ms",@(t3-t2));
}

- (void)pri_testRunLoopFreeEvent {
    
    NSLog(@"do test");
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFStringRef runLoopMode = kCFRunLoopDefaultMode;
    __block CFRunLoopObserverRef observer;
    __block NSInteger cnt = 0;
    observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, true, 0xFFFFFF, ^(CFRunLoopObserverRef ob, CFRunLoopActivity activity) {
        
        NSLog(@"before waiting,activity=%@",@(activity));
        
        if (cnt == 0) {
//            dispatch_after_in_main_queue(10, ^{
//                NSLog(@"after");
//            });
//            dispatch_async_in_main_queue(^{
//                NSLog(@"async");
//            });
        }
        
//        CFRunLoopRemoveObserver(runLoop, ob, runLoopMode);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            CFRunLoopAddObserver(runLoop, ob, runLoopMode);
//        });
//        CFRelease(observer);
        
        ++cnt;
    });
    CFRunLoopAddObserver(runLoop, observer, runLoopMode);
    
    CFRunLoopObserverRef afterWaitingObserver = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAfterWaiting, true, 0xFFFFFF, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"after waiting,activity=%@",@(activity));
        
    });
    CFRunLoopAddObserver(runLoop, afterWaitingObserver, runLoopMode);
}

- (void)pri_threadTest {
//    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(pri_newThreadEntry) object:nil];
//    thread.name = @"test";
//    [thread start];
    
    [self pri_newThreadEntry];
}

- (void)pri_newThreadEntry {
    
    NSInteger cnt = 10;
    for (NSInteger i = 0; i < cnt; ++i) {
        NSLog(@"ADD.i=%@",@(i));
        [YZHActivityManager addActivity:kCFRunLoopBeforeWaiting taskBlock:^(CFRunLoopActivity activity) {
            NSLog(@"i=%@",@(i));
            [NSThread sleepForTimeInterval:0.5];
        }];
    }
    NSLog(@"finish");
}

- (void)pri_performTest:(id)object {
    NSLog(@"object=%@",object);
}



- (BOOL)shouldAutorotate
{
    BOOL should = [self hz_shouldAutorotate];
    NSLog(@"VC.should=%@",@(should));
    return should;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
    NSLog(@"VC.mask=%@",@([self hz_supportedInterfaceOrientations]));
    return [self hz_supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    NSLog(@"prefer=%@",@([self hz_preferredInterfaceOrientationForPresentation]));
    return [self hz_preferredInterfaceOrientationForPresentation];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    [self hz_updateCurrentDeviceOrientation:UIDeviceOrientationLandscapeLeft];
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self hz_updateCurrentDeviceOrientation:UIDeviceOrientationLandscapeLeft];
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
