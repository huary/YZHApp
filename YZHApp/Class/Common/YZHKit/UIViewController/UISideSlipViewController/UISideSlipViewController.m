//
//  UISideSlipViewController.m
//  UISideSlipViewControllerDemo
//
//  Created by yuan on 2018/1/1.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UISideSlipViewController.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger,NSSideSlipDirection)
{
    NSSideSlipDirectionLeft     = 0,
    NSSideSlipDirectionRight    = 1,
};

@interface UIView (Cover)
@property (nonatomic, strong) UIButton *cover;
@end

@implementation UIView (Cover)
-(void)setCover:(UIButton *)cover
{
    objc_setAssociatedObject(self, @selector(cover), cover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIButton*)cover
{
    return objc_getAssociatedObject(self, _cmd);
}
@end



@interface UISideSlipViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *LRViewContainer;
@property (nonatomic, strong) UIView *contentViewContainer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

//config
@property (nonatomic, assign) CGFloat panStartXRatio;
//@property (nonatomic, assign) CGFloat maxAlpha;

@property (nonatomic, assign) CGFloat LRMaxAlpha;
@property (nonatomic, assign) CGFloat contentMaxAlpha;

@property (nonatomic, assign) CGFloat minShiftOKRatio;
@property (nonatomic, assign) CGFloat minShiftOKVelocity;
@property (nonatomic, assign) NSTimeInterval animateDuration;
@property (nonatomic, assign) CGFloat LRViewContainerBeganShiftRatio;

@property (nonatomic, strong) UIColor *coverBGColor;

//存储
@property (nonatomic, assign) CGFloat gestureBeganLRTX;
@property (nonatomic, assign) CGFloat gestureBeganContentTX;
@property (nonatomic, strong) UIColor *gestureBeganLRColor;
@property (nonatomic, strong) UIColor *gestureBeganContentColor;

@property (nonatomic, assign) NSSideSlipDirection slipDirection;

@property (nonatomic, assign) NSInteger adjustCnt;
//大于0表示允许调整的次数，小于0表示不限制次数，等于0表示不允许调整
@property (nonatomic, assign) NSInteger maxAdjustCnt;
@property (nonatomic, assign) BOOL canAdjust;
@end

@implementation UISideSlipViewController

-(instancetype)initWithContentViewController:(nonnull UIViewController *)contentViewController leftViewController:(nullable UIViewController *)leftViewController rightViewController:(nullable UIViewController *)rightViewController
{
    self = [super init];
    if (self) {
        NSAssert(contentViewController != nil, @"contentViewController can't be nil");
        _contentViewController = contentViewController;
        _leftViewController = leftViewController;
        _rightViewController = rightViewController;
        [self _setUpDefaultValue];
    }
    return self;
}

-(void)_setUpDefaultValue
{
//    self.maxAlpha = 0.3;
    self.LRMaxAlpha = 0.05;
    self.contentMaxAlpha = 0.25;
    self.minShiftOKRatio = 0.2;
    self.minShiftOKVelocity = 2000;
    self.animateDuration = 0.15;
    self.LRViewContainerBeganShiftRatio = 0.5;
    self.coverBGColor = BLACK_COLOR;
    self.maxAdjustCnt = 1;
    
    self.sideSlipEnabled = YES;
    self.maxShiftXRatio = 0.8;
    _showVCType = NSSideShowVCTypeContentVC;
    
    self.sideShowVCViewAlignmentType = NSSideShowVCViewAlignmentTypeLeft;
}

-(void)setMaxShiftXRatio:(CGFloat)maxShiftXRatio
{
    NSAssert(maxShiftXRatio >= 0 &&  maxShiftXRatio <= 1.0, @"maxShiftXRatio %f can only be 0.0-1.0",maxShiftXRatio);
    _maxShiftXRatio = maxShiftXRatio;
    self.panStartXRatio = 1 - maxShiftXRatio;
}

-(void)_addShadowToContainer:(UIView*)containerView scrollToRight:(CGFloat)scrollToRight
{
    UIColor *shadowColor = BLACK_COLOR;
    CGSize shadowOffset = CGSizeMake(-5, 0);
    if (scrollToRight == NO) {
        shadowOffset = CGSizeMake(5, 0);
    }
    CGFloat shadowOpacity = 0.4;
    CGFloat shadowRadius = 5;
    
    if (containerView) {
        containerView.layer.shadowColor = shadowColor.CGColor;
        containerView.layer.shadowOffset = shadowOffset;
        containerView.layer.shadowOpacity = shadowOpacity;
        containerView.layer.shadowRadius = shadowRadius;
    }
}

-(UIView*)LRViewContainer
{
    if (_LRViewContainer == nil) {
        _LRViewContainer = [[UIView alloc] init];
        _LRViewContainer.frame = self.view.bounds;
        _LRViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [self _addShadowToContainer:_LRViewContainer];
    }
    return _LRViewContainer;
}

-(UIView*)contentViewContainer
{
    if (_contentViewContainer == nil) {
        _contentViewContainer = [[UIView alloc] init];
        _contentViewContainer.frame = self.view.bounds;
        _contentViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _contentViewContainer;
}

-(void)_addViewController:(UIViewController*)viewController toViewContainer:(UIView*)viewContainer
{
    if (viewController) {
        [self addChildViewController:viewController];
//        viewController.view.frame = viewContainer.bounds;
        viewController.view.autoresizingMask = viewContainer.autoresizingMask;
        [viewContainer addSubview:viewController.view];
        [viewController didMoveToParentViewController:self];
    }
}

-(void)_removeViewController:(UIViewController*)viewController
{
    if (viewController) {
        [viewController willMoveToParentViewController:nil];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = WHITE_COLOR;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.LRViewContainer];
    [self.view addSubview:self.contentViewContainer];
    
    [self _addViewController:self.leftViewController toViewContainer:self.LRViewContainer];
    [self _addViewController:self.rightViewController toViewContainer:self.LRViewContainer];
    
    [self _addViewController:self.contentViewController toViewContainer:self.contentViewContainer];
    
//    if (self.sideSlipEnabled) {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panGestureAction:)];
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
//    }
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.view bringSubviewToFront:self.contentViewContainer];
}

-(CGFloat)_getLRViewContainerBeganShift
{
    return CGRectGetWidth(self.LRViewContainer.bounds) * self.LRViewContainerBeganShiftRatio;
}

-(CGFloat)_getContentMaxShift
{
    return CGRectGetWidth(self.contentViewContainer.bounds) * self.maxShiftXRatio;
}

-(UIViewController*)_getCurrentShowViewController
{
    if (self.showVCType == NSSideShowVCTypeContentVC) {
        return self.contentViewController;
    }
    else if (self.showVCType == NSSideShowVCTypeLeftVC) {
        return self.leftViewController;
    }
    else if (self.showVCType == NSSideShowVCTypeRightVC) {
        return self.rightViewController;
    }
    return nil;
}

-(void)_panGestureAction:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.canAdjust = YES;
        [self _beginGesture:gesture];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged){
        [self _updateGesture:gesture];
        self.canAdjust = NO;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
        self.canAdjust = NO;
        [self _endGesture:gesture];
    }
}

