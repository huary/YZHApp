//
//  YZHAlertView.m
//  yxx_ios
//
//  Created by yuan on 2017/4/11.
//  Copyright © 2017年 yuanzh. All rights reserved.
//

#import "YZHAlertView.h"
#import "YZHButton.h"
#import "YZHKitType.h"
#import <objc/runtime.h>

#define ACTION_CELL_SUBVIEW_TAG             (1234)

#define TOP_ALERT_VIEW_HEIGHT               (STATUS_BAR_HEIGHT + 44)

#define CUSTOM_CELL_VERTICAL_NEW            (1)

#define YZHALERT_VIEW_STYLE_IS_TIPS(STYLE)    (((STYLE) == YZHAlertViewStyleTopInfoTips )|| ((STYLE) == YZHAlertViewStyleTopWarningTips))

#define YZHALERT_VIEW_STYLE_IS_ALERT(STYLE)   (((STYLE) == YZHAlertViewStyleAlertInfo )|| ((STYLE) == YZHAlertViewStyleAlertEdit) || ((STYLE) == YZHAlertViewStyleAlertForce))

#define YZHALERT_VIEW_STYLE_IS_SHEET(STYLE)   ((STYLE) == YZHAlertViewStyleActionSheet)

#define YZHALERT_ACTION_STYLE_IS_HEAD(ACTION_STYLE)   ((ACTION_STYLE) == YZHAlertActionStyleHeadTitle || (ACTION_STYLE) == YZHAlertActionStyleHeadMessage)

#define YZHALERT_ACTION_STYLE_IS_INFO_SUPPORT(ACTION_STYLE) ((!YZHALERT_ACTION_STYLE_IS_HEAD(ACTION_STYLE)) && (ACTION_STYLE) != YZHAlertActionStyleTextEdit && (ACTION_STYLE) != YZHAlertActionStyleTextViewWrite && (ACTION_STYLE) != YZHAlertActionStyleTextViewRW)

#define YZHALERT_ACTION_STYLE_IS_SHEET_SUPPORT(ACTION_STYLE)  ((!YZHALERT_ACTION_STYLE_IS_HEAD(ACTION_STYLE)) /*&& (ACTION_STYLE) != YZHAlertActionStyleCancel && (ACTION_STYLE) != YZHAlertActionStyleTextEdit*/)

#define YZHALERT_ACTION_STYLE_CAN_LAYOUT(ACTION_STYLE)        (TYPE_AND(ACTION_STYLE,YZHAlertActionStyleMask) == YZHAlertActionStyleCancel || TYPE_AND(ACTION_STYLE,YZHAlertActionStyleMask) == YZHAlertActionStyleConfirm || TYPE_AND(ACTION_STYLE,YZHAlertActionStyleMask) == YZHAlertActionStyleDestructive)

#define YZHALERT_ACTION_STYLE_SHOULD_LAYOUT(ACTION_STYLE,LAYOUT_STYLE)     (YZHALERT_ACTION_STYLE_CAN_LAYOUT(ACTION_STYLE) && (LAYOUT_STYLE) == YZHAlertActionCellLayoutStyleHorizontal)

#define YZHALERT_ACTION_STYLE_IS_TEXTVIEW(ACTION_STYLE)   ((ACTION_STYLE) == YZHAlertActionStyleTextViewRead || (ACTION_STYLE) == YZHAlertActionStyleTextViewWrite || (ACTION_STYLE) == YZHAlertActionStyleTextViewRW)

#define YZHALERT_ACTION_STYLE_IS_EDIT(ACTION_STYLE)       (YZHALERT_ACTION_STYLE_IS_TEXTVIEW(ACTION_STYLE) || (ACTION_STYLE) == YZHAlertActionStyleTextEdit)

static const CGFloat defaultYZHAlertViewStyleAlertAnimateDuration             = 0.8;
static const CGFloat defaultYZHAlertViewStyleTopTipsAnimateDuration           = 0.3;
static const CGFloat defaultYZHAlertViewStyleActionSheetAnimateDuration       = 0.3;

static const CGFloat UIAlertViewWidthWithScreenWidthRatio                       = 0.7;
static const CGFloat UIAlertViewLandscapeWidthWithScreenWidthRatio              = 0.4;
static const UIEdgeInsets defaultYZHAlertViewSubViewEdgeInsets                = {.top=10,.left=10,.bottom=10,.right=10};
static const CGFloat defaultYZHAlertViewCellHeight                            = 50;
static const CGFloat defaultYZHAlertViewHeadTitleHeight                       = 50;//55;
static const CGFloat defaultYZHAlertViewHeadMessageHeight                     = 50;
static const CGFloat defaultYZHAlertViewCellTextViewHeight                    = 80;
static const CGFloat defaultYZHAlertViewCellSeparatorLineWidth                = 1.0;

static const CGFloat defaultYZHAlertViewCellTextFontSize                      = 16.0;
static const CGFloat defaultYZHAlertViewCellHeadTitleTextFontSize             = 18.0;
static const CGFloat defaultYZHAlertViewCellHeadMessageTextFontSize           = 16.0;

static const CGFloat defaultYZHAlertViewCellCancelConfirmDestructiveTextFontSize     = 18.0;

static const CGFloat defaultYZHAlertViewCoverAlpha                            = 0.1;

static const CGFloat defaultYZHAlertViewSheetCancelCellTopLineWidth           = 8.0;

/********************************************************************************
 * UIView (RowIndex)
 ********************************************************************************/
@interface UIView (YZHAlertActionCellRowIndex)

@property (nonatomic, assign) NSInteger rowIndex;

@end

@implementation UIView (YZHAlertActionCellRowIndex)

-(void)setRowIndex:(NSInteger)rowIndex
{
    objc_setAssociatedObject(self, @selector(rowIndex), @(rowIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)rowIndex
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

@end

/********************************************************************************
 *NSText
 ********************************************************************************/
@interface NSText : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSAttributedString *attributedText;

-(instancetype)initWithTextObj:(id)textObj;
@end


@implementation NSText

-(instancetype)initWithTextObj:(id)textObj
{
    self = [super init];
    if (self) {
        [self _setupValueWithTextObj:textObj];
    }
    return self;
}

-(void)_setupValueWithTextObj:(id)textObj
{
    if ([textObj isKindOfClass:[NSString class]]) {
        self.text = (NSString*)textObj;
    }
    else if ([textObj isKindOfClass:[NSAttributedString class]])
    {
        self.attributedText = (NSAttributedString*)textObj;
    }
}

@end

/********************************************************************************
 *YZHAlertActionModel
 ********************************************************************************/

@implementation YZHAlertActionModel

-(YZHAlertActionTextStyle)textStyle
{
    id checkObj = self.actionTitleText;
    
    if ([checkObj isKindOfClass:[NSString class]]) {
        return YZHAlertActionTextStyleNormal;
    }
    else if ([checkObj isKindOfClass:[NSAttributedString class]])
    {
        return YZHAlertActionTextStyleAttribute;
    }
    else
    {
        return YZHAlertActionTextStyleNull;
    }
}
@end

typedef NS_ENUM(NSInteger, NSAlertActionCellType)
{
    NSAlertActionCellTypeTextLabel  = 0,
    NSAlertActionCellTypeTextField  = 1,
    NSAlertActionCellTypeCustomView = 2,
    NSAlertActionCellTypeTextView   = 3,
};


/********************************************************************************
 *YZHAlertActionCell
 ********************************************************************************/
@class YZHAlertActionCell;
typedef void(^YZHAlertActionCellContentViewChangeSizeBlock)(YZHAlertActionCell *actionCell);

@interface YZHAlertActionCell : UIControl <UIAlertActionCellProtocol>

@property (nonatomic, assign, readonly) NSAlertActionCellType cellType;

@property (nonatomic, strong, readonly) UIView *customView;

@property (nonatomic, copy, readonly) UIColor *normalColor;
@property (nonatomic, copy) UIColor *highlightColor;

@property (nonatomic, strong) YZHAlertActionModel *actionModel;

@property (nonatomic, weak) YZHAlertView *alertView;

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

//contentView正常显示时的大小
@property (nonatomic, assign) CGSize contentViewNMSize;
//contentView最大显示大小
@property (nonatomic, assign) CGSize contentViewMaxSize;
/* <#注释#> */
@property (nonatomic, copy) YZHAlertActionCellContentViewChangeSizeBlock contentViewSizeChangeBlock;


#pragma mark UIAlertActionCellProtocol
@property (nonatomic, assign) CGRect cellFrame;
@property (nonatomic, assign, readonly) CGSize cellMaxSize;
@property (nonatomic, assign, readonly) NSInteger cellIndex;

@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UITextView *textView;
@property (nonatomic, strong, readonly) UITextField *editTextField;

//这里传进来的frame中的size是alertCell最大可以的size
-(instancetype)initWithAlertActionModel:(YZHAlertActionModel*)actionModel cellFrame:(CGRect)cellFrame atCellIndex:(NSInteger)cellIndex;

@end

@implementation YZHAlertActionCell

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefaultValue];
    }
    return self;
}

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
    _cellIndex = -1;
    _edgeInsets = defaultYZHAlertViewSubViewEdgeInsets;
}

