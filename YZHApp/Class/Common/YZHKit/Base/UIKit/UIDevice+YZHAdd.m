//
//  UIDevice+YZHAdd.m
//  LZGameBox
//
//  Created by yuan on 2020/4/26.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "UIDevice+YZHAdd.h"
#import <CoreMotion/CoreMotion.h>

static CMMotionManager *_defaultMotionManager_s = nil;


@implementation UIDevice (YZHAdd)

+ (CMMotionManager *)defaultMotionManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultMotionManager_s = [[CMMotionManager alloc] init];
    });
    return _defaultMotionManager_s;
}

+ (UIDeviceOrientation)pri_currentDeviceOrientationFromDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    if (deviceMotion == nil) {
        return UIDeviceOrientationUnknown;
    }
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
//    double z = deviceMotion.gravity.z;
    UIDeviceOrientation orientation = UIDeviceOrientationUnknown;
    if (fabs(y) > fabs(x)) {
        if (y >= 0.0f) {
            orientation = UIDeviceOrientationPortraitUpsideDown;
        }
        else {
            orientation = UIDeviceOrientationPortrait;
        }
    }
    else {
        if (x >= 0.0f) {
            orientation = UIDeviceOrientationLandscapeRight;
        }
        else {
            orientation = UIDeviceOrientationLandscapeLeft;
        }
    }
    NSLog(@"x=%@, y=%@，orientation=%@",@(x),@(y),@(orientation));
    return orientation;
}

+ (UIDeviceOrientation)hz_currentDeviceOrientation
{
    CMMotionManager *defaultMgr = [self defaultMotionManager];
    
    if (![defaultMgr isDeviceMotionAvailable]) {
        return UIDeviceOrientationUnknown;
    }
    
    [defaultMgr startDeviceMotionUpdates];
    
    UIDeviceOrientation orientation = [self pri_currentDeviceOrientationFromDeviceMotion:defaultMgr.deviceMotion];
    
    return orientation;
}

+ (void)hz_updateDeviceOrientation:(UIDeviceOrientation)orientation
{
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
}

@end
