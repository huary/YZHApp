//
//  YZHKeyboardManager.m
//  YZHKeyboardManagerDemo
//
//  Created by yuan on 2018/8/20.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHKeyboardManager.h"
#import <objc/runtime.h>

/************************************************************
 *YZHKeyboardManager ()
 ************************************************************/
@interface YZHKeyboardManager ()

@property (nonatomic, assign) BOOL isSpecialFirstResponderView;

/* <#name#> */
@property (nonatomic, assign) CGAffineTransform relatedShiftViewBeforeShowTransform;

/* <#注释#> */
@property (nonatomic, strong) NSNotification *keyboardNotification;

/* <#name#> */
@property (nonatomic, assign) BOOL isKeyboardShowing;

@end


@implementation YZHKeyboardManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpDefault];
    }
    return self;
}

-(void)setUpDefault
{
    self.isSpecialFirstResponderView = NO;
    self.relatedShiftViewUseContentOffsetToShift = YES;
    [self _registerAllNotification:YES];
}

-(void)setFirstResponderView:(UIView *)firstResponderView
{
    _firstResponderView = firstResponderView;
    if (_firstResponderView != nil) {
        self.isSpecialFirstResponderView = YES;
    }
    else {
        self.isSpecialFirstResponderView = NO;
    }
}

-(void)_registerAllNotification:(BOOL)regist
{
    [self _registerFirstResponderViewNotification:regist didBecomeFirstResponderNotificationName:UITextFieldTextDidBeginEditingNotification didResignFirstResponderNotificationName:UITextFieldTextDidEndEditingNotification];
    [self _registerFirstResponderViewNotification:regist didBecomeFirstResponderNotificationName:UITextViewTextDidBeginEditingNotification didResignFirstResponderNotificationName:UITextViewTextDidEndEditingNotification];
    
    [self _registerKeyboardNotification:regist];
}

-(void)_registerKeyboardNotification:(BOOL)regist
{
    if (regist) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

-(void)_registerFirstResponderViewNotification:(BOOL)regist didBecomeFirstResponderNotificationName:(NSString*)becomeNotificationName didResignFirstResponderNotificationName:(NSString*)resignNotificationName
{
    if (regist) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didBecomeFirstResponder:) name:becomeNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didResignFirstResponder:) name:resignNotificationName object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:becomeNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:resignNotificationName object:nil];
    }
}

-(void)_registerStatusBarNotification:(BOOL)regist
{
    if (regist) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeStatusBarFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:[UIApplication sharedApplication]];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:[UIApplication sharedApplication]];
    }
}

-(BOOL)_doUpdateWithKeyboardFrame:(CGRect)keyboardFrame duration:(NSTimeInterval)duration isShow:(BOOL)isShow
{
    if (self.firstResponderView == nil) {
        return NO;
    }
    
    CGRect firstResponderViewFrame = self.firstResponderView.frame;
    firstResponderViewFrame = [self.firstResponderView.superview convertRect:firstResponderViewFrame toView:[UIApplication sharedApplication].keyWindow];
    
    CGFloat diffY = keyboardFrame.origin.y - CGRectGetMaxY(firstResponderViewFrame) - self.keyboardMinTopToResponder;
    
    if (self.willUpdateBlock) {
        self.willUpdateBlock(self, self.keyboardNotification, diffY, isShow);
    }
    
//    NSLog(@"firstResponderViewFrame=%@",NSStringFromCGRect(firstResponderViewFrame));
    
    if (self.shiftBlock) {
        self.shiftBlock(self, self.keyboardNotification, diffY, isShow);
        return YES;
    }
    else {
        void (^animateCompletionBlock)(BOOL finished) = ^(BOOL finished){
            if (self.completionBlock) {
                self.completionBlock(self, isShow);
            }
        };
        if ([self.relatedShiftView isKindOfClass:[UIScrollView class]] && self.relatedShiftViewUseContentOffsetToShift) {
            UIScrollView *scrollView = (UIScrollView*)self.relatedShiftView;
            CGPoint contentOffset = scrollView.contentOffset;
            CGFloat offsetY = contentOffset.y - diffY;
            offsetY = MAX(offsetY, 0);
            CGFloat maxOffsetY = scrollView.contentSize.height - scrollView.bounds.size.height;
            if (isShow) {
                [scrollView setContentOffset:CGPointMake(contentOffset.x, offsetY)];
            }
            else {
                if (contentOffset.y > maxOffsetY) {
                    [scrollView setContentOffset:CGPointMake(contentOffset.x, maxOffsetY)];
                }
            }
            animateCompletionBlock(YES);
        }
        else {
//            NSLog(@"diffY=%f",diffY);
            if (diffY > 0) {
                if (!isShow) {
                    [UIView animateWithDuration:duration animations:^{
                        self.relatedShiftView.transform = self.relatedShiftViewBeforeShowTransform;
                    } completion:animateCompletionBlock];
                    return YES;
                }
                if (!self.firstResponderShiftToKeyboardMinTop) {
                    return YES;
                }
            }
            
            CGFloat oldTranslationX = self.relatedShiftView.transform.tx;
            CGFloat oldTranslationY = self.relatedShiftView.transform.ty;
            CGFloat ty = oldTranslationY + diffY;
//            NSLog(@"ty=%f",ty);
            
            [UIView animateWithDuration:duration animations:^{
                self.relatedShiftView.transform = CGAffineTransformMakeTranslation(oldTranslationX, ty);
            } completion:animateCompletionBlock];
        }
        return YES;        
    }
}

