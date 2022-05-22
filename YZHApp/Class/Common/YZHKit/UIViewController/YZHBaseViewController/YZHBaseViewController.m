//
//  YZHBaseUIViewController.m
//  YXX
//
//  Created by yuan on 2017/4/24.
//  Copyright © 2017年 yuanzh. All rights reserved.
//

#import "YZHBaseViewController.h"
#import "YZHKitMacro.h"


@interface YZHBaseViewController ()

@end

@implementation YZHBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = WHITE_COLOR;
    
    [self _setupContentView];

    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)_setupContentView
{
    UIView *contentView = [UIView new];
    [self.view addSubview:contentView];
    _contentView = contentView;
    [self _updateContentView];
}

-(void)_updateContentView
{
    CGRect frame = CGRectZero;
    frame.origin = CGPointMake(SAFE_X, SAFE_Y);
    frame.size = [[self class] contentViewSize];
    if (self.tabBarController.tabBar && self.hidesBottomBarWhenPushed == NO) {
        frame.size.height = frame.size.height + SAFE_BOTTOM - self.tabBarController.tabBar.hz_height;        
    }
    self.contentView.frame = frame;
    
//    self.layoutTopY = self.navigationBar.hz_height - SAFE_Y;
    self.contentViewLayoutTopY = self.navigationBar.hz_height - SAFE_Y;
    
    self.contentView.backgroundColor = self.view.backgroundColor;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self _updateContentView];
}


-(void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    [self _updateContentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

+(CGSize)contentViewSize
{
    return CGSizeMake(SAFE_WIDTH, SAFE_HEIGHT);
}

+ (CGFloat)bottomSafeOffY {
    return SAFE_BOTTOM;
}

@end
