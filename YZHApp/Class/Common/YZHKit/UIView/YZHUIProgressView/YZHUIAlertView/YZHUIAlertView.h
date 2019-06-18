//
//  YZHUIAlertView.h
//  yxx_ios
//
//  Created by yuan on 2017/4/11.
//  Copyright © 2017年 yuanzh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUITextView.h"
#import "YZHKeyboardManager.h"

typedef NS_ENUM(NSInteger, YZHUIAlertViewStyle)
{
    //如下所有的都不能支持YZHUIAlertActionStyleHeadTitle和YZHUIAlertActionStyleHeadMessage，由控件本身来负责
    /*点击周边是可以取消的，或者在规定的时间内消失掉
     *ActionStyle 不支持YZHUIAlertActionStyleTextEdit,YZHUIAlertActionStyleTextViewWrite,YZHUIAlertActionStyleTextViewRW
     */
    YZHUIAlertViewStyleAlertInfo        = 0,
    /*点击周边可以消失，但是没有规定的时间消失，是一种编辑的View,但是不仅仅是，可以包含Info所支持的情况
     *这和下面的Force的区别在于不用陈列排布的cell（cancel，confirm，destructive）
     *ActionStyle所支持所有,
     */
    YZHUIAlertViewStyleAlertEdit        = 1,
    /*这种是一种比较严重的错误警告或者提示，必须至少有陈列排布的cell（cancel，confirm，destructive）中的一个
     *ActionStyle支持所有
     */
    YZHUIAlertViewStyleAlertForce       = 2,
    /*是从底部的选项框
     *ActionStyle支持所有
     *如果最后一个Action的style为YZHUIAlertActionStyleCustomLastSheetCell，则不会添加【确定】和【取消】
     *如果所有的Action里面没有actionStyle为TextEdit，则会添加YZHUIAlertActionStyleDefault的【取消】，
     *否则添加YZHUIAlertActionStyleDefault的【确定】
     */
    YZHUIAlertViewStyleActionSheet      = 3,
    /*是从顶部的提示框
     *不可以支持任何的ActionStyle
     */
    YZHUIAlertViewStyleTopInfoTips      = 4,
    /*是从顶部的错误提示框
     *不可以支持任何的ActionStyle
     */
    YZHUIAlertViewStyleTopWarningTips   = 5,
};

typedef NS_ENUM(NSInteger, YZHUIAlertActionStyle)
{
    YZHUIAlertActionStyleMask           = 0XFF,
    YZHUIAlertActionStyleDefault        = 0,
    //不能指定如下两种格式的，这个由控件本身来负责，只可以指定字体，字体颜色，背景色，
    YZHUIAlertActionStyleHeadTitle      = 1,
    YZHUIAlertActionStyleHeadMessage    = 2,
    /*
     *字体可以修改，颜色不可以修改，为蓝色，可以进行陈列排布，
     */
    YZHUIAlertActionStyleCancel         = 3,
    //字体和颜色都可以修改，可以进行陈列排布
    YZHUIAlertActionStyleConfirm        = 4,
    //字体可以修改，颜色不可以修改，为红色，可以进行陈列排布
    YZHUIAlertActionStyleDestructive    = 5,
    //是一种文字编辑的，TextField的控件
    YZHUIAlertActionStyleTextEdit       = 6,
    /*
     *如下的textView
     *YZHUIAlertActionStyleTextViewRead
     *YZHUIAlertActionStyleTextViewWrite
     *YZHUIAlertActionStyleTextViewRW
     *的读写说的并不是严格的是否可以编辑的功能，只是有没有placeHolder或者text的区别
     *
     */
    /*
     *是一种仅仅可以展示的（只读）没有placeHolder，只有text或者attributedText，UITextView的控件，
     *editable为NO
     */
    YZHUIAlertActionStyleTextViewRead   = 8,
    /*
     *是一种仅仅进行编辑的（只写）有placeHolder，可以从0开始编辑text或者attributedText，UITextView的控件，
     *传入的title是placeHolder或者attributedPlaceholder
     *editable为YES
     */
    YZHUIAlertActionStyleTextViewWrite  = 9,
    /*
     *是一种既可以读又可以写的，没有placeHolder，
     *可以从非0开始编辑text,attributedText，开始的text或者attributedText是title，UITextView的控件
     *editable为YES
     */
    YZHUIAlertActionStyleTextViewRW     = 10,
    //自定义actionCell的掩码，支持CustomMark范围内的Cell和以上的进行或运算
    YZHUIAlertActionStyleCustomMask             = 0XF00,
    //自定义的customView
    YZHUIAlertActionStyleCustomCell             = 0X100,
    //自定义Sheet的最后的一个Cell
    YZHUIAlertActionStyleCustomLastSheetCell    = 0X200,
};

