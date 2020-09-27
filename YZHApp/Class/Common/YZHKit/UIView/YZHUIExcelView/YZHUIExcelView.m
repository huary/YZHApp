//
//  YZHUIExcelView.m
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIExcelView.h"
#import "YZHUIExcelContentView.h"
#import "YZHKitType.h"

@interface YZHUIExcelView ()<YZHUIExcelContentViewDelegate>

//上部lock的view
@property (nonatomic, strong) YZHUIExcelContentView *topExcelContentView;
//底部滚动的view
@property (nonatomic, strong) YZHUIExcelContentView *bottomExcelContentView;

@property (nonatomic, strong) YZHUIExcelContentViewModel *topContentViewModel;
@property (nonatomic, strong) YZHUIExcelContentViewModel *bottomContentViewModel;

@property (nonatomic, assign) NSInteger rowCnt;
@property (nonatomic, assign) NSInteger columnCnt;

@property (nonatomic, assign) CGFloat topExcelContentViewHeight;

@end

@implementation YZHUIExcelView

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
        [self _setupExcelChildView];
        [self _setupExcelDefaultValue];
    }
    return self;
}

-(void)_setupExcelChildView
{
    self.topExcelContentView = [[YZHUIExcelContentView alloc] init];
    self.topExcelContentView.delegate = self;
    [self addSubview:self.topExcelContentView];
    
    self.bottomExcelContentView = [[YZHUIExcelContentView alloc] init];
    self.bottomExcelContentView.delegate = self;
    [self addSubview:self.bottomExcelContentView];
}

-(void)_setupExcelDefaultValue
{
    self.verticalLineType = NSExcelSeparatorLineTypeSingleLine;
    self.verticalLineWidth = 1.0;
    self.verticalLineColor = BLACK_COLOR;
    
    self.horizontalLineType = NSExcelSeparatorLineTypeSingleLine;
    self.horizontalLineWidth = 1.0;
    self.horizontalLineColor = BLACK_COLOR;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self _doReloadData];
}

-(void)_updateRowCellSeparatorLineInfo:(YZHUIExcelContentViewModel*)viewModel
{
    viewModel.verticalLineType = self.verticalLineType;
    viewModel.verticalLineWidth = self.verticalLineWidth;
    viewModel.verticalLineColor = self.verticalLineColor;
    
    viewModel.horizontalLineType = self.horizontalLineType;
    viewModel.horizontalLineWidth = self.horizontalLineWidth;
    viewModel.horizontalLineColor = self.horizontalLineColor;
}

-(YZHUIExcelContentViewModel*)_createContentViewModel:(BOOL)isTop
{
    YZHUIExcelContentViewModel *viewModel = [[YZHUIExcelContentViewModel alloc] init];
    viewModel.excelRowCnt = self.rowCnt;
    viewModel.excelColumnCnt = self.columnCnt;
    viewModel.cellInLeftLockViewCnt = self.lockIndexPath.hz_excelColumn;
    
    if (isTop) {
        viewModel.startRowIndex = 0;
        viewModel.excelRowCnt = self.lockIndexPath.hz_excelRow;
    }
    else
    {
        viewModel.startRowIndex = self.lockIndexPath.hz_excelRow;
        viewModel.excelRowCnt = self.rowCnt - self.lockIndexPath.hz_excelRow;
    }
    viewModel.scrollInfo = [[NSExcelRowScrollInfo alloc] init];
    
    [self _updateRowCellSeparatorLineInfo:viewModel];
    
    return viewModel;
}

-(YZHUIExcelContentViewModel*)topContentViewModel
{
    if (_topContentViewModel == nil) {
        _topContentViewModel = [self _createContentViewModel:YES];
    }
    return _topContentViewModel;
}

-(YZHUIExcelContentViewModel*)bottomContentViewModel
{
    if (_bottomContentViewModel == nil) {
        _bottomContentViewModel = [self _createContentViewModel:NO];
    }
    return _bottomContentViewModel;
}

-(void)_updateExcelFrame
{
    CGSize size = self.bounds.size;

    [self _updateLockViewFrame];
    
    self.topExcelContentView.frame = CGRectMake(0, 0, size.width, self.topExcelContentViewHeight);
    self.bottomExcelContentView.frame = CGRectMake(0, self.topExcelContentViewHeight, size.width, size.height - self.topExcelContentViewHeight);
}

-(void)_doReloadData
{
    [self _updateExcelFrame];
    
    self.topContentViewModel = nil;
    self.bottomContentViewModel = nil;
    self.topExcelContentView.contentViewModel = self.topContentViewModel;
    self.bottomExcelContentView.contentViewModel = self.bottomContentViewModel;
}

