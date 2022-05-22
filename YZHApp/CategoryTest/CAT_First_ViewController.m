//
//  CAT_First_ViewController.m
//  YZHApp
//
//  Created by bytedance on 2021/11/25.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "CAT_First_ViewController.h"
#import "UIViewController+YZHNavigation.h"

#import "YZHActivityManager.h"
#import "YZHImageBrowserController.h"
#import "YZHCircleProgressView.h"

#import "UIViewController+YZHAdd.h"
#import "ViewController.h"

@interface CAT_First_ViewController ()

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, strong) YZHImageBrowserController *imageBrowserController;

@property (nonatomic, copy) NSArray<NSString*> *imageNamedList;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) YZHCircleProgressView *progressView;

@end

@implementation CAT_First_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self pri_setupNavgationBar];
    
    [self pri_setupSubviews];
}

- (void)pri_setupNavgationBar {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appperance = [[UINavigationBarAppearance alloc] init];
        appperance.backgroundColor = ORANGE_COLOR;
        appperance.shadowImage = [[UIImage alloc]init];
        appperance.shadowColor = nil;
        self.navigationController.navigationBar.standardAppearance = appperance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appperance;
    } else {
        // Fallback on earlier versions
    }
    if (!self.level) {
        self.hz_navigationBarViewBackgroundColor = [UIColor redColor];
                
//        [self hz_setupItemsSpace:20 left:YES];
//        [self hz_setupItemsSpace:20 left:NO];
//        [self hz_setupItemEdgeSpace:30 left:YES];
//        [self hz_setupItemEdgeSpace:30 left:NO];
        
        [self hz_addNavigationLeftItemWithImage:nil title:@"L" isReset:YES actionBlock:nil];
        [self hz_addNavigationRightItemsWithTitles:@[@"R"] isReset:YES actionBlock:nil];

        [self hz_addNavigationLeftItemsWithTitles:@[@"L-1",@"L-2",] isReset:NO actionBlock:^(UIViewController *viewController, UIView *itemView) {
            NSLog(@"left.btn=%ld",itemView.tag);
        }];
        [self hz_addNavigationRightItemsWithTitles:@[@"R-1",@"R-2"] isReset:NO actionBlock:^(UIViewController *viewController, UIView *itemView) {
            NSLog(@"right.btn=%ld",itemView.tag);
        }];
        
//        [self hz_addNavigationLeftItemWithImage:nil title:@"Left" isReset:YES actionBlock:nil];
//        [self hz_addNavigationRightItemsWithTitles:@[@"Right"] isReset:YES actionBlock:nil];
        
        
//        [self hz_setupItemsSpace:20 left:YES];
//        [self hz_setupItemsSpace:20 left:NO];
//        [self hz_setupItemEdgeSpace:30 left:YES];
//        [self hz_setupItemEdgeSpace:30 left:NO];
        return;
    }
    
    self.hz_navigationBarViewBackgroundColor = [UIColor purpleColor];
    
    [self hz_addNavigationFirstLeftBackItemWithTitle:@"返回" actionBlock:^(UIViewController *viewController, UIView *itemView) {
        [viewController.navigationController popViewControllerAnimated:YES];
    }];
    
    YZHNavigationController *nav = (YZHNavigationController*)self.navigationController;
    self.hz_navigationTitle = [NSString stringWithFormat:@"%ld-level-%ld",nav.hz_navigationBarAndItemStyle,self.level];
}

- (void)pri_setupSubviews {
//    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    self.imageView.image = [UIImage imageNamed:@"9.jpg"];
//
//
//    [self.view addSubview:self.imageView];
    
    self.progressView = [[YZHCircleProgressView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.progressView.circleType = YZHCircleProgressViewTypeDefaultOnce;
//    self.progressView.progressBorderWidth = 10;
    self.progressView.progressColor = [UIColor purpleColor];
    self.progressView.progressTrackColor = [UIColor redColor];
//    self.progressView.progressBorderColor = [UIColor yellowColor];
    
    self.progressView.backgroundColor = [UIColor brownColor];
    
    self.progressView.progressLineWidth = 30;
    self.progressView.progressInsideRadius = 0;
    
    
    self.progressView.progressTrackLineWidth = 2;
    self.progressView.progressTrackInsideRadius = 50 - 2;
//    self.progressView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.progressView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if (self.level < 1) {
//        [self pri_enter];
//    }
//    else {
//        [self pri_pop];
//    }
        
//    [self pri_newThread];
//    [self pri_newThreadEntry];
    
//    [self pri_startShowImage];
//    [self pri_setupProgress];
    
//    [self pri_testOrientation];
    
//    [self pri_testPresentation];
}

- (void)pri_pop {
    NSMutableArray *vc = [self.navigationController.viewControllers mutableCopy];
    [vc removeLastObject];
//    UIViewController *last = vc.lastObject;
//    last.hidesBottomBarWhenPushed = NO;
    [self.navigationController setViewControllers:vc animated:NO];
}

- (void)pri_enter {
//    CAT_First_ViewController *vc = [[self class] new];
//    vc.hz_navigationEnable = YES;
//    [self.navigationController setViewControllers:@[vc] animated:YES];
//    return;

//    CAT_First_ViewController *vc = [[self class] new];
//    vc.level = self.level + 1;
//    vc.hz_navigationEnable = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//    return;
#if 0
    
    CAT_First_ViewController *vc = [[self class] new];
    vc.level = self.level + 1;
    vc.hz_navigationEnable = YES;
    
    NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
    [vcs addObject:vc];
    
    CAT_First_ViewController *tmp = [[self class] new];
    tmp.level = self.level + 2;
    tmp.hz_navigationEnable = YES;
    [vcs addObject:tmp];
    tmp.hidesBottomBarWhenPushed = NO;
    
    [self.navigationController hz_setViewControllers:vcs completion:^(UINavigationController *navigationController) {
        NSLog(@"push completion");
    }];
#endif
}


- (void)pri_newThread {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(pri_newThreadEntry) object:nil];
    thread.name = @"test";
    [thread start];
//    [self pri_newThreadEntry];
}

- (void)pri_newThreadEntry {
    
//    static BOOL have = NO;
//    if (have) {
//        return;
//    }
//    have = YES;
    
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:5.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"timer action");
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    NSInteger cnt = 10;
    for (NSInteger i = 0; i < cnt; ++i) {
        NSLog(@"ADD.i=%@",@(i));
        [YZHActivityManager addActivity:kCFRunLoopBeforeWaiting taskBlock:^(CFRunLoopActivity activity) {
            NSLog(@"i=%@",@(i));
            [NSThread sleepForTimeInterval:0.5];
        }];
    }
    NSLog(@"finish");
    

    [[NSRunLoop currentRunLoop] run];
}