-(void)_dispatchBeginActionFrom:(UIViewController*)from to:(UIViewController*)to
{
    if ([self.delegate respondsToSelector:@selector(sideSlipViewController:willBeginSlipFromViewController:toViewController:)]) {
        [self.delegate sideSlipViewController:self willBeginSlipFromViewController:from toViewController:to];
    }
}

-(void)_dispatchSlipProgress:(CGFloat)progress from:(UIViewController*)from to:(UIViewController*)to
{
    if ([self.delegate respondsToSelector:@selector(sideSlipViewController:slipProgress:fromViewController:toViewController:)]) {
        [self.delegate sideSlipViewController:self slipProgress:progress fromViewController:from toViewController:to];
    }
}

-(void)_dispatchEndActionFrom:(UIViewController*)from to:(UIViewController*)to
{
    if ([self.delegate respondsToSelector:@selector(sideSlipViewController:didEndSlipFromViewController:toViewController:)]) {
        [self.delegate sideSlipViewController:self didEndSlipFromViewController:from toViewController:to];
    }
}

-(void)_doAdjustBeginAction:(CGFloat)tx dispatchAction:(BOOL)dispatch
{
    CGFloat shiftX = [self _getLRViewContainerBeganShift];
    if (tx > 0) {
        if (self.showVCType == NSSideShowVCTypeContentVC) {
            [self _addCoverViewToView:self.contentViewContainer alpha:0 action:YES];
            [self _addCoverViewToView:self.LRViewContainer alpha:self.LRMaxAlpha action:NO];
            
            [self _addShadowToContainer:self.contentViewContainer scrollToRight:YES];
            
            self.LRViewContainer.transform = CGAffineTransformMakeTranslation(-shiftX, 0);
            self.leftViewController.view.hidden = NO;
            self.rightViewController.view.hidden = YES;
            if (dispatch) {
                [self _dispatchBeginActionFrom:self.contentViewController to:self.leftViewController];
            }
        }
        else {
            [self _addCoverViewToView:self.LRViewContainer alpha:0 action:NO];
            if (dispatch) {
                [self _dispatchBeginActionFrom:self.rightViewController to:self.contentViewController];
            }
        }
        self.slipDirection = NSSideSlipDirectionRight;
    }
    else{
        if (self.showVCType == NSSideShowVCTypeContentVC) {
            [self _addCoverViewToView:self.contentViewContainer alpha:0 action:YES];
            [self _addCoverViewToView:self.LRViewContainer alpha:self.LRMaxAlpha action:NO];
            
            [self _addShadowToContainer:self.contentViewContainer scrollToRight:NO];
            
            self.LRViewContainer.transform = CGAffineTransformMakeTranslation(shiftX, 0);
            self.leftViewController.view.hidden = YES;
            self.rightViewController.view.hidden = NO;
            
            if (dispatch) {
                [self _dispatchBeginActionFrom:self.contentViewController to:self.rightViewController];
            }
        }
        else{
            [self _addCoverViewToView:self.LRViewContainer alpha:0 action:NO];
            if (dispatch) {
                [self _dispatchBeginActionFrom:self.leftViewController to:self.contentViewController];
            }
        }
        self.slipDirection = NSSideSlipDirectionLeft;
    }
//    NSLog(@"began==========================,slipDirectrion=%ld",self.slipDirection);
    self.gestureBeganLRTX = self.LRViewContainer.transform.tx;
    self.gestureBeganContentTX = self.contentViewContainer.transform.tx;
    self.gestureBeganLRColor = self.LRViewContainer.cover.backgroundColor;
    self.gestureBeganContentColor = self.contentViewContainer.cover.backgroundColor;
}

