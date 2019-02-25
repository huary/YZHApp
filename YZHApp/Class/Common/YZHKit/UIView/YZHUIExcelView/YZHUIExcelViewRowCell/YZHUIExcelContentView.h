//
//  YZHUIExcelContentView.h
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUIExcelViewType.h"

@class YZHUIExcelContentView;
@protocol YZHUIExcelContentViewDelegate <NSObject>

-(CGFloat)excelContentView:(YZHUIExcelContentView *)excelContentView heightForRowAtIndex:(NSInteger)rowIndex;
-(CGFloat)excelContentView:(YZHUIExcelContentView *)excelContentView widthForColumnAtIndex:(NSInteger)columnIndex;

-(UIView*)excelContentView:(YZHUIExcelContentView *)excelContentView excelCellForItemAtIndexPath:(NSIndexPath*)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView;
-(void)excelContentView:(YZHUIExcelContentView *)excelContentView didSelectExcelCellItemAtIndexPath:(NSIndexPath *)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView;

-(BOOL)excelContentView:(YZHUIExcelContentView *)excelContentView canScrollExcelRowWithScrollInfo:(NSExcelRowScrollInfo *)scrollInfo;

@end


/****************************************************************************
 *YZHUIExcelContentViewModel
 *****************************************************************************/
@interface YZHUIExcelContentViewModel : NSObject

//起始的行号
@property (nonatomic, assign) NSInteger startRowIndex;

@property (nonatomic, assign) NSInteger excelRowCnt;
@property (nonatomic, assign) NSInteger excelColumnCnt;
@property (nonatomic, assign) NSInteger cellInLeftLockViewCnt;

@property (nonatomic, copy) NSExcelRowScrollInfo *scrollInfo;

@property (nonatomic, assign) NSExcelSeparatorLineType verticalLineType;
@property (nonatomic, assign) NSExcelSeparatorLineType horizontalLineType;

//下面的line统一指的是线条的粗细
@property (nonatomic, assign) CGFloat verticalLineWidth;
@property (nonatomic, assign) CGFloat horizontalLineWidth;

@property (nonatomic, strong) UIColor *verticalLineColor;
@property (nonatomic, strong) UIColor *horizontalLineColor;

@end


/****************************************************************************
 *YZHUIExcelContentView
 *****************************************************************************/
@interface YZHUIExcelContentView : UIView

@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, strong) YZHUIExcelContentViewModel *contentViewModel;

@property (nonatomic, weak) id<YZHUIExcelContentViewDelegate> delegate;

-(BOOL)canUpdateExcelRowScrollInfo:(NSExcelRowScrollInfo*)newScrollInfo;

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

-(void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
@end
