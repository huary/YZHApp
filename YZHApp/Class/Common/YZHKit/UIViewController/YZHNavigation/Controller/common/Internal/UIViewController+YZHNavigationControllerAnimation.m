//
//  UIViewController+YZHNavigationControllerAction.m
//  YZHApp
//
//  Created by bytedance on 2021/11/23.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "UIViewController+YZHNavigationControllerAnimation.h"

@implementation UIViewController (YZHNavigationControllerAnimation)

- (void)setItn_popCompletionBlock:(YZHNavigationControllerAnimationCompletionBlock)itn_popCompletionBlock {
    [self hz_addStrongReferenceObject:itn_popCompletionBlock forKey:@"itn_popCompletionBlock"];
}

- (YZHNavigationControllerAnimationCompletionBlock)itn_popCompletionBlock {
    return [self hz_strongReferenceObjectForKey:@"itn_popCompletionBlock"];
}

- (void)setItn_pushCompletionBlock:(YZHNavigationControllerAnimationCompletionBlock)itn_pushCompletionBlock
{
    [self hz_addStrongReferenceObject:itn_pushCompletionBlock forKey:@"itn_pushCompletionBlock"];
}

- (YZHNavigationControllerAnimationCompletionBlock)itn_pushCompletionBlock {
    return [self hz_strongReferenceObjectForKey:@"itn_pushCompletionBlock"];
}

@end
