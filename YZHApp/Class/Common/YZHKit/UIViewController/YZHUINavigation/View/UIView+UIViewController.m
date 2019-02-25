//
//  UIView+UIViewController.m
//  BaseDefaultUINavigationController
//
//  Created by captain on 16/11/15.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "UIView+UIViewController.h"

@implementation UIView (UIViewController)

-(UIViewController*)viewController
{
    UIResponder *next = self.nextResponder;
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)next;
        }
        next = next.nextResponder;
    } while (next != nil);
    return nil;
}


//-(UINavigationController*)navigationController
//{
//    UIResponder *next = self.nextResponder;
//    do {
//        if ([next isKindOfClass:[UINavigationController class]]) {
//            return (UINavigationController*)next;
//        }
//        next = next.nextResponder;
//    } while (next != nil);
//    
//    return self.viewController.navigationController;
//}

@end
