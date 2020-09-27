//
//  YZHKeyboardInputView.m
//  YZHKeyboardManagerDemo
//
//  Created by yuan on 2018/9/1.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHKeyboardInputView.h"
#import "YZHKitType.h"
#import "UIView+YZHAdd.h"
#import "NSObject+YZHAddForKVO.h"

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
    return [self initWithInputView:inputView inView:inputView.superview];
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
//    self.relatedShiftViewUseContentOffsetToShift = YES;
    
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
        [weakSelf _doUpdateRelateViewShift:keyboardNotification shift:currentShift isShow:isShow animated:YES];
    };
}

-(void)setRelatedShiftView:(UIView *)relatedShiftView
{
    [self _addScrollShiftViewKVO:NO];
    _relatedShiftView = relatedShiftView;
    _relatedShiftViewBeforeShowTransform = relatedShiftView.transform;
    [self _addScrollShiftViewKVO:YES];
}

-(void)_setInputViewWithView:(UIView<YZHKeyboardInputViewProtocol> *)inputView inView:(UIView*)inView
{
    if (_inputView != inputView) {
        [_inputView removeFromSuperview];
        
        [self _addInputViewKVO:NO];
        _inputView = inputView;
        [self _addInputViewKVO:YES];
        
        [self _addInputViewToKeyWindow:(UIView*)inView];
    }
}