-(void)_beginGesture:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGFloat tx = [gesture translationInView:gesture.view].x;
        self.adjustCnt = 0;
        [self _doAdjustBeginAction:tx dispatchAction:YES];
    }
}

-(BOOL)_canAdjustUpdateGesutre
{
    if (self.canAdjust && ((self.maxAdjustCnt > 0 && self.adjustCnt < self.maxAdjustCnt) || self.maxAdjustCnt < 0)) {
        return YES;
    }
    return NO;
}

-(void)_updateGesture:(UIPanGestureRecognizer*)gesture
{
    if (self.maxShiftXRatio <= 0) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat tx = [gesture translationInView:gesture.view].x;
        CGFloat contentMaxShift = [self _getContentMaxShift];
        CGFloat shiftRatio = tx / contentMaxShift;
        shiftRatio = MIN(shiftRatio, 1.0);
        shiftRatio = MAX(shiftRatio, -1.0);
//        NSLog(@"shiftRatio----------1=%f,adjustCnt=%ld,tx=%f",shiftRatio,self.adjustCnt,tx);
        if (self.slipDirection == NSSideSlipDirectionRight) {
            if (tx < 0) {
                if ([self _canAdjustUpdateGesutre]) {
                    ++self.adjustCnt;
                    [self _doAdjustBeginAction:tx dispatchAction:YES];
                }
            }
            shiftRatio = MAX(shiftRatio, 0);
        }
        else {
            if (tx > 0) {
                if ([self _canAdjustUpdateGesutre]) {
                    ++self.adjustCnt;
                    [self _doAdjustBeginAction:tx dispatchAction:YES];
                }
            }
            shiftRatio = MIN(shiftRatio, 0);
        }
        
        CGFloat lrShiftX = 0;
        if (self.sideShowVCViewAlignmentType == NSSideShowVCViewAlignmentTypeLeft) {
            if (self.slipDirection == NSSideSlipDirectionRight) {
                if (self.showVCType == NSSideShowVCTypeContentVC) {
                    lrShiftX = [self _getLRViewContainerBeganShift];
                }
                else {
                    lrShiftX = CGRectGetWidth(self.contentViewContainer.bounds) * (self.maxShiftXRatio - self.LRViewContainerBeganShiftRatio);
                }
            }
            else {
                if (self.showVCType == NSSideShowVCTypeContentVC) {
                    lrShiftX = CGRectGetWidth(self.contentViewContainer.bounds) * (self.maxShiftXRatio - self.LRViewContainerBeganShiftRatio);
                }
                else {
                    lrShiftX = [self _getLRViewContainerBeganShift];
                }
            }
        }
        else {
            if (self.slipDirection == NSSideShowVCViewAlignmentTypeRight) {
                if (self.showVCType == NSSideShowVCTypeContentVC) {
                    lrShiftX = CGRectGetWidth(self.contentViewContainer.bounds) * (self.maxShiftXRatio - self.LRViewContainerBeganShiftRatio);
                }
                else {
                    lrShiftX = [self _getLRViewContainerBeganShift];
                }
            }
            else {
                if (self.showVCType == NSSideShowVCTypeContentVC) {
                    lrShiftX = [self _getLRViewContainerBeganShift];
                }
                else {
                    lrShiftX = CGRectGetWidth(self.contentViewContainer.bounds) * (self.maxShiftXRatio - self.LRViewContainerBeganShiftRatio);
                }
            }
        }
        lrShiftX = lrShiftX * shiftRatio;
        lrShiftX = self.gestureBeganLRTX + lrShiftX;
//        NSLog(@"lrShiftX=%f,geganTX=%f,shiftRatio=%f",lrShiftX,self.gestureBeganLRTX,shiftRatio);
        self.LRViewContainer.transform = CGAffineTransformMakeTranslation(lrShiftX, 0);
        
        CGFloat contentShiftX = shiftRatio * contentMaxShift;
        contentShiftX = self.gestureBeganContentTX + contentShiftX;
        self.contentViewContainer.transform = CGAffineTransformMakeTranslation(contentShiftX, 0);
        
        UIViewController *from = nil;
        UIViewController *to = nil;
        if (self.showVCType == NSSideShowVCTypeContentVC) {
            from = self.contentViewController;
            if (self.slipDirection == NSSideSlipDirectionLeft) {
                shiftRatio = -shiftRatio;
                to = self.rightViewController;
            }
            else {
                to = self.leftViewController;
            }
        }
        else if (self.showVCType == NSSideShowVCTypeLeftVC) {
            from = self.leftViewController;
            if (self.slipDirection == NSSideSlipDirectionLeft) {
                to = self.contentViewController;
            }
            else {
                //nothing,不会存在这种情况
            }
        }
        else if (self.showVCType == NSSideShowVCTypeRightVC) {
            from = self.rightViewController;
            if (self.slipDirection == NSSideSlipDirectionRight) {
                shiftRatio = -shiftRatio;
                to = self.contentViewController;
            }
            else {
                //nothing,不会存在这种情况
            }
        }
        
        CGFloat lrDifferAlpha = shiftRatio * self.LRMaxAlpha;
        CGFloat contentDifferAlpha = shiftRatio * self.contentMaxAlpha;
        CGFloat lrBeganAlpha = ALPHA_FROM_RGB_COLOR(self.gestureBeganLRColor);
        CGFloat contentBeganAlpha = ALPHA_FROM_RGB_COLOR(self.gestureBeganContentColor);
        
        self.LRViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:lrBeganAlpha -lrDifferAlpha];
        self.contentViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:contentBeganAlpha + contentDifferAlpha];
        
        [self _dispatchSlipProgress:shiftRatio from:from to:to];
    }
}

