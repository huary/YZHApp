//
//  YZHKeyboardManager.m
//  YZHKeyboardManagerDemo
//
//  Created by yuan on 2018/8/20.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHKeyboardManager.h"
#import <objc/runtime.h>
#import "YZHKitType.h"

static inline CGRect pri_keyboardEndFrameFromNotification(NSNotification *notification) {
    CGRect keyboardFrame = CGRectZero;
    [notification.userInfo[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    return keyboardFrame;
}

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
    self.relatedShiftViewBeforeShowTransform = CGAffineTransformIdentity;
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
    
    CGFloat off = 0;
    if (FLOAT_EQUAL(keyboardFrame.origin.y, SCREEN_HEIGHT)) {
        off = SAFE_BOTTOM;
    }
    
    CGFloat diffY = keyboardFrame.origin.y - CGRectGetMaxY(firstResponderViewFrame) - self.keyboardMinTopToResponder - off;
    
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
            
            if (isShow) {
                if ((diffY > 0 && self.firstResponderShiftToKeyboardMinTop) || diffY <= 0) {
                    [scrollView setContentOffset:CGPointMake(contentOffset.x, offsetY)];
                }
            }
            else {
                CGFloat maxOffsetY = scrollView.contentSize.height - scrollView.bounds.size.height;
                maxOffsetY = MAX(maxOffsetY, 0);
                if (contentOffset.y > maxOffsetY) {
                    [scrollView setContentOffset:CGPointMake(contentOffset.x, maxOffsetY)];
                }
            }
            
//            offsetY = MAX(offsetY, 0);
//            if (isShow) {
//                [scrollView setContentOffset:CGPointMake(contentOffset.x, offsetY)];
//            }
//            else {
//                CGFloat maxOffsetY = scrollView.contentSize.height - scrollView.bounds.size.height;
//                maxOffsetY = MAX(maxOffsetY, 0);
//                if (contentOffset.y > maxOffsetY) {
//                    [scrollView setContentOffset:CGPointMake(contentOffset.x, maxOffsetY)];
//                }
//            }
            animateCompletionBlock(YES);
        }
        else {
//            NSLog(@"diffY=%f",diffY);
            CGAffineTransform t = CGAffineTransformIdentity;
            BOOL haveShiftTransform = NO;
            if (self.shiftTransformBlock) {
                BOOL use = NO;
                t = self.shiftTransformBlock(self,self.keyboardNotification,diffY,isShow, &use);
                if (use) {
                    haveShiftTransform = YES;
                }
            }
            if (diffY > 0) {
                if (!isShow) {
                    if (duration > 0) {
                        [UIView animateWithDuration:duration animations:^{
                            self.relatedShiftView.transform = haveShiftTransform ? t : self.relatedShiftViewBeforeShowTransform;
                        } completion:animateCompletionBlock];
                    }
                    else {
                        self.relatedShiftView.transform = haveShiftTransform ? t : self.relatedShiftViewBeforeShowTransform;
                        animateCompletionBlock(YES);
                    }
//                    NSLog(@"shiftView=%@",self.relatedShiftView);
                    return YES;
                }
                if (!self.firstResponderShiftToKeyboardMinTop) {
                    return YES;
                }
            }
            
            CGFloat oldTranslationX = self.relatedShiftView.transform.tx;
            CGFloat oldTranslationY = self.relatedShiftView.transform.ty;
            CGFloat ty = oldTranslationY + diffY;
//            NSLog(@"=======ty=%f",ty);
            if (!haveShiftTransform) {
                t = CGAffineTransformMakeTranslation(oldTranslationX, ty);
            }
            
//            NSLog(@"t.ty=%f",t.ty);
            if (duration > 0) {
                [UIView animateWithDuration:duration animations:^{
                    self.relatedShiftView.transform = t;
                } completion:animateCompletionBlock];
            }
            else {
                self.relatedShiftView.transform = t;
                animateCompletionBlock(YES);
            }
//            NSLog(@"shiftView2=%@",self.relatedShiftView);
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
    
    CGRect keyboardFrame = pri_keyboardEndFrameFromNotification(notification);
    
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
//            self.isKeyboardShowing = NO;
//            self.keyboardNotification = nil;
//            self.relatedShiftViewBeforeShowTransform = CGAffineTransformIdentity;
            
            //这里不应该将firstResponderView赋值为nil,比如在旋转屏幕的时候就不应该
//            if (!self.isSpecialFirstResponderView) {
//                _firstResponderView = nil;
//            }
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
    self.isKeyboardShowing = NO;
    self.keyboardNotification = nil;
    /*这里不需要将relatedShiftView的transform更改为relatedShiftViewBeforeShowTransform，
     有可能在didHide时不需要将relatedShiftView还原为relatedShiftViewBeforeShowTransform，
     比如在IM键盘时，keyboard已经hide了，但是可以通过content（emoji）输入
     */
//    self.relatedShiftView.transform = self.relatedShiftViewBeforeShowTransform;
    if (self.didHideBlock) {
        self.didHideBlock(self, notification);
    }
}

-(void)_keyboardWillChangeFrame:(NSNotification*)notification
{
//    NSLog(@"%s,notification=%@",__FUNCTION__,notification);
    if (!self.isKeyboardShowing) {
        return;
    }
    [self _keyboardAction:notification show:self.isKeyboardShowing];
}

-(BOOL)isKeyboardShow
{
    return self.isKeyboardShowing;
}

-(void)dealloc
{
    [self _registerAllNotification:NO];
}

@end



/*****************************************************************************
 *YZHShareKeyboardManager
 *****************************************************************************/

@implementation YZHSharedKeyboardManager

+(instancetype)sharedKeyboardManager
{
    static YZHSharedKeyboardManager *_sharedKeyboardManager_s = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedKeyboardManager_s = [[super allocWithZone:NULL] init];
        [_sharedKeyboardManager_s _setUpDefault];
    });
    return _sharedKeyboardManager_s;
}

-(void)_setUpDefault
{
    _keyboardManager = [[YZHKeyboardManager alloc] init];
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [YZHSharedKeyboardManager sharedKeyboardManager];
}

-(id)copyWithZone:(struct _NSZone *)zone
{
    return [YZHSharedKeyboardManager sharedKeyboardManager];
}

@end
