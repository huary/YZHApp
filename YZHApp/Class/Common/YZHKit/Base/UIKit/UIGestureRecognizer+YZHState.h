//
//  UIGestureRecognizer+YZHState.h
//  yxx_ios
//
//  Created by yuan on 2017/4/8.
//  Copyright © 2017年 GDtech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YZHUIGestureRecognizerState)
{
    YZHUIGestureRecognizerStateNull     = 0,
    YZHUIGestureRecognizerStateBegan    = 1,
    YZHUIGestureRecognizerStateChanged  = 2,
    YZHUIGestureRecognizerStateEnded    = 3,
};


@interface UIGestureRecognizer (YZHState)

@property (nonatomic, assign) YZHUIGestureRecognizerState YZHState;

@property (nonatomic, assign) CGPoint lastPoint;

@end
