//
//  UIViewController+YZHNavigationRootVCInitSetup.m
//  YZHApp
//
//  Created by bytedance on 2021/11/26.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "UIViewController+YZHNavigationRootVCInitSetup.h"
#import "YZHKit.h"

@implementation UIViewController (YZHNavigationRootVCInitSetup)

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

@end
