//
//  UIViewController+YZHNavigationControllerAction.h
//  YZHApp
//
//  Created by bytedance on 2021/11/23.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHNavigationTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (YZHNavigationControllerAnimation)

@property (nonatomic, copy, nullable) YZHNavigationControllerAnimationCompletionBlock itn_popCompletionBlock;
@property (nonatomic, copy, nullable) YZHNavigationControllerAnimationCompletionBlock itn_pushCompletionBlock;

@end
NS_ASSUME_NONNULL_END