-(void)_endGesture:(UIPanGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        CGFloat tx = [gesture translationInView:gesture.view].x;
        CGFloat percent = fabs(tx) / CGRectGetWidth(gesture.view.frame);
        CGFloat vx = [gesture velocityInView:gesture.view].x;
//        NSLog(@"tx=%f,percent=%f,vx=%f",tx,percent,vx);
        if (percent > self.minShiftOKRatio || fabs(vx) > self.minShiftOKVelocity) {
            if (self.showVCType == NSSideShowVCTypeContentVC) {
                if (tx > 0) {
                    [self presentLeftViewController:YES];
                }
                else{
                    [self presentRightViewContrller:YES];
                }
            }
            else if (self.showVCType == NSSideShowVCTypeLeftVC){
                if (tx < 0) {
                    [self presentContentViewContrller:YES];
                }
                else{
                    //nothing,不会存在这种情况
                    NSLog(@"特殊情况-------------------1");
                }
            }
            else {
                if (tx > 0) {
                    [self presentContentViewContrller:YES];
                }
                else {
                    //nothing,不会存在这种情况
                    NSLog(@"特殊情况-------------------2");
                }
            }
        }
        else{
            if (self.showVCType == NSSideShowVCTypeContentVC) {
                [self presentContentViewContrller:YES];
            }
            else if (self.showVCType == NSSideShowVCTypeLeftVC) {
                [self presentLeftViewController:YES];
            }
            else {
                [self presentRightViewContrller:YES];
            }
        }
    }
}

