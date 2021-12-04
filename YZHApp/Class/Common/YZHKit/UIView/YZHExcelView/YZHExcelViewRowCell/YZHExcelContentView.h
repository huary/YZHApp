//
//  YZHExcelContentView.h
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHExcelViewType.h"

@class YZHExcelContentView;
@protocol YZHExcelContentViewDelegate <NSObject>

-(CGFloat)excelContentView:(YZHExcelContentView *)excelContentView heightForRowAtIndex:(NSInteger)rowIndex;
-(CGFloat)excelContentView:(YZHExcelContentView *)excelContentView widthForColumnAtIndex:(NSInteger)columnIndex;

-(UIView*)excelContentView:(YZHExcelContentView *)excelContentView excelCellForItemAtIndexPath:(NSIndexPath*)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView;
-(void)excelContentView:(YZHExcelContentView *)excelContentView didSelectExcelCellItemAtIndexPath:(NSIndexPath *)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView;

-(BOOL)excelContentView:(YZHExcelContentView *)excelContentView canScrollExcelRowWithScrollInfo:(NSExcelRowScrollInfo *)scrollInfo;

@end


/****************************************************************************
 *YZHExcelContentViewModel
 *****************************************************************************/
@interface YZHExcelContentViewModel : NSObject

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
 *YZHExcelContentView
 *****************************************************************************/
@interface YZHExcelContentView : UIView

@property (nonatomic, strong, readonly) UITableView *tableView;

@property (nonatomic, strong) YZHExcelContentViewModel *contentViewModel;

@property (nonatomic, weak) id<YZHExcelContentViewDelegate> delegate;

-(BOOL)canUpdateExcelRowScrollInfo:(NSExcelRowScrollInfo*)newScrollInfo;

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

-(void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
@end
