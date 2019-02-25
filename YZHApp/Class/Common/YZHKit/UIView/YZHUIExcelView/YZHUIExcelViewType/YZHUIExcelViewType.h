//
//  YZHUIExcelViewType.h
//  YZHApp
//
//  Created by yuan on 2017/7/18.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSExcelSeparatorLineType)
{
    NSExcelSeparatorLineTypeSingleLine  = 0,
    NSExcelSeparatorLineTypeNone        = 1,
};

typedef NS_ENUM(NSInteger, NSExcelRowScrollType)
{
    //都没有开始滚动的时候
    NSExcelRowScrollTypeNull   = 0,
    //主动
    NSExcelRowScrollTypeDrive  = 1,
    //驱动
    NSExcelRowScrollTypeDriven = 2,
};

typedef NS_ENUM(NSInteger, NSExcelRowScrollState)
{
    NSExcelRowScrollStateNull   = 0,
    NSExcelRowScrollStateBegin  = 1,
    NSExcelRowScrollStateMove   = 2,
    NSExcelRowScrollStateEnd    = 3,
};


@interface NSExcelRowScrollInfo : NSObject <NSCopying>

//默认为NSExcelRowScrollTypeNull
@property (nonatomic, assign) NSExcelRowScrollType scrollType;
//在设置为NSExcelRowScrollStateEnd是会对scrollType、driveScrollRowIndex归为默认值
@property (nonatomic, assign) NSExcelRowScrollState scrollState;

//默认为CGSizeZero
@property (nonatomic, assign) CGPoint scrollContentOffset;

//默认为-1
@property (nonatomic, assign) NSInteger driveScrollRowIndex;

@end