-(instancetype)initWithAlertActionModel:(YZHAlertActionModel*)actionModel cellFrame:(CGRect)cellFrame atCellIndex:(NSInteger)cellIndex
{
    self = [self init];
    if (self) {
        _cellFrame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, cellFrame.size.width-cellFrame.origin.x, cellFrame.size.height);
        _cellMaxSize = cellFrame.size;
        _cellIndex = cellIndex;
        self.clipsToBounds = YES;
        self.actionModel = actionModel;
    }
    return self;
}

-(UILabel*)_createAlertHeadLabelWithActionModel:(YZHAlertActionModel*)actionModel
{
    if (actionModel == nil || !YZHALERT_ACTION_STYLE_IS_HEAD(actionModel.actionStyle)) {
        return nil;
    }
    UILabel *headLabel = [[UILabel alloc] init];
    headLabel.textAlignment = NSTextAlignmentCenter;
    headLabel.tag = ACTION_CELL_SUBVIEW_TAG;
    headLabel.numberOfLines = 0;
    if (actionModel.textStyle == YZHAlertActionTextStyleAttribute) {
        headLabel.attributedText = actionModel.actionTitleText;
    }
    else
    {
        headLabel.text = actionModel.actionTitleText;
    }
    
    [self addTarget:self action:@selector(_controlAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:headLabel];
    return headLabel;
}

-(UILabel*)_createAlertInfoCellWithActionModel:(YZHAlertActionModel*)actionModel
{
    if (actionModel == nil || actionModel.actionStyle == YZHAlertActionStyleTextEdit) {
        return nil;
    }
    
    UILabel *infoCell = [[UILabel alloc] init];
    infoCell.textAlignment = NSTextAlignmentCenter;
    infoCell.tag = ACTION_CELL_SUBVIEW_TAG;
    infoCell.numberOfLines = 0;

    if (actionModel.textStyle == YZHAlertActionTextStyleAttribute) {
        infoCell.attributedText = actionModel.actionTitleText;
    }
    else
    {
        infoCell.text = actionModel.actionTitleText;
        CGFloat fontSize= defaultYZHAlertViewCellTextFontSize;
        if (actionModel.actionStyle == YZHAlertActionStyleDefault) {
            infoCell.textColor = BLACK_COLOR;
            infoCell.font = SYS_FONT(fontSize);
        }
        else if (actionModel.actionStyle == YZHAlertActionStyleCancel)
        {
            infoCell.textColor = BLUE_COLOR;
            infoCell.font = BOLD_SYS_FONT(fontSize);
        }
        else if (actionModel.actionStyle == YZHAlertActionStyleDestructive)
        {
            infoCell.textColor = RED_COLOR;
            infoCell.font = BOLD_SYS_FONT(fontSize);
        }
    }

    [self addTarget:self action:@selector(_controlAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:infoCell];
    return infoCell;
}

-(UITextField*)_createAlertEditCellWithActionModel:(YZHAlertActionModel*)actionModel
{
    if (actionModel.actionStyle != YZHAlertActionStyleTextEdit) {
        return nil;
    }
    UITextField *editCell = [[UITextField alloc] init];
    editCell.tag = ACTION_CELL_SUBVIEW_TAG;

    if (actionModel.textStyle == YZHAlertActionTextStyleAttribute) {
        editCell.attributedPlaceholder = actionModel.actionTitleText;
    }
    else
    {
        editCell.placeholder = actionModel.actionTitleText;
    }
    
    [self addSubview:editCell];
    return editCell;
}

-(YZHTextView*)_createAlertTextViewCellWithActionModel:(YZHAlertActionModel*)actionModel
{
    if (!YZHALERT_ACTION_STYLE_IS_TEXTVIEW(actionModel.actionStyle)) {
        return nil;
    }
    YZHTextView *textView = [[YZHTextView alloc] init];
    textView.tag = ACTION_CELL_SUBVIEW_TAG;
    textView.editable = YES;
    
    if (actionModel.actionStyle == YZHAlertActionStyleTextViewRead || actionModel.actionStyle == YZHAlertActionStyleTextViewRW) {
        if (actionModel.textStyle == YZHAlertActionTextStyleAttribute) {
            textView.attributedText = actionModel.actionTitleText;
        }
        else
        {
            textView.text = actionModel.actionTitleText;
        }
        if (actionModel.actionStyle == YZHAlertActionStyleTextViewRead) {
            textView.editable = NO;
        }
    }
    else if (actionModel.actionStyle == YZHAlertActionStyleTextViewWrite) {
        if (actionModel.textStyle == YZHAlertActionTextStyleAttribute) {
            textView.attributedPlaceholder = actionModel.actionTitleText;
        }
        else
        {
            textView.placeholder = actionModel.actionTitleText;
        }
    }
    [self addSubview:textView];
    WEAK_SELF(weakSelf);
    textView.contentSizeChangeBlock = ^(YZHTextView *textView, CGSize lastContentSize) {
        [weakSelf _changeTextViewSizeAction:textView];
    };
    
//    textView.textSizeChangeBlock = ^(YZHTextView *textView, CGSize textSize) {
//        [weakSelf _changeTextViewSizeAction:textView];
//    };
    
//    textView.textChangeBlock = ^(YZHTextView *textView, CGSize textSize) {
//        [weakSelf _changeTextViewSizeAction:textView];
//    };
    
    return textView;
}


-(void)_changeTextViewSizeAction:(YZHTextView *)textView
{
    CGRect frame = self.frame;
    if (CGRectIsEmpty(frame)) {
        return;
    }
//    CGSize contentSize = [textView sizeThatFits:textView.contentSize];//textView.contentSize;
    CGSize contentSize = textView.contentSize;
    
    CGFloat w = textView.bounds.size.width;
    CGFloat h = contentSize.height;

    [self updateAlertActionCellContentViewSize:CGSizeMake(w, h)];    
}

-(UIView*)_createAlertCustomCellWithActionModel:(YZHAlertActionModel*)actionModel
{
    if (!TYPE_AND(actionModel.actionStyle, YZHAlertActionStyleCustomMask)) {
        return nil;
    }
    if (!actionModel.customCellBlock) {
        return nil;
    }
    UIView *customView = actionModel.customCellBlock(actionModel, self);
    customView.tag = ACTION_CELL_SUBVIEW_TAG;
    [self addSubview:customView];
    
    [self addTarget:self action:@selector(_controlAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return customView;
}

-(void)_controlAction:(UIControl*)control
{
    [self.alertView endEditing:YES];
    if (YZHALERT_ACTION_STYLE_IS_HEAD(self.actionModel.actionStyle)) {
        if (self.actionModel.actionBlock) {
            self.actionModel.actionBlock(self.actionModel, [self.alertView getAllAlertActionCellInfo]);
        }
    }
    else
    {
        BOOL dismiss = YES;
        if (self.actionModel && self.actionModel.actionBlock) {
            dismiss = self.actionModel.actionBlock(self.actionModel,[self.alertView getAllAlertActionCellInfo]);
        }
        if (dismiss) {
            [self.alertView dismiss];
        }
    }
}

-(void)_createAlertActionViewForActionModel:(YZHAlertActionModel*)actionModel
{
    if (!actionModel) {
        return;
    }
    
    if (YZHALERT_ACTION_STYLE_IS_HEAD(actionModel.actionStyle)) {
        _textLabel = [self _createAlertHeadLabelWithActionModel:actionModel];
        _cellType = NSAlertActionCellTypeTextLabel;
    }
    else if (actionModel.actionStyle == YZHAlertActionStyleTextEdit)
    {
        _editTextField = [self _createAlertEditCellWithActionModel:actionModel];
        _cellType = NSAlertActionCellTypeTextField;
    }
    else if (TYPE_AND(actionModel.actionStyle, YZHAlertActionStyleCustomMask))
    {
        _customView = [self _createAlertCustomCellWithActionModel:actionModel];
        _cellType = NSAlertActionCellTypeCustomView;
        _edgeInsets = UIEdgeInsetsZero;
    }
    else if (YZHALERT_ACTION_STYLE_IS_TEXTVIEW(actionModel.actionStyle)) {
        _textView = [self _createAlertTextViewCellWithActionModel:actionModel];
        _cellType = NSAlertActionCellTypeTextView;
    }
    else
    {
        _textLabel = [self _createAlertInfoCellWithActionModel:actionModel];
        _cellType = NSAlertActionCellTypeTextLabel;
    }
}

-(void)setActionModel:(YZHAlertActionModel *)actionModel
{
    _actionModel = actionModel;
    [self _createAlertActionViewForActionModel:actionModel];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView *subView = [self viewWithTag:ACTION_CELL_SUBVIEW_TAG];
    CGRect frame = self.frame;
    
    CGRect newFrame = [self getCellContentFrameForCellSize:frame.size];
    
    if (TYPE_AND(self.actionModel.actionStyle, YZHAlertActionStyleCustomMask))
    {
//        subView.frame = self.bounds;
    }
    else
    {
        subView.frame = newFrame;
    }
}

-(CGRect)getCellContentFrameForCellSize:(CGSize)cellSize
{
    UIEdgeInsets edgeInsets = self.edgeInsets;
    CGFloat x = edgeInsets.left;
    CGFloat y = edgeInsets.top;
    CGFloat w = cellSize.width - edgeInsets.left - edgeInsets.right;
    CGFloat h = cellSize.height - edgeInsets.top - edgeInsets.bottom;
    
    w = MAX(w, 0);
    h = MAX(h, 0);
    
    return CGRectMake(x, y, w, h);
}

-(CGSize)getCellSizeForCellContentSize:(CGSize)cellContentSize
{
    UIEdgeInsets edgeInsets = self.edgeInsets;
    CGFloat w = edgeInsets.left + cellContentSize.width + edgeInsets.right;
    CGFloat h = edgeInsets.top + cellContentSize.height + edgeInsets.bottom;
    return CGSizeMake(w, h);
}

-(CGSize)getCellLabelFitSizeForCellMaxSize:(CGSize)cellMaxSize
{
    CGSize size = [self getCellContentFrameForCellSize:cellMaxSize].size;
    CGSize labelSize = [self.textLabel sizeThatFits:size];
    CGFloat w = cellMaxSize.width;
    CGFloat h = labelSize.height + self.edgeInsets.top + self.edgeInsets.bottom;
    return CGSizeMake(w, h);
}

-(void)adjustCellContentEdgeInsetsWithCellContentSize:(CGSize)cellContentSize cellSize:(CGSize)cellSize
{
    if (self.cellType == NSAlertActionCellTypeCustomView) {
        self.edgeInsets = UIEdgeInsetsZero;
        return;
    }
    CGSize size = [self getCellContentFrameForCellSize:cellSize].size;
    UIEdgeInsets edgeInsets = self.edgeInsets;
    if (cellContentSize.width < size.width) {
        edgeInsets.left = edgeInsets.right = (cellSize.width - cellContentSize.width)/2;
    }
    if (cellContentSize.height < size.height) {
        edgeInsets.top = edgeInsets.bottom = (cellSize.height - cellContentSize.height)/2;
    }
    self.edgeInsets = edgeInsets;
}

//更新contentView的size
-(void)updateAlertActionCellContentViewSize:(CGSize)contentSize
{
    if (CGSizeEqualToSize(self.contentViewMaxSize, CGSizeZero)) {
        return;
    }
    if (self.contentViewMaxSize.height < self.contentViewNMSize.height) {
        return;
    }
    CGRect frame = self.frame;
    CGFloat height = MAX(contentSize.height, self.contentViewNMSize.height);
    height = MIN(height, self.contentViewMaxSize.height);
    CGFloat cellHeight = height + self.edgeInsets.top + self.edgeInsets.bottom;
    CGFloat cellWidth = frame.size.width;
    
    [self adjustCellContentEdgeInsetsWithCellContentSize:CGSizeMake(contentSize.width, height) cellSize:CGSizeMake(cellWidth, cellHeight)];

    if (cellHeight != frame.size.height) {
        frame.size.height = cellHeight;
        self.frame = frame;
        if (self.contentViewSizeChangeBlock) {
            self.contentViewSizeChangeBlock(self);
        }
    }
}

#pragma mark override
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _normalColor = self.backgroundColor;
    if (self.highlightColor) {
        self.backgroundColor = self.highlightColor;
    }
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:self];
    if (!CGRectContainsPoint(self.bounds, point)) {
        self.backgroundColor = self.normalColor;
        return NO;
    }
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.backgroundColor = self.normalColor;
}

-(void)cancelTrackingWithEvent:(UIEvent *)event
{
    self.backgroundColor = self.normalColor;
}

@end


@interface YZHAlertView ()

@property (nonatomic, weak) UIView *showInView;

//cover
@property (nonatomic, strong) UIButton *cover;

// tipsButton
@property (nonatomic, strong) YZHButton *tipsButton;

// tipsBottomLine
@property (nonatomic, strong) UIView *tipsBottomLine;

//alertviewStyle
@property (nonatomic, assign) YZHAlertViewStyle alertViewStyle;

@property (nonatomic, strong) id alertTitle;
@property (nonatomic, strong) id alertMessage;

@property (nonatomic, strong) NSMutableArray<YZHAlertActionModel*> *actionModels;

//YZHAlertViewStyleActionSheet
@property (nonatomic, strong) YZHAlertActionModel *sheetCancelModel;
@property (nonatomic, strong) YZHAlertActionModel *sheetConfirmModel;

@property (nonatomic, assign) BOOL isCreate;

//@property (nonatomic, strong) NSKeyboardManager *keyboardManager;

/* <#注释#> */
@property (nonatomic, strong) NSMutableArray<UIView*> *contentSubViews;

@end

@implementation YZHAlertView

@synthesize effectView = _effectView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alertTitle = nil;
        self.alertMessage = nil;
        self.alertViewStyle = YZHAlertViewStyleAlertInfo;
        [self _setup];
    }
    return self;
}

