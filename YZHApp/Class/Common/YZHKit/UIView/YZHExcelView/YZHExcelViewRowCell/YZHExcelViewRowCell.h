//
//  YZHExcelViewRowCell.h
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHExcelViewType.h"

@class YZHExcelViewRowCell;
@protocol YZHExcelViewRowCellDelegate <NSObject>

-(UIView*)excelViewRowCell:(YZHExcelViewRowCell *)excelViewRowCell excelCellForItemAtIndexPath:(NSIndexPath *)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView;
-(CGSize)excelViewRowCell:(YZHExcelViewRowCell *)excelViewRowCell excelCellSizeForItemAtIndexPath:(NSIndexPath *)indexPath;
-(void)excelViewRowCell:(YZHExcelViewRowCell *)excelViewRowCell didSelectExcelCellItemAtIndexPath:(NSIndexPath *)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView;
-(BOOL)excelViewRowCell:(YZHExcelViewRowCell *)excelViewRowCell canScrollExcelRowWithScrollInfo:(NSExcelRowScrollInfo*)scrollInfo;
@end



/********************************************************************
 *YZHExcelViewRowCellModel
 *********************************************************************/
@interface YZHExcelViewRowCellModel : NSObject

@property (nonatomic, assign) NSInteger rowIndex;
@property (nonatomic, assign) NSInteger cellInLeftLockViewCnt;
@property (nonatomic, assign) NSInteger cellInRightScrollViewCnt;

//@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat leftLockViewWidth;
@property (nonatomic, assign) CGFloat rightScrollViewWidth;
//滚动的信息
@property (nonatomic, copy) NSExcelRowScrollInfo *scrollInfo;

@property (nonatomic, assign) NSExcelSeparatorLineType verticalLineType;
@property (nonatomic, assign) NSExcelSeparatorLineType horizontalLineType;

//下面的line统一指的是线条的粗细
@property (nonatomic, assign) CGFloat verticalLineWidth;
@property (nonatomic, assign) CGFloat horizontalLineWidth;

@property (nonatomic, strong) UIColor *verticalLineColor;
@property (nonatomic, strong) UIColor *horizontalLineColor;
@end




/********************************************************************
 *YZHExcelViewRowCell
 *********************************************************************/
@interface YZHExcelViewRowCell : UITableViewCell

@property (nonatomic, strong) YZHExcelViewRowCellModel *cellModel;

@property (nonatomic, weak) id<YZHExcelViewRowCellDelegate> delegate;

-(void)updateRightScrollViewWithScrollInfo:(NSExcelRowScrollInfo*)scrollInfo;

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

-(void)reloadData;
@end
