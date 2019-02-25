//
//  YZHUIHoverView.h
//  OfficeLensDemo
//
//  Created by yuan on 2017/5/2.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "YZHUIButton.h"

#define YZHUIHoverViewFlexDirectionHorizontal   (YZHUIHoverViewFlexDirectionRight | YZHUIHoverViewFlexDirectionLeft)
#define YZHUIHoverViewFlexDirectionVertical     (YZHUIHoverViewFlexDirectionUp | YZHUIHoverViewFlexDirectionDown)

//typedef void(^YZHHoverActionBlock)(NSString *title);

typedef NS_ENUM(NSInteger, YZHUIHoverViewFlexDirection)
{
    YZHUIHoverViewFlexDirectionAny      = -1,
    YZHUIHoverViewFlexDirectionRight    = 1 << 0,
    YZHUIHoverViewFlexDirectionLeft     = 1 << 1,
    YZHUIHoverViewFlexDirectionUp       = 1 << 2,
    YZHUIHoverViewFlexDirectionDown     = 1 << 3,
};

typedef NS_ENUM(NSInteger, YZHUIHoverState)
{
    //收缩
    YZHUIHoverStateShrink   = 0,
    //扩展
    YZHUIHoverStateExpand   = 1,
};


/******************************************************************************
 *YZHUIHoverView
 ******************************************************************************/
@class YZHUIHoverView;
@class YZHHoverActionModel;
typedef void(^YZHHoverActionBlock)(YZHUIHoverView *hoverView, YZHHoverActionModel *actionModel, NSInteger index);

typedef void(^YZHHoverActionBouttonUpdateBlock)(YZHHoverActionModel *actionModel, YZHUIButton *actionButton);

@interface YZHHoverActionModel : NSObject

@property (nonatomic, assign) NSInteger actionIdentity;

@property (nonatomic, strong) UIImage *hoverImage;
@property (nonatomic, strong) NSString *hoverTitle;

@property (nonatomic, weak) YZHUIButton *button;

@property (nonatomic, copy) YZHHoverActionBlock hoverActionBlock;

@property (nonatomic, copy) YZHHoverActionBouttonUpdateBlock updateBlock;

-(instancetype)initWithImageName:(NSString*)imageName title:(NSString*)title hoverActionBlock:(YZHHoverActionBlock)hoverActionBlock;

@end


/******************************************************************************
 *YZHUIHoverView
 ******************************************************************************/

@interface YZHUIHoverView : UIView

@property (nonatomic, strong, readonly) YZHUIButton *hoverButton;

//默认的大小为HoverView初始化时最小的宽高
@property (nonatomic, assign) CGSize hoverButtonSize;

//点击hoverButton时的响应事件
@property (nonatomic, copy) YZHHoverActionBlock hoverAction;

//朝向那方向进行滚动
@property (nonatomic, assign) YZHUIHoverViewFlexDirection flexDirection;

//切换到normalAlpha时的delay
@property (nonatomic, assign) NSTimeInterval delayToNormalTimeInterval;


 //默认为YES
@property (nonatomic, assign) BOOL autoAdjustNormalPosition;
//默认0.15
@property (nonatomic, assign) CGFloat normalAlpha;
//收缩时的大小
@property (nonatomic, assign) CGSize shrinkSize;
//扩展时正方形的大小
@property (nonatomic, assign) CGSize expandSize;
//扩展的item的个数,默认为5
@property (nonatomic, assign) NSInteger expandShowItemCnt;
//
@property (nonatomic, assign) CGFloat actionItemWidth;

@property (nonatomic, assign, readonly) BOOL isExpand;

/* default is 5.0 */
@property (nonatomic, assign) CGFloat edgeSpace;

//
@property (nonatomic, assign) BOOL selected;

-(YZHHoverActionModel *)addHoverActionWithImage:(UIImage*)image title:(NSString*)title hoverActionBlock:(YZHHoverActionBlock)hoverActionBlock;

-(YZHHoverActionModel *)addHoverActionWithImageName:(NSString*)imageName title:(NSString*)title hoverActionBlock:(YZHHoverActionBlock)hoverActionBlock;

-(void)addHoverAction:(YZHHoverActionModel *)action;

-(void)updateHoverAction:(YZHHoverActionModel *)action atIndex:(NSInteger)index;

-(void)updateHoverAction:(YZHHoverActionModel *)action withOldAction:(YZHHoverActionModel *)oldAction;

-(void)updateHoverAction:(YZHHoverActionModel *)action withOldActionIdentity:(NSInteger)actionIdentity;

-(void)hoverShrink;
-(void)hoverExpand;

-(void)reloadData;

-(void)showInView:(UIView*)showInView;
@end