-(instancetype)initWithTitle:(id)alertTitle alertViewStyle:(YZHAlertViewStyle)alertViewStyle
{
    self = [self initWithTitle:alertTitle alertMessage:nil alertViewStyle:alertViewStyle];
    if (self) {
    }
    return self;
}

-(instancetype)initWithTitle:(id)alertTitle alertMessage:(id)alertMessage alertViewStyle:(YZHAlertViewStyle)alertViewStyle
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.alertTitle = alertTitle;
        self.alertMessage = alertMessage;
        self.alertViewStyle = alertViewStyle;
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    if (self.alertTitle && !self.alertMessage) {
        self.cellHeadTitleMessageHaveSeparatorLine = YES;
    }
    [self _setupDefaultValue];
    [self _setupChildView];
    [self _registerNotification:YES];
}

-(UIView*)effectView
{
    if (YZHALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle)) {
        return nil;
    }
    if (_effectView == nil) {
        if (SYSTEMVERSION_NUMBER > 8.0) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            _effectView = effectView;
        }
        else
        {
            UIToolbar *toolBar = [[UIToolbar alloc] init];
            toolBar.barStyle = UIBarStyleDefault;
            _effectView = toolBar;
        }
    }
    return _effectView;
}

-(void)_setupDefaultValue
{
    self.delayDismissInterval = 0;
    
    //cover
    self.coverColor = BLACK_COLOR;
    self.coverAlpha = defaultYZHAlertViewCoverAlpha;
    
    //height
    self.cellHeight = defaultYZHAlertViewCellHeight;
    self.cellHeadTitleHeight = defaultYZHAlertViewHeadTitleHeight;
    self.cellHeadMessageHeight = defaultYZHAlertViewHeadMessageHeight;
    self.cellTextViewHeight = defaultYZHAlertViewCellTextViewHeight;
    self.cellSeparatorLineWidth = defaultYZHAlertViewCellSeparatorLineWidth/SCREEN_SCALE;
    
    //color
    self.cellBackgroundColor = [WHITE_COLOR colorWithAlphaComponent:0.8];
    self.cellHighlightColor = CLEAR_COLOR;
    self.cellSeparatorLineColor = RGB_WITH_INT_WITH_NO_ALPHA(0x999999);//[BLACK_COLOR colorWithAlphaComponent:0.8];
    self.cellEditBackgroundColor = GROUP_TABLEVIEW_BG_COLOR;
    self.cellHeadTitleBackgroundColor = self.cellBackgroundColor;
    self.cellHeadMessageBackgroundColor = self.cellBackgroundColor;
    
    //textColor
    self.cellTextColor = BLACK_COLOR;
    self.cellEditTextColor = BLACK_COLOR;
    self.cellConfirmTextColor = BLACK_COLOR;
    self.cellHeadTitleTextColor = BLACK_COLOR;
    self.cellHeadMessageTextColor = BLACK_COLOR;
    
    //font
    self.cellTextFont = SYS_FONT(defaultYZHAlertViewCellTextFontSize);
    self.cellEditTextFont = SYS_FONT(defaultYZHAlertViewCellTextFontSize);
    self.cellHeadTitleTextFont = BOLD_SYS_FONT(defaultYZHAlertViewCellHeadTitleTextFontSize);
    self.cellHeadMessageTextFont = SYS_FONT(defaultYZHAlertViewCellHeadMessageTextFontSize);
    
    self.cellCancelTextFont = BOLD_SYS_FONT(defaultYZHAlertViewCellCancelConfirmDestructiveTextFontSize);
    self.cellConfirmTextFont = self.cellCancelTextFont;
    self.cellDestructiveTextFont = self.cellCancelTextFont;
    
    self.cellEditSecureTextEntry = NO;
    
    if (YZHALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle)) {
        self.animateDuration = defaultYZHAlertViewStyleTopTipsAnimateDuration;
        
        self.cellHeadTitleTextColor = BLACK_COLOR;
        self.cellHeadTitleTextFont = SYS_FONT(defaultYZHAlertViewCellTextFontSize);
        
        self.cellHeadTitleHighlightTextFont = self.cellHeadTitleTextFont;
        self.cellHeadTitleHighlightTextColor = RED_COLOR;
        
        self.cellHeadImageName = @"alert_info";
        self.cellHeadHighlightImageName = @"chat_warning";
    }
    else if (YZHALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle))
    {
        self.animateDuration = defaultYZHAlertViewStyleAlertAnimateDuration;
    }
    else if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
    {
        //only for sheet
        self.sheetCancelCellTopLineWidth = defaultYZHAlertViewSheetCancelCellTopLineWidth;
        self.sheetCancelCellTopLineColor = CLEAR_COLOR;

        self.animateDuration = defaultYZHAlertViewStyleActionSheetAnimateDuration;
    }
}

