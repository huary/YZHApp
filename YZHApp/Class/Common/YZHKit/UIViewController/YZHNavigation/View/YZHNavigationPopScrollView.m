//
//  UINavigationPopScrollView.m
//  YZHNavigationController
//
//  Created by yuan on 16/11/21.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "YZHNavigationPopScrollView.h"

@interface YZHNavigationPopScrollView ()<UIGestureRecognizerDelegate>

@end

@implementation YZHNavigationPopScrollView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDefaultValue];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initDefaultValue];

    }
    return self;
}

-(void)initDefaultValue
{
    self.panGestureRecognizer.delegate = self;
    self.delaysContentTouches = NO;
    self.canCancelContentTouches = NO;
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ( self.contentOffset.x <= 0) {
            return YES;
        }
        else if (_shouldRecognizeSimultaneouslyBlock)
        {
            return _shouldRecognizeSimultaneouslyBlock(self, gestureRecognizer, otherGestureRecognizer);
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

@end
