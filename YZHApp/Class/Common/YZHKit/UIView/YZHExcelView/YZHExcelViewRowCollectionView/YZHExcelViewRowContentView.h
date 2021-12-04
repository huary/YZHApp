//
//  YZHExcelViewRowContentView.h
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHExcelViewType.h"

@class YZHExcelViewRowContentView;
@protocol YZHExcelViewRowContentViewDelegate  <NSObject>

-(NSInteger)numberOfExcelCellsInRowContentView:(YZHExcelViewRowContentView*)rowContentView;

-(UIView*)excelViewRowContentView:(YZHExcelViewRowContentView*)excelRowContentView excelCellForItemAtIndexPath:(NSIndexPath *)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView;

-(CGSize)excelViewRowContentView:(YZHExcelViewRowContentView*)excelRowContentView excelCellSizeForItemAtIndexPath:(NSIndexPath*)indexPath;

-(void)excelViewRowContentView:(YZHExcelViewRowContentView*)excelRowContentView didSelectExcelCellItemAtIndexPath:(NSIndexPath*)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView;

-(BOOL)excelViewRowContentView:(YZHExcelViewRowContentView*)excelRowContentView canScrollExcelRowWithScrollInfo:(NSExcelRowScrollInfo*)scrollInfo;
@end



/****************************************************************************
 *YZHExcelViewRowContentView
 ****************************************************************************/
@interface YZHExcelViewRowContentView : UIView

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger excelRowIndex;
@property (nonatomic, assign) NSInteger startColumnIndex;

@property (nonatomic, copy) NSExcelRowScrollInfo *scrollInfo;

@property (nonatomic, assign) NSExcelSeparatorLineType verticalLineType;

//下面的line统一指的是线条的粗细
@property (nonatomic, assign) CGFloat verticalLineWidth;

@property (nonatomic, strong) UIColor *verticalLineColor;

@property (nonatomic, weak) id<YZHExcelViewRowContentViewDelegate> delegate;

@end
