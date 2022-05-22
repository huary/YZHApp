//
//  First_IHRT_ViewController.m
//  YZHApp
//
//  Created by bytedance on 2021/11/25.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "IHRT_First_ViewController.h"
#import "UIViewController+YZHNavigation.h"
#import "ViewController.h"

@interface IHRT_First_ViewController ()

@property (nonatomic, assign) NSInteger level;

@end

@implementation IHRT_First_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self pri_setupNavgationBar];
    
    [self pri_testTextView];
}

- (void)pri_setupNavgationBar {
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self pri_testOrientation];
//    if (self.level < 1) {
//        [self pri_enter];
//    }
//    else {
//        [self pri_pop];
//    }
}

- (void)pri_pop {
    NSMutableArray *vc = [self.navigationController.viewControllers mutableCopy];
    [vc removeLastObject];
//    UIViewController *last = vc.lastObject;
//    last.hidesBottomBarWhenPushed = NO;
    [self.navigationController setViewControllers:vc animated:YES];
}

- (void)pri_enter {
//    IHRT_First_ViewController *vc = [[self class] new];
//    vc.level = self.level + 1;
//    [self.navigationController pushViewController:vc animated:YES];
    
//    IHRT_First_ViewController *vc = [[self class] new];
//    vc.level = 1;
//    [self.navigationController setViewControllers:@[vc] animated:NO];
//    return;

//    IHRT_First_ViewController *vc = [[self class] new];
//    vc.level = self.level + 1;
//    [self.navigationController pushViewController:vc animated:NO];
//    return;
#if 1
    
    IHRT_First_ViewController *vc = [[self class] new];
    vc.level = self.level + 1;
    
    NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
    [vcs addObject:vc];
    
    IHRT_First_ViewController *tmp = [[self class] new];
    tmp.level = self.level + 2;
    [vcs addObject:tmp];
    tmp.hidesBottomBarWhenPushed = NO;
    
    [self.navigationController hz_setViewControllers:vcs animated:YES completion:^(UINavigationController *navigationController) {
        NSLog(@"push completion");
    }];
#endif
    
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


- (void)pri_testOrientation {
    ViewController *vc = [ViewController new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.hz_interfaceOrientationConfig.autoRotatable = YES;
    vc.hz_interfaceOrientationConfig.interfaceOrientationMask = UIInterfaceOrientationMaskLandscape;
    vc.hz_interfaceOrientationConfig.preferredInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
    self.hz_interfaceOrientationConfig.autoRotatable = YES;
    self.hz_interfaceOrientationConfig.interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
    [self.navigationController pushViewController:vc animated:YES];
//    [self presentViewController:vc animated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return YES;
    return [self hz_shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    NSLog(@"mask=%@",@([self hz_supportedInterfaceOrientations]));
//    return [self hz_supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskPortrait;
}



@end
