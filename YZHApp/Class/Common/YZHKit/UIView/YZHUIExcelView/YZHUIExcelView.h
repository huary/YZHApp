//
//  YZHUIExcelView.h
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUIExcelViewType.h"
#import "NSIndexPath+YZHUIExcelView.h"

@class YZHUIExcelView;

@protocol YZHUIExcelViewDelegate <NSObject>

-(NSInteger)numberOfRowsInExcelView:(YZHUIExcelView *)excelView;
-(NSInteger)numberOfColumnsInExcelView:(YZHUIExcelView *)excelView;
-(CGFloat)excelView:(YZHUIExcelView *)excelView heightForRowAtIndex:(NSInteger)rowIndex;
-(CGFloat)excelView:(YZHUIExcelView *)excelView widthForColumnAtIndex:(NSInteger)columnIndex;
-(UIView*)excelView:(YZHUIExcelView *)excelView excelCellForItemAtIndexPath:(NSIndexPath*)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView;
-(void)excelView:(YZHUIExcelView *)excelView didSelectExcelCellItemAtIndexPath:(NSIndexPath *)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView;

@end


@interface YZHUIExcelView : UIView

//上部锁住的excelRow,左边锁住的excelColumn
@property (nonatomic, strong) NSIndexPath *lockIndexPath;

@property (nonatomic, assign) NSExcelSeparatorLineType verticalLineType;
@property (nonatomic, assign) NSExcelSeparatorLineType horizontalLineType;

//下面的line统一指的是线条的粗细
@property (nonatomic, assign) CGFloat verticalLineWidth;
@property (nonatomic, assign) CGFloat horizontalLineWidth;

@property (nonatomic, strong) UIColor *verticalLineColor;
@property (nonatomic, strong) UIColor *horizontalLineColor;

@property (nonatomic, strong) id<YZHUIExcelViewDelegate> delegate;

-(void)reloadData;

-(void)reloadTopExcel;

-(void)reloadBottomExcel;

-(void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths withRowAnimation:(UITableViewRowAnimation)rowAnimation;

-(void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

@end
