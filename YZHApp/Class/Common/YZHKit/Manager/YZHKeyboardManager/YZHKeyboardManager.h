//
//  YZHKeyboardManager.h
//  YZHKeyboardManagerDemo
//
//  Created by yuan on 2018/8/20.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YZHKeyboardManager;
//成为第一响应者时的block
typedef void(^YZHKeyboardBecomeFirstResponderBlock)(YZHKeyboardManager *keyboardManager, NSNotification *notification);
//辞去第一响应者时的block
typedef void(^YZHKeyboardResignFirstResponderBlock)(YZHKeyboardManager *keyboardManager, NSNotification *notification);
//keyboard的notification
typedef void(^YZHKeyboardWillShowBlock)(YZHKeyboardManager *keyboardManager, NSNotification *keyboardNotification);
typedef void(^YZHKeyboardWillHideBlock)(YZHKeyboardManager *keyboardManager, NSNotification *keyboardNotification);
typedef void(^YZHKeyboardWillUpdateBlock)(YZHKeyboardManager *keyboardManager, NSNotification *keyboardNotification, CGFloat currentShift, BOOL isShow);
typedef void(^YZHKeyboardDidShowBlock)(YZHKeyboardManager *keyboardManager, NSNotification *keyboardNotification);
typedef void(^YZHKeyboardDidHideBlock)(YZHKeyboardManager *keyboardManager, NSNotification *keyboardNotification);
//进行偏移的block
typedef void(^YZHKeyboardShiftBlock)(YZHKeyboardManager *keyboardManager, NSNotification *keyboardNotification, CGFloat currentShift, BOOL isShow);
//完成动画后的block
typedef void(^YZHKeyboardCompletionBlock)(YZHKeyboardManager *keyboardManager, BOOL isShow);




@interface YZHKeyboardManager : NSObject

@property (nonatomic, weak) UIView *relatedShiftView;

//既可以指定也可以不用指定，就是keyboard不要遮挡的view,默认会自动去获取
@property (nonatomic, weak) UIView *firstResponderView;
//指的是keyboard和firstResponder的最小距离,默认为0;
@property (nonatomic, assign) CGFloat keyboardMinTopToResponder;
/*
 *指的是keyboard和firstResponder是否始终保持着keyboardMinTopToResponder，
 *默认为NO，此时他们的距离则保持着距离至少是keyboardMinTopToResponder，
 *为YES，则他们的距离始终保持着keyboardMinTopToResponder
 *
 */
@property (nonatomic, assign) BOOL firstResponderShiftToKeyboardMinTop;

/*
 *如果relatedShiftView是scrollView的话，是否使用contentOffset进行偏移
 *在进行hide后，scroll的contentOffset没有还原到开始时的
 *默认为YES
 */
@property (nonatomic, assign) BOOL relatedShiftViewUseContentOffsetToShift;

@property (nonatomic, copy) YZHKeyboardBecomeFirstResponderBlock becomeFirstResponderBlock;
@property (nonatomic, copy) YZHKeyboardResignFirstResponderBlock resignFirstResponderBlock;

@property (nonatomic, copy) YZHKeyboardWillShowBlock willShowBlock;
@property (nonatomic, copy) YZHKeyboardWillHideBlock willHideBlock;
@property (nonatomic, copy) YZHKeyboardWillUpdateBlock willUpdateBlock;
@property (nonatomic, copy) YZHKeyboardDidShowBlock didShowBlock;
@property (nonatomic, copy) YZHKeyboardDidHideBlock didHideBlock;

@property (nonatomic, copy) YZHKeyboardShiftBlock shiftBlock;

@property (nonatomic, copy) YZHKeyboardCompletionBlock completionBlock;

@end


/*****************************************************************************
 *YZHShareKeyboardManager
 *****************************************************************************/
@interface YZHShareKeyboardManager : NSObject

@property (nonatomic, strong, readonly) YZHKeyboardManager *keyboardManager;

+(instancetype)shareKeyboardManager;

@end
