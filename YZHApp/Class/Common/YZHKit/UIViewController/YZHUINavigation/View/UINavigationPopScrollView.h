//
//  UINavigationPopScrollView.h
//  YZHUINavigationController
//
//  Created by yuan on 16/11/21.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHKitType.h"

@interface UINavigationPopScrollView : UIScrollView

//在进行回调的时候，一定要注意循环引用的问题,这里已经对scrollView进行弱引用
@property (nonatomic, copy) UIPanGestureRecognizersShouldRecognizeSimultaneouslyBlock panRecognizersSimultaneouslyBlock;

@end
