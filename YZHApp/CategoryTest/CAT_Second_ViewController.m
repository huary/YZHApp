//
//  CAT_Second_ViewController.m
//  YZHApp
//
//  Created by bytedance on 2021/11/25.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "CAT_Second_ViewController.h"
#import "UIViewController+YZHNavigation.h"

@interface CAT_Second_ViewController ()

@property (nonatomic, assign) NSInteger level;

@end

@implementation CAT_Second_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self pri_setupNavgationBar];
}

- (void)pri_setupNavgationBar {
    UIButton *btn = nil;
    if (!self.level) {
        self.hz_navigationBarViewBackgroundColor = [UIColor redColor];
        btn = [self hz_addNavigationLeftItemWithImage:nil title:@"left" isReset:YES actionBlock:nil];
        
        [btn setTitle:@"hello world" forState:UIControlStateNormal];
        
        [self hz_addNavigationRightItemsWithTitles:@[@"right"] isReset:YES actionBlock:nil];
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
    CAT_Second_ViewController *vc = [[self class] new];
    vc.level = self.level + 1;
    vc.hz_navigationEnable = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