-(void)_updateLockViewFrame
{
    NSInteger rowCnt = 0;
    NSInteger columnCnt = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfRowsInExcelView:)]) {
        rowCnt = [self.delegate numberOfRowsInExcelView:self];
    }
    if ([self.delegate respondsToSelector:@selector(numberOfColumnsInExcelView:)]) {
        columnCnt = [self.delegate numberOfColumnsInExcelView:self];
    }
    self.rowCnt = rowCnt;
    self.columnCnt = columnCnt;
    
    NSInteger lockRow = self.lockIndexPath.hz_excelRow;
    CGFloat lockHeight = 0;
    if (lockRow > 0 && [self.delegate respondsToSelector:@selector(excelView:heightForRowAtIndex:)]) {
        for (NSInteger i = 0; i < lockRow; ++i) {
            CGFloat rowHeight = [self.delegate excelView:self heightForRowAtIndex:i];
            lockHeight += rowHeight;
        }
    }
    self.topExcelContentViewHeight = lockHeight;
}

-(BOOL)_doUpdateOtherExcelContentWithNow:(YZHUIExcelContentView*)now excelRowScrollInfo:(NSExcelRowScrollInfo*)scrollInfo
{
    YZHUIExcelContentView *update = nil;
    if (self.topExcelContentView == now) {
        update = self.bottomExcelContentView;
    }
    else
    {
        update = self.topExcelContentView;
    }
    
    return [update canUpdateExcelRowScrollInfo:scrollInfo];
}

#pragma mark YZHUIExcelContentViewDelegate

-(CGFloat)excelContentView:(YZHUIExcelContentView *)excelContentView heightForRowAtIndex:(NSInteger)rowIndex
{
    if ([self.delegate respondsToSelector:@selector(excelView:heightForRowAtIndex:)]) {
        return [self.delegate excelView:self heightForRowAtIndex:rowIndex];
    }
    return 0;
}

-(CGFloat)excelContentView:(YZHUIExcelContentView *)excelContentView widthForColumnAtIndex:(NSInteger)columnIndex
{
    if ([self.delegate respondsToSelector:@selector(excelView:widthForColumnAtIndex:)]) {
        return [self.delegate excelView:self widthForColumnAtIndex:columnIndex];
    }
    return 0;
}

-(UIView*)excelContentView:(YZHUIExcelContentView *)excelContentView excelCellForItemAtIndexPath:(NSIndexPath*)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView
{
    if ([self.delegate respondsToSelector:@selector(excelView:excelCellForItemAtIndexPath:withReusableExcelCellView:)]) {
        return [self.delegate excelView:self excelCellForItemAtIndexPath:indexPath withReusableExcelCellView:reusableExcelCellView];
    }
    return nil;
}

-(void)excelContentView:(YZHUIExcelContentView *)excelContentView didSelectExcelCellItemAtIndexPath:(NSIndexPath *)indexPath withReusableExcelCellView:(UIView *)reusableExcelCellView
{
    if ([self.delegate respondsToSelector:@selector(excelView:didSelectExcelCellItemAtIndexPath:withReusableExcelCellView:)]) {
        [self.delegate excelView:self didSelectExcelCellItemAtIndexPath:indexPath withReusableExcelCellView:reusableExcelCellView];
    }
}

-(BOOL)excelContentView:(YZHUIExcelContentView *)excelContentView canScrollExcelRowWithScrollInfo:(NSExcelRowScrollInfo *)scrollInfo
{
    return [self _doUpdateOtherExcelContentWithNow:excelContentView excelRowScrollInfo:scrollInfo];
}

-(void)reloadData
{
    [self _doReloadData];
}

-(void)reloadTopExcel
{
    [self _updateExcelFrame];
    [self.topExcelContentView.tableView reloadData];
}

-(void)reloadBottomExcel
{
    [self _updateExcelFrame];
    [self.bottomExcelContentView.tableView reloadData];
}

-(void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath*>*)indexPaths withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSMutableArray<NSIndexPath*> *topIndexPaths = [NSMutableArray array];
    NSMutableArray<NSIndexPath*> *bottomIndexPaths = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.hz_excelRow < self.lockIndexPath.hz_excelRow) {
            [topIndexPaths addObject:indexPath];
        }
        else {
            [bottomIndexPaths addObject:indexPath];
        }
    }
    [self _updateExcelFrame];
    if (IS_AVAILABLE_NSSET_OBJ(topIndexPaths)) {
        [self.topExcelContentView reloadRowsAtIndexPaths:topIndexPaths withRowAnimation:rowAnimation];
    }
    if (IS_AVAILABLE_NSSET_OBJ(bottomIndexPaths)) {
        [self.bottomExcelContentView reloadRowsAtIndexPaths:bottomIndexPaths withRowAnimation:rowAnimation];
    }
}

-(void)reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    NSMutableArray<NSIndexPath*> *topIndexPaths = [NSMutableArray array];
    NSMutableArray<NSIndexPath*> *bottomIndexPaths = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.hz_excelRow < self.lockIndexPath.hz_excelRow) {
            [topIndexPaths addObject:indexPath];
        }
        else {
            [bottomIndexPaths addObject:indexPath];
        }
    }

    if (IS_AVAILABLE_NSSET_OBJ(topIndexPaths)) {
        [self.topExcelContentView reloadItemsAtIndexPaths:topIndexPaths];
    }
    if (IS_AVAILABLE_NSSET_OBJ(bottomIndexPaths)) {
        [self.bottomExcelContentView reloadItemsAtIndexPaths:bottomIndexPaths];
    }
}
@end
