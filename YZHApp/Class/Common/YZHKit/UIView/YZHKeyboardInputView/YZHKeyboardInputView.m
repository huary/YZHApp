//
//  YZHKeyboardInputView.m
//  YZHKeyboardManagerDemo
//
//  Created by yuan on 2018/9/1.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHKeyboardInputView.h"
#import "YZHKitType.h"

@interface YZHKeyboardInputView ()

/* <#注释#> */
@property (nonatomic, strong) UIView *inView;

/* <#name#> */
@property (nonatomic, assign) BOOL isInputViewInFirstResponder;

@property (nonatomic, assign) CGAffineTransform relatedShiftViewBeforeShowTransform;

@end

@implementation YZHKeyboardInputView

-(instancetype)initWithInputView:(UIView<YZHKeyboardInputViewProtocol>*)inputView
{
    return [self initWithInputView:inputView inView:nil];
}

-(instancetype)initWithInputView:(UIView<YZHKeyboardInputViewProtocol>*)inputView inView:(UIView*)inView
{
    self = [super init];
    if (self) {
        [self _setInputViewWithView:inputView inView:inView];
        [self _setupDefaultValue];
    }
    return self;
}

-(void)_setupDefaultValue
{
    self.isInputViewInFirstResponder = NO;
    self.relatedShiftViewBeforeShowTransform = CGAffineTransformIdentity;
    self.inputViewMinTopToResponder = 0;
    self.firstResponderShiftToInputViewMinTop = YES;
    self.relatedShiftViewUseContentOffsetToShift = YES;
    
    _keyboardManager = [[YZHKeyboardManager alloc] init];
    self.keyboardManager.firstResponderView = self.inputView.firstResponderView;
    self.keyboardManager.relatedShiftView = self.inputView;
    WEAK_SELF(weakSelf);
    self.keyboardManager.willShowBlock = ^(YZHKeyboardManager *keyboardManager, NSNotification *keyboardNotification) {
        [weakSelf _doWillShowOrHideAction:keyboardNotification show:YES];
    };
    self.keyboardManager.willHideBlock = ^(YZHKeyboardManager *keyboardManager, NSNotification *keyboardNotification) {
        [weakSelf _doWillShowOrHideAction:keyboardNotification show:NO];
    };
    self.keyboardManager.willUpdateBlock = ^(YZHKeyboardManager *keyboardManager, NSNotification *keyboardNotification, CGFloat currentShift, BOOL isShow) {
        [weakSelf _doUpdateRelateViewShift:keyboardNotification shift:currentShift isShow:isShow];
    };
}

-(void)_setInputViewWithView:(UIView<YZHKeyboardInputViewProtocol> *)inputView inView:(UIView*)inView
{
    if (_inputView != inputView) {
        [_inputView removeFromSuperview];
        _inputView = inputView;
        [self _addInputViewToKeyWindow:(UIView*)inView];
    }
}


-(void)_addInputViewToKeyWindow:(UIView*)inView
{
    if (inView == nil) {
        inView = [UIApplication sharedApplication].keyWindow;
    }
    self.inView = inView;
    [inView addSubview:self.inputView];
}

-(void)_doWillShowOrHideAction:(NSNotification*)notification show:(BOOL)show
{
    if (show) {
        if (!self.isInputViewInFirstResponder) {
            self.relatedShiftViewBeforeShowTransform = self.relatedShiftView.transform;
        }
    }
    else {
        self.relatedShiftViewBeforeShowTransform = CGAffineTransformIdentity;
    }
}

