//
//  CAT_Third_ViewController.m
//  YZHApp
//
//  Created by bytedance on 2021/11/25.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "CAT_Third_ViewController.h"
#import "UIViewController+YZHNavigation.h"

@interface CAT_Third_ViewController ()

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, strong) UIButton *btn;

@property (nonatomic, strong) UIButton *btn2;

@end

@implementation CAT_Third_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self pri_setupNavgationBar];
}

- (void)pri_setupNavgationBar {
    if (!self.level) {
        UIButton *btn = nil;
        self.hz_navigationBarViewBackgroundColor = [UIColor redColor];
//        btn = [self hz_addNavigationLeftItemWithImage:nil title:@"left" isReset:YES actionBlock:nil];
//        
//        [btn setTitle:@"首页Left" forState:UIControlStateNormal];
//        self.btn = btn;
//        
//        self.btn2 = [self hz_addNavigationLeftItemWithImage:nil title:@"Left-2" isReset:NO actionBlock:nil];
//        
//        
//        btn = [[self hz_addNavigationRightItemsWithTitles:@[@"right"] isReset:YES actionBlock:nil] firstObject];
//        [btn setTitle:@"首页RightItem" forState:UIControlStateNormal];
        
        
//        [self hz_setupItemsSpace:20 left:YES];
//        [self hz_setupItemsSpace:20 left:NO];
//        [self hz_setupItemEdgeSpace:30 left:YES];
//        [self hz_setupItemEdgeSpace:30 left:NO];
        
        [self hz_addNavigationLeftItemWithImage:nil title:@"L" isReset:YES actionBlock:nil];
        [self hz_addNavigationRightItemsWithTitles:@[@"R"] isReset:YES actionBlock:nil];

        [self hz_addNavigationLeftItemsWithTitles:@[@"L-1",@"L-2",] isReset:YES actionBlock:^(UIViewController *viewController, UIButton *button) {
            NSLog(@"left.btn=%ld",button.tag);
        }];
        [self hz_addNavigationRightItemsWithTitles:@[@"R-1",@"R-2"] isReset:NO actionBlock:^(UIViewController *viewController, UIButton *button) {
            NSLog(@"right.btn=%ld",button.tag);
        }];
        return;
    }
    
    self.hz_navigationBarViewBackgroundColor = [UIColor purpleColor];

    [self hz_addNavigationFirstLeftBackItemWithTitle:@"返回" actionBlock:^(UIViewController *viewController, UIButton *button) {
        [viewController.navigationController popViewControllerAnimated:YES];
    }];
    
    YZHNavigationController *nav = (YZHNavigationController*)self.navigationController;
    self.hz_navigationTitle = [NSString stringWithFormat:@"%ld-level-%ld",nav.hz_navigationBarAndItemStyle,self.level];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.level == 0) {
        [self pri_enter];
    }
}

- (void)pri_enter {
    CAT_Third_ViewController *vc = [[self class] new];
    vc.level = self.level + 1;
    vc.hz_navigationEnable = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
