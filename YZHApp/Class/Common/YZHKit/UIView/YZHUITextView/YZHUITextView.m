//
//  YZHUITextView.m
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2018/8/9.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHUITextView.h"
#import "YZHKitType.h"

#define USE_TEXTVIEW_TEXT_AS_PLACEHOLDER    (0)

/****************************************************
 *YZHUITextViewLimit
 ****************************************************/
@implementation YZHUITextViewLimit

-(instancetype)initWithLimitType:(NSTextViewLimitType)limitType limitValue:(NSNumber*)limitValue
{
    self = [super init];
    if (self) {
        self.limitType = limitType;
        self.limitValue = limitValue;
    }
    return self;
}

@end



/****************************************************
 *YZHUITextView
 ****************************************************/
#if USE_TEXTVIEW_TEXT_AS_PLACEHOLDER
@interface YZHUITextView ()
/* <#注释#> */
@property (nonatomic, strong) UIColor *originalTextColor;

/* <#注释#> */
@property (nonatomic, strong) NSString *inputText;

/* <#注释#> */
@property (nonatomic, strong) NSAttributedString *inputAttributedText;

#else
@interface YZHUITextView () <UITextViewDelegate>
/* <#注释#> */
@property (nonatomic, strong) UITextView *placeHolderTextView;

/* <#注释#> */
@property (nonatomic, assign) CGSize textSize;

#endif
/* <#注释#> */
@property (nonatomic, assign) CGSize lastContentSize;

/* <#name#> */
@property (nonatomic, assign) CGFloat normalHeight;

@end

@implementation YZHUITextView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupDefaultValue];
    }
    return self;
}

-(void)_setupDefaultValue
{
#if USE_TEXTVIEW_TEXT_AS_PLACEHOLDER
    self.originalTextColor = self.textColor;
#endif
    [self _registNotification:YES];
    self.lastContentSize = self.contentSize;
    self.normalHeight = -1;
    self.maxLimit = nil;
    [self _initNormalHeight];
}

-(void)_initNormalHeight
{
    if (self.normalHeight < 0 && self.bounds.size.height > 0) {
        self.normalHeight = self.bounds.size.height;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
#if !USE_TEXTVIEW_TEXT_AS_PLACEHOLDER
    self.placeHolderTextView.frame = self.bounds;
#endif
    [self _initNormalHeight];
    
    CGFloat w = self.contentSize.width;
    CGFloat h = MAX(self.contentSize.height, self.bounds.size.height);
    [self _textContainerView].frame = CGRectMake(0, 0, w, h);
}

-(UIView*)_textContainerView
{
    UIView *textContainerView = nil;
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"_UITextContainerView")]) {
            textContainerView = subView;
            break;
        }
    }
    
    return textContainerView;
}

-(UIView*)_textSelectRangeView
{
    UIView *textContainerView = [self _textContainerView];
    UIView *textSelectionView = nil;
    for (UIView *subView in textContainerView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITextSelectionView")]) {
            textSelectionView = subView;
            break;
        }
    }
    
    return [textSelectionView.subviews firstObject];
}

-(UIColor*)_placeHolderTextColor
{
    CGFloat r,g,b,a;
    [GRAY_COLOR getRed:&r green:&g blue:&b alpha:&a];
    UIColor *color = RGBA_F(r * 0.7, g * 0.7, b * 0.7, a * 0.7) ;
    return color;
}

-(void)_registNotification:(BOOL)regist
{
    if (regist) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didBeginEditingAction:) name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeTextAction:) name:UITextViewTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didEndEditingAction:) name:UITextViewTextDidEndEditingNotification object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
    }
}

#if USE_TEXTVIEW_TEXT_AS_PLACEHOLDER
-(void)_updateSuperText:(NSString*)text
{
    NSAttributedString *inputAttributedText = self.inputAttributedText;
    [super setText:text];
    self.inputAttributedText = inputAttributedText;
}

-(void)setText:(NSString *)text
{
    [self _updateSuperText:text];
    self.inputText = text;
    [super setTextColor:self.originalTextColor];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    self.inputAttributedText = attributedText;
}

-(void)setTextColor:(UIColor *)textColor
{
    [super setTextColor:textColor];
    _originalTextColor = textColor;
    self.placeholder = _placeholder;
}

-(BOOL)_canUpdatePlaceholder
{
    if (IS_AVAILABLE_NSSTRNG(self.inputText) || IS_AVAILABLE_ATTRIBUTEDSTRING(self.inputAttributedText)) {
        return NO;
    }
    return YES;
}

-(void)_didBeginEditingAction:(NSNotification*)notification
{
//        NSLog(@"didBegin,notification=%@",notification);
    if (!IS_AVAILABLE_NSSTRNG(self.inputText) && !IS_AVAILABLE_ATTRIBUTEDSTRING(self.inputAttributedText)) {
        [self _updateSuperText:nil];
        [super setTextColor:self.originalTextColor];
        
    }
}

-(void)_didChangeTextAction:(NSNotification*)notification
{
    UITextView *textView = (UITextView*)notification.object;
    self.inputText = textView.text;
    self.inputAttributedText = textView.attributedText;
}

-(void)_didEndEditingAction:(NSNotification*)notification
{
    NSAttributedString *oldAttributedPlaceholder = _attributedPlaceholder;
    self.placeholder = _placeholder;
    if (IS_AVAILABLE_ATTRIBUTEDSTRING(oldAttributedPlaceholder)) {
        self.attributedPlaceholder = oldAttributedPlaceholder;
    }
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    _attributedPlaceholder = nil;
    if (![self _canUpdatePlaceholder]) {
        return;
    }
    
    [self _updateSuperText:placeholder];
    
    if (IS_AVAILABLE_NSSTRNG(placeholder)) {
        [super setTextColor:[self _placeHolderTextColor]];
    }
    else {
        [super setTextColor:self.originalTextColor];
    }
}