-(void)_addCoverViewToView:(UIView*)view alpha:(CGFloat)alpha action:(BOOL)action
{
    if (view == nil) {
        return;
    }
    if (view.cover == nil || view.cover.superview == nil) {
        UIButton *cover = [UIButton buttonWithType:UIButtonTypeCustom];
        cover.frame = view.bounds;
        if (action) {
            [cover addTarget:self action:@selector(_coverAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        [view addSubview:cover];
        view.cover = cover;
    }
    view.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:alpha];
}

-(void)_coverAction:(UIButton*)sender
{
    [self presentContentViewContrller:YES];
}

-(void)presentLeftViewController:(BOOL)animated
{
    if (self.leftViewController == nil || self.contentViewController == nil) {
        return;
    }
    self.leftViewController.view.hidden = NO;
    self.rightViewController.view.hidden = YES;
    
    UIViewController *from = [self _getCurrentShowViewController];
    
    [self _addCoverViewToView:self.contentViewContainer alpha:self.contentMaxAlpha action:YES];
    
    [self _addShadowToContainer:self.contentViewContainer scrollToRight:YES];
    
    CGFloat contentShiftX = [self _getContentMaxShift];
    CGFloat lrShiftX = 0;
    if (self.sideShowVCViewAlignmentType == NSSideShowVCViewAlignmentTypeRight) {
        lrShiftX = contentShiftX - CGRectGetWidth(self.contentViewContainer.bounds);
    }
    if (animated) {
        [UIView animateWithDuration:self.animateDuration animations:^{
            self.contentViewContainer.transform = CGAffineTransformMakeTranslation(contentShiftX, 0);
            self.LRViewContainer.transform = CGAffineTransformMakeTranslation(lrShiftX, 0);
            self.contentViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:self.contentMaxAlpha];
            self.LRViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:0];
        } completion:^(BOOL finished) {
            [self.LRViewContainer.cover removeFromSuperview];
            self.LRViewContainer.cover = nil;
        }];
    }
    else {
        self.contentViewContainer.transform = CGAffineTransformMakeTranslation(contentShiftX, 0);
        self.LRViewContainer.transform = CGAffineTransformMakeTranslation(lrShiftX, 0);
        self.contentViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:self.contentMaxAlpha];
        self.LRViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:0];
        [self.LRViewContainer.cover removeFromSuperview];
        self.LRViewContainer.cover = nil;
    }
    _showVCType = NSSideShowVCTypeLeftVC;
    [self _dispatchEndActionFrom:from to:self.leftViewController];
}

-(void)presentRightViewContrller:(BOOL)animated
{
    if (self.rightViewController == nil || self.contentViewController == nil) {
        return;
    }
    self.leftViewController.view.hidden = YES;
    self.rightViewController.view.hidden = NO;
    
    UIViewController *from = [self _getCurrentShowViewController];
    
    [self _addCoverViewToView:self.contentViewContainer alpha:self.contentMaxAlpha action:YES];
    
    [self _addShadowToContainer:self.contentViewContainer scrollToRight:NO];
    
    CGFloat contentShiftX = -[self _getContentMaxShift];
    CGFloat lrShiftX = 0;
    if (self.sideShowVCViewAlignmentType == NSSideShowVCViewAlignmentTypeLeft) {
        lrShiftX = CGRectGetWidth(self.contentViewContainer.bounds) + contentShiftX;
    }
    if (animated) {
        [UIView animateWithDuration:self.animateDuration animations:^{
            self.contentViewContainer.transform = CGAffineTransformMakeTranslation(contentShiftX, 0);
            self.LRViewContainer.transform = CGAffineTransformMakeTranslation(lrShiftX, 0);
            self.contentViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:self.contentMaxAlpha];
            self.LRViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:0];
        } completion:^(BOOL finished) {
            [self.LRViewContainer.cover removeFromSuperview];
            self.LRViewContainer.cover = nil;
        }];
    }
    else {
        self.contentViewContainer.transform = CGAffineTransformMakeTranslation(contentShiftX, 0);
        self.LRViewContainer.transform = CGAffineTransformMakeTranslation(lrShiftX, 0);
        self.contentViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:self.contentMaxAlpha];
        self.LRViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:0];
        [self.LRViewContainer.cover removeFromSuperview];
        self.LRViewContainer.cover = nil;
    }
    _showVCType = NSSideShowVCTypeRightVC;
    [self _dispatchEndActionFrom:from to:self.rightViewController];
}