-(void)_setupChildView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = YES;
    
    if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle)) {
        self.backgroundColor = CLEAR_COLOR;

        [self addSubview:self.effectView];
    }
    else if (YZHALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle))
    {
        self.backgroundColor = WHITE_COLOR;
        
        YZHButton *tipsButton = [YZHButton buttonWithType:UIButtonTypeCustom];
        tipsButton.layoutStyle = NSButtonLayoutStyleLR | NSButtonLayoutStyleCustomSpace;
        tipsButton.imageTitleSpace = 10;
        tipsButton.userInteractionEnabled = NO;
        tipsButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:tipsButton];
        self.tipsButton = tipsButton;
        
        UIView *tipsBottomLine = [UIView new];
        tipsBottomLine.backgroundColor = SINGLE_LINE_COLOR;
        [self addSubview:tipsBottomLine];
        self.tipsBottomLine = tipsBottomLine;
    }
    else if (YZHALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle))
    {
        self.backgroundColor = CLEAR_COLOR;
        [self addSubview:self.effectView];
    }
}

-(UIButton*)cover
{
    if (YZHALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle)) {
        return nil;
    }
    if (self.outSideUserInteractionEnabled) {
        return _cover;
    }
    if (_cover == nil) {
        _cover = [UIButton buttonWithType:UIButtonTypeCustom];
        _cover.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _cover.backgroundColor = self.coverColor;
        _cover.alpha = self.coverAlpha;
        [_cover addTarget:self action:@selector(_coverClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cover;
}

-(void)_coverClickAction:(UIButton*)sender
{
    [self endEditing:YES];
    if (self.alertViewStyle == YZHAlertViewStyleAlertForce) {
        return;
    }
    BOOL dismiss = YES;
    if (self.coverActionBlock) {
        dismiss = self.coverActionBlock(nil, [self getAllAlertActionCellInfo]);
    }
    if (dismiss) {
        [self dismiss];
    }
}

-(void)setAlertTitle:(id)alertTitle
{
    _alertTitle = alertTitle;
    if (alertTitle) {
        
        NSText *text = [[NSText alloc] initWithTextObj:alertTitle];
        if (IS_AVAILABLE_NSSTRNG(text.text) || IS_AVAILABLE_ATTRIBUTEDSTRING(text.attributedText)) {
            WEAK_SELF(weakSelf);
            [self _addAlertActionWithoutCheckWithTitle:alertTitle actionStyle:YZHAlertActionStyleHeadTitle actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
                [weakSelf endEditing:YES];
                return YES;
            }];
        }
    }
}

-(void)setAlertMessage:(id)alertMessage
{
    _alertMessage = alertMessage;
    if (alertMessage) {
        NSText *text = [[NSText alloc] initWithTextObj:alertMessage];
        if (IS_AVAILABLE_NSSTRNG(text.text) || IS_AVAILABLE_ATTRIBUTEDSTRING(text.attributedText)) {
            WEAK_SELF(weakSelf);
            [self _addAlertActionWithoutCheckWithTitle:alertMessage actionStyle:YZHAlertActionStyleHeadMessage actionBlock:^BOOL(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo) {
                [weakSelf endEditing:YES];
                return YES;
            }];
        }
    }
}

-(void)setCustomContentAlertView:(UIView *)customContentAlertView
{
    if (_customContentAlertView != customContentAlertView) {
        _customContentAlertView = customContentAlertView;
        if (customContentAlertView) {
            [self addSubview:customContentAlertView];
        }
    }
//    self.animateDuration = defaultYZHAlertViewStyleCustomViewAnimateDuration;
}

-(void)setOutSideUserInteractionEnabled:(BOOL)outSideUserInteractionEnabled
{
    _outSideUserInteractionEnabled = outSideUserInteractionEnabled;
    if (self.cover && outSideUserInteractionEnabled) {
        [self.cover removeFromSuperview];
        self.cover = nil;
    }
}

-(UIView*)_createSeparatorLineWithFrame:(CGRect)frame lineColor:(UIColor*)lineColor
{
    UIView *line = [UIView new];
    line.frame = frame;
    line.backgroundColor = lineColor;
    
    return line;
}

-(void)_addLayoutActionForFoce
{
    if (self.alertViewStyle == YZHAlertViewStyleAlertForce) {
        __block BOOL needToAdd = YES;
        [self.actionModels enumerateObjectsUsingBlock:^(YZHAlertActionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (YZHALERT_ACTION_STYLE_CAN_LAYOUT(obj.actionStyle))
            {
                needToAdd = NO;
                *stop = YES;
            }
        }];
        if (needToAdd) {
            NSInteger index = self.actionModels.count;
            NSString *cancelId = [NSString stringWithFormat:@"%@",@(index)];
            NSString *confirmId = [NSString stringWithFormat:@"%@",@(index+1)];
            [self addAlertActionWithActionId:cancelId actionTitle:NSLOCAL_STRING(@"取消") actionStyle:YZHAlertActionStyleCancel actionBlock:self.forceActionBlock];
            [self addAlertActionWithActionId:confirmId actionTitle:NSLOCAL_STRING(@"确定") actionStyle:YZHAlertActionStyleConfirm actionBlock:self.forceActionBlock];
            self.actionCellLayoutStyle = YZHAlertActionCellLayoutStyleHorizontal;
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.bounds.size;
    if (self.customContentAlertView) {
        self.customContentAlertView.frame = CGRectMake(0, 0, size.width, size.height);
    }
    self.effectView.frame = self.bounds;
}

-(BOOL)_haveTransformYAnimated
{
    return self.animateDuration > 0;
}

-(NSMutableArray<UIView*>*)contentSubViews
{
    if (_contentSubViews == nil) {
        _contentSubViews = [NSMutableArray array];
    }
    return _contentSubViews;
}

-(void)_createAlertActionCellWithShowInView:(UIView*)showInView;
{
    if (self.isCreate) {
        return;
    }
    self.isCreate = YES;
    self.showInView = showInView;
    CGSize showInViewSize = showInView.bounds.size;
    CGFloat widthRatio = UIAlertViewWidthWithScreenWidthRatio;
    if (UIInterfaceOrientationIsLandscape(STATUS_BAR_ORIENTATION)) {
        widthRatio = UIAlertViewLandscapeWidthWithScreenWidthRatio;
    }
    CGFloat contentWidth = showInViewSize.width * widthRatio;
    
    CGFloat contentHeight = 0;
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero) == NO && YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle) == NO) {
        contentWidth = self.bounds.size.width;
        contentHeight = self.bounds.size.height;
    }
    if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle)) {
        contentWidth = showInViewSize.width;
        contentHeight = 0;
    }
    
    if (self.customContentAlertView) {
        self.customContentAlertView.frame = CGRectMake(0, 0, contentWidth, contentHeight);
    }
    
    if (YZHALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle) || YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
    {
        if (self.customContentAlertView == nil) {
            [self _addLayoutActionForFoce];
        }
        __block CGFloat totalY = 0;
        __block CGFloat totalX = 0;
        __block CGFloat lastY = 0;
#if !CUSTOM_CELL_VERTICAL_NEW
        __block CGFloat cTotalX = 0;
        __block CGFloat cLastY = 0;
#endif
        
        CGFloat cellHeight = self.cellHeight;
        CGFloat headTitleHeight = self.cellHeadTitleHeight;
        CGFloat headMessageHeight = self.cellHeadMessageHeight;
        CGFloat lineHeight = self.cellSeparatorLineWidth;
        UIColor *lineColor = self.cellSeparatorLineColor;
        
        if (self.customContentAlertView == nil) {
            [self.contentSubViews removeAllObjects];
            self.contentSubViews = nil;
            NSInteger cnt = self.actionModels.count;
            __block NSInteger rowIndex = 0;
            [self.actionModels enumerateObjectsUsingBlock:^(YZHAlertActionModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CGRect cellFrame = CGRectMake(totalX, totalY, contentWidth, contentHeight);
                YZHAlertActionCell *cell = [[YZHAlertActionCell alloc] initWithAlertActionModel:obj cellFrame:cellFrame atCellIndex:idx];
                cell.alertView = self;
                
                if (cell.cellType == NSAlertActionCellTypeTextLabel) {
                    cell.backgroundColor = self.cellBackgroundColor;
                    if (obj.textStyle != YZHAlertActionTextStyleAttribute) {
                        if (obj.actionStyle == YZHAlertActionStyleHeadTitle) {
                            cell.textLabel.font = self.cellHeadTitleTextFont;
                            cell.textLabel.textColor = self.cellHeadTitleTextColor;
                            cell.backgroundColor = self.cellHeadTitleBackgroundColor;
                        }
                        else if (obj.actionStyle == YZHAlertActionStyleHeadMessage)
                        {
                            cell.textLabel.font = self.cellHeadMessageTextFont;
                            cell.textLabel.textColor =self.cellHeadMessageTextColor;
                            cell.backgroundColor = self.cellHeadMessageBackgroundColor;
                        }
                        else
                        {
                            cell.highlightColor = self.cellHighlightColor;
                            if (obj.actionStyle == YZHAlertActionStyleCancel) {
                                cell.textLabel.font = self.cellCancelTextFont;
                            }
                            else if (obj.actionStyle == YZHAlertActionStyleConfirm)
                            {
                                cell.textLabel.font = self.cellConfirmTextFont;
                            }
                            else if (obj.actionStyle == YZHAlertActionStyleDestructive)
                            {
                                cell.textLabel.font = self.cellDestructiveTextFont;
                            }
                            else
                            {
                                cell.textLabel.font =self.cellTextFont;
                            }
                            
                            if (obj.actionStyle != YZHAlertActionStyleCancel && obj.actionStyle != YZHAlertActionStyleDestructive) {
                                if (obj.actionStyle == YZHAlertActionStyleConfirm) {
                                    cell.textLabel.textColor = self.cellConfirmTextColor;
                                }
                                else {
                                    cell.textLabel.textColor = self.cellTextColor;
                                }
                            }
                        }
                    }
                }
                else if (cell.cellType == NSAlertActionCellTypeTextField)
                {
                    cell.backgroundColor = self.cellBackgroundColor;
                    cell.editTextField.font = self.cellEditTextFont;
                    cell.editTextField.textColor = self.cellEditTextColor;
                    cell.editTextField.backgroundColor = self.cellEditBackgroundColor;
                    if (obj.textStyle == YZHAlertActionTextStyleAttribute) {
                        cell.editTextField.defaultTextAttributes = [cell.editTextField.attributedPlaceholder attributesAtIndex:0 effectiveRange:NULL];
                    }
                    cell.editTextField.secureTextEntry = self.cellEditSecureTextEntry;
                }
                else if (cell.cellType == NSAlertActionCellTypeTextView) {
                    cell.backgroundColor = self.cellBackgroundColor;
                    cell.textView.font = self.cellEditTextFont;
                    cell.textView.textColor = self.cellEditTextColor;
                    cell.textView.backgroundColor = self.cellEditBackgroundColor;
                }
                else if (cell.cellType == NSAlertActionCellTypeCustomView)
                {
                    if (cell.backgroundColor == nil) {
                        cell.backgroundColor = self.cellBackgroundColor;
                    }
                }
                
                WEAK_SELF(weakSelf);
                cell.contentViewSizeChangeBlock = ^(YZHAlertActionCell *actionCell) {
                    [weakSelf updateAlertActionCellsLayout];
                    if (actionCell.actionModel.cellContentViewUpdateAttributedBlock) {
                        actionCell.actionModel.cellContentViewUpdateAttributedBlock(actionCell.actionModel, actionCell);
                    }
                };
                
                BOOL haveContentViewMaxSize = NO;
                if (obj.cellContentViewMaxSizeAttributedBlock) {
                    cell.contentViewMaxSize = obj.cellContentViewMaxSizeAttributedBlock(obj, cell);
                    haveContentViewMaxSize = YES;
                }
                
                CGFloat x = 0;
                CGFloat y = totalY;
                CGFloat width = contentWidth;
                CGFloat height = cellHeight;
                
                if (obj.cellContentViewAttributedBlock) {
                    CGSize contentSize = obj.cellContentViewAttributedBlock(obj, cell);
                    height = contentSize.height + cell.edgeInsets.top + cell.edgeInsets.bottom;
                    [cell adjustCellContentEdgeInsetsWithCellContentSize:contentSize cellSize:CGSizeMake(width, height)];
                }
                else {
                    if (cell.cellType == NSAlertActionCellTypeTextView) {
                        height = self.cellTextViewHeight;
                    }
                }
                
                BOOL haveBottomLine = YES;
                BOOL haveVerticalLine = NO;
                
                if (cell.cellType == NSAlertActionCellTypeCustomView) {
                    x = cell.cellFrame.origin.x;
                    width = cell.cellFrame.size.width;
                    height = cell.cellFrame.size.height;
                    
                    //这里只考虑从totalY开始新的一行，不考虑从原来的行横向后面接新的行
#if CUSTOM_CELL_VERTICAL_NEW
                    y = totalY;
#else
                    //如下考虑到上一行没有占满的情况下，下一行可以在横线后面接入新的行，不太好，也不太准，所以弃用
                    if (width > contentWidth) {
                        width = contentWidth;
                    }
                    CGFloat cTotalXTmp = x + width;
                    if (cTotalXTmp > contentWidth) {
                        x = 0;
                        y = totalY;
                        totalY += height;
                    }
                    else {
                        if (cTotalX == 0) {
                            y = totalY;
                        }
                        else {
                            y = cLastY;
                        }
                        totalY = MAX(y + height, totalY);
                    }
                    cTotalX = cTotalXTmp;
                    cLastY = y;
#endif
                    if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle) && idx + 1 == cnt) {
                        height = [self _adjustSheetCellHeightForCell:cell cellSize:CGSizeMake(width, height)];
                    }
                    totalY += height;
                    ++rowIndex;
                }
                else
                {
#if !CUSTOM_CELL_VERTICAL_NEW
                    cTotalX = 0;
#endif
                    CGFloat attributeCellHeight = -1;
                    if (cell.cellType == NSAlertActionCellTypeTextLabel && obj.textStyle == YZHAlertActionTextStyleAttribute) {
                        /*
                         *如下两种方法都不行，因为NSAttributedString中的font和Label中的font不一致，除非在NSAttributedString指定了所有range的font
                        //方法1、
                        NSAttributedString *attributeString = (NSAttributedString*)obj.actionTitleText;
                        NSDictionary *dict = [attributeString attributesAtIndex:0 effectiveRange:NULL];
                        CGSize labelSizeO = [attributeString.string boundingRectWithSize:CGSizeMake(width * UIAlertViewTextFieldWidthWithBaseWidthRatio, showInViewSize.height) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading  attributes:dict context:nil].size;
                        
                        //方法2
                        CGSize labelSize = [attributeString boundingRectWithSize:CGSizeMake(width * UIAlertViewTextFieldWidthWithBaseWidthRatio, showInViewSize.height) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
                        CGSize labelSize = attributeString.size;
                        */
                        
                        attributeCellHeight = [cell getCellLabelFitSizeForCellMaxSize:CGSizeMake(width, showInViewSize.height)].height;
                    }
                    if (YZHALERT_ACTION_STYLE_SHOULD_LAYOUT(obj.actionStyle, self.actionCellLayoutStyle))
                    {
                        BOOL neetLayoutModel = NO;
                        if (totalX == 0) {
                            if (idx + 1 < cnt) {
                                YZHAlertActionModel *nextModel = self.actionModels[idx+1];
                                if (YZHALERT_ACTION_STYLE_SHOULD_LAYOUT(nextModel.actionStyle, self.actionCellLayoutStyle)) {
                                    neetLayoutModel = YES;
                                }
                            }
                        }
                        else
                        {
                            if (idx >= 1 ) {
                                YZHAlertActionModel *prevModel = self.actionModels[idx-1];
                                if (YZHALERT_ACTION_STYLE_SHOULD_LAYOUT(prevModel.actionStyle, self.actionCellLayoutStyle)) {
                                    neetLayoutModel = YES;
                                }
                            }
                        }
                        
                        if (neetLayoutModel) {
                            haveBottomLine = NO;
                            x = totalX;
                            
                            if (x == 0) {
                                lastY = totalY;
                                totalY += height;
                                haveVerticalLine = YES;
                                ++rowIndex;
                            }
                            y = lastY;
                            width = (contentWidth - lineHeight)/2;
                            totalX = x + width;
                            if (totalX > contentWidth) {
                                totalX = 0;
                                if (idx+1 < cnt) {
                                    haveBottomLine = YES;
                                }
                            }
                        }
                        else
                        {
                            totalY += height;
                            ++rowIndex;
                        }
                    }
                    else if (obj.actionStyle == YZHAlertActionStyleHeadTitle) {
                        height = headTitleHeight;
                        if (attributeCellHeight > height) {
                            height = attributeCellHeight;
                        }
                        haveBottomLine = self.cellHeadTitleMessageHaveSeparatorLine;
                        totalY += height;
                        ++rowIndex;
                    }
                    else if (obj.actionStyle == YZHAlertActionStyleHeadMessage)
                    {
                        height = headMessageHeight;
                        if (attributeCellHeight > height) {
                            height = attributeCellHeight;
                        }
                        haveBottomLine = YES;
                        totalY += height;
                        ++rowIndex;
                    }
                    else if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle) && idx + 1 == cnt) {
                        if (attributeCellHeight > height) {
                            height = attributeCellHeight;
                        }
                        
                        height = [self _adjustSheetCellHeightForCell:cell cellSize:CGSizeMake(width, height)];
                        totalY += height;
                        ++rowIndex;
                    }
                    else
                    {
                        if (attributeCellHeight > height) {
                            height = attributeCellHeight;
                        }
                        totalY += height;
                        ++rowIndex;
                    }
                }
                
                if (idx+1 == cnt) {
                    haveBottomLine = NO;
                }
                
                cell.frame = CGRectMake(x, y, width, height);
                [self addSubview:cell];
                [self.contentSubViews addObject:cell];
                cell.rowIndex = rowIndex;
                cell.contentViewNMSize = [cell getCellContentFrameForCellSize:CGSizeMake(width, height)].size;
                if (haveContentViewMaxSize == NO || cell.contentViewMaxSize.height < cell.contentViewNMSize.height) {
                    cell.contentViewMaxSize = cell.contentViewNMSize;
                }
                
                if (haveBottomLine || haveVerticalLine) {
                    CGFloat lineHeightTmp = lineHeight;
                    UIColor *lineColorTmp = lineColor;
                    if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle)) {
                        if (idx == cnt - 2) {
                            lineHeightTmp = self.sheetCancelCellTopLineWidth;
                            lineColorTmp = self.sheetCancelCellTopLineColor;
                        }
                    }
                    
                    UIView *line = nil;
                    if (haveBottomLine) {
                        CGRect frame = CGRectMake(0, totalY, contentWidth, lineHeightTmp);
                        line = [self _createSeparatorLineWithFrame:frame lineColor:lineColorTmp];
                        totalY += lineHeightTmp;
                        line.rowIndex = 0;
                    }
                    else
                    {
                        CGRect frame = CGRectMake(x+width, y, lineHeightTmp, cellHeight);
                        line = [self _createSeparatorLineWithFrame:frame lineColor:lineColorTmp];
                        totalX += lineHeightTmp;
                        line.rowIndex = cell.rowIndex;
                    }
                    [self addSubview:line];
                    [self.contentSubViews addObject:line];
                }
            }];
            contentHeight = totalY;
        }
        
        if (YZHALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle)) {
            if ([self _haveTransformYAnimated]) {
                self.frame = CGRectMake((showInViewSize.width - contentWidth)/2, -contentHeight, contentWidth, contentHeight);
            }
            else
            {
                self.frame =  CGRectMake((showInViewSize.width - contentWidth)/2, (showInViewSize.height - contentHeight)/2, contentWidth, contentHeight);
            }
        }
        else if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
        {
            if ([self _haveTransformYAnimated]) {
                self.frame = CGRectMake(0, showInViewSize.height, showInViewSize.width, contentHeight);
            }
            else
            {
                self.frame = CGRectMake(0, showInViewSize.height - contentHeight, showInViewSize.width, contentHeight);
            }
        }
        self.effectView.frame = self.bounds;
    }
    else if (YZHALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle))
    {
        self.frame = CGRectMake(0, -TOP_ALERT_VIEW_HEIGHT, showInViewSize.width, TOP_ALERT_VIEW_HEIGHT);
        CGFloat x = 0;
        CGFloat y = STATUS_BAR_HEIGHT;
        CGFloat w = self.bounds.size.width;
        CGFloat h = self.bounds.size.height - y;
        self.tipsButton.frame = CGRectMake(x, y, w, h);
        
        self.tipsBottomLine.frame = CGRectMake(x, self.bounds.size.height - SINGLE_LINE_WIDTH, w, SINGLE_LINE_WIDTH);
        
        NSText *text = [[NSText alloc] initWithTextObj:self.alertTitle];
        if (IS_AVAILABLE_NSSTRNG(text.text)) {
            self.tipsButton.titleLabel.font = self.cellHeadTitleTextFont;
            [self.tipsButton setTitleColor:self.cellHeadTitleTextColor forState:UIControlStateNormal];
            [self.tipsButton setTitle:text.text forState:UIControlStateNormal];
        }
        else if (IS_AVAILABLE_ATTRIBUTEDSTRING(text.attributedText))
        {
            [self.tipsButton setAttributedTitle:text.attributedText forState:UIControlStateNormal];
        }
        UIImage *image = [UIImage imageNamed:self.cellHeadImageName];
        [self.tipsButton setImage:image forState:UIControlStateNormal];
        
        if (self.alertViewStyle == YZHAlertViewStyleTopWarningTips) {
            image = [UIImage imageNamed:self.cellHeadHighlightImageName];
            self.tipsButton.titleLabel.font = self.cellHeadTitleHighlightTextFont;
            [self.tipsButton setTitleColor:self.cellHeadTitleHighlightTextColor forState:UIControlStateNormal];
            [self.tipsButton setImage:image forState:UIControlStateNormal];
        }
    }
}

