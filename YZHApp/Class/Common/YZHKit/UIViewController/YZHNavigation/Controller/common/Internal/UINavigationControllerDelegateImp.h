//
//  UINavigationControllerDelegateImp.h
//  YZHApp
//
//  Created by bytedance on 2021/11/22.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationControllerDelegateImp : NSObject <UINavigationControllerDelegate>

+ (instancetype)delegateWithTarget:(UINavigationController *)target;

@end

NS_ASSUME_NONNULL_END
