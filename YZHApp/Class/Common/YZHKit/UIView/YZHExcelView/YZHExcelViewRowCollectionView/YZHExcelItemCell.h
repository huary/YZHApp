//
//  YZHExcelItemCell.h
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHExcelViewType.h"
#import "NSIndexPath+YZHExcelView.h"

@class YZHExcelItemCell;
@protocol YZHExcelItemCellDelegate <NSObject>

-(void)excelItemCell:(YZHExcelItemCell*)excelItemCell touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
@end

@interface YZHExcelItemCell : UICollectionViewCell

@property (nonatomic, assign) NSExcelSeparatorLineType verticalLineType;
//下面的line统一指的是线条的粗细
@property (nonatomic, assign) CGFloat verticalLineWidth;

@property (nonatomic, strong) UIColor *verticalLineColor;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id<YZHExcelItemCellDelegate> cellDelegate;

-(UIView*)reusableExcelCellSubView;

-(void)addExcelCellView:(UIView*)excelCellView;

@end