-(CGFloat)_adjustSheetCellHeightForCell:(YZHAlertActionCell*)cell cellSize:(CGSize)cellSize
{
    CGPoint point = CGPointMake(0, self.showInView.frame.size.height);
    if (!CGRectIsEmpty(cell.frame)) {
        point = CGPointMake(0, CGRectGetMaxY(cell.frame));
        point = [cell.superview convertPoint:point toView:self.showInView];
    }
    
    return [self _adjustSheetCellHeightForCell:cell cellSize:cellSize maxYPoint:point];
}

-(CGFloat)_adjustSheetCellHeightForCell:(YZHAlertActionCell*)cell cellSize:(CGSize)cellSize maxYPoint:(CGPoint)point
{
    if (UIEdgeInsetsEqualToEdgeInsets(SAFE_INSETS, UIEdgeInsetsZero)) {
        return cellSize.height;
    }
    if (self.showInView.superview) {
        point = [self.showInView.superview convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
    }
    CGFloat cellHeight = cellSize.height;
    CGFloat diffHeight = point.y - CGRectGetMaxY(SAFE_FRAME);
    if (diffHeight > 0) {
        UIEdgeInsets insets = cell.edgeInsets;
        insets.bottom += diffHeight;
        cell.edgeInsets = insets;
        cellHeight += diffHeight;
    }
    else {
        UIEdgeInsets insets = cell.edgeInsets;
        insets.bottom = insets.top;
        cell.edgeInsets = insets;
    }
    return cellHeight;
}

-(YZHAlertActionModel*)sheetCancelModel
{
    if (_sheetCancelModel == nil) {
        _sheetCancelModel = [[YZHAlertActionModel alloc] init];
        _sheetCancelModel.actionTitleText = NSLOCAL_STRING(@"取消");
        _sheetCancelModel.actionStyle = YZHAlertActionStyleDefault;
        _sheetCancelModel.actionBlock = self.forceActionBlock;
    }
    return _sheetCancelModel;
}

-(YZHAlertActionModel*)sheetConfirmModel
{
    if (_sheetCancelModel == nil) {
        _sheetCancelModel = [[YZHAlertActionModel alloc] init];
        _sheetCancelModel.actionTitleText = NSLOCAL_STRING(@"确定");
        _sheetCancelModel.actionStyle = YZHAlertActionStyleDefault;
        _sheetCancelModel.actionBlock = self.forceActionBlock;
    }
    return _sheetCancelModel;
}

-(NSMutableArray<YZHAlertActionModel*>*)actionModels
{
    if (_actionModels == nil) {
        _actionModels = [NSMutableArray array];
    }
    return _actionModels;
}

-(BOOL)_canAddAlertActionWithActionStyle:(YZHAlertActionStyle)actionStyle
{
    if (YZHALERT_ACTION_STYLE_IS_HEAD(actionStyle)) {
        return NO;
    }
    if (self.alertViewStyle == YZHAlertViewStyleAlertInfo) {
        if (!YZHALERT_ACTION_STYLE_IS_INFO_SUPPORT(actionStyle)) {
            return NO;
        }
    }
    else if (self.alertViewStyle == YZHAlertViewStyleAlertEdit) {
        
    }
    else if (self.alertViewStyle == YZHAlertViewStyleAlertForce)
    {
        
    }
    else if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
    {
        if (!YZHALERT_ACTION_STYLE_IS_SHEET_SUPPORT(actionStyle)) {
            return NO;
        }
    }
    else
    {
        return NO;
    }
    return YES;
}

-(YZHAlertActionModel *)addAlertActionWithTitle:(id)actionTitle actionStyle:(YZHAlertActionStyle)actionStyle actionBlock:(YZHAlertActionBlock)actionBlock
{
    return [self addAlertActionWithActionId:nil actionTitle:actionTitle actionStyle:actionStyle actionBlock:actionBlock];
}

-(YZHAlertActionModel *)addAlertActionWithActionId:(NSString *)actionId actionTitle:(id)actionTitle actionStyle:(YZHAlertActionStyle)actionStyle actionBlock:(YZHAlertActionBlock)actionBlock
{
    BOOL canAdd = [self _canAddAlertActionWithActionStyle:actionStyle];
    if (canAdd) {
        YZHAlertActionModel *model = [self _addAlertActionWithoutCheckWithTitle:actionTitle actionStyle:actionStyle actionBlock:actionBlock];
        model.actionId = actionId;
        return model;
    }
    return nil;
}

-(YZHAlertActionModel *)addAlertActionWithActionModel:(YZHAlertActionModel *)actionModel
{
    BOOL canAdd = NO;
    if (actionModel) {
        canAdd = [self _canAddAlertActionWithActionStyle:actionModel.actionStyle];
        if (canAdd) {
            [self.actionModels addObject:actionModel];
            return actionModel;
        }
    }
    return nil;
}

-(YZHAlertActionModel *)addAlertActionWithCustomCellBlock:(YZHAlertActionCellCustomViewBlock)customCellBlock actionBlock:(YZHAlertActionBlock)actionBlock
{
    return [self addCustomAlertActionWithStyle:YZHAlertActionStyleCustomCell customCellBlock:customCellBlock actionBlock:actionBlock];
}

-(YZHAlertActionModel *)addCustomAlertActionWithStyle:(YZHAlertActionStyle)actionStyle customCellBlock:(YZHAlertActionCellCustomViewBlock)customCellBlock actionBlock:(YZHAlertActionBlock)actionBlock
{
    if (!TYPE_AND(actionStyle, YZHAlertActionStyleCustomMask)) {
        return nil;
    }
    BOOL canAdd = [self _canAddAlertActionWithActionStyle:actionStyle];
    if (canAdd) {
        YZHAlertActionModel *model = [self _addAlertActionWithoutCheckWithTitle:nil actionStyle:actionStyle actionBlock:actionBlock];
        model.customCellBlock = customCellBlock;
        return model;
    }
    return nil;
}

-(YZHAlertActionModel *)addCustomSheetLastActionWithCustomCellBlock:(YZHAlertActionCellCustomViewBlock)customCellBlock actionBlock:(YZHAlertActionBlock)actionBlock
{
    BOOL canAdd = [self _canAddAlertActionWithActionStyle:YZHAlertActionStyleCustomLastSheetCell];
    if (canAdd) {
        YZHAlertActionModel *model = [self _addAlertActionWithoutCheckWithTitle:nil actionStyle:YZHAlertActionStyleCustomLastSheetCell actionBlock:actionBlock];
        model.customCellBlock = customCellBlock;
        return model;
    }
    return nil;
}

-(YZHAlertActionModel *)_addAlertActionWithoutCheckWithTitle:(id)title actionStyle:(YZHAlertActionStyle)actionStyle actionBlock:(YZHAlertActionBlock)actionBlock
{
    YZHAlertActionModel *model = [[YZHAlertActionModel alloc] init];
    model.actionTitleText = title;
    model.actionStyle = actionStyle;
    model.actionBlock = actionBlock;
    [self.actionModels addObject:model];
    return model;
}

-(CGFloat)_getDefaultAnimateDuration
{
    if (YZHALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle)) {
        return defaultYZHAlertViewStyleTopTipsAnimateDuration;
    }
    else if (YZHALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle))
    {
        return defaultYZHAlertViewStyleAlertAnimateDuration;
    }
    else if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
    {
        return defaultYZHAlertViewStyleActionSheetAnimateDuration;
    }
    return 0;
}

