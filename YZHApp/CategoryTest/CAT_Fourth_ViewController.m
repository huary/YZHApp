//
//  CAT_Fourth_ViewController.m
//  YZHApp
//
//  Created by bytedance on 2021/11/25.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "CAT_Fourth_ViewController.h"
#import "UIViewController+YZHNavigation.h"

#import "ViewController.h"
#import "UIViewController+YZHPresentation.h"

@interface CAT_Fourth_ViewController ()
@property (nonatomic, assign) NSInteger level;

@end

@implementation CAT_Fourth_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self pri_setupNavgationBar];
}

- (void)pri_setupNavgationBar {
    if (!self.level) {
        self.hz_navigationBarViewBackgroundColor = [UIColor redColor];
        [self hz_addNavigationLeftItemWithImage:nil title:@"left" isReset:YES actionBlock:nil];
        
        [self hz_addNavigationRightItemsWithTitles:@[@"right"] isReset:YES actionBlock:nil];
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
//    if (self.level == 0) {
//        [self pri_enter];
//    }
    [self pri_testPresentation];
}

- (void)pri_enter {
    CAT_Fourth_ViewController *vc = [[self class] new];
    vc.level = self.level + 1;
    vc.hz_navigationEnable = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pri_testPresentation {
    ViewController *first = [ViewController new];
//    first.hz_presentationEnable = YES;
    first.hz_navigationEnable = YES;
    first.hz_navigationEnableForRootVCInitSetToNavigation = YES;
    first.hz_barAndItemStyleForRootVCInitSetToNavigation = YZHNavigationBarAndItemStyleVCBarItem;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:first];
    nav.hz_presentationEnable = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