typedef NS_ENUM(NSInteger, YZHUIAlertActionCellLayoutStyle)
{
    //default
    YZHUIAlertActionCellLayoutStyleVertical      = 0,
    YZHUIAlertActionCellLayoutStyleHorizontal    = 1,
};

typedef NS_ENUM(NSInteger, YZHUIAlertActionTextStyle)
{
    YZHUIAlertActionTextStyleNull       = -1,
    YZHUIAlertActionTextStyleNormal     = 0,
    YZHUIAlertActionTextStyleAttribute  = 1,
};

@class YZHAlertActionModel;
/********************************************************************************
 *UIAlertActionCellProtocol
 ********************************************************************************/
@protocol UIAlertActionCellProtocol <NSObject>

//这里的cellFrame只接受其中的x,width,height，y坐标会自己计算
@property (nonatomic, assign) CGRect cellFrame;
@property (nonatomic, assign, readonly) CGSize cellMaxSize;
@property (nonatomic, assign, readonly) NSInteger cellIndex;

@property (nonatomic, strong, readonly) UILabel *textLabel;
//YZHUIAlertActionStyleTextView的textView
@property (nonatomic, strong, readonly) UITextView *textView;
//YZHUIAlertActionStyleTextEdit的textField
@property (nonatomic, strong, readonly) UITextField *editTextField;
@end

typedef UIView*(^YZHUIAlertActionCellCustomViewBlock)(YZHAlertActionModel *actionModel, UIView <UIAlertActionCellProtocol>*actionCell);
/*
 *在这个cellContentAttributedblock返回cellContentView的大小或者最大时的大小
 *可以修改cellContentView（UILabel,UITextField,UITextView的属性）
 */
typedef CGSize(^YZHUIAlertActionCellContentViewAttributedBlock)(YZHAlertActionModel *actionModel, UIView <UIAlertActionCellProtocol>*actionCell);
//typedef void(^YZHUIAlertActionCellContentViewUpdateAttributedBlock)(YZHAlertActionModel *actionModel, UIView <UIAlertActionCellProtocol>*actionCell);


@class YZHUIAlertView;
typedef void(^YZHUIAlertDidShowBlock)(YZHUIAlertView *alertView);
typedef void(^YZHUIAlertDismissCompletionBlock)(YZHUIAlertView *alertView, BOOL finished);
/*
 *actionCellInfo中的object 要么是YZHAlertActionModel，要么是UIView<UIAlertActionCellProtocol>的对象
 *返回YES表示block后进行dismiss,NO表示继续停留在当前
 */
typedef BOOL(^YZHUIAlertActionBlock)(YZHAlertActionModel *actionModel, NSDictionary *actionCellInfo);

/********************************************************************************
 *YZHAlertActionModel
 ********************************************************************************/
@interface YZHAlertActionModel : NSObject

//根据这个actionId可以获取到Edit的textField
@property (nonatomic, copy) NSString *actionId;
//actionTitle是NSString或者NSAttributedString,如果是edit的style，则actionTitle就是placeholder
@property (nonatomic, strong) id actionTitleText;

@property (nonatomic, copy) YZHUIAlertActionBlock actionBlock;
@property (nonatomic, assign) YZHUIAlertActionStyle actionStyle;
//自定义的cell的block
@property (nonatomic, copy) YZHUIAlertActionCellCustomViewBlock customCellBlock;
//cell正常显示时content大小的block
@property (nonatomic, copy) YZHUIAlertActionCellContentViewAttributedBlock cellContentViewAttributedBlock;
/*
 *cell扩大显示时content大小的block
 *当前的alertActionCell只有textView的style才会改变cell的高度
 */
@property (nonatomic, copy) YZHUIAlertActionCellContentViewAttributedBlock cellContentViewMaxSizeAttributedBlock;
/*
 *在更改cellContentView大小时的block,返回的size大小不起作用
 */
@property (nonatomic, copy) YZHUIAlertActionCellContentViewAttributedBlock cellContentViewUpdateAttributedBlock;

//alertEditText是NSString或者NSAttributedString
@property (nonatomic, strong) id alertEditText;

//根据actionTitleTex来进行判断
-(YZHUIAlertActionTextStyle)textStyle;
@end


