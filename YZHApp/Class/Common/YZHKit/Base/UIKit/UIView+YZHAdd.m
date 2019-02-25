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

GET_SET_PROPERTY(CGFloat, top, Top)

GET_SET_PROPERTY(CGFloat, left, Left)

GET_SET_PROPERTY(CGFloat, right, Right)

GET_SET_PROPERTY(CGFloat, bottom, Bottom)

GET_SET_PROPERTY(CGFloat, width, Width)

GET_SET_PROPERTY(CGFloat, height, Height)

GET_SET_PROPERTY(CGFloat, centerX, CenterX)

GET_SET_PROPERTY(CGFloat, centerY, CenterY)

GET_SET_PROPERTY(CGPoint, origin, Origin)

GET_SET_PROPERTY(CGSize, size, Size)



-(UIImage*)snapshotImage
{
    return [self.layer snapshotImage];
}

-(UIImageView*)snapshotImageView
{
    return [self.layer snapshotImageView];
}

-(UIViewController*)viewController
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
