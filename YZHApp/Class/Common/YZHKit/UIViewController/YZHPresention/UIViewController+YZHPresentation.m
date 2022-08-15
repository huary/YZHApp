//
//  UIViewController+YZHPresentation.m
//  YZHApp
//
//  Created by bytedance on 2022/5/20.
//  Copyright © 2022 yuan. All rights reserved.
//

#import "UIViewController+YZHPresentation.h"
#import "YZHDefaultPresentationController.h"

@implementation UIViewController (YZHPresentation)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self hz_exchangeInstanceMethod:@selector(presentViewController:animated:completion:) with:@selector(hz_presentViewController:animated:completion:)];
    });
}

- (void)setHz_presentationEnable:(BOOL)hz_presentationEnable {
    if (![self hz_strongReferenceObjectForKey:@"hz_presentationEnable"]) {
        [self hz_addStrongReferenceObject:@(hz_presentationEnable) forKey:@"hz_presentationEnable"];
    }
}

- (BOOL)hz_presentationEnable {
    NSNumber *enableValue = [self hz_strongReferenceObjectForKey:@"hz_presentationEnable"];
    if (!enableValue) {
        return NO;
    }
    return [enableValue boolValue];
}

- (void)setHz_presentTopLayoutY:(CGFloat)hz_presentTopLayoutY {
    [self hz_addStrongReferenceObject:@(hz_presentTopLayoutY) forKey:@"hz_presentTopLayoutY"];
}

- (CGFloat)hz_presentTopLayoutY {
    return [[self hz_strongReferenceObjectForKey:@"hz_presentTopLayoutY"] floatValue];
}

- (NSNumber *)pri_itn_presentTopLayoutY {
    return [self hz_strongReferenceObjectForKey:@"hz_presentTopLayoutY"];
}

- (void)hz_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    YZHDefaultPresentationController *presentationController = nil;
    if (viewControllerToPresent.hz_presentationEnable) {
        presentationController = [[YZHDefaultPresentationController alloc] initWithPresentedViewController:viewControllerToPresent presentingViewController:self];
        NSNumber *topLayoutY = [viewControllerToPresent pri_itn_presentTopLayoutY];
        if (topLayoutY) {
            presentationController.defaultTopLayoutY = [topLayoutY floatValue];
        }
    }
    [self hz_presentViewController:viewControllerToPresent animated:flag completion:completion];

}

@end
