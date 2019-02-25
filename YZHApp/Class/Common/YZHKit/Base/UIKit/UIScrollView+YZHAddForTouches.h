//
//  UIScrollView+YZHAddForTouches.h
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL(^YZHTouchesShouldCancelInContentViewBlock)(UIScrollView *scrollView,UIView *contentView);

@interface UIScrollView (YZHAddForTouches)

@property (nonatomic, assign) BOOL touchToNextResponder;

@property (nonatomic, copy) YZHTouchesShouldCancelInContentViewBlock touchesShouldCancelBlock;

@end
