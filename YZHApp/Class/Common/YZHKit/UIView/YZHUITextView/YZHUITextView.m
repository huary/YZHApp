//
//  YZHUITextView.m
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2018/8/9.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHUITextView.h"
#import "YZHKitType.h"
#import "NSObject+YZHAddForKVO.h"
#import "YZHTransaction.h"

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
@interface YZHUITextView () <UITextViewDelegate>

/* <#注释#> */
@property (nonatomic, assign) CGSize textSize;

/** <#注释#> */
@property (nonatomic, strong) UIImageView *placeholderView;

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
        [self pri_setupDefaultValue];
    }
    return self;
}

-(void)pri_setupDefaultValue
{
    [self pri_registNotification:YES];
    self.lastContentSize = self.contentSize;
    self.normalHeight = -1;
    self.maxLimit = nil;
    self.enablePerformAction = YES;
    [self pri_initNormalHeight];
    [self addSubview:self.placeholderView];
}

-(void)pri_initNormalHeight
{
    if (self.normalHeight < 0 && self.bounds.size.height > 0) {
        self.normalHeight = self.bounds.size.height;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    [self pri_initNormalHeight];
    
    CGFloat w = self.contentSize.width;
    CGFloat h = MAX(self.contentSize.height, self.bounds.size.height);
    [self pri_textContainerView].frame = CGRectMake(0, 0, w, h);
    [self pri_hiddenPlaceholderView];
}

-(UIView*)pri_textContainerView
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

-(UIView*)pri_textSelectRangeView
{
    UIView *textContainerView = [self pri_textContainerView];
    UIView *textSelectionView = nil;
    for (UIView *subView in textContainerView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITextSelectionView")]) {
            textSelectionView = subView;
            break;
        }
    }
    
    return [textSelectionView.subviews firstObject];
}

- (UIFont *)pri_defaultFont
{
    return [UIFont systemFontOfSize:12];
}

- (UIColor*)pri_placeholderDefaultTextColor
{
    return [UIColor colorWithRed:0 green:0 blue:25/255.0 alpha:44/255.0];
}

-(void)pri_registNotification:(BOOL)regist
{
    if (regist) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pri_didBeginEditingAction:) name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pri_didChangeTextAction:) name:UITextViewTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pri_didEndEditingAction:) name:UITextViewTextDidEndEditingNotification object:nil];
        
        [self addKVOObserver:self forKeyPath:@"selectedRange" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
        
        [self removeKVOObserver:self forKeyPath:@"selectedRange" context:nil];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedRange"]) {
        self.contentOffset = self.contentOffset;
    }
}

- (UIImageView *)placeholderView
{
    if (_placeholderView == nil) {
        _placeholderView = [UIImageView new];
        _placeholderView.userInteractionEnabled = NO;
        _placeholderView.hidden = YES;
    }
    return _placeholderView;
}

-(void)setFrame:(CGRect)frame
{
    CGSize oldSize = self.frame.size;
    CGSize newSize = frame.size;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        [self pri_updatePlaceholder];
    }
}

-(void)setBounds:(CGRect)bounds
{
    CGSize oldSize = self.bounds.size;
    CGSize newSize = bounds.size;
    [super setBounds:bounds];
    if (!CGSizeEqualToSize(oldSize, newSize)) {
        [self pri_updatePlaceholder];
    }
}

-(void)setFont:(UIFont *)font
{
    UIFont *oldFont = self.font;
    [super setFont:font];
    if (oldFont != font || (font && [oldFont isEqual:font] == NO)) {
        [self pri_updatePlaceholder];
    }
}

-(void)setText:(NSString *)text
{
    [super setText:text];
    [self pri_updateTextAction];
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self pri_updateTextAction];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    UIEdgeInsets oldInsets = self.textContainerInset;
    [super setTextContainerInset:textContainerInset];
    if (!UIEdgeInsetsEqualToEdgeInsets(oldInsets, textContainerInset)) {
        [self pri_updatePlaceholder];
    }
}

-(void)setPlaceholder:(NSString *)placeholder
{
    BOOL isEqual = ((_placeholder == placeholder) || (placeholder && [_placeholder isEqualToString:placeholder]));
    if (!isEqual) {
        _placeholder = placeholder;
        [self pri_updatePlaceholder];
    }
}

-(void)setPlaceholderFont:(UIFont *)placeholderFont
{
    if (![_placeholderFont isEqual:placeholderFont]) {
        _placeholderFont = placeholderFont;
        [self pri_updatePlaceholder];
    }
}

-(void)setPlaceholderColor:(UIColor *)placeholderColor
{
    if (![_placeholderColor isEqual:placeholderColor]) {
        _placeholderColor = placeholderColor;
        [self pri_updatePlaceholder];
    }
}

-(void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    if (![_attributedPlaceholder isEqual:attributedPlaceholder]) {
        _attributedPlaceholder = attributedPlaceholder;
        [self pri_updatePlaceholder];
    }
}

-(void)pri_updatePlaceholder
{
    [[YZHTransaction transactionWithTransactionId:@"YZHUITextView.updatePlaceholder" action:^(YZHTransaction * _Nonnull transaction) {
                
        NSAttributedString *attrPlaceholder = self.attributedPlaceholder;
        if (attrPlaceholder.length == 0) {
            if (self.placeholder.length == 0) {
                return;
            }
            UIFont *font = self.placeholderFont;
            if (!font) {
                font = self.font ?: [self pri_defaultFont];
            }
            UIColor *textColor = self.placeholderColor ?:[self pri_placeholderDefaultTextColor];
            attrPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{
                NSFontAttributeName:font,
                NSForegroundColorAttributeName:textColor
            }];
        }
        
        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        
        CGSize size = [attrPlaceholder boundingRectWithSize:self.bounds.size options:options context:nil].size;
        size = CGSizeMake(ceil(size.width), ceil(size.height));
        
        CGRect rect = {.origin = CGPointZero,.size = size};
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        [attrPlaceholder drawInRect:rect];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.placeholderView.image = image;
        
        UIEdgeInsets textContainerInset = self.textContainerInset;
        CGFloat x = textContainerInset.left + 5;
        CGFloat y = textContainerInset.top;
        self.placeholderView.frame = CGRectMake(x, y, size.width, size.height);
    }] commit];
}