-(void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    _attributedPlaceholder = attributedPlaceholder;
    _placeholder = nil;
    if (![self _canUpdatePlaceholder]) {
        return;
    }
    
    [super setAttributedText:attributedPlaceholder];
}
#else

-(UITextView*)placeHolderTextView
{
    if (_placeHolderTextView == nil) {
        _placeHolderTextView = [[UITextView alloc] initWithFrame:self.bounds];
        _placeHolderTextView.delegate = self;
        _placeHolderTextView.font = self.font;
        _placeHolderTextView.backgroundColor = CLEAR_COLOR;
        _placeHolderTextView.textColor = [self _placeHolderTextColor];
        [self addSubview:_placeHolderTextView];
    }
    return _placeHolderTextView;
}

-(void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self _updatePlaceHolder];
}

-(void)setText:(NSString *)text
{
    [super setText:text];
    [self _updateTextAction];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self _updateTextAction];
}

-(void)_updatePlaceHolder
{
    self.placeHolderTextView.frame = self.bounds;
    self.placeHolderTextView.font = self.font;
    self.placeHolderTextView.textContainer.size = self.placeHolderTextView.bounds.size;
    self.placeHolderTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    self.placeHolderTextView.text = placeholder;
    [self _updatePlaceHolder];
}

-(void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    _attributedPlaceholder = attributedPlaceholder;
    self.placeHolderTextView.attributedText = attributedPlaceholder;
    [self _updatePlaceHolder];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self becomeFirstResponder];
    return NO;
}

-(void)_hiddenPlaceholderTextView
{
    if (IS_AVAILABLE_NSSTRNG(self.text) || IS_AVAILABLE_ATTRIBUTEDSTRING(self.attributedText)) {
        self.placeHolderTextView.hidden = YES;
    }
    else {
        self.placeHolderTextView.hidden = NO;
    }
}

-(void)_didBeginEditingAction:(NSNotification*)notification
{
    if (notification.object == self) {
        
    }
}

-(void)_didChangeTextAction:(NSNotification*)notification
{
    if (notification.object == self) {
        [self _updateTextAction];
    }
}

-(void)_updateTextAction
{
    [self _hiddenPlaceholderTextView];

    CGSize textSize = [self sizeThatFits:self.contentSize];
    if (self.textChangeBlock) {
        self.textChangeBlock(self, textSize);
        
    }
    if (!CGSizeEqualToSize(self.textSize, textSize)) {
        if (self.textSizeChangeBlock) {
            self.textSizeChangeBlock(self, textSize);
        }
    }
    self.textSize = textSize;
    
    if (self.maxLimit) {
        CGRect frame = self.frame;
        CGRect oldFrame = frame;
        if (self.maxLimit.limitType == NSTextViewLimitTypeHeight) {
            CGFloat limitHeight = [self.maxLimit.limitValue floatValue];
            CGFloat height = MAX(self.normalHeight, textSize.height);
            CGFloat maxHeight = MAX(self.normalHeight, limitHeight);
            height = MIN(maxHeight, height);
            if (height > 0) {
                frame.size.height = height;
            }
        }
        else if (self.maxLimit.limitType == NSTextViewLimitTypeLines) {
            NSInteger limitCnt = [self.maxLimit.limitValue integerValue];
            NSInteger lineCnt = [self textLines];
            if (lineCnt > 0 && lineCnt <= limitCnt && limitCnt > 0) {
                CGFloat height = MAX(self.normalHeight, textSize.height);
                frame.size.height = height;
            }
        }
        if (!CGRectEqualToRect(frame, oldFrame)) {
            self.frame = frame;
            if (self.changeFrameBlock) {
                self.changeFrameBlock(self, oldFrame, frame);
            }
        }
    }
}

-(void)_didEndEditingAction:(NSNotification*)notification
{
    if (notification.object == self) {
        [self _hiddenPlaceholderTextView];
    }
}
#endif

-(void)setContentSize:(CGSize)contentSize
{
    [super setContentSize:contentSize];
    if (!CGSizeEqualToSize(self.lastContentSize, contentSize)) {
        if (self.contentSizeChangeBlock) {
            self.contentSizeChangeBlock(self, self.lastContentSize);
        }
    }
    self.lastContentSize = contentSize;
}

-(void)setContentOffset:(CGPoint)contentOffset
{
    if (!self.decelerating && !self.tracking && !self.dragging && self.selectedRange.location >= self.text.length) {
        CGFloat y = self.contentSize.height - self.frame.size.height;
        contentOffset.y = MAX(0, y);
    }
    [super setContentOffset:contentOffset];
}

-(CGFloat)normalHeight
{
    return _normalHeight;
}

-(NSInteger)textLineHeight
{
    CGFloat lineHeight = self.font.lineHeight;
    return lineHeight;
}

-(NSInteger)textLines
{
    CGFloat lineHeight = [self textLineHeight];
    NSInteger lineCnt = 0;
    if (lineHeight > 0) {
        CGSize textSize = [self sizeThatFits:self.contentSize];
        lineCnt = (textSize.height - self.textContainerInset.top - self.textContainerInset.bottom) / lineHeight;
    }
    return lineCnt;
}

-(void)dealloc
{
    [self _registNotification:NO];
}
@end
