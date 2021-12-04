//
//  YZHNavigationBarView.h
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHNavigationTypes.h"

@interface YZHNavigationBarView : UIView

@property (nonatomic, assign) YZHNavBarStyle style;

@property (nonatomic, strong, readonly) UIImageView *bottomLine;

@end