-(void)pri_hiddenPlaceholderView
{
    if (IS_AVAILABLE_NSSTRNG(self.text) || IS_AVAILABLE_ATTRIBUTEDSTRING(self.attributedText)) {
        self.placeholderView.hidden = YES;
    }
    else {
        self.placeholderView.hidden = NO;
    }
}

-(void)pri_didBeginEditingAction:(NSNotification*)notification
{
    if (notification.object == self) {
        if (self.didBeginEditingBlock) {
            self.didBeginEditingBlock(self, notification);
        }
    }
}

-(void)pri_didChangeTextAction:(NSNotification*)notification
{
    if (notification.object == self) {
        [self pri_updateTextAction];
    }
}

-(void)pri_updateTextAction
{
    [self pri_hiddenPlaceholderView];

    CGSize textSize = [self sizeThatFits:self.contentSize];
    if (self.textChangeBlock) {
        self.textChangeBlock(self, textSize);
        textSize = [self sizeThatFits:self.contentSize];
        [self pri_hiddenPlaceholderView];
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
            if (lineCnt > 0 && limitCnt > 0) {
                CGFloat height = frame.size.height;
                if (lineCnt <= limitCnt) {
                    height = textSize.height;
                }
                else {
                    height = limitCnt * [self textLineHeight] + self.textContainerInset.top + self.textContainerInset.bottom;
                }
                frame.size.height = MAX(self.normalHeight, height);
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

-(void)pri_didEndEditingAction:(NSNotification*)notification
{
    if (notification.object == self) {
        [self pri_hiddenPlaceholderView];
        if (self.didEndEditingBlock) {
            self.didEndEditingBlock(self,notification);
        }
    }
}

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
    if (!self.decelerating && !self.tracking && !self.dragging && (self.selectedRange.location >= self.text.length || self.selectedRange.location >= self.attributedText.length)) {
        CGFloat y = self.contentSize.height - self.frame.size.height;
        contentOffset.y = MAX(0, y);
    }
    [super setContentOffset:contentOffset];
}

-(CGFloat)normalHeight
{
    return _normalHeight;
}

-(CGFloat)textLineHeight
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

//- (BOOL)pri_isPasteboardContainsValidValue {
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
////    NSLog(@"pastedboard=%@",pasteboard);
////    NSLog(@"string=%@,strings=%@",pasteboard.string,pasteboard.strings);
//    if (SYSTEMVERSION_NUMBER >= 10.0) {
//        if ([pasteboard hasStrings] ||
//            [pasteboard hasURLs] ||
//            [pasteboard hasImages] ||
//            [pasteboard hasColors]) {
//            return YES;
//        }
//        return NO;
//    }
//    else {
//        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//        if (pasteboard.string.length > 0) {
//            return YES;
//        }
////        if (pasteboard.attributedString.length > 0) {
////            return YES;
////        }
//        return NO;
//    }
//}

//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
//    /*
//     ------------------------------------------------------
//     Default menu actions list:
//     cut:                                   Cut
//     copy:                                  Copy
//     select:                                Select
//     selectAll:                             Select All
//     paste:                                 Paste
//     delete:                                Delete
//     _promptForReplace:                     Replace...
//     _transliterateChinese:                 简⇄繁
//     _showTextStyleOptions:                 BIU
//     _define:                               Define
//     _addShortcut:                          Add...
//     _accessibilitySpeak:                   Speak
//     _accessibilitySpeakLanguageSelection:  Speak...
//     _accessibilityPauseSpeaking:           Pause Speak
//     makeTextWritingDirectionRightToLeft:   ⇋
//     makeTextWritingDirectionLeftToRight:   ⇌
//     
//     ------------------------------------------------------
//     Default attribute modifier list:
//     toggleBoldface:
//     toggleItalics:
//     toggleUnderline:
//     increaseSize:
//     decreaseSize:
//     */
//    BOOL OK = YES;
//    if (self.canPerformActionBlock) {
//        OK = self.canPerformActionBlock(self, action, sender);
//    }
//    else {
//        if (self.enablePerformAction) {
//            NSRange selectedRange = self.selectedRange;
//            if (selectedRange.length == 0) {
//                if (action == @selector(select:) ||
//                    action == @selector(selectAll:)) {
//                    OK = self.text.length > 0;
//                }
//                if (action == @selector(paste:)) {
//                    OK = [self pri_isPasteboardContainsValidValue];
//                }
//            } else {
//                if (action == @selector(cut:)) {
//                    OK = (self.isFirstResponder && self.editable);
//                }
//                if (action == @selector(copy:)) {
//                    OK = YES;
//                }
//                if (action == @selector(selectAll:)) {
//                    OK = (selectedRange.length < self.text.length);
//                }
//                if (action == @selector(paste:)) {
//                    OK = (self.isFirstResponder && self.editable && [self pri_isPasteboardContainsValidValue]);
//                }
//            }
//        }
//    }
////    NSLog(@"action=%@,OK=%@",NSStringFromSelector(action),OK ? @"YES" : @"NO");
//    return OK;
//}

-(void)dealloc
{
    [self pri_registNotification:NO];
}
@end
