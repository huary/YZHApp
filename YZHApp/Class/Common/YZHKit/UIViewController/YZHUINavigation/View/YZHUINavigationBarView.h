//
//  YZHUINavigationBarView.h
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHKitType.h"

typedef NS_ENUM(NSInteger, UIBarViewStyle)
{
    UIBarViewStyleNone     = 0,
    UIBarViewStyleDefault  = UIBarStyleDefault,
    UIBarViewStyleBlack    = UIBarStyleBlack,
};

@interface YZHUINavigationBarView : UIView

@property (nonatomic, assign) UIBarViewStyle style;

@property (nonatomic, strong, readonly) UIImageView *bottomLine;

@end
