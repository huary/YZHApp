//
//  UIView+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIView+YZHAdd.h"
#import "YZHKitType.h"
#import "CALayer+YZHAdd.h"

@implementation UIView (YZHAdd)

GET_SET_PROPERTY(CGFloat, top, hz_top, Hz_top)

GET_SET_PROPERTY(CGFloat, left, hz_left, Hz_left)

GET_SET_PROPERTY(CGFloat, right, hz_right, Hz_right)

GET_SET_PROPERTY(CGFloat, bottom, hz_bottom, Hz_bottom)

GET_SET_PROPERTY(CGFloat, width, hz_width, Hz_width)

GET_SET_PROPERTY(CGFloat, height, hz_height, Hz_height)

GET_SET_PROPERTY(CGFloat, centerX, hz_centerX, Hz_centerX)

GET_SET_PROPERTY(CGFloat, centerY, hz_centerY, Hz_centerY)

GET_SET_PROPERTY(CGPoint, origin, hz_origin, Hz_origin)

GET_SET_PROPERTY(CGSize, size, hz_size, Hz_size)



-(UIImage*)hz_snapshotImage
{
    return [self.layer hz_snapshotImage];
}

-(UIImageView*)hz_snapshotImageView
{
    return [self.layer hz_snapshotImageView];
}

-(UIViewController*)hz_viewController
{
    UIResponder *next = self.nextResponder;
    while (next) {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)next;
        }
        next = next.nextResponder;
    }
    return nil;
}

@end
