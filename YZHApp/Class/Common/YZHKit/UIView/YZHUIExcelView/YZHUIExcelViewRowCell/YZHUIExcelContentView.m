//
//  YZHUIExcelContentView.m
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIExcelContentView.h"
#import "YZHUIExcelViewRowCell.h"
#import "NSIndexPath+YZHUIExcelView.h"
#import "YZHKitType.h"

/****************************************************************************
 *YZHUIExcelContentViewModel
 *****************************************************************************/

@implementation YZHUIExcelContentViewModel

@end



/****************************************************************************
 *YZHUIExcelContentView
 *****************************************************************************/
@interface YZHUIExcelContentView () <UITableViewDelegate, UITableViewDataSource,YZHUIExcelViewRowCellDelegate>


@property (nonatomic, strong) NSMutableArray<YZHUIExcelViewRowCellModel*> *cellModels;
@end

@implementation YZHUIExcelContentView

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupExcelContentView];
    }
    return self;
}

-(void)_setupExcelContentView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.bounces = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.tableView];
    
    [self.tableView registerClass:CLASS_FROM_CLASSNAME(YZHUIExcelViewRowCell) forCellReuseIdentifier:NSSTRING_FROM_CLASS(YZHUIExcelViewRowCell)];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

-(NSMutableArray<YZHUIExcelViewRowCellModel*>*)cellModels
{
    if (_cellModels == nil) {
        _cellModels = [NSMutableArray array];
    }
    return _cellModels;
}

#pragma mark UITableViewDelegate, UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contentViewModel.excelRowCnt;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(excelContentView:heightForRowAtIndex:)]) {
        CGFloat height = [self.delegate excelContentView:self heightForRowAtIndex:indexPath.row];
        return height;
    }
    return 40;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YZHUIExcelViewRowCell *rowCell = [tableView dequeueReusableCellWithIdentifier:NSSTRING_FROM_CLASS(YZHUIExcelViewRowCell) forIndexPath:indexPath];
    YZHUIExcelViewRowCellModel *cellModel = self.cellModels[indexPath.row];
    cellModel.scrollInfo.scrollContentOffset = self.contentViewModel.scrollInfo.scrollContentOffset;
    rowCell.cellModel = cellModel;
    rowCell.delegate = self;
    return rowCell;
}

-(void)_updateRowCellSeparatorLineInfo:(YZHUIExcelViewRowCellModel*)cellModel
{
    cellModel.verticalLineType = self.contentViewModel.verticalLineType;
    cellModel.horizontalLineType = self.contentViewModel.horizontalLineType;
    
    cellModel.verticalLineWidth = self.contentViewModel.verticalLineWidth;
    cellModel.horizontalLineWidth = self.contentViewModel.horizontalLineWidth;
    
    cellModel.verticalLineColor = self.contentViewModel.verticalLineColor;
    cellModel.horizontalLineColor = self.contentViewModel.horizontalLineColor;
}

-(void)_updateRowCellModels
{
    NSInteger rowCnt = self.contentViewModel.excelRowCnt;
    NSInteger columnCnt = self.contentViewModel.excelColumnCnt;
    NSInteger lockColumnCnt = self.contentViewModel.cellInLeftLockViewCnt;
    NSInteger startRowIndex = self.contentViewModel.startRowIndex;
    
    CGFloat lockWidth = 0;
    CGFloat contentWidth = 0;
    
    if ([self.delegate respondsToSelector:@selector(excelContentView:widthForColumnAtIndex:)]) {
        for (NSInteger i = 0; i < columnCnt; ++i) {
            CGFloat columnWidth = [self.delegate excelContentView:self widthForColumnAtIndex:i];
            if (i < lockColumnCnt) {
                lockWidth += columnWidth;
            }
            contentWidth += columnWidth;
        }
    }
    
    self.cellModels = nil;
    for (NSInteger i = 0; i < rowCnt; ++i) {
        YZHUIExcelViewRowCellModel *cellModel = [[YZHUIExcelViewRowCellModel alloc] init];
        cellModel.rowIndex = startRowIndex + i;
        cellModel.cellInLeftLockViewCnt = lockColumnCnt;
        cellModel.cellInRightScrollViewCnt = columnCnt - lockColumnCnt;
        cellModel.leftLockViewWidth = lockWidth;
        cellModel.rightScrollViewWidth = self.bounds.size.width - lockWidth;
        
        cellModel.scrollInfo = self.contentViewModel.scrollInfo;
        
        [self _updateRowCellSeparatorLineInfo:cellModel];
        [self.cellModels addObject:cellModel];
    }
}

