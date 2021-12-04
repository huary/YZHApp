//
//  YZHExcelViewRowCell.m
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHExcelViewRowCell.h"
#import "YZHExcelViewRowContentView.h"
#import "NSIndexPath+YZHExcelView.h"
#import "YZHKitType.h"
#import "UIView+YZHAdd.h"
#import "CALayer+YZHAdd.h"

/********************************************************************
 *YZHExcelViewRowCellModel
 *********************************************************************/
IMPLEMENTATION_FOR_CLASS(YZHExcelViewRowCellModel)

@interface YZHExcelViewRowCell () <YZHExcelViewRowContentViewDelegate>

@property (nonatomic, assign) NSExcelSeparatorLineType separatorLineType;
//default is 1
@property (nonatomic, assign) CGFloat separatorLineWidth;
//default is blackColor;
@property (nonatomic, strong) UIColor *separatorLineColor;

@property (nonatomic, strong) CALayer *firstRowTopLine;
@property (nonatomic, strong) CALayer *separatorLine;

@property (nonatomic, strong) YZHExcelViewRowContentView *leftLockContentView;
@property (nonatomic, strong) YZHExcelViewRowContentView *rightScrollContentView;

@end

@implementation YZHExcelViewRowCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupRowCellDefaultValue];
        [self _setupRowCellChildView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    CGFloat leftWidth = self.cellModel.leftLockViewWidth;
    CGFloat rightWidth = size.width - leftWidth;
    self.leftLockContentView.frame = CGRectMake(0, 0, leftWidth, size.height);
    self.rightScrollContentView.frame = CGRectMake(leftWidth, 0, rightWidth, size.height);
    
    self.separatorLine.hz_size = CGSizeMake(size.width, self.separatorLineWidth);
    self.separatorLine.hz_bottom = self.contentView.hz_bottom;
    
    if (self.firstRowTopLine) {
        self.firstRowTopLine.hz_size = CGSizeMake(self.bounds.size.width, self.separatorLineWidth);
        self.firstRowTopLine.hz_top = 0;
    }
}

-(CALayer*)_createSeparatorLine
{
    CALayer *separatorLine = [[CALayer alloc] init];
    separatorLine.backgroundColor = self.separatorLineColor.CGColor;
    return separatorLine;
}

-(void)_setupRowCellDefaultValue
{
    self.separatorLineWidth = 1.0;
    self.separatorLineColor = BLACK_COLOR;
}

-(void)_setupRowCellChildView
{
    self.leftLockContentView = [[YZHExcelViewRowContentView alloc] init];
    [self.contentView addSubview:self.leftLockContentView];
    self.rightScrollContentView = [[YZHExcelViewRowContentView alloc] init];
    [self.contentView addSubview:self.rightScrollContentView];
    
    self.separatorLine = [self _createSeparatorLine];
    [self.contentView.layer addSublayer:self.separatorLine];
}

-(void)_createFirstRowTopSeparatorLine
{
    if (self.cellModel == nil || self.cellModel.rowIndex != 0) {
        return;
    }
    if (self.firstRowTopLine == nil) {
        self.firstRowTopLine = [self _createSeparatorLine];
        [self.contentView.layer addSublayer:self.firstRowTopLine];
    }
    self.firstRowTopLine.hz_size = CGSizeMake(self.bounds.size.width, self.separatorLineWidth);
    self.firstRowTopLine.hz_top = 0;
}

-(void)_updateSeparatorLineLayer:(CALayer*)lineLayer
{
    if (lineLayer == nil) {
        return;
    }
    lineLayer.backgroundColor = self.separatorLineColor.CGColor;
    if (self.separatorLineType == NSExcelSeparatorLineTypeNone) {
        lineLayer.hidden = YES;
    }
    else
    {
        lineLayer.hidden = NO;
    }
}

-(void)_updateSeparatorLine
{
    self.separatorLineType = self.cellModel.horizontalLineType;
    self.separatorLineWidth = self.cellModel.horizontalLineWidth;
    self.separatorLineColor = self.cellModel.horizontalLineColor;
    
    [self _updateSeparatorLineLayer:self.firstRowTopLine];
    [self _updateSeparatorLineLayer:self.separatorLine];
}