#pragma mark firstResponder
-(void)_didBecomeFirstResponder:(NSNotification*)notification
{
//    NSLog(@"%s,notification=%@",__FUNCTION__,notification);
    if (self.becomeFirstResponderBlock) {
        self.becomeFirstResponderBlock(self, notification);
    }
    
    if (self.isSpecialFirstResponderView && self.firstResponderView != nil) {
        goto _DID_BECOME_FIRST_RESPONDER_END;
    }
    self.isSpecialFirstResponderView = NO;
    _firstResponderView = notification.object;
    
_DID_BECOME_FIRST_RESPONDER_END:
    [self _keyboardAction:self.keyboardNotification show:YES];
}

-(void)_didResignFirstResponder:(NSNotification*)notification
{
//    NSLog(@"%s,notification=%@",__FUNCTION__,notification);
    if (self.resignFirstResponderBlock) {
        self.resignFirstResponderBlock(self, notification);
    }
}

#pragma mark statusBarFrame
-(void)_didChangeStatusBarFrame:(NSNotification*)notification
{
}


#pragma mark keyBoard

-(void)_keyboardAction:(NSNotification*)notification show:(BOOL)show
{
    if (!notification) {
        return;
    }
    
//    NSLog(@"notification=%@",notification);
    NSTimeInterval time = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardFrame = CGRectZero;
    [notification.userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    if (show) {
        if (!self.isKeyboardShowing) {
            self.relatedShiftViewBeforeShowTransform = self.relatedShiftView.transform;
        }
        
        self.keyboardNotification = notification;
        
        BOOL OK = [self _doUpdateWithKeyboardFrame:keyboardFrame duration:time isShow:YES];
        
        if (OK) {
            self.isKeyboardShowing = YES;
//            self.keyboardNotification = nil;
        }
    }
    else {
        self.keyboardNotification = notification;
        
        BOOL OK = [self _doUpdateWithKeyboardFrame:keyboardFrame duration:time isShow:NO];
        
        if (OK) {
            self.isKeyboardShowing = NO;
            self.keyboardNotification = nil;
            self.relatedShiftViewBeforeShowTransform = CGAffineTransformIdentity;
            
            if (!self.isSpecialFirstResponderView) {
                _firstResponderView = nil;
            }
        }
    }
}

-(void)_keyboardWillShow:(NSNotification*)notification
{
//    NSLog(@"%s,notification=%@",__FUNCTION__,notification);
    if (self.willShowBlock) {
        self.willShowBlock(self, notification);
    }
    
    [self _keyboardAction:notification show:YES];
    
}

-(void)_keyboardWillHide:(NSNotification*)notification
{
//    NSLog(@"%s,notification=%@",__FUNCTION__,notification);
    if (self.willHideBlock) {
        self.willHideBlock(self, notification);
    }
    [self _keyboardAction:notification show:NO];
}

-(void)_keyboardDidShow:(NSNotification*)notification
{
//    NSLog(@"%s,notification=%@",__FUNCTION__,notification);
    if (self.didShowBlock) {
        self.didShowBlock(self, notification);
    }
}

-(void)_keyboardDidHide:(NSNotification*)notification
{
//    NSLog(@"%s,notification=%@",__FUNCTION__,notification);
    if (self.didHideBlock) {
        self.didHideBlock(self, notification);
    }
}

-(void)_keyboardWillChangeFrame:(NSNotification*)notification
{
//    NSLog(@"%s,notification=%@",__FUNCTION__,notification);
}

-(void)dealloc
{
    [self _registerAllNotification:NO];
}

@end



/*****************************************************************************
 *YZHShareKeyboardManager
 *****************************************************************************/
static YZHShareKeyboardManager *_shareKeyboardManager_s = nil;

@implementation YZHShareKeyboardManager

+(instancetype)shareKeyboardManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareKeyboardManager_s = [[super allocWithZone:NULL] init];
        [_shareKeyboardManager_s _setUpDefault];
    });
    return _shareKeyboardManager_s;
}

-(void)_setUpDefault
{
    _keyboardManager = [[YZHKeyboardManager alloc] init];
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [YZHShareKeyboardManager shareKeyboardManager];
}

-(id)copyWithZone:(struct _NSZone *)zone
{
    return [YZHShareKeyboardManager shareKeyboardManager];
}

@end
