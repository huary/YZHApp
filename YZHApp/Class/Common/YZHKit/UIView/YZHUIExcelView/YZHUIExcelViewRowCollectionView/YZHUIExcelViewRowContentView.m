//
//  YZHUIExcelViewRowContentView.m
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIExcelViewRowContentView.h"
#import "YZHUIExcelItemCell.h"
#import "YZHUIExcelViewRowCollectionViewLayout.h"
#import "NSIndexPath+YZHUIExcelView.h"
#import "YZHKitType.h"

/****************************************************************************
 *YZHUIExcelViewRowContentView
 ****************************************************************************/
@interface YZHUIExcelViewRowContentView () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,YZHUIExcelItemCellDelegate>

@property (nonatomic, strong) YZHUIExcelViewRowCollectionViewLayout *flowLayout;

@end

@implementation YZHUIExcelViewRowContentView

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
        [self _setupRowContentViewChildView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

-(YZHUIExcelViewRowCollectionViewLayout*)flowLayout
{
    if (_flowLayout == nil) {
        _flowLayout = [[YZHUIExcelViewRowCollectionViewLayout alloc] init];
        _flowLayout.delegate = self;
    }
    return _flowLayout;
}

-(void)_setupRowContentViewChildView
{    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    self.collectionView.bounces = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = WHITE_COLOR;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.collectionView];
    
    [self.collectionView registerClass:[YZHUIExcelItemCell class] forCellWithReuseIdentifier:NSSTRING_FROM_CLASS(YZHUIExcelItemCell)];
}

-(NSIndexPath*)_excelIndexPathForCollectionCellIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath *excelIndexPath = [NSIndexPath hz_indexPathForExcelRow:self.excelRowIndex excelColumn:self.startColumnIndex + indexPath.item];
    return excelIndexPath;
}

#pragma mark UICollectionViewDelegate,UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(numberOfExcelCellsInRowContentView:)]) {
        NSInteger itemCnt= [self.delegate numberOfExcelCellsInRowContentView:self];
        return itemCnt;
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YZHUIExcelItemCell *excelCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSSTRING_FROM_CLASS(YZHUIExcelItemCell) forIndexPath:indexPath];
    
    NSIndexPath *excelIndexPath = [self _excelIndexPathForCollectionCellIndexPath:indexPath];
    excelCell.indexPath = excelIndexPath;
    excelCell.verticalLineType = self.verticalLineType;
    excelCell.verticalLineWidth = self.verticalLineWidth;
    excelCell.verticalLineColor = self.verticalLineColor;
    
    if ([self.delegate respondsToSelector:@selector(excelViewRowContentView:excelCellForItemAtIndexPath:withReusableExcelCellView:)]) {
        UIView *cellItem = [self.delegate excelViewRowContentView:self excelCellForItemAtIndexPath:excelIndexPath withReusableExcelCellView:excelCell.reusableExcelCellSubView];
        
        [excelCell addExcelCellView:cellItem];
    }
    excelCell.cellDelegate = self;
    return excelCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self _dispatchScrollInfo:collectionView scrollType:NSExcelRowScrollTypeDrive scrollState:NSExcelRowScrollStateEnd];
    
    NSIndexPath *excelIndexPath = [self _excelIndexPathForCollectionCellIndexPath:indexPath];
    YZHUIExcelItemCell *excelCell = (YZHUIExcelItemCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(excelViewRowContentView:didSelectExcelCellItemAtIndexPath:withReusableExcelCellView:)]) {
        [self.delegate excelViewRowContentView:self didSelectExcelCellItemAtIndexPath:excelIndexPath withReusableExcelCellView:excelCell.reusableExcelCellSubView];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSExcelRowScrollType scrollType = NSExcelRowScrollTypeNull;
    NSExcelRowScrollState scrollState = NSExcelRowScrollStateMove;
    if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        scrollType = NSExcelRowScrollTypeDrive;
        scrollState = NSExcelRowScrollStateBegin;
    }
    else if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        scrollType = NSExcelRowScrollTypeDrive;
        scrollState = NSExcelRowScrollStateMove;
    }
    else if (scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        scrollType = NSExcelRowScrollTypeDrive;
        scrollState = NSExcelRowScrollStateEnd;
    }
    else
    {
    }
    if (self.excelRowIndex == self.scrollInfo.driveScrollRowIndex) {
    }
    
    [self _dispatchScrollInfo:scrollView scrollType:scrollType scrollState:scrollState];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self _dispatchScrollInfo:scrollView scrollType:NSExcelRowScrollTypeDrive scrollState:NSExcelRowScrollStateBegin];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self _dispatchScrollInfo:scrollView scrollType:NSExcelRowScrollTypeDrive scrollState:NSExcelRowScrollStateEnd];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self _dispatchScrollInfo:scrollView scrollType:NSExcelRowScrollTypeDrive scrollState:NSExcelRowScrollStateEnd];
}

-(BOOL)_dispatchScrollInfoCheck:(UIScrollView *)scrollView
{
    if (self.scrollInfo.scrollState == NSExcelRowScrollStateEnd) {
        return YES;
    }
    if (self.scrollInfo.scrollType == NSExcelRowScrollTypeDrive) {
        return YES;
    }
    return NO;
}

-(void)_dispatchScrollInfo:(UIScrollView *)scrollView scrollType:(NSExcelRowScrollType)scrollType scrollState:(NSExcelRowScrollState)scrollState
{
    if (scrollType != NSExcelRowScrollTypeNull) {
        self.scrollInfo.scrollType = scrollType;
    }
    self.scrollInfo.scrollState = scrollState;
    
    if (![self _dispatchScrollInfoCheck:scrollView]) {
        return;
    }
    self.scrollInfo.scrollType = NSExcelRowScrollTypeDrive;
    self.scrollInfo.scrollContentOffset = scrollView.contentOffset;
    self.scrollInfo.driveScrollRowIndex = self.excelRowIndex;
    
    if ([self.delegate respondsToSelector:@selector(excelViewRowContentView:canScrollExcelRowWithScrollInfo:)]) {
        BOOL canDrive = [self.delegate excelViewRowContentView:self canScrollExcelRowWithScrollInfo:self.scrollInfo];
        if (!canDrive) {
            self.scrollInfo.scrollType = NSExcelRowScrollTypeDriven;
            scrollView.contentOffset = self.scrollInfo.scrollContentOffset;
        }
    }
}

#pragma mark UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *excelIndexPath = [self _excelIndexPathForCollectionCellIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(excelViewRowContentView:excelCellSizeForItemAtIndexPath:)]) {
        CGSize itemSize = [self.delegate excelViewRowContentView:self excelCellSizeForItemAtIndexPath:excelIndexPath];
        return itemSize;
    }
    return CGSizeMake(60, 40);
}


#pragma mark YZHUIExcelItemCellDelegate
-(void)excelItemCell:(YZHUIExcelItemCell *)excelItemCell touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
}

-(void)setScrollInfo:(NSExcelRowScrollInfo *)scrollInfo
{
    _scrollInfo = scrollInfo;
    [self.collectionView setContentOffset:scrollInfo.scrollContentOffset animated:NO];
}

@end
