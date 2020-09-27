//
//  UIViewController+YZHAdd.h
//  LZGameBox
//
//  Created by yuan on 2020/4/8.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSVCInterfaceOrientationConfigOption)
{
    NSVCInterfaceOrientationConfigOptionAutoRotatable                  = 1,
    NSVCInterfaceOrientationConfigOptionInterfaceOrientationMask       = 2,
    NSVCInterfaceOrientationConfigOptionPreferredInterfaceOrientation  = 3,
};

typedef NSNumber*_Nonnull(^NSVCInterfaceOrientationConfigDynamicProvider)(UIViewController * _Nonnull viewController, NSVCInterfaceOrientationConfigOption option);

@interface NSVCInterfaceOrientationConfig : NSObject

/** <#name#> */
@property (nonatomic, assign) BOOL autoRotatable;

/** <#name#> */
@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientationMask;

/** <#name#> */
@property (nonatomic, assign) UIInterfaceOrientation preferredInterfaceOrientation;

- (instancetype _Nonnull )initWithDynamicProvider:(NSVCInterfaceOrientationConfigDynamicProvider _Nullable )provider;


@end





NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (YZHAdd)

/** <#注释#> */
@property (nonatomic, strong, readonly) NSVCInterfaceOrientationConfig *hz_interfaceOrientationConfig;

- (BOOL)hz_shouldAutorotate;

- (UIInterfaceOrientationMask)hz_supportedInterfaceOrientations;

//The system calls this method when presenting the view controller full screen
//只会在调用presentViewController的时候，并且self.modalPresentationStyle 为UIModalPresentationFullScreen时才会调用这个值
- (UIInterfaceOrientation)hz_preferredInterfaceOrientationForPresentation;

- (void)hz_updateCurrentDeviceOrientation:(UIDeviceOrientation)orientation;

@end

NS_ASSUME_NONNULL_END