-(void)setContentViewModel:(YZHUIExcelContentViewModel *)contentViewModel
{
    _contentViewModel = contentViewModel;
    [self _updateRowCellModels];
    [self.tableView reloadData];
}

-(BOOL)_canDriveOtherExcelRowScroll:(NSExcelRowScrollInfo *)scrollInfo
{
#if 1
    if (scrollInfo.scrollType == NSExcelRowScrollTypeDrive && scrollInfo.driveScrollRowIndex >= 0) {
        return YES;
    }
    return NO;
#else
    BOOL canDrive = YES;
    if (scrollInfo.scrollState != NSExcelRowScrollStateEnd) {
        NSInteger startIndex = self.contentViewModel.startRowIndex;
        NSInteger endIndex = self.contentViewModel.startRowIndex + self.contentViewModel.excelRowCnt;
        BOOL isIn = NO;
        if (scrollInfo.driveScrollRowIndex >= startIndex && scrollInfo.driveScrollRowIndex < endIndex ) {
            isIn = YES;
        }
        
        //只能存在一个驱动的cell，
        for (NSInteger i = 0; i < self.cellModels.count; ++i) {
            YZHUIExcelViewRowCellModel *cellModel = self.cellModels[i];
            if (isIn) {
                if (scrollInfo.driveScrollRowIndex != cellModel.rowIndex && cellModel.scrollInfo.scrollType == NSExcelRowScrollTypeDrive) {
                    canDrive = NO;
                }
            }
            else
            {
                if (cellModel.scrollInfo.scrollType == NSExcelRowScrollTypeDrive) {
                    canDrive = NO;
                }
            }
        }
    }
    return canDrive;
#endif
}

-(void)_doLocalOtherExcelRowScroll:(NSExcelRowScrollInfo*)scrollInfo canDriveScroll:(BOOL)canDriveScroll
{
    if (canDriveScroll) {
        CGPoint driveScrollContentOffset = scrollInfo.scrollContentOffset;
        self.contentViewModel.scrollInfo.scrollContentOffset = driveScrollContentOffset;
        
        NSArray *visibleCells = [self.tableView.visibleCells copy];
        
        for (NSInteger i = 0; i < visibleCells.count; ++i) {
            YZHUIExcelViewRowCell *cell = visibleCells[i];
            if (scrollInfo.scrollState == NSExcelRowScrollStateEnd || (scrollInfo.scrollState != NSExcelRowScrollStateEnd && cell.cellModel.rowIndex != scrollInfo.driveScrollRowIndex)) {
                cell.cellModel.scrollInfo.scrollType = NSExcelRowScrollTypeDriven;
                cell.cellModel.scrollInfo.scrollContentOffset = driveScrollContentOffset;
                cell.cellModel.scrollInfo.driveScrollRowIndex = scrollInfo.driveScrollRowIndex;

                cell.cellModel.scrollInfo.scrollState = scrollInfo.scrollState; //和上面的顺序不能换

                [cell updateRightScrollViewWithScrollInfo:cell.cellModel.scrollInfo];
            }
        }
    }
    else
    {
        //如果不能滚动的话，将scrollContentOffset还原
        scrollInfo.scrollContentOffset = self.contentViewModel.scrollInfo.scrollContentOffset;
    }
}

