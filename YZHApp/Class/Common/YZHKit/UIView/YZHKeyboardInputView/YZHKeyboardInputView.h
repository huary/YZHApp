//
//  YZHKeyboardInputView.h
//  YZHKeyboardManagerDemo
//
//  Created by yuan on 2018/9/1.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHTextView.h"
#import "YZHKeyboardManager.h"


typedef NS_ENUM(NSInteger, YZHShiftType)
{
    //正常按那个view的底部Y值计算移动
    YZHShiftTypeNormal              = 0,
    //按contentOffset的进行移动，专指UIScrollView及其子类的对象
    YZHShiftTypeContentOffset       = 1,
    //按contentSizePoint判断，移动View(专指UIScrollView及其子类的对象),此时contentSize的height需要小于view.height
    YZHShiftTypeContentSizePoint    = 2,
};

@class YZHKeyboardInputView;
//开始要偏移的block
typedef void(^YZHKeyboardInputViewWillUpdateBlock)(YZHKeyboardInputView *inputView, NSNotification *keyboardNotification, CGFloat currentShift, BOOL isShow);
//进行偏移的block
typedef void(^YZHKeyboardInputViewShiftBlock)(YZHKeyboardInputView *inputView, NSNotification *keyboardNotification, CGFloat currentShift, BOOL isShow);
//完成动画后的block
typedef void(^YZHKeyboardInputViewCompletionBlock)(YZHKeyboardInputView *inputView, BOOL isShow);


/****************************************************
 *YZHKeyboardInputViewProtocol
 ****************************************************/
@protocol YZHKeyboardInputViewProtocol <NSObject>

/* 能够响应becomeFirstResponder或者resignFirstResponder的view */
@property (nonatomic, strong) UIResponder *inputTextView;

/*
 *firstResponderView其实就是keyboard上方需要显示的输入框
 *inputTextView应该是在firstResponderView上的subView
 *也可以让firstResponderView就是inputTextView
 */
@property (nonatomic, strong) UIView *firstResponderView;

/*
 *contentView，这个contentview其实在keyboard进行展示的时候，被keyboard进行遮挡住了的
 *在keyboard隐藏的时候进行显示，可以为nil
 *
 */
@property (nonatomic, strong) UIView *contentView;

@end


/****************************************************
 *YZHKeyboardInputView
 ****************************************************/
@interface YZHKeyboardInputView : NSObject

@property (nonatomic, strong, readonly) YZHKeyboardManager *keyboardManager;


@property (nonatomic, strong, readonly) UIView<YZHKeyboardInputViewProtocol>*inputView;

//需要移动的view
@property (nonatomic, weak) UIView *relatedShiftView;
/*
 *这里的firstResponderView指的是inputView需要靠近的那个view
 *这里的firstResponderView需要开发者来指定
 *如果relatedShiftView是scrollView，而firstResponderView此时可以不用指定，
 *此时已scrollView的(0,contentSize.height-contentOffset.y)这个点作为需要靠近的点
 */
@property (nonatomic, weak) UIView *firstResponderView;
//指的是inputView和firstResponder的最小距离,默认为0;
@property (nonatomic, assign) CGFloat inputViewMinTopToResponder;
/*
 *指的是inputView和firstResponder是否始终保持着inputViewMinTopToResponder，
 *默认为YES，则他们的距离始终保持着inputViewMinTopToResponder，
 *为NO，此时他们的距离则保持着距离至少是inputViewMinTopToResponder
 */
@property (nonatomic, assign) BOOL firstResponderShiftToInputViewMinTop;

/*
 *如果relatedShiftView是scrollView的话，是否使用contentOffset进行偏移
 *在进行hide后，scroll的contentOffset没有还原到开始时的
 *默认为YES
 */
//@property (nonatomic, assign) BOOL relatedShiftViewUseContentOffsetToShift;
/* <#name#> */
@property (nonatomic, assign) YZHShiftType shiftType;

/* <#name#> */
@property (nonatomic, assign) NSTimeInterval updateAnimationDuaration;

/* <#注释#> */
@property (nonatomic, copy) YZHKeyboardInputViewWillUpdateBlock willUpdateBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHKeyboardInputViewShiftBlock shiftBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHKeyboardCompletionBlock completionBlock;



-(instancetype)initWithInputView:(UIView<YZHKeyboardInputViewProtocol>*)inputView;

-(instancetype)initWithInputView:(UIView<YZHKeyboardInputViewProtocol>*)inputView inView:(UIView*)inView;

-(void)becomeFirstResponder;

-(void)resignFirstResponder;

//这个主要是在更新inputView中的firstResponderView（inputTextView）的大小时需要调用
-(void)updateKeyboardInputView:(UIView<YZHKeyboardInputViewProtocol>*)inputView animated:(BOOL)animated;

@end
