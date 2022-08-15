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
        self.defaultTopLayoutY = 57;
        self.presentWillBeginAnimationBlock = ^(YZHPresentationController * _Nonnull presentationController, id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            presentationController.dimmingView.alpha = 0.5;
        };
        self.dismissWillBeginAnimationBlock = ^(YZHPresentationController * _Nonnull presentationController, id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            presentationController.dimmingView.alpha = 0;
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

- (UIView *)dimmingView {
    if (!_dimmingView) {
        _dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        _dimmingView.backgroundColor = [UIColor blackColor];
        _dimmingView.alpha = 0;
        WEAK_SELF(weakSelf);
        [_dimmingView hz_addTapGestureRecognizerBlock:^(UIGestureRecognizer *gesture) {
            [weakSelf.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _dimmingView;
}

//- (CGRect)frameOfPresentedViewInContainerView {
//    CGSize size = self.presentingViewController.view.hz_size;
//    return CGRectMake(0, self.defaultTopLayoutY, size.width, size.height - self.defaultTopLayoutY);
//}


//- (void)dealloc {
//    NSLog(@"YZHDefaultPresentationController dealloc");
//}

@end
