//
//  YZHUITextView.h
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2018/8/9.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSTextViewLimitType)
{
    NSTextViewLimitTypeNULL     = 0,
    //限制显示的高度
    NSTextViewLimitTypeHeight   = 1,
    //限制显示的行数
    NSTextViewLimitTypeLines    = 2,
};

@class YZHUITextView;
typedef void(^YZHUITextViewTextDidBeginEditingBlock)(YZHUITextView *textView,NSNotification *notification);
typedef void(^YZHUITextViewTextDidEndEditingBlock)(YZHUITextView *text,NSNotification *notification);

typedef void(^YZHUITextViewTextDidChangeBlock)(YZHUITextView *textView, CGSize textSize);
typedef void(^YZHUITextViewTextSizeDidChangeBlock)(YZHUITextView *textView, CGSize textSize);
typedef void(^YZHUITextViewContentSizeDidChangeBlock)(YZHUITextView *textView, CGSize lastContentSize);
typedef void(^YZHUITextViewDidChangeFrameBlock)(YZHUITextView *textView, CGRect oldFrame, CGRect newFrame);

typedef BOOL(^YZHUITextViewCanPerformActionBlock)(YZHUITextView *textView, SEL selector, id sender);


/****************************************************
 *YZHUITextViewLimit
 ****************************************************/
@interface YZHUITextViewLimit : NSObject

/* <#name#> */
@property (nonatomic, assign) NSTextViewLimitType limitType;

/* <#注释#> */
@property (nonatomic, strong) NSNumber *limitValue;

-(instancetype)initWithLimitType:(NSTextViewLimitType)limitType limitValue:(NSNumber*)limitValue;

@end


/****************************************************
 *YZHUITextView
 ****************************************************/
@interface YZHUITextView : UITextView
/* <#注释#> */
@property (nonatomic, strong) NSString *placeholder;

/** <#注释#> */
@property (nonatomic, strong) UIFont *placeholderFont;

/** <#注释#> */
@property (nonatomic, strong) UIColor *placeholderColor;

/* <#注释#> */
@property (nonatomic, strong) NSAttributedString *attributedPlaceholder;

/* <#注释#> */
@property (nonatomic, strong) YZHUITextViewLimit *maxLimit;

/* <#注释#> */
@property (nonatomic, copy) YZHUITextViewTextDidBeginEditingBlock didBeginEditingBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHUITextViewTextDidEndEditingBlock didEndEditingBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHUITextViewTextDidChangeBlock textChangeBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHUITextViewTextSizeDidChangeBlock textSizeChangeBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHUITextViewContentSizeDidChangeBlock contentSizeChangeBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHUITextViewDidChangeFrameBlock changeFrameBlock;


@property (nonatomic, copy) YZHUITextViewCanPerformActionBlock canPerformActionBlock;

//默认为YES
@property (nonatomic, assign) BOOL enablePerformAction;


-(CGFloat)normalHeight;

-(CGFloat)textLineHeight;

-(NSInteger)textLines;

@end