-(void)_addSheetActionModel
{
    YZHAlertActionModel *last = [self.actionModels lastObject];
    if (TYPE_AND(last.actionStyle, YZHAlertActionStyleCustomMask) == YZHAlertActionStyleCustomLastSheetCell) {
        return;
    }
    __block BOOL haveEditStyleAction = NO;
    [self.actionModels enumerateObjectsUsingBlock:^(YZHAlertActionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (YZHALERT_ACTION_STYLE_IS_EDIT(obj.actionStyle)) {
            haveEditStyleAction = YES;
            *stop = YES;
        }
    }];
    
    if (haveEditStyleAction) {
        [self.actionModels addObject:self.sheetConfirmModel];
    }
    else {
        [self.actionModels addObject:self.sheetCancelModel];
    }
}

-(UIView*)_doPrepareShowInView:(UIView*)inView
{
    if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle)) {
        [self _addSheetActionModel];
    }
    UIView *showInView = inView;
    if (!showInView) {
//        showInView = [UIApplication sharedApplication].keyWindow;
        showInView = APP_TOP_WINDOW;
    }
    [self _createAlertActionCellWithShowInView:showInView];
    return self.showInView;
}

-(void)_showInView:(UIView *)inView frame:(CGRect)frame
{
    [self _doPrepareShowInView:inView];
    
    if (CGSizeEqualToSize(frame.size, CGSizeZero)) {
        frame = self.showInView.bounds;
    }
    
    [self.showInView addSubview:self];
    
    self.cover.frame = frame;
    if (self.cover) {
        [self.showInView insertSubview:self.cover belowSubview:self];
    }
    
    void (^showCompletionBlock)(BOOL finished) = ^(BOOL finished){
        if (self.alertViewStyle == YZHAlertViewStyleAlertInfo && self.delayDismissInterval > 0) {
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:self.delayDismissInterval];
        }
//        [self _registerNotification:YES];
        if (self.didShowBlock) {
            self.didShowBlock(self);
        }
    };
    
    if (YZHALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle)) {
        if ([self _haveTransformYAnimated]) {
            CGSize size = self.bounds.size;
            CGFloat translationY = size.height + (self.showInView.bounds.size.height - size.height)/2;
            
            [UIView animateWithDuration:self.animateDuration delay:0 usingSpringWithDamping:0.45 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, translationY);
            } completion:showCompletionBlock];
        }
        else
        {
            showCompletionBlock(YES);
        }
    }
    else if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle))
    {
        self.layer.cornerRadius = 0;
        CGFloat totalHeight = self.bounds.size.height;
        if ([self _haveTransformYAnimated]) {
            [UIView animateWithDuration:self.animateDuration animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, -totalHeight);
            } completion:showCompletionBlock];
        }
        else
        {
            showCompletionBlock(YES);
        }
    }
    else if (YZHALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle))
    {
        self.layer.cornerRadius = 0;
        if ([self _haveTransformYAnimated]) {
            [UIView animateWithDuration:self.animateDuration delay:0 usingSpringWithDamping:0.45 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, TOP_ALERT_VIEW_HEIGHT);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:self.animateDuration delay:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.transform = CGAffineTransformMakeTranslation(0, 0);
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
            }];
        }
        else {
            self.transform = CGAffineTransformMakeTranslation(0, TOP_ALERT_VIEW_HEIGHT);
            dispatch_after_in_main_queue(1, ^{
                self.transform = CGAffineTransformMakeTranslation(0, 0);
                [self removeFromSuperview];
            });
        }
    }
}

