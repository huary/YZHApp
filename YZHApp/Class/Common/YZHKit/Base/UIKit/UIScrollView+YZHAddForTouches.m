//
//  UIScrollView+YZHAddForTouches.m
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIScrollView+YZHAddForTouches.h"
#import "YZHKitType.h"

@implementation UIScrollView (YZHAddForTouches)

-(void)setTouchToNextResponder:(BOOL)touchToNextResponder
{
    objc_setAssociatedObject(self, @selector(touchToNextResponder), @(touchToNextResponder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)touchToNextResponder
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setTouchesShouldCancelBlock:(YZHTouchesShouldCancelInContentViewBlock)touchesShouldCancelBlock
{
    objc_setAssociatedObject(self, @selector(touchesShouldCancelBlock), touchesShouldCancelBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHTouchesShouldCancelInContentViewBlock)touchesShouldCancelBlock
{
    return objc_getAssociatedObject(self, _cmd);
}



- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if (self.touchesShouldCancelBlock) {
        return self.touchesShouldCancelBlock(self, view);
    }
    return YES;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (self.touchToNextResponder) {
        [[self nextResponder] touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    if (self.touchToNextResponder) {
        [[self nextResponder] touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.touchToNextResponder) {
        [[self nextResponder] touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if (self.touchToNextResponder) {
        [[self nextResponder] touchesCancelled:touches withEvent:event];
    }
}

@end