#pragma mark YZHUIExcelViewRowCellDelegate
-(UIView*)excelViewRowCell:(YZHUIExcelViewRowCell*)excelViewRowCell excelCellForItemAtIndexPath:(NSIndexPath *)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView
{
    if ([self.delegate respondsToSelector:@selector(excelContentView:excelCellForItemAtIndexPath:withReusableExcelCellView:)]) {
        return [self.delegate excelContentView:self excelCellForItemAtIndexPath:indexPath withReusableExcelCellView:reusableExcelCellView];
    }
    return nil;
}

-(CGSize)excelViewRowCell:(YZHUIExcelViewRowCell*)excelViewRowCell excelCellSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = 0;
    CGFloat height = 0;
    if ([self.delegate respondsToSelector:@selector(excelContentView:widthForColumnAtIndex:)]) {
        width = [self.delegate excelContentView:self widthForColumnAtIndex:indexPath.excelColumn];
    }
    if ([self.delegate respondsToSelector:@selector(excelContentView:heightForRowAtIndex:)]) {
        height = [self.delegate excelContentView:self heightForRowAtIndex:indexPath.excelRow];
    }
    return CGSizeMake(width, height);
}

-(void)excelViewRowCell:(YZHUIExcelViewRowCell*)excelViewRowCell didSelectExcelCellItemAtIndexPath:(NSIndexPath *)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView
{
    if ([self.delegate respondsToSelector:@selector(excelContentView:didSelectExcelCellItemAtIndexPath:withReusableExcelCellView:)]) {
        [self.delegate excelContentView:self didSelectExcelCellItemAtIndexPath:indexPath withReusableExcelCellView:reusableExcelCellView];
    }
}

-(BOOL)excelViewRowCell:(YZHUIExcelViewRowCell *)excelViewRowCell canScrollExcelRowWithScrollInfo:(NSExcelRowScrollInfo *)scrollInfo
{
    BOOL canDriveScroll = [self _canDriveOtherExcelRowScroll:scrollInfo];
    if (canDriveScroll) {
        if ([self.delegate respondsToSelector:@selector(excelContentView:canScrollExcelRowWithScrollInfo:)]) {
            canDriveScroll = [self.delegate excelContentView:self canScrollExcelRowWithScrollInfo:scrollInfo];
        }
    }
    [self _doLocalOtherExcelRowScroll:scrollInfo canDriveScroll:canDriveScroll];

    return canDriveScroll;
}

-(BOOL)canUpdateExcelRowScrollInfo:(NSExcelRowScrollInfo*)newScrollInfo
{
    BOOL canDriveScroll = [self _canDriveOtherExcelRowScroll:newScrollInfo];
    [self _doLocalOtherExcelRowScroll:newScrollInfo canDriveScroll:canDriveScroll];
    return canDriveScroll;
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    if (self.contentViewModel == nil) {
        return;
    }
    NSMutableArray *reloadRows = [NSMutableArray array];
    
    NSInteger rowCnt = self.contentViewModel.excelRowCnt;
    NSInteger startRowIndex = self.contentViewModel.startRowIndex;
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.excelRow >= startRowIndex && obj.excelRow < startRowIndex + rowCnt) {
            [reloadRows addObject:[NSIndexPath indexPathForRow:obj.excelRow - startRowIndex inSection:0]];
        }
    }];
    
    if (IS_AVAILABLE_NSSET_OBJ(reloadRows)) {
        [self.tableView reloadRowsAtIndexPaths:reloadRows withRowAnimation:animation];
    }
}

-(void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (self.contentViewModel == nil) {
        return;
    }
    
    NSMutableArray *reloadItems = [NSMutableArray array];
    
    NSInteger startRowIndex = self.contentViewModel.startRowIndex;
    
    [self.tableView.indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger excelRowIndex = obj.row + startRowIndex;
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.excelRow == excelRowIndex) {
                [reloadItems addObject:obj];
            }
        }];
    }];
    
    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(YZHUIExcelViewRowCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj reloadItemsAtIndexPaths:reloadItems];
    }];
}
@end