-(void)alertShowInView:(UIView*)inView
{
    [self _showInView:inView frame:CGRectZero];
}

-(void)_prepareAnimation:(BOOL)animated
{
    if (!animated) {
        self.animateDuration = 0;
    }
    else
    {
        if (self.animateDuration <= 0.01) {
            self.animateDuration = [self _getDefaultAnimateDuration];
        }
    }
}

-(void)alertShowInView:(UIView *)inView animated:(BOOL)animated
{
    [self _prepareAnimation:animated];
    [self alertShowInView:inView];
}

-(void)alertShowInView:(UIView *)inView frame:(CGRect)frame
{
    [self _showInView:inView frame:frame];
}

-(void)alertShowInView:(UIView *)inView frame:(CGRect)frame animated:(BOOL)animated
{
    [self _prepareAnimation:animated];
    [self _showInView:inView frame:frame];
}

-(void)_dispatchCompletionAction:(BOOL)finished
{
//    NSLog(@"self=%@,showInView=%@,supperView=%@",self,self.showInView,self.showInView.superview);
    if (self.dismissCompletionBlock) {
        self.dismissCompletionBlock(self, finished);
    }
}

-(void)_dismissAction
{
    [self.cover removeFromSuperview];
    self.cover = nil;
//    [self.customContentAlertView removeFromSuperview];
    self.customContentAlertView = nil;
    [self _dispatchCompletionAction:YES];
}

-(void)dismiss
{
    [self endEditing:YES];
    
    void (^completionBlock)(BOOL finished) = ^(BOOL finished){
        [self removeFromSuperview];
    };
    
    if (YZHALERT_VIEW_STYLE_IS_ALERT(self.alertViewStyle)) {
        if ([self _haveTransformYAnimated]) {
            CGFloat translationY = self.transform.ty;
            translationY += 40;
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, translationY);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.transform = CGAffineTransformIdentity;
                } completion:completionBlock];
            }];
        }
        else
        {
            completionBlock(YES);
        }
    }
    else if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle)) {
        if ([self _haveTransformYAnimated]) {
            [UIView animateWithDuration:self.animateDuration animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, 0);
            } completion:completionBlock];
        }
        else
        {
            completionBlock(YES);
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
}

-(void)dismissAnimated:(BOOL)animated
{
    if (animated) {
        self.animateDuration = [self _getDefaultAnimateDuration];
    }
    else
    {
        self.animateDuration = 0;
    }
    [self dismiss];
}

-(UIView*)getShowInView
{
    return self.showInView;
}

-(void)updateAlertActionCellsLayout
{
    if (YZHALERT_VIEW_STYLE_IS_TIPS(self.alertViewStyle)) {
        return;
    }
    __block UIView *lastObj = nil;
    __block YZHAlertActionCell *lastCell = nil;
    [self.contentSubViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (lastCell) {
            CGRect frame = obj.frame;
            if (obj.rowIndex == lastCell.rowIndex) {
                frame.origin.y = lastCell.frame.origin.y;
            }
            else {
                frame.origin.y = CGRectGetMaxY(lastObj.frame);
            }
            obj.frame = frame;
        }
        
        if ([obj isKindOfClass:[YZHAlertActionCell class]]) {
            lastCell = (YZHAlertActionCell*)obj;
        }
        lastObj = obj;
    }];
    
    CGFloat height = CGRectGetMaxY(lastObj.frame);
    CGRect frame = self.frame;
    frame.origin.y = frame.origin.y - (height - frame.size.height);
    frame.size.height = height;
    self.frame = frame;
}

-(YZHAlertActionCell*)_alertActionCellForActionModel:(YZHAlertActionModel*)actionModel cellIndex:(NSInteger)cellIndex
{
    __block YZHAlertActionCell *cell = nil;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (NSOBJ_TYPE_IS_CLASS(obj, YZHAlertActionCell)) {
            YZHAlertActionCell *cellTmp = (YZHAlertActionCell*)obj;
            if ((actionModel != nil && cellTmp.actionModel == actionModel) || (actionModel.actionId != nil && [cellTmp.actionModel.actionId isEqualToString:actionModel.actionId]) || (cellIndex >= 0 && cellTmp.cellIndex == cellIndex)) {
                cell = cellTmp;
                *stop = YES;
            }
        }
    }];
    return cell;
}

