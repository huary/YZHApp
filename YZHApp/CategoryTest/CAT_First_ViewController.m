//
//  CAT_First_ViewController.m
//  YZHApp
//
//  Created by bytedance on 2021/11/25.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "CAT_First_ViewController.h"
#import "UIViewController+YZHNavigation.h"

@interface CAT_First_ViewController ()

@property (nonatomic, assign) NSInteger level;

@end

@implementation CAT_First_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
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

        [self hz_addNavigationLeftItemsWithTitles:@[@"L-1",@"L-2",] isReset:NO actionBlock:^(UIViewController *viewController, UIButton *button) {
            NSLog(@"left.btn=%ld",button.tag);
        }];
        [self hz_addNavigationRightItemsWithTitles:@[@"R-1",@"R-2"] isReset:NO actionBlock:^(UIViewController *viewController, UIButton *button) {
            NSLog(@"right.btn=%ld",button.tag);
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
    CAT_First_ViewController *vc = [[self class] new];
    vc.level = self.level + 1;
    vc.hz_navigationEnable = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
