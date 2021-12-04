//
//  UIViewController+YZHNavigationItn.h
//  YZHApp
//
//  Created by bytedance on 2021/11/26.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHNavigationBarView.h"
#import "YZHNavigationItemView.h"

@interface UIViewController (YZHNavigationItn)

@property (nonatomic, strong) YZHNavigationBarView *hz_itn_navigationBarView;

@property (nonatomic, strong) YZHNavigationItemView *hz_itn_navigationItemView;

//默认为8
@property (nonatomic, assign) CGFloat hz_itn_leftItemsSpace;

//默认为8
@property (nonatomic, assign) CGFloat hz_itn_rightItemsSpace;

//默认为20
@property (nonatomic, assign) CGFloat hz_itn_leftEdgeSpace;

//默认为20
@property (nonatomic, assign) CGFloat hz_itn_rightEdgeSpace;

@end