- (void)pri_testDelay{
    NSLog(@"==========%s",__FUNCTION__);
}


- (void)pri_images {
    self.imageNamedList = @[@"1.jpg",
                            @"2.jpg",
                            @"4.jpg",
                            @"5.jpg",
                            @"6.jpg",
                            @"7.jpg",
                            @"8.jpg",
                            @"9.jpg",
                            @"10.jpg",
                            @"11.jpg",
                            @"12.jpg",
                            @"13.jpg",
                            @"14.png",
                            @"15.png",
                            @"16.png",
                            @"17.png",
    ];
}

- (YZHImageBrowserController *)imageBrowserController
{
    if (_imageBrowserController == nil) {
        [self pri_images];
        _imageBrowserController = [YZHImageBrowserController new];
        WEAK_SELF(weakSelf);
        _imageBrowserController.updateCellBlock = ^(id  _Nonnull model, YZHImageCell * _Nonnull imageCell) {
            NSString *imageNamed = (NSString*)model;
            imageCell.zoomView.autoFitImageViewContentModeWithImage = YES;
            [imageCell updateWithImage:[UIImage imageNamed:imageNamed]];
        };
        
        _imageBrowserController.fetchBlock = ^(id  _Nonnull currModel, BOOL next, YZHImageBrowserControllerFetchCompletionBlock  _Nonnull fetchCompletionBlock) {
            NSLog(@"currModel=%@",currModel);
            if ([currModel isEqualToString:@"9.jpg"]) {
                if (next) {
                    fetchCompletionBlock(currModel, next, @[@"10.jpg",
                                                            @"11.jpg",
                                                            @"12.jpg",
                                                            @"13.jpg",
                                                            @"14.png",
                                                            @"15.png",
                                                            @"16.png",
                                                            @"17.png"]);

                }
                else {
                    fetchCompletionBlock(currModel, next, @[@"1.jpg",
                                                            @"2.jpg",
                                                            @"4.jpg",
                                                            @"5.jpg",
                                                            @"6.jpg",
                                                            @"7.jpg",
                                                            @"8.jpg"]);
                }
            }
            else {
                fetchCompletionBlock(currModel, next, @[]);
            }
        };
        
        _imageBrowserController.dismissBlock = ^(YZHImageBrowserController * _Nonnull imageBrowserController) {
            weakSelf.imageBrowserController = nil;
        };
    }
    return _imageBrowserController;
}

- (void)pri_startShowImage {
    UIImage *srcImage = self.imageView.image;
    [self.imageBrowserController showInView:nil fromView:self.imageView image:srcImage model:@"9.jpg"];
}

- (NSTimer *)timer {
    if (!_timer) {
        
        WEAK_SELF(weakSelf);
        __block CGFloat progress = 0;
        _timer = [NSTimer timerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            progress += 0.05;
            [weakSelf.progressView setProgress:progress animated:NO];
            if (progress >= 1.0) {
                [timer invalidate];
                weakSelf.timer = nil;
            }
        }];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    return _timer;
}

- (void)pri_setupProgress {
    [_timer invalidate];
    _timer = nil;
    [self.timer fire];
}


- (void)pri_testOrientation {
    ViewController *vc = [ViewController new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.hz_interfaceOrientationConfig.autoRotatable = YES;
    vc.hz_interfaceOrientationConfig.interfaceOrientationMask = UIInterfaceOrientationMaskLandscapeLeft;
    vc.hz_interfaceOrientationConfig.preferredInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
//    [self presentViewController:vc animated:YES completion:nil];
    self.hz_interfaceOrientationConfig.autoRotatable = NO;
    self.hz_interfaceOrientationConfig.interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)shouldAutorotate {
    return NO;
}


- (void)pri_testPresentation {
    CAT_First_ViewController *first = [CAT_First_ViewController new];
    first.hz_navigationEnable = YES;
    first.hz_navigationEnableForRootVCInitSetToNavigation = YES;
    first.hz_barAndItemStyleForRootVCInitSetToNavigation = YZHNavigationBarAndItemStyleVCBarItem;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:first];
    [self presentViewController:nav animated:YES completion:nil];
}


@end