-(void)_addInputViewToKeyWindow:(UIView*)inView
{
    if (inView == nil) {
        inView = [UIApplication sharedApplication].keyWindow;
    }
    self.inView = inView;
    if (self.inputView.superview != inView) {
        [inView addSubview:self.inputView];        
    }
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

-(BOOL)_isRelatedShiftScrollView
{
    if (![self.relatedShiftView isKindOfClass:[UIScrollView class]]) {
        return NO;
    }
    if (self.shiftType == YZHShiftTypeContentOffset || self.shiftType == YZHShiftTypeContentSizePoint) {
        return YES;
    }
    return NO;
}

-(BOOL)_isRelatedShiftScrollViewContentSizePointToBottom
{
    UIScrollView *scrollView = nil;
    if ([self.relatedShiftView isKindOfClass:[UIScrollView class]]) {
        scrollView = (UIScrollView*)self.relatedShiftView;
    }
    CGSize size = scrollView.contentSize;
    if (size.height >= scrollView.hz_height && self.shiftType == YZHShiftTypeContentSizePoint) {
        return YES;
    }
    return NO;
}

//-(BOOL)_shouldNotDownShiftWithRelatedShiftScrollViewContentSizePoint
//{
//
//    UIScrollView *scrollView = nil;
//    if ([self.relatedShiftView isKindOfClass:[UIScrollView class]]) {
//        scrollView = (UIScrollView*)self.relatedShiftView;
//    }
//    else {
//        return NO;
//    }
//
//    CGSize size = scrollView.contentSize;
//
//    return (size.height < scrollView.height && scrollView.transform.ty != self.relatedShiftViewBeforeShowTransform.ty && self.shiftType == YZHShiftTypeContentSizePoint);
//}

-(BOOL)_doUpdateRelateViewShift:(NSNotification*)keyboardNotification shift:(CGFloat)currentShift isShow:(BOOL)isShow animated:(BOOL)animated
{
//    NSLog(@"keyboardNotification=%@",keyboardNotification);
    BOOL isScrollViewShift = [self _isRelatedShiftScrollView];
    UIView *firstResponderView = self.firstResponderView;
    if (firstResponderView == nil && isScrollViewShift == NO) {
        return NO;
    }
    
//    if (firstResponderView == nil && [self _isRelatedShiftScrollViewContentSizePointToBottom]) {
//        firstResponderView = self.relatedShiftView;
//    }
    
    self.isInputViewInFirstResponder = isShow;
    
    CGFloat firstResponderViewMaxY = 0;
    if (firstResponderView) {
        CGRect rect = [firstResponderView.superview convertRect:firstResponderView.frame toView:[UIApplication sharedApplication].keyWindow];
        firstResponderViewMaxY = CGRectGetMaxY(rect);
    }
    else {
        if ([self _isRelatedShiftScrollViewContentSizePointToBottom]) {
            CGRect rect = [self.relatedShiftView.superview convertRect:self.relatedShiftView.frame toView:[UIApplication sharedApplication].keyWindow];
            firstResponderViewMaxY = CGRectGetMaxY(rect);
        }
        else {
            //这里firstResponderView为nil，则relatedShiftView必须是scrollView
            UIScrollView *scrollView = (UIScrollView*)self.relatedShiftView;
            CGPoint contentSizePoint = CGPointMake(0, scrollView.contentSize.height);
            contentSizePoint = [scrollView convertPoint:contentSizePoint toView:[UIApplication sharedApplication].keyWindow];
            firstResponderViewMaxY = contentSizePoint.y;
        }
//        NSLog(@"firstResponderViewMaxY=%f",firstResponderViewMaxY);
    }
    
    CGRect keyboardFirstResponderViewFrame = [self.keyboardManager.firstResponderView.superview convertRect:self.keyboardManager.firstResponderView.frame toView:[UIApplication sharedApplication].keyWindow];
    
    CGFloat inputY = keyboardFirstResponderViewFrame.origin.y + currentShift;
    CGFloat diffY = inputY - firstResponderViewMaxY - self.inputViewMinTopToResponder;
//    NSLog(@"diffY=%f，inputY=%f",diffY,inputY);
    
    if (self.willUpdateBlock) {
        self.willUpdateBlock(self, keyboardNotification, diffY, isShow);
    }
    
    if (self.shiftBlock) {
        self.shiftBlock(self, keyboardNotification, diffY, isShow);
    }
    else {
        void (^animateCompletionBlock)(BOOL finished) = ^(BOOL finished){
        };
        
        
        NSTimeInterval duration = self.updateAnimationDuaration;
        if (keyboardNotification) {
            duration = [[keyboardNotification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        }
        
        if ([self.relatedShiftView isKindOfClass:[UIScrollView class]] && self.shiftType == YZHShiftTypeContentOffset) {
            UIScrollView *scrollView = (UIScrollView*)self.relatedShiftView;
            CGPoint contentOffset = scrollView.contentOffset;
            CGFloat offsetY = contentOffset.y - diffY;
#if 0
            if (!self.firstResponderShiftToInputViewMinTop) {
                offsetY = MAX(offsetY, 0);
            }
            if (isShow) {
                if (animated) {
                    [UIView animateWithDuration:duration animations:^{
                        scrollView.contentOffset = CGPointMake(contentOffset.x, offsetY);
                    } completion:animateCompletionBlock];
                }
                else {
                    scrollView.contentOffset = CGPointMake(contentOffset.x, offsetY);
                }
            }
            else {
                CGFloat maxOffsetY = scrollView.contentSize.height - scrollView.bounds.size.height;
                maxOffsetY = MAX(maxOffsetY, 0);
                if (contentOffset.y > maxOffsetY) {
                    if (animated) {
                        [UIView animateWithDuration:duration animations:^{
                            scrollView.contentOffset = CGPointMake(contentOffset.x, maxOffsetY);
                        } completion:animateCompletionBlock];
                    }
                    else {
                        scrollView.contentOffset = CGPointMake(contentOffset.x, maxOffsetY);
                    }
                }
                else if (contentOffset.y <= 0) {
                    if (animated) {
                        [UIView animateWithDuration:duration animations:^{
                            scrollView.contentOffset = CGPointMake(contentOffset.x, 0);
                        } completion:animateCompletionBlock];
                    }
                    else {
                        scrollView.contentOffset = CGPointMake(contentOffset.x, 0);
                    }
                }
            }
#else
            if (self.firstResponderShiftToInputViewMinTop) {
                if (keyboardNotification) {
                    if (isShow) {
                    }
                    else {
                        offsetY = MAX(offsetY, 0);
                        CGFloat maxOffsetY = scrollView.contentSize.height - scrollView.bounds.size.height;
                        offsetY = MIN(offsetY, maxOffsetY);
                    }
                }
            }
            else {
                offsetY = MAX(offsetY, 0);
                if (isShow) {
                }
                else {
                    CGFloat maxOffsetY = scrollView.contentSize.height - scrollView.bounds.size.height;
                    maxOffsetY = MAX(maxOffsetY, 0);
                    offsetY = MIN(offsetY, maxOffsetY);
                }
            }
            
            if (animated) {
                [UIView animateWithDuration:duration animations:^{
                    scrollView.contentOffset =  CGPointMake(contentOffset.x, offsetY);
                } completion:animateCompletionBlock];
            }
            else {
                scrollView.contentOffset =  CGPointMake(contentOffset.x, offsetY);
            }
#endif
        }
        else {
#if 0
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
            
//            NSLog(@"======ty=%f",ty);
            if (animated) {
                [UIView animateWithDuration:duration animations:^{
                    self.relatedShiftView.transform = CGAffineTransformMakeTranslation(oldTranslationX, ty);
                } completion:animateCompletionBlock];
            }
            else {
                self.relatedShiftView.transform = CGAffineTransformMakeTranslation(oldTranslationX, ty);
            }
#else
            CGFloat tx = self.relatedShiftViewBeforeShowTransform.tx;
            CGFloat ty = self.relatedShiftViewBeforeShowTransform.ty;
            if (diffY > 0 && self.shiftType == YZHShiftTypeContentSizePoint) {
                //此时scrollView的contentSize的高度小于本身高度的时候，不需要向下移动
//                NSLog(@"diffY=%f,isShow=%@",diffY,@(isShow));
                if (self.relatedShiftView.transform.ty == self.relatedShiftViewBeforeShowTransform.ty) {
                    return YES;
                }
                tx = self.relatedShiftView.transform.tx;
                ty = self.relatedShiftView.transform.ty + diffY;
                if (ty > 0) {
                    ty = self.relatedShiftViewBeforeShowTransform.ty;
                }
            }
            else {
                
                tx = self.relatedShiftView.transform.tx;
                ty = self.relatedShiftView.transform.ty + diffY;
                
                if (self.firstResponderShiftToInputViewMinTop) {
                    if (keyboardNotification) {
                        if (isShow) {
                        }
                        else {
                            tx = self.relatedShiftViewBeforeShowTransform.tx;
                            ty = self.relatedShiftViewBeforeShowTransform.ty;
                        }
                    }
                }
                else {
                    if (diffY > 0) {
                    }
                    
                    if (isShow) {
                    }
                    else {
                        tx = self.relatedShiftViewBeforeShowTransform.tx;
                        ty = self.relatedShiftViewBeforeShowTransform.ty;
                    }
                }
            }
            
//            NSLog(@"ty=%f,diffY=%f",ty,diffY);
            if (animated) {
                [UIView animateWithDuration:duration animations:^{
                    self.relatedShiftView.transform = CGAffineTransformMakeTranslation(tx, ty);
                } completion:animateCompletionBlock];
            }
            else {
                self.relatedShiftView.transform = CGAffineTransformMakeTranslation(tx, ty);
            }
#endif
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

-(void)updateKeyboardInputView:(UIView<YZHKeyboardInputViewProtocol>*)inputView animated:(BOOL)animated
{
    [self _setInputViewWithView:inputView inView:self.inView];
    [self _doUpdateRelateViewShift:nil shift:0 isShow:YES animated:animated];
}



#pragma mark KVO
-(void)_addScrollShiftViewKVO:(BOOL)add
{
    if (![self.relatedShiftView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    if (add) {
        [self.relatedShiftView hz_addKVOObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    }
    else {
        [self.relatedShiftView hz_removeKVOObserver:self forKeyPath:@"contentSize" context:NULL];
    }
}

-(void)_addInputViewKVO:(BOOL)add
{
    if (add) {
        [self.inputView hz_addKVOObserver:self forKeyPath:@"transform" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
    else {
        [self.inputView hz_removeKVOObserver:self forKeyPath:@"transform" context:NULL];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.relatedShiftView) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            [self updateKeyboardInputView:self.inputView animated:YES];
        }
    }
    else if (object == self.inputView) {
        if ([keyPath isEqualToString:@"transform"]) {
            [self updateKeyboardInputView:self.inputView animated:YES];
        }
    }
}



-(void)dealloc
{
    [self _addScrollShiftViewKVO:NO];
    [self _addInputViewKVO:NO];
}
@end
