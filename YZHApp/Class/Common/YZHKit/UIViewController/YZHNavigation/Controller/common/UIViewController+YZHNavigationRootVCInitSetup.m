//
//  UIViewController+YZHNavigationRootVCInitSetup.m
//  YZHApp
//
//  Created by bytedance on 2021/11/26.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "UIViewController+YZHNavigationRootVCInitSetup.h"
#import "UIViewController+YZHNavigationItn.h"

static YZHNavigationConfig *navigationConfig_s = nil;

@implementation UIViewController (YZHNavigationRootVCInitSetup)

+ (void)setHz_navigationConfig:(YZHNavigationConfig *)hz_navigationConfig {
    navigationConfig_s = hz_navigationConfig;
}

+ (YZHNavigationConfig *)hz_navigationConfig {
    if (!navigationConfig_s) {
        navigationConfig_s = [YZHNavigationConfig new];
    }
    return navigationConfig_s;
}

- (void)setHz_navbarFrameBlock:(YZHNavBarViewFrameBlock)hz_navbarFrameBlock {
    YZHNavBarViewFrameBlock block = hz_navbarFrameBlock;
    if (hz_navbarFrameBlock) {
        block = ^CGRect(UIViewController *viewController, CGFloat *itemViewLayoutHeight) {
            CGRect frame = hz_navbarFrameBlock(viewController, itemViewLayoutHeight);
            viewController.hz_itn_navBarFrame = frame;
            viewController.hz_itn_itemViewLayoutHeight = *itemViewLayoutHeight;
            return frame;
        };
    }
    [self hz_addStrongReferenceObject:block forKey:@"hz_navbarFrameBlock"];
    [self hz_addStrongReferenceObject:block ? @(YES) : @(NO) forKey:@"hz_navbarFrameBlock_customSet"];
}

- (YZHNavBarViewFrameBlock)hz_navbarFrameBlock {
    YZHNavBarViewFrameBlock frameBlock = [self hz_strongReferenceObjectForKey:@"hz_navbarFrameBlock"];
    if (!frameBlock) {
        if ([self isKindOfClass:[UINavigationController class]]) {
            frameBlock = ^CGRect(UIViewController *viewController, CGFloat *itemViewLayoutHeight) {
                CGRect frame = CGRectMake(SAFE_X, -STATUS_BAR_HEIGHT, SAFE_WIDTH, STATUS_NAV_BAR_HEIGHT);
                viewController.hz_itn_navBarFrame = frame;
                viewController.hz_itn_itemViewLayoutHeight = frame.size.height - STATUS_BAR_HEIGHT;
                return frame;
            };
        }
        else {
            if (self.navigationController && [[self.navigationController hz_strongReferenceObjectForKey:@"hz_navbarFrameBlock_customSet"] boolValue]) {
                return self.navigationController.hz_navbarFrameBlock;
            }
            frameBlock = ^CGRect(UIViewController *viewController, CGFloat *itemViewLayoutHeight) {
                CGRect frame = CGRectMake(0, 0, SAFE_WIDTH, STATUS_NAV_BAR_HEIGHT);
                viewController.hz_itn_navBarFrame = frame;
                viewController.hz_itn_itemViewLayoutHeight = frame.size.height - STATUS_BAR_HEIGHT;
                return frame;
            };
        }
    }
    return frameBlock;
}


- (void)setHz_barAndItemStyleForRootVCInitSetToNavigation:(YZHNavigationBarAndItemStyle)hz_barAndItemStyleForRootVCInitSetToNavigation {
    [self hz_addStrongReferenceObject:@(hz_barAndItemStyleForRootVCInitSetToNavigation)
                               forKey:@"hz_barAndItemStyleForRootVCInitSetToNavigation"];
}

- (YZHNavigationBarAndItemStyle)hz_barAndItemStyleForRootVCInitSetToNavigation {
    return [[self hz_strongReferenceObjectForKey:@"hz_barAndItemStyleForRootVCInitSetToNavigation"] integerValue];
}

- (void)setHz_navigationEnableForRootVCInitSetToNavigation:(BOOL)hz_navigationEnableForRootVCInitSetToNavigation {
    [self hz_addStrongReferenceObject:@(hz_navigationEnableForRootVCInitSetToNavigation)
                               forKey:@"hz_navigationEnableForRootVCInitSetToNavigation"];
}

- (BOOL)hz_navigationEnableForRootVCInitSetToNavigation {
    return [self hz_strongReferenceObjectForKey:@"hz_navigationEnableForRootVCInitSetToNavigation"];
}

- (void)setHz_navbarFrameBlockForRootVCInitSetToNavigation:(YZHNavBarViewFrameBlock)hz_navbarFrameBlockForRootVCInitSetToNavigation {
    [self hz_addStrongReferenceObject:hz_navbarFrameBlockForRootVCInitSetToNavigation forKey:@"hz_navbarFrameBlockForRootVCInitSetToNavigation"];
}

- (YZHNavBarViewFrameBlock)hz_navbarFrameBlockForRootVCInitSetToNavigation {
    return [self hz_strongReferenceObjectForKey:@"hz_navbarFrameBlockForRootVCInitSetToNavigation"];
}

- (CGRect)hz_navbarFrame {
    return self.hz_itn_navBarFrame;
}
@end
