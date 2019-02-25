//
//  YZHCalendarItemModel.h
//  YZHUICalendarViewDemo
//
//  Created by yuan on 2018/8/8.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHKitType.h"

/**********************************************************************
 *YZHTextViewModel
 **********************************************************************/
@interface YZHTextViewModel : NSObject

/* <#注释#> */
@property (nonatomic, strong) NSString *text;

/* <#注释#> */
@property (nonatomic, strong) UIFont *font;

/* default is black color */
@property (nonatomic, strong) UIColor *textColor;

/* default is clear color */
@property (nonatomic, strong) UIColor *backgroundColor;

-(instancetype)initWithText:(NSString*)text font:(UIFont*)font;

-(instancetype)initWithText:(NSString*)text font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor;
@end


/**********************************************************************
 *YZHControlTextViewModel
 **********************************************************************/
@interface YZHControlTextViewModel : YZHTextViewModel

/* default is textColor */
@property (nonatomic, strong) UIColor *selectedTextColor;

@end



@interface YZHCalendarItemModel : NSObject

/* <#注释#> */
@property (nonatomic, strong) YZHControlTextViewModel *textModel;

/* default is NO */
@property (nonatomic, assign) BOOL isSelected;

/* default is NO */
@property (nonatomic, assign) BOOL haveBottomDot;

/* default is YES*/
@property (nonatomic, assign) BOOL canSelected;

/* <#注释#> */
@property (nonatomic, strong) NSDateComponents *dateComponents;

-(instancetype)initWithDateComponents:(NSDateComponents*)dateComponents;

-(instancetype)initWithTextModel:(YZHControlTextViewModel*)textModel;

@end
