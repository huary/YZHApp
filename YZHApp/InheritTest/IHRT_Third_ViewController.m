//
//  Third_IHRT_ViewController.m
//  YZHApp
//
//  Created by bytedance on 2021/11/25.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "IHRT_Third_ViewController.h"
#import "UIViewController+YZHNavigation.h"

@interface IHRT_Third_ViewController ()

@property (nonatomic, assign) NSInteger level;

@end

@implementation IHRT_Third_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self pri_setupNavgationBar];
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
    if (self.level == 0) {
        [self pri_enter];
    }
}

- (void)pri_enter {
    IHRT_Third_ViewController *vc = [IHRT_Third_ViewController new];
    vc.level = self.level + 1;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
