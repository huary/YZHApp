//
//  YZHDefaultPresentationController.m
//  YZHApp
//
//  Created by bytedance on 2022/5/6.
//  Copyright © 2022 yuan. All rights reserved.
//

#import "YZHDefaultPresentationController.h"
#import "YZHPresentView.h"

@implementation YZHDefaultPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        self.defaultTopLayoutY = 300;
        self.presentWillBeginAnimationBlock = ^(YZHPresentationController * _Nonnull presentationController, id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            presentationController.dismissView.alpha = 0.5;
        };
        self.dismissWillBeginAnimationBlock = ^(YZHPresentationController * _Nonnull presentationController, id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            presentationController.dismissView.alpha = 0;
        };
    }
    return self;
}

- (UIView *)presentView {
    if (!_presentView) {
        CGRect frame = [self frameOfPresentedViewInContainerView];
        
        YZHPresentView *tmp = [[YZHPresentView alloc] initWithFrame:frame];
        tmp.layer.cornerRadius = 16;
        tmp.maskedCornerRadius = UIRectCornerTopLeft | UIRectCornerTopRight;
        tmp.layer.masksToBounds = YES;
        
        _presentView = tmp;
    }
    return _presentView;
}

- (UIView *)dismissView {
    if (!_dismissView) {
        _dismissView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        _dismissView.backgroundColor = [UIColor blackColor];
        _dismissView.alpha = 0;
        WEAK_SELF(weakSelf);
        [_dismissView hz_addTapGestureRecognizerBlock:^(UIGestureRecognizer *gesture) {
            [weakSelf.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _dismissView;
}


//- (void)dealloc {
//    NSLog(@"YZHDefaultPresentationController dealloc");
//}

@end