-(void)updateAlertActionCellForIndex:(NSInteger)index contentSize:(CGSize)contentSize
{
    YZHAlertActionCell *cell = [self _alertActionCellForActionModel:nil cellIndex:index];
    [cell updateAlertActionCellContentViewSize:contentSize];
}

-(void)updateAlertActionCellForActionModel:(YZHAlertActionModel*)actionModel contentSize:(CGSize)contentSize
{
    YZHAlertActionCell *cell = [self _alertActionCellForActionModel:actionModel cellIndex:-1];
    [cell updateAlertActionCellContentViewSize:contentSize];
}

-(void)_registerNotification:(BOOL)regist
{
    if (regist) {
        _keyboardManager = [[YZHKeyboardManager alloc] init];
        self.keyboardManager.relatedShiftView = self;
        self.keyboardManager.firstResponderView = self;
        self.keyboardManager.keyboardMinTopToResponder = 5;
        
        if (YZHALERT_VIEW_STYLE_IS_SHEET(self.alertViewStyle)) {
            WEAK_SELF(weakSelf);
            self.keyboardManager.willShowBlock = ^(YZHKeyboardManager *keyboardManager, NSNotification *keyboardNotification) {
                [weakSelf _adjustSheetLastCellWithKeyboardNotification:keyboardNotification];
            };
            self.keyboardManager.willHideBlock = ^(YZHKeyboardManager *keyboardManager, NSNotification *keyboardNotification) {
                [weakSelf _adjustSheetLastCellWithKeyboardNotification:keyboardNotification];
            };

        }
    }
    else
    {
        self.keyboardManager.relatedShiftView = nil;
        self.keyboardManager.firstResponderView = nil;
        _keyboardManager = nil;
    }
}

-(void)_adjustSheetLastCellWithKeyboardNotification:(NSNotification*)notification
{
    YZHAlertActionModel *actionModel = [self.actionModels lastObject];
    YZHAlertActionCell *cell = [self _alertActionCellForActionModel:actionModel cellIndex:-1];
    CGSize cellSize = cell.bounds.size;
    CGFloat maxY = 0;
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        maxY = frame.size.height + self.keyboardManager.keyboardMinTopToResponder;
    }
    else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        maxY = self.showInView.bounds.size.height;
    }
    [self _adjustSheetCellHeightForCell:cell cellSize:cellSize maxYPoint:CGPointMake(0, maxY)];
    CGSize contentSize = [cell getCellContentFrameForCellSize:cell.bounds.size].size;
    [self updateAlertActionCellForActionModel:actionModel contentSize:contentSize];
}

+(NSArray<YZHAlertView*>*)alertViewsForTag:(NSInteger)tag inView:(UIView*)inView
{
    if (inView == nil) {
//        inView = [UIApplication sharedApplication].keyWindow;
        inView = APP_TOP_WINDOW;
    }
    NSMutableArray *views = [NSMutableArray array];
    for (UIView *view in inView.subviews) {
        if (view.tag == tag && [view isKindOfClass:[self class]]) {
            [views addObject:view];
        }
    }
    return [views copy];
}

+(NSInteger)alertViewCountForTag:(NSInteger)tag inView:(UIView*)inView
{
    return [[self class] alertViewsForTag:tag inView:inView].count;
}

-(void)dealloc
{
    NSLog(@"YZHAlertView-----------dealloc");
    [self _registerNotification:NO];
}

#pragma mark override
-(void)removeFromSuperview
{
    [self _dismissAction];
    [super removeFromSuperview];
}

@end

@implementation YZHAlertView (YZHAlertViewAttributes)

-(YZHAlertActionModel*)alertActionModelForModelIndex:(NSInteger)index
{
    if (index < 0 || index >= self.actionModels.count) {
        return nil;
    }
    YZHAlertActionModel *actionModel = self.actionModels[index];
    return actionModel;
}

-(UIView*)prepareShowInView:(UIView*)inView
{
    return [self _doPrepareShowInView:inView];
}

-(UILabel*)alertTextLabelForAlertActionModel:(YZHAlertActionModel*)actionModel
{
    YZHAlertActionCell *cell = [self _alertActionCellForActionModel:actionModel cellIndex:-1];
    return cell.textLabel;
}

-(UITextView*)alertTextViewForAlertActionModel:(YZHAlertActionModel*)actionModel
{
    YZHAlertActionCell *cell = [self _alertActionCellForActionModel:actionModel cellIndex:-1];
    return cell.textView;
}

-(UITextField*)alertEditTextFieldForAlertActionModel:(YZHAlertActionModel*)actionModel
{
    YZHAlertActionCell *cell = [self _alertActionCellForActionModel:actionModel cellIndex:-1];
    return cell.editTextField;
}

-(UIView*)alertCustomCellSubViewForAlertActionModel:(YZHAlertActionModel*)actionModel
{
    YZHAlertActionCell *cell = [self _alertActionCellForActionModel:actionModel cellIndex:-1];
    return cell.customView;
}

-(UIView*)alertCellContentViewForAlertActionModelIndex:(NSInteger)index
{
    if (index < 0 || index >= self.actionModels.count) {
        return nil;
    }
    YZHAlertActionModel *actionModel = self.actionModels[index];
    
    YZHAlertActionCell *cell = [self _alertActionCellForActionModel:actionModel cellIndex:index];
    if (cell.cellType == NSAlertActionCellTypeTextLabel) {
        return cell.textLabel;
    }
    else if (cell.cellType == NSAlertActionCellTypeTextField)
    {
        return cell.editTextField;
    }
    else if (cell.cellType == NSAlertActionCellTypeCustomView)
    {
        return cell.customView;
    }
    else if (cell.cellType == NSAlertActionCellTypeTextView)
    {
        return cell.textView;
    }
    return cell.textLabel;
}

-(NSDictionary*)getAllAlertEditViewActionModelInfo
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [self.actionModels enumerateObjectsUsingBlock:^(YZHAlertActionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YZHAlertActionCell *cell = [self _alertActionCellForActionModel:obj cellIndex:idx];
        if (cell.cellType == NSAlertActionCellTypeTextField) {
            YZHAlertActionTextStyle textStyle = obj.textStyle;
            if (textStyle == YZHAlertActionTextStyleNormal) {
                obj.alertEditText = cell.editTextField.text;
            }
            else if (textStyle == YZHAlertActionTextStyleAttribute)
            {
                obj.alertEditText = cell.editTextField.attributedText;
            }
            [mutDict setObject:obj forKey:@(cell.cellIndex)];
        }
        else if (cell.cellType == NSAlertActionCellTypeTextView) {
            YZHAlertActionTextStyle textStyle = obj.textStyle;
            if (textStyle == YZHAlertActionTextStyleNormal) {
                obj.alertEditText = cell.textView.text;
            }
            else if (textStyle == YZHAlertActionTextStyleAttribute)
            {
                obj.alertEditText = cell.textView.attributedText;
            }
            [mutDict setObject:obj forKey:@(cell.cellIndex)];
        }
    }];
    return [mutDict copy];
}

-(NSDictionary*)getAllAlertCustomCellViewInfo
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [self.actionModels enumerateObjectsUsingBlock:^(YZHAlertActionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YZHAlertActionCell *cell = [self _alertActionCellForActionModel:obj cellIndex:idx];
        if (cell.cellType == NSAlertActionCellTypeCustomView)
        {
            [mutDict setObject:cell.customView forKey:@(cell.cellIndex)];
        }
    }];
    return [mutDict copy];
}

-(NSDictionary*)getAllAlertActionCellInfo
{
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [self.actionModels enumerateObjectsUsingBlock:^(YZHAlertActionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YZHAlertActionCell *cell = [self _alertActionCellForActionModel:obj cellIndex:idx];
        if (!cell) {
            return ;
        }
        if (cell.cellType == NSAlertActionCellTypeCustomView)
        {
            [mutDict setObject:cell.customView forKey:@(cell.cellIndex)];
        }
        else if (cell.cellType == NSAlertActionCellTypeTextField)
        {
            YZHAlertActionTextStyle textStyle = obj.textStyle;
            if (textStyle == YZHAlertActionTextStyleNormal) {
                obj.alertEditText = cell.editTextField.text;
            }
            else if (textStyle == YZHAlertActionTextStyleAttribute)
            {
                obj.alertEditText = cell.editTextField.attributedText;
            }
            [mutDict setObject:obj forKey:@(cell.cellIndex)];
        }
        else if (cell.cellType == NSAlertActionCellTypeTextView)
        {
            YZHAlertActionTextStyle textStyle = obj.textStyle;
            if (textStyle == YZHAlertActionTextStyleNormal) {
                obj.alertEditText = cell.textView.text;
            }
            else if (textStyle == YZHAlertActionTextStyleAttribute)
            {
                obj.alertEditText = cell.textView.attributedText;
            }
            [mutDict setObject:obj forKey:@(cell.cellIndex)];
        }
    }];
    return [mutDict copy];
}
@end
