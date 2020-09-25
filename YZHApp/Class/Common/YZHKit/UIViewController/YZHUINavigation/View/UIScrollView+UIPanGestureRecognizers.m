//
//  UIScrollView+UIPanGestureRecognizers.m
//  YZHUINavigationController
//
//  Created by yzh on 17/3/8.
//  Copyright © 2017年 dlodlo. All rights reserved.
//

#import "UIScrollView+UIPanGestureRecognizers.h"
#import <objc/runtime.h>

@interface UIScrollView () <UIGestureRecognizerDelegate>

@end

static char panRecognizerShouldBeginBlockKey;
static char panRecognizersShouldRecognizeSimultaneouslyBlockKey;


@implementation UIScrollView (UIPanGestureRecognizers)

//panRecognizerShouldBeginBlock
-(UIPanGestureRecognizerShouldBeginBlock)panRecognizerShouldBeginBlock
{
    return objc_getAssociatedObject(self, &panRecognizerShouldBeginBlockKey);
}

-(void)setPanRecognizerShouldBeginBlock:(UIPanGestureRecognizerShouldBeginBlock)panRecognizerShouldBeginBlock
{
    objc_setAssociatedObject(self, &panRecognizerShouldBeginBlockKey, panRecognizerShouldBeginBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

//panRecognizersShouldRecognizeSimultaneouslyBlock
-(UIPanGestureRecognizersShouldRecognizeSimultaneouslyBlock)panRecognizersShouldRecognizeSimultaneouslyBlock
{
    return objc_getAssociatedObject(self, &panRecognizersShouldRecognizeSimultaneouslyBlockKey);
}

-(void)setPanRecognizersShouldRecognizeSimultaneouslyBlock:(UIPanGestureRecognizersShouldRecognizeSimultaneouslyBlock)panRecognizersShouldRecognizeSimultaneouslyBlock
{
    objc_setAssociatedObject(self, &panRecognizersShouldRecognizeSimultaneouslyBlockKey, panRecognizersShouldRecognizeSimultaneouslyBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


//-(void)setUIPanGestureRecognizersEnabled:(BOOL)enabled withShouldRecognizesBlock:(UIPanGestureRecognizersShouldRecognizeSimultaneouslyBlock)panRecognizersBlock
//{
//    if (enabled) {
//        self.panGestureRecognizer.delegate = self;
//        self.delaysContentTouches = NO;
//        self.canCancelContentTouches = NO;
//    }
//    else
//    {
//        self.panGestureRecognizer.delegate = nil;
//        self.delaysContentTouches = YES;
//        self.canCancelContentTouches = YES;
//    }
//    self.panRecognizersBlock = panRecognizersBlock;
//}

//-(void)setUIPanGestureRecognizersEnabled:(BOOL)enabled whitPanGestureRecognizerShouldBeginBlock:(UIPanGestureRecognizerShouldBeginBlock)panRecognizerShouldBeginBlock panGestureRecognizersShouldRecognizeSimultaneouslyBlock:(UIPanGestureRecognizersShouldRecognizeSimultaneouslyBlock)panRecognizersShouldRecognizeSimultaneouslyBlock
//{
//    if (enabled) {
//        self.panGestureRecognizer.delegate = self;
////        self.delaysContentTouches = NO;
////        self.canCancelContentTouches = NO;
//    }
//    else
//    {
//        self.panGestureRecognizer.delegate = nil;
////        self.delaysContentTouches = YES;
////        self.canCancelContentTouches = YES;
//    }
//    self.panRecognizerShouldBeginBlock = panRecognizerShouldBeginBlock;
//    self.panRecognizersShouldRecognizeSimultaneouslyBlock = panRecognizersShouldRecognizeSimultaneouslyBlock;
//}


//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        if (self.panRecognizersShouldRecognizeSimultaneouslyBlock) {
//            WEAK_SELF(weakSelf);
//            return self.panRecognizersShouldRecognizeSimultaneouslyBlock(weakSelf,gestureRecognizer, otherGestureRecognizer);
//        }
//    }
//    return NO;
//}
//
//-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        if (self.panRecognizerShouldBeginBlock) {
//            WEAK_SELF(weakSelf);
//            return self.panRecognizerShouldBeginBlock(weakSelf, gestureRecognizer);
//        }
//    }
//    return YES;
//}
@end
