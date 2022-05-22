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
    if (![self hz_strongReferenceObjectForKey:@"hz_VCPresentationEnableKey"]) {
        [self hz_addStrongReferenceObject:@(hz_presentationEnable) forKey:@"hz_VCPresentationEnableKey"];
    }
}

- (BOOL)hz_presentationEnable {
    return [self hz_strongReferenceObjectForKey:@"hz_VCPresentationEnableKey"];
}

- (void)hz_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    YZHDefaultPresentationController *presentationController = nil;
    if (viewControllerToPresent.hz_presentationEnable) {
        presentationController = [[YZHDefaultPresentationController alloc] initWithPresentedViewController:viewControllerToPresent presentingViewController:self];
    }
    [self hz_presentViewController:viewControllerToPresent animated:flag completion:completion];

}

@end
