//
//  YZHViewController+Internal.h
//  YZHApp
//
//  Created by bytedance on 2021/11/21.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "YZHViewController.h"
#import "YZHNavigationBarView.h"
#import "YZHNavigationItemView.h"

@interface YZHViewController ()

@property (nonatomic, strong) YZHNavigationBarView *navigationBarView;

@property (nonatomic, strong) YZHNavigationItemView *navigationItemView;

//默认为8
@property (nonatomic, assign) CGFloat leftItemsSpace;

//默认为8
@property (nonatomic, assign) CGFloat rightItemsSpace;

//默认为20
@property (nonatomic, assign) CGFloat leftEdgeSpace;

//默认为20
@property (nonatomic, assign) CGFloat rightEdgeSpace;


@end