-(BOOL)_doUpdateRelateViewShift:(NSNotification*)keyboardNotification shift:(CGFloat)currentShift isShow:(BOOL)isShow
{
    BOOL isScrollViewContentOffset = ([self.relatedShiftView isKindOfClass:[UIScrollView class]] && self.relatedShiftViewUseContentOffsetToShift);
    if (self.firstResponderView == nil && isScrollViewContentOffset == NO) {
        return NO;
    }
    
    self.isInputViewInFirstResponder = isShow;
    
    CGFloat firstResponderViewMaxY = 0;
    if (self.firstResponderView) {
        CGRect rect = [self.firstResponderView.superview convertRect:self.firstResponderView.frame toView:[UIApplication sharedApplication].keyWindow];
        firstResponderViewMaxY = CGRectGetMaxY(rect);
    }
    else {
        //这里firstResponderView为nil，则relatedShiftView必须是scrollView
        UIScrollView *scrollView = (UIScrollView*)self.relatedShiftView;
        CGPoint contentSizePoint = CGPointMake(0, scrollView.contentSize.height - scrollView.contentOffset.y);
        contentSizePoint = [scrollView.superview convertPoint:contentSizePoint toView:[UIApplication sharedApplication].keyWindow];
        firstResponderViewMaxY = contentSizePoint.y;
    }
    
    CGRect keyboardFirstResponderViewFrame = [self.keyboardManager.firstResponderView.superview convertRect:self.keyboardManager.firstResponderView.frame toView:[UIApplication sharedApplication].keyWindow];
    
    CGFloat inputY = keyboardFirstResponderViewFrame.origin.y + currentShift;
    CGFloat diffY = inputY - firstResponderViewMaxY - self.inputViewMinTopToResponder;
    
    if (self.willUpdateBlock) {
        self.willUpdateBlock(self, keyboardNotification, diffY, isShow);
    }
    
    if (self.shiftBlock) {
        self.shiftBlock(self, keyboardNotification, diffY, isShow);
    }
    else {
        void (^animateCompletionBlock)(BOOL finished) = ^(BOOL finished){
        };
        
        if ([self.relatedShiftView isKindOfClass:[UIScrollView class]] && self.relatedShiftViewUseContentOffsetToShift) {
            UIScrollView *scrollView = (UIScrollView*)self.relatedShiftView;
            CGPoint contentOffset = scrollView.contentOffset;
            CGFloat offsetY = contentOffset.y - diffY;
            CGFloat maxOffsetY = scrollView.contentSize.height - scrollView.bounds.size.height;
            if (!self.firstResponderShiftToInputViewMinTop) {
                offsetY = MAX(offsetY, 0);
            }
            maxOffsetY = MAX(maxOffsetY, 0);
            if (isShow) {
                [scrollView setContentOffset:CGPointMake(contentOffset.x, offsetY) animated:NO];
            }
            else {
                if (contentOffset.y > maxOffsetY) {
                    [scrollView setContentOffset:CGPointMake(contentOffset.x, maxOffsetY) animated:NO];
                }
                else if (contentOffset.y <= 0) {
                    [scrollView setContentOffset:CGPointMake(contentOffset.x, 0) animated:NO];

                }
                    
            }
            animateCompletionBlock(YES);
        }
        else {
            NSTimeInterval duration = 0.1;
            if (keyboardNotification) {
                duration = [[keyboardNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            }
            
            if (diffY > 0) {
                if (!isShow) {
                    [UIView animateWithDuration:duration animations:^{
                        self.relatedShiftView.transform = self.relatedShiftViewBeforeShowTransform;
                    } completion:animateCompletionBlock];
                    return YES;
                }
                if (!self.firstResponderShiftToInputViewMinTop) {
                    return YES;
                }
            }
            
            CGFloat oldTranslationX = self.relatedShiftView.transform.tx;
            CGFloat oldTranslationY = self.relatedShiftView.transform.ty;
            CGFloat ty = oldTranslationY + diffY;
            
            [UIView animateWithDuration:duration animations:^{
                self.relatedShiftView.transform = CGAffineTransformMakeTranslation(oldTranslationX, ty);
            } completion:animateCompletionBlock];
        }
    }
    return YES;
}

-(void)becomeFirstResponder
{
    [self.inputView.inputTextView becomeFirstResponder];
}

-(void)resignFirstResponder
{
    [self.inputView.inputTextView resignFirstResponder];
}

-(void)updateKeyboardInputView:(UIView<YZHKeyboardInputViewProtocol>*)inputView
{
    [self _setInputViewWithView:inputView inView:self.inView];
    [self _doUpdateRelateViewShift:nil shift:0 isShow:self.isInputViewInFirstResponder];
}
@end
