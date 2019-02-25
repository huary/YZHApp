//
//  UIScrollView+YZHAddForUIPanGestureRecognizer.m
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIScrollView+YZHAddForUIPanGestureRecognizer.h"
#import "YZHKitType.h"

@implementation UIScrollView (YZHAddForUIPanGestureRecognizer)

-(void)setPanGestureRecognizerShouldBeginBlock:(UIGestureRecognizerShouldBeginBlock)panGestureRecognizerShouldBeginBlock
{
    objc_setAssociatedObject(self, @selector(panGestureRecognizerShouldBeginBlock), panGestureRecognizerShouldBeginBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(UIGestureRecognizerShouldBeginBlock)panGestureRecognizerShouldBeginBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setPanGestureRecognizerShouldSimultaneouslyBlock:(UIGestureRecognizerShouldRecognizeSimultaneouslyBlock)panGestureRecognizerShouldSimultaneouslyBlock
{
    objc_setAssociatedObject(self, @selector(panGestureRecognizerShouldSimultaneouslyBlock), panGestureRecognizerShouldSimultaneouslyBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(UIGestureRecognizerShouldRecognizeSimultaneouslyBlock)panGestureRecognizerShouldSimultaneouslyBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setUIPanGestureRecognizersEnabled:(BOOL)enabled whitPanGestureRecognizerShouldBeginBlock:(UIGestureRecognizerShouldBeginBlock)panGestureRecognizerShouldBeginBlock panGestureRecognizerShouldSimultaneouslyBlock:(UIGestureRecognizerShouldRecognizeSimultaneouslyBlock)panGestureRecognizerShouldSimultaneouslyBlock
{
    self.panGestureRecognizer.delegate = enabled ? self : nil;
    self.panGestureRecognizerShouldBeginBlock = panGestureRecognizerShouldBeginBlock;
    self.panGestureRecognizerShouldSimultaneouslyBlock = panGestureRecognizerShouldSimultaneouslyBlock;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (self.panGestureRecognizerShouldSimultaneouslyBlock) {
            return self.panGestureRecognizerShouldSimultaneouslyBlock(self, gestureRecognizer, otherGestureRecognizer);
        }
    }
    return NO;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (self.panGestureRecognizerShouldBeginBlock) {
            return self.panGestureRecognizerShouldBeginBlock(self, gestureRecognizer);
        }
    }
    return YES;
}

@end