-(void)setCellModel:(YZHExcelViewRowCellModel *)cellModel
{
    _cellModel = cellModel;
    
    [self _createFirstRowTopSeparatorLine];
    
    [self _updateSeparatorLine];
    
    self.leftLockContentView.delegate = self;
    self.rightScrollContentView.delegate = self;
    
    [self updateRightScrollViewWithScrollInfo:cellModel.scrollInfo];
    
    self.leftLockContentView.excelRowIndex = cellModel.rowIndex;
    self.leftLockContentView.startColumnIndex = 0;
    
    self.leftLockContentView.verticalLineType = cellModel.verticalLineType;
    self.leftLockContentView.verticalLineWidth = cellModel.verticalLineWidth;
    self.leftLockContentView.verticalLineColor = cellModel.verticalLineColor;
    
    self.rightScrollContentView.excelRowIndex = cellModel.rowIndex;
    self.rightScrollContentView.startColumnIndex = cellModel.cellInLeftLockViewCnt;
    
    self.rightScrollContentView.verticalLineType = cellModel.verticalLineType;
    self.rightScrollContentView.verticalLineWidth = cellModel.verticalLineWidth;
    self.rightScrollContentView.verticalLineColor = cellModel.verticalLineColor;
    
    [self.leftLockContentView.collectionView reloadData];
    [self.rightScrollContentView.collectionView reloadData];
}

#pragma mark YZHExcelViewRowContentViewDelegate
-(NSInteger)numberOfExcelCellsInRowContentView:(YZHExcelViewRowContentView *)rowContentView
{
    if (self.leftLockContentView == rowContentView) {
        return self.cellModel.cellInLeftLockViewCnt;
    }
    else
    {
        return self.cellModel.cellInRightScrollViewCnt;
    }
}

-(UIView*)excelViewRowContentView:(YZHExcelViewRowContentView*)excelRowContentView excelCellForItemAtIndexPath:(NSIndexPath *)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView
{
    if ([self.delegate respondsToSelector:@selector(excelViewRowCell:excelCellForItemAtIndexPath:withReusableExcelCellView:)]) {
        return [self.delegate excelViewRowCell:self excelCellForItemAtIndexPath:indexPath withReusableExcelCellView:reusableExcelCellView];
    }
    return nil;
}

-(CGSize)excelViewRowContentView:(YZHExcelViewRowContentView*)excelRowContentView excelCellSizeForItemAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self.delegate respondsToSelector:@selector(excelViewRowCell:excelCellSizeForItemAtIndexPath:)]) {
        CGSize itemSize = [self.delegate excelViewRowCell:self excelCellSizeForItemAtIndexPath:indexPath];
        return itemSize;
    }
    return CGSizeZero;
}

-(void)excelViewRowContentView:(YZHExcelViewRowContentView *)excelRowContentView didSelectExcelCellItemAtIndexPath:(NSIndexPath *)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView
{
    if ([self.delegate respondsToSelector:@selector(excelViewRowCell:didSelectExcelCellItemAtIndexPath:withReusableExcelCellView:)]) {
        [self.delegate excelViewRowCell:self didSelectExcelCellItemAtIndexPath:indexPath withReusableExcelCellView:reusableExcelCellView];
    }
}

-(BOOL)excelViewRowContentView:(YZHExcelViewRowContentView *)excelRowContentView canScrollExcelRowWithScrollInfo:(NSExcelRowScrollInfo *)scrollInfo
{
    if ([self.delegate respondsToSelector:@selector(excelViewRowCell:canScrollExcelRowWithScrollInfo:)]) {
        return [self.delegate excelViewRowCell:self canScrollExcelRowWithScrollInfo:scrollInfo];
    }
    return YES;
}

#pragma mark public event
-(void)updateRightScrollViewWithScrollInfo:(NSExcelRowScrollInfo*)scrollInfo
{
    self.rightScrollContentView.scrollInfo = scrollInfo;
}

- (void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (self.cellModel == nil) {
        return;
    }
    
    NSMutableArray *leftReloadIndexPaths = [NSMutableArray array];
    NSMutableArray *rightReloadIndexPaths = [NSMutableArray array];
    NSInteger leftCnt = self.cellModel.cellInLeftLockViewCnt;
    NSInteger rightCnt = self.cellModel.cellInRightScrollViewCnt;
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.hz_excelRow != self.cellModel.rowIndex) {
            return ;
        }
        if (obj.hz_excelColumn < leftCnt) {
            [leftReloadIndexPaths addObject:[NSIndexPath indexPathForItem:obj.hz_excelColumn inSection:0]];
        }
        else {
            NSInteger index = obj.hz_excelColumn - leftCnt;
            if (index < rightCnt) {
                [rightReloadIndexPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
            }
        }
    }];
    if (IS_AVAILABLE_NSSET_OBJ(leftReloadIndexPaths)) {
        [self.leftLockContentView.collectionView reloadItemsAtIndexPaths:leftReloadIndexPaths];
    }
    if (IS_AVAILABLE_NSSET_OBJ(rightReloadIndexPaths)) {
        [self.rightScrollContentView.collectionView reloadItemsAtIndexPaths:rightReloadIndexPaths];
    }
}

-(void)reloadData
{
    [self.leftLockContentView.collectionView reloadData];
    [self.rightScrollContentView.collectionView reloadData];
}

@end