/********************************************************************************
 *YZHUIAlertView
 ********************************************************************************/
@interface YZHUIAlertView : UIView

@property (nonatomic, copy) UIColor *coverColor;
@property (nonatomic, assign) CGFloat coverAlpha;

//effectview
@property (nonatomic, strong, readonly) UIView *effectView;

@property (nonatomic, strong, readonly) YZHKeyboardManager *keyboardManager;

@property (nonatomic, copy) YZHUIAlertActionBlock coverActionBlock;
/*
 *在YZHUIAlertViewStyleAlertForce的style的情况下没有提供action的时候，控件会自动生成action，这个action的block需要开发者指定如下
 *
 */
@property (nonatomic, copy) YZHUIAlertActionBlock forceActionBlock;
//显示完成的回调
@property (nonatomic, copy) YZHUIAlertDidShowBlock didShowBlock;
//消失完成的回调
@property (nonatomic, copy) YZHUIAlertDismissCompletionBlock dismissCompletionBlock;

//这个只针对alert的style才有效
@property (nonatomic, assign) YZHUIAlertActionCellLayoutStyle actionCellLayoutStyle;

/*
 *指定为weak，是怕出现循环应用的问题，可以在dimss时界面循环引用，但是如果没有调用dismiss时
 *或者调用removeFromSupperView(已在removefromsupperview上做解除循环引用)等其他的方法时没法解除循环应用，
 *为了保险起见使用weak(这里支持使用strong，不会出现循环引用问题)
*/
@property (nonatomic, strong) UIView *customContentAlertView;

-(instancetype)initWithTitle:(id)alertTitle alertViewStyle:(YZHUIAlertViewStyle)alertViewStyle;

-(instancetype)initWithTitle:(id)alertTitle alertMessage:(id)alertMessage alertViewStyle:(YZHUIAlertViewStyle)alertViewStyle;
/*
 *这种是不需要加入id的
 */
-(YZHAlertActionModel *)addAlertActionWithTitle:(id)actionTitle actionStyle:(YZHUIAlertActionStyle)actionStyle actionBlock:(YZHUIAlertActionBlock)actionBlock;
/*
 *这种是需要加入id的
 */
-(YZHAlertActionModel *)addAlertActionWithActionId:(NSString *)actionId actionTitle:(id)actionTitle actionStyle:(YZHUIAlertActionStyle)actionStyle actionBlock:(YZHUIAlertActionBlock)actionBlock;

//以actionModel的方式添加
-(YZHAlertActionModel *)addAlertActionWithActionModel:(YZHAlertActionModel*)actionModel;

/*
 *这种添加的actionCell的actionStyle须是YZHUIAlertActionStyleCustomCell
 */
-(YZHAlertActionModel *)addAlertActionWithCustomCellBlock:(YZHUIAlertActionCellCustomViewBlock)customCellBlock actionBlock:(YZHUIAlertActionBlock)actionBlock;

/*
 *这种添加的actionCell的actionStyle须是YZHUIAlertActionStyleCustomCell|
 */
-(YZHAlertActionModel *)addCustomAlertActionWithStyle:(YZHUIAlertActionStyle)actionStyle customCellBlock:(YZHUIAlertActionCellCustomViewBlock)customCellBlock actionBlock:(YZHUIAlertActionBlock)actionBlock;

/*
 *自定义sheet的最后一个Action为YZHUIAlertActionStyleCustomLastSheetCell
 */
-(YZHAlertActionModel *)addCustomSheetLastActionWithCustomCellBlock:(YZHUIAlertActionCellCustomViewBlock)customCellBlock actionBlock:(YZHUIAlertActionBlock)actionBlock;

-(void)alertShowInView:(UIView*)inView;

-(void)alertShowInView:(UIView *)inView animated:(BOOL)animated;

-(void)alertShowInView:(UIView *)inView frame:(CGRect)frame;

-(void)alertShowInView:(UIView *)inView frame:(CGRect)frame animated:(BOOL)animated;

-(void)dismiss;

-(void)dismissAnimated:(BOOL)animated;

-(UIView*)getShowInView;
//当修改了cell的高度时，需要调用此方法
-(void)updateAlertActionCellsLayout;
//当需要修改cell的contentSize时，直接调用此方法就可以，传入cell的index
-(void)updateAlertActionCellForIndex:(NSInteger)index contentSize:(CGSize)contentSize;
//当需要修改cell的contentSize时，直接调用此方法就可以，传入cell的actionModel
-(void)updateAlertActionCellForActionModel:(YZHAlertActionModel*)actionModel contentSize:(CGSize)contentSize;

