//
//  UIScrollView+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "UIScrollView+YZHAdd.h"
#import <objc/runtime.h>


@implementation UIScrollView (YZHAdd)

//-(void)setPanGestureRecognizerShouldBeginBlock:(UIGestureRecognizerShouldBeginBlock)panGestureRecognizerShouldBeginBlock
//{
//    objc_setAssociatedObject(self, @selector(panGestureRecognizerShouldBeginBlock), panGestureRecognizerShouldBeginBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//-(UIGestureRecognizerShouldBeginBlock)panGestureRecognizerShouldBeginBlock
//{
//    return objc_getAssociatedObject(self, _cmd);
//}
//
//-(void)setPanGestureRecognizerShouldSimultaneouslyBlock:(UIGestureRecognizerShouldRecognizeSimultaneouslyBlock)panGestureRecognizerShouldSimultaneouslyBlock
//{
//    objc_setAssociatedObject(self, @selector(panGestureRecognizerShouldSimultaneouslyBlock), panGestureRecognizerShouldSimultaneouslyBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//-(UIGestureRecognizerShouldRecognizeSimultaneouslyBlock)panGestureRecognizerShouldSimultaneouslyBlock
//{
//    return objc_getAssociatedObject(self, _cmd);
//}
//
//-(void)setUIPanGestureRecognizersEnabled:(BOOL)enabled whitPanGestureRecognizerShouldBeginBlock:(UIGestureRecognizerShouldBeginBlock)panGestureRecognizerShouldBeginBlock panGestureRecognizerShouldSimultaneouslyBlock:(UIGestureRecognizerShouldRecognizeSimultaneouslyBlock)panGestureRecognizerShouldSimultaneouslyBlock
//{
//    self.panGestureRecognizer.delegate = enabled ? self : nil;
//    self.panGestureRecognizerShouldBeginBlock = panGestureRecognizerShouldBeginBlock;
//    self.panGestureRecognizerShouldSimultaneouslyBlock = panGestureRecognizerShouldSimultaneouslyBlock;
//}
//
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        if (self.panGestureRecognizerShouldSimultaneouslyBlock) {
//            return self.panGestureRecognizerShouldSimultaneouslyBlock(self, gestureRecognizer, otherGestureRecognizer);
//        }
//    }
//    return NO;
//}
//
//-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        if (self.panGestureRecognizerShouldBeginBlock) {
//            return self.panGestureRecognizerShouldBeginBlock(self, gestureRecognizer);
//        }
//    }
//    return YES;
//}



//-(void)setTouchToNextResponder:(BOOL)touchToNextResponder
//{
//    objc_setAssociatedObject(self, @selector(touchToNextResponder), @(touchToNextResponder), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//-(BOOL)touchToNextResponder
//{
//    return [objc_getAssociatedObject(self, _cmd) boolValue];
//}
//
//-(void)setTouchesShouldCancelBlock:(YZHTouchesShouldCancelInContentViewBlock)touchesShouldCancelBlock
//{
//    objc_setAssociatedObject(self, @selector(touchesShouldCancelBlock), touchesShouldCancelBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//-(YZHTouchesShouldCancelInContentViewBlock)touchesShouldCancelBlock
//{
//    return objc_getAssociatedObject(self, _cmd);
//}
//
//
//
//- (BOOL)touchesShouldCancelInContentView:(UIView *)view
//{
//    if (self.touchesShouldCancelBlock) {
//        return self.touchesShouldCancelBlock(self, view);
//    }
//    return YES;
//}
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    if (self.touchToNextResponder) {
//        [[self nextResponder] touchesBegan:touches withEvent:event];
//    }
//}
//
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesMoved:touches withEvent:event];
//    if (self.touchToNextResponder) {
//        [[self nextResponder] touchesMoved:touches withEvent:event];
//    }
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//    if (self.touchToNextResponder) {
//        [[self nextResponder] touchesEnded:touches withEvent:event];
//    }
//}
//
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesCancelled:touches withEvent:event];
//    if (self.touchToNextResponder) {
//        [[self nextResponder] touchesCancelled:touches withEvent:event];
//    }
//}

@end
