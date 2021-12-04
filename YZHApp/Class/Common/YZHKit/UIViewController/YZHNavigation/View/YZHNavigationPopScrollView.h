//
//  UINavigationPopScrollView.h
//  YZHNavigationController
//
//  Created by yuan on 16/11/21.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL(^YZHPanGestureRecognizerShouldRecognizeSimultaneouslyBlock)(UIScrollView *scrollView,UIGestureRecognizer *first, UIGestureRecognizer *second);

@interface YZHNavigationPopScrollView : UIScrollView

//在进行回调的时候，要注意循环引用的问题
@property (nonatomic, copy) YZHPanGestureRecognizerShouldRecognizeSimultaneouslyBlock shouldRecognizeSimultaneouslyBlock;

@end