+(NSArray<YZHUIAlertView*>*)alertViewsForTag:(NSInteger)tag inView:(UIView*)inView;

+(NSInteger)alertViewCountForTag:(NSInteger)tag inView:(UIView*)inView;

//default is NO
@property (nonatomic, assign) BOOL outSideUserInteractionEnabled;

//只针对YZHUIAlertViewStyleAlertInfo有效
@property (nonatomic, assign) NSTimeInterval delayDismissInterval;
//还可以设置如下属性
//public,<=0时没有动画效果
@property (nonatomic, assign) CGFloat animateDuration;

//height
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat cellHeadTitleHeight;
@property (nonatomic, assign) CGFloat cellHeadMessageHeight;
//这个只针对textView的cell的高度
@property (nonatomic, assign) CGFloat cellTextViewHeight;
//如果是竖线，此值就是宽度，这个值其实就是线的”宽度“ lineWidth
@property (nonatomic, assign) CGFloat cellSeparatorLineWidth;
//Title和Message直接是否允许有SeparatorLineWidth，default is NO
@property (nonatomic, assign) BOOL cellHeadTitleMessageHaveSeparatorLine;

//color
@property (nonatomic, copy) UIColor *cellBackgroundColor;
@property (nonatomic, copy) UIColor *cellHighlightColor;
@property (nonatomic, copy) UIColor *cellSeparatorLineColor;
@property (nonatomic, copy) UIColor *cellEditBackgroundColor;
@property (nonatomic, copy) UIColor *cellHeadTitleBackgroundColor;
@property (nonatomic, copy) UIColor *cellHeadMessageBackgroundColor;

//textColor
@property (nonatomic, copy) UIColor *cellTextColor;
@property (nonatomic, copy) UIColor *cellEditTextColor;
@property (nonatomic, copy) UIColor *cellConfirmTextColor;
@property (nonatomic, copy) UIColor *cellHeadTitleTextColor;
@property (nonatomic, copy) UIColor *cellHeadMessageTextColor;
//only for tips
@property (nonatomic, copy) UIColor *cellHeadTitleHighlightTextColor;

//textFont
@property (nonatomic, copy) UIFont *cellTextFont;
@property (nonatomic, copy) UIFont *cellEditTextFont;
@property (nonatomic, copy) UIFont *cellHeadTitleTextFont;
@property (nonatomic, copy) UIFont *cellHeadMessageTextFont;

@property (nonatomic, copy) UIFont *cellCancelTextFont;
@property (nonatomic, copy) UIFont *cellConfirmTextFont;
@property (nonatomic, copy) UIFont *cellDestructiveTextFont;
//only for tips
@property (nonatomic, copy) UIFont *cellHeadTitleHighlightTextFont;

@property (nonatomic, assign) BOOL cellEditSecureTextEntry;

//tips 的image
@property (nonatomic, copy) NSString *cellHeadImageName;
@property (nonatomic, copy) NSString *cellHeadHighlightImageName;

//YZHUIAlertViewStyleActionSheet
@property (nonatomic, assign) CGFloat sheetCancelCellTopLineWidth;
//default is clearColor
@property (nonatomic, copy) UIColor *sheetCancelCellTopLineColor;

@end

@interface YZHUIAlertView (YZHUIAlertViewAttributes)

//如下方法为特殊用法，如果不是特别要求的话，可以不用
-(YZHAlertActionModel*)alertActionModelForModelIndex:(NSInteger)index;
//调用这些方法的前提是调用了show之后或者prepareShow
-(UIView*)prepareShowInView:(UIView*)inView;

-(UILabel*)alertTextLabelForAlertActionModel:(YZHAlertActionModel*)actionModel;
-(UITextView*)alertTextViewForAlertActionModel:(YZHAlertActionModel*)actionModel;
-(UITextField*)alertEditTextFieldForAlertActionModel:(YZHAlertActionModel*)actionModel;
-(UIView*)alertCustomCellSubViewForAlertActionModel:(YZHAlertActionModel*)actionModel;

-(UIView*)alertCellContentViewForAlertActionModelIndex:(NSInteger)index;

-(NSDictionary*)getAllAlertEditViewActionModelInfo;

-(NSDictionary*)getAllAlertCustomCellViewInfo;

-(NSDictionary*)getAllAlertActionCellInfo;

@end
