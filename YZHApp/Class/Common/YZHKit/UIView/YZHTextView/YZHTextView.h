//
//  YZHTextView.h
//  YZHAlertViewDemo
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

@class YZHTextView;
typedef void(^YZHTextViewTextDidBeginEditingBlock)(YZHTextView *textView,NSNotification *notification);
typedef void(^YZHTextViewTextDidEndEditingBlock)(YZHTextView *text,NSNotification *notification);

typedef void(^YZHTextViewTextDidChangeBlock)(YZHTextView *textView, CGSize textSize);
typedef void(^YZHTextViewTextSizeDidChangeBlock)(YZHTextView *textView, CGSize textSize);
typedef void(^YZHTextViewContentSizeDidChangeBlock)(YZHTextView *textView, CGSize lastContentSize);
typedef void(^YZHTextViewDidChangeFrameBlock)(YZHTextView *textView, CGRect oldFrame, CGRect newFrame);

/****************************************************
 *YZHTextViewLimit
 ****************************************************/
@interface YZHTextViewLimit : NSObject

/* <#name#> */
@property (nonatomic, assign) NSTextViewLimitType limitType;

/* <#注释#> */
@property (nonatomic, strong) NSNumber *limitValue;

-(instancetype)initWithLimitType:(NSTextViewLimitType)limitType limitValue:(NSNumber*)limitValue;

@end


/****************************************************
 *YZHTextView
 ****************************************************/
@interface YZHTextView : UITextView
/* placeholder */
@property (nonatomic, strong) NSString *placeholder;

/** placeholderFont */
@property (nonatomic, strong) UIFont *placeholderFont;

/** placeholderColor */
@property (nonatomic, strong) UIColor *placeholderColor;

/** 行间距，默认为2 */
@property (nonatomic, assign) CGFloat lineSpacing;

/* attributedPlaceholder */
@property (nonatomic, strong) NSAttributedString *attributedPlaceholder;

/* textView最大允许展示的高度 */
@property (nonatomic, strong) YZHTextViewLimit *maxLimit;

/* <#注释#> */
@property (nonatomic, copy) YZHTextViewTextDidBeginEditingBlock didBeginEditingBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHTextViewTextDidEndEditingBlock didEndEditingBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHTextViewTextDidChangeBlock textChangeBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHTextViewTextSizeDidChangeBlock textSizeChangeBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHTextViewContentSizeDidChangeBlock contentSizeChangeBlock;

/* <#注释#> */
@property (nonatomic, copy) YZHTextViewDidChangeFrameBlock changeFrameBlock;

-(CGFloat)normalHeight;

-(CGFloat)textLineHeight;

-(NSInteger)textLines;

@end
