//
//  YZHTextView.m
//  YZHAlertViewDemo
//
//  Created by yuan on 2018/8/9.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHTextView.h"
#import "YZHKitType.h"
#import "NSObject+YZHAddForKVO.h"
#import "YZHTransaction.h"

/****************************************************
 *YZHTextViewLimit
 ****************************************************/
@implementation YZHTextViewLimit

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
 *YZHTextView
 ****************************************************/
@interface YZHTextView () <UITextViewDelegate>

/* <#注释#> */
@property (nonatomic, assign) CGSize textSize;

/** <#注释#> */
@property (nonatomic, strong) UIImageView *placeholderView;

/* <#注释#> */
@property (nonatomic, assign) CGSize lastContentSize;

/* <#name#> */
@property (nonatomic, assign) CGFloat normalHeight;

@end

@implementation YZHTextView

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
    self.lineSpacing = 2;
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
        
//        [self hz_addKVOObserver:self forKeyPath:@"selectedRange" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//
//        //selectedTextRange
//        [self hz_addKVOObserver:self forKeyPath:@"selectedTextRange" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
        
//        [self hz_removeKVOObserver:self forKeyPath:@"selectedRange" context:nil];
//
//        [self hz_removeKVOObserver:self forKeyPath:@"selectedTextRange" context:nil];
    }
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
//{
//    if ([keyPath isEqualToString:@"selectedRange"]) {
////        self.contentOffset = self.contentOffset;
//    }
//    else if ([keyPath isEqualToString:@"selectedTextRange"]) {
////        NSLog(@"====change=%@",change);
////        [self pri_updateContentOffsetAction];
//    }
//}

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
    NSMutableAttributedString *tmp = [attributedText mutableCopy];

    if (tmp.length > 0) {
        NSMutableParagraphStyle *style = [[attributedText attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL] mutableCopy];
        if (!style) {
            style = [NSMutableParagraphStyle new];
        }
        style.lineSpacing = self.lineSpacing;
        [tmp addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedText.length)];
    }
    
    [super setAttributedText:tmp];
    
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

-(void)setLineSpacing:(CGFloat)lineSpacing {
    CGFloat oldLineSpacing = lineSpacing;
    _lineSpacing = lineSpacing;
    if (oldLineSpacing != lineSpacing) {
        [self setAttributedPlaceholder:self.attributedText];
    }
}

-(void)pri_updatePlaceholder
{
    [[YZHTransaction transactionWithTransactionId:@"YZHTextView.updatePlaceholder" action:^(YZHTransaction * _Nonnull transaction) {
                
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
        NSString *markText = [self textInRange:self.markedTextRange];
//        NSLog(@"noti.userInfo=%@,markText=%@,attrText=%@",notification.userInfo,markText,self.attributedText.string);
        if (markText.length > 0) {
            return;
        }
        [self setAttributedText:self.attributedText];
//        [self pri_updateTextAction];
    }
}

-(void)pri_updateTextAction
{
    [[YZHTransaction transactionWithTransactionId:@"YZHTextView.updateText" action:^(YZHTransaction * _Nonnull transaction) {
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
    }] commit];
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

-(void)dealloc
{
    [self pri_registNotification:NO];
}
@end
