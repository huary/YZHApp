//
//  UIDevice+YZHAdd.h
//  LZGameBox
//
//  Created by yuan on 2020/4/26.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (YZHAdd)

+ (UIDeviceOrientation)hz_currentDeviceOrientation;

+ (void)hz_updateDeviceOrientation:(UIDeviceOrientation)orientation;


@end

NS_ASSUME_NONNULL_END