-(void)presentContentViewContrller:(BOOL)animated
{
    if (self.contentViewController == nil) {
        return;
    }
    UIViewController *from = [self _getCurrentShowViewController];
    if (animated) {
        [UIView animateWithDuration:self.animateDuration animations:^{
            self.contentViewContainer.transform = CGAffineTransformIdentity;
            self.LRViewContainer.transform = CGAffineTransformIdentity;
            self.contentViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:0];
            self.LRViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:self.LRMaxAlpha];
        } completion:^(BOOL finished) {
            [self.LRViewContainer.cover removeFromSuperview];
            [self.contentViewContainer.cover removeFromSuperview];
            self.LRViewContainer.cover = nil;
            self.contentViewContainer.cover = nil;
        }];
    }
    else {
        self.contentViewContainer.transform = CGAffineTransformIdentity;
        self.LRViewContainer.transform = CGAffineTransformIdentity;
        self.contentViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:0];
        self.LRViewContainer.cover.backgroundColor = [self.coverBGColor colorWithAlphaComponent:self.LRMaxAlpha];
        [self.LRViewContainer.cover removeFromSuperview];
        [self.contentViewContainer.cover removeFromSuperview];
        self.LRViewContainer.cover = nil;
        self.contentViewContainer.cover = nil;
    }
    _showVCType = NSSideShowVCTypeContentVC;
    [self _dispatchEndActionFrom:from to:self.contentViewController];
}

-(void)updateContentViewController:(nonnull UIViewController *)contentViewController
{
    if (contentViewController == nil || contentViewController == self.contentViewController) {
        return;
    }
    [self _removeViewController:self.contentViewController];
    _contentViewController = contentViewController;
    [self _addViewController:self.contentViewController toViewContainer:self.contentViewContainer];
}

-(void)updateLeftViewController:(nullable UIViewController *)leftViewController
{
    if (self.leftViewController == leftViewController) {
        return;
    }
    [self _removeViewController:self.leftViewController];
    _leftViewController = leftViewController;
    [self _addViewController:self.leftViewController toViewContainer:self.LRViewContainer];
    [self.view bringSubviewToFront:self.contentViewContainer];
}

-(void)updateRightViewController:(nullable UIViewController *)rightViewController
{
    if (self.rightViewController == rightViewController) {
        return;
    }
    [self _removeViewController:self.rightViewController];
    _rightViewController = rightViewController;
    [self _addViewController:self.rightViewController toViewContainer:self.LRViewContainer];
    [self.view bringSubviewToFront:self.contentViewContainer];
}

-(BOOL)_shouldBeganForPangesture:(UIPanGestureRecognizer*)gesture
{
    if (!self.sideSlipEnabled) {
        return NO;
    }
    CGPoint pt = [gesture locationInView:gesture.view];
    CGPoint t = [gesture translationInView:gesture.view];
//    NSLog(@"t=%@",NSStringFromCGPoint(t));
    if (fabs(t.x) < fabs(t.y)) {
        return NO;
    }
    //向右滑动
    if (t.x > 0 && pt.x <= CGRectGetWidth(gesture.view.frame) * self.panStartXRatio) {
        if ((self.showVCType == NSSideShowVCTypeContentVC && self.leftViewController != nil) || self.showVCType == NSSideShowVCTypeRightVC) {
            return YES;
        }
    }
    //向左滑动
    else if (t.x < 0 && pt.x >= CGRectGetWidth(gesture.view.frame) * (1 - self.panStartXRatio)) {
        if ((self.showVCType == NSSideShowVCTypeContentVC && self.rightViewController != nil) || self.showVCType == NSSideShowVCTypeLeftVC) {
            return YES;
        }
    }
    return NO;
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [self _shouldBeganForPangesture:(UIPanGestureRecognizer*)gestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
