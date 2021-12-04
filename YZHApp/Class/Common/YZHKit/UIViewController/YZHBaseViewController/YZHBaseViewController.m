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

-(instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

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
    self.contentView.frame = frame;
//    _contentViewSize = self.contentView.bounds.size;
    
    self.layoutTopY = STATUS_NAV_BAR_HEIGHT - SAFE_Y;
    
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


@end
