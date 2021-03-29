//
//  YZHLoopScrollView.m
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/5.
//  Copyright © 2019 yuan. All rights reserved.
//

#import "YZHLoopScrollView.h"

typedef NS_ENUM(NSInteger, _YZHScrollViewDragVector)
{
    //drag 0 向量
    _YZHScrollViewDragVectorNone    = 0,
    //drag 前进方向(contentoffset 变大)
    _YZHScrollViewDragVectorNext    = 1,
    //drag 后退方向(contentoffset 变小)
    _YZHScrollViewDragVectorPrev    = 2,
};

/**********************************************************************
 *YZHLoopScrollView ()
 ***********************************************************************/
@interface YZHLoopScrollView ()<UIScrollViewDelegate>

//@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray<YZHLoopCell*> *cacheCells;

@property (nonatomic, strong) YZHLoopCell *cell;

@property (nonatomic, strong) YZHLoopCell *prevCell;

@property (nonatomic, strong) YZHLoopCell *nextCell;

@property (nonatomic, assign) CGPoint dragFromOffset;

@property (nonatomic, assign) CGPoint dragToOffset;

@property (nonatomic, assign) CGPoint lastScrollOffset;

@property (nonatomic, assign) _YZHScrollViewDragVector dragVector;

@end

@implementation YZHLoopScrollView

@synthesize scrollView = _scrollView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self pri_setupLoopScrollViewChildView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect scrollViewFrame = [self pri_getScrollViewFrameWithFrame:self.bounds];
    if (!CGRectEqualToRect(self.scrollView.frame, scrollViewFrame)) {
        self.scrollView.frame = scrollViewFrame;
        [self loadViewWithModel:self.cell.model];
    }
}

- (UIScrollView*)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 1.0;
        _scrollView.pinchGestureRecognizer.enabled = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

-(NSMutableArray<YZHLoopCell*>*)cacheCells
{
    if (_cacheCells == nil) {
        _cacheCells = [NSMutableArray array];
    }
    return _cacheCells;
}

- (void)pri_setupLoopScrollViewChildView
{
    self.clipsToBounds = YES;
    [self addSubview:self.scrollView];
    self.scrollView.frame = [self pri_getScrollViewFrameWithFrame:self.bounds];
}

- (CGRect)pri_getScrollViewFrameWithFrame:(CGRect)frame
{
    CGRect retFrame = frame;
    if (self.separatorSpace > 0.0 && frame.size.width > 0.0 && frame.size.height > 0.0) {
        if (self.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
            CGFloat dx = -self.separatorSpace/2;
            retFrame = CGRectInset(frame, dx, 0);
        }
        else {
            CGFloat dy = -self.separatorSpace/2;
            retFrame = CGRectInset(frame, 0, dy);
        }
    }
    return retFrame;
}

- (YZHLoopCell*)pri_reusableCellWithPossibleModel:(id<YZHLoopCellModelProtocol>)possibleModel
{
    if (self.cacheCells.count == 0) {
        return nil;
    }
    
    YZHLoopCell *cell = nil;
    if (possibleModel) {
        for (YZHLoopCell *cellTmp in self.cacheCells) {
            if (cellTmp.model == possibleModel) {
                cell = cellTmp;
                break;
            }
        }
    }
    if (cell == nil) {
        cell = [self.cacheCells lastObject];
    }
    [self.cacheCells removeObject:cell];
    return cell;
}

- (YZHLoopCell*)pri_cellWithModel:(id<YZHLoopCellModelProtocol>)model
{
    YZHLoopCell *cell = nil;
    YZHLoopCell *reusableCell = [self pri_reusableCellWithPossibleModel:model];
    if ([self.delegate respondsToSelector:@selector(loopScrollView:cellForModel:withReusableCell:)]) {
        cell = [self.delegate loopScrollView:self cellForModel:model withReusableCell:reusableCell];
        if (cell) {
            cell.model = model;
            return cell;
        }
        else {
            if (reusableCell) {
                if (self.cacheCells.count  == 0) {
                    [self.cacheCells addObject:reusableCell];
                }
                else {
                    [self.cacheCells insertObject:reusableCell atIndex:0];
                }
            }
        }
    }
    cell = [YZHLoopCell new];
    cell.model = model;
    return cell;
}

- (YZHLoopCell*)pri_nextCell:(BOOL)next withCurrentShowModel:(id<YZHLoopCellModelProtocol>)currentShowModel
{
    YZHLoopCell *cell = nil;
    YZHLoopCell *reusableCell = [self pri_reusableCellWithPossibleModel:nil];
    if (next) {
        if ([self.delegate respondsToSelector:@selector(loopScrollView:nextCellWithCurrentShowModel:withReusableCell:)]) {
            cell = [self.delegate loopScrollView:self nextCellWithCurrentShowModel:currentShowModel withReusableCell:reusableCell];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(loopScrollView:prevCellWithCurrentShowModel:withReusableCell:)]) {
            cell = [self.delegate loopScrollView:self prevCellWithCurrentShowModel:currentShowModel withReusableCell:reusableCell];
        }
    }
    if (cell == nil && reusableCell) {
        if (self.cacheCells.count  == 0) {
            [self.cacheCells addObject:reusableCell];
        }
        else {
            [self.cacheCells insertObject:reusableCell atIndex:0];
        }
    }
    return cell;
}

- (void)pri_adjustCellFrame:(NSInteger)pages
{
    CGSize size = self.scrollView.bounds.size;
    if (size.width == 0.0 || size.height == 0.0) {
        return;
    }
    
    CGPoint contentInsets = CGPointZero;
    if (self.separatorSpace > 0) {
        if (self.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
            contentInsets.x = self.separatorSpace/2;
        }
        else {
            contentInsets.y = self.separatorSpace/2;
        }
    }
    
    if (pages == 1) {
        self.cell.frame = CGRectMake(0, 0, size.width, size.height);
        self.scrollView.contentSize = self.cell.bounds.size;
        self.scrollView.contentOffset = CGPointZero;
    }
    else if (pages == 2) {
        if (self.prevCell) {
            self.prevCell.frame = CGRectMake(0, 0, size.width, size.height);
            if (self.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
                self.cell.frame = CGRectMake(size.width, 0, size.width, size.height);
                self.scrollView.contentSize = CGSizeMake(pages * size.width, size.height);
                self.scrollView.contentOffset = CGPointMake(size.width, 0);
            }
            else {
                self.cell.frame = CGRectMake(0, size.height, size.width, size.height);
                self.scrollView.contentSize = CGSizeMake(size.width, pages * size.height);
                self.scrollView.contentOffset = CGPointMake(0, size.height);
            }
        }
        else {
            self.cell.frame = CGRectMake(0, 0, size.width, size.height);
            if (self.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
                self.nextCell.frame = CGRectMake(size.width, 0, size.width, size.height);
                self.scrollView.contentSize = CGSizeMake(pages * size.width, size.height);
                self.scrollView.contentOffset = CGPointMake(0, 0);
            }
            else {
                self.nextCell.frame = CGRectMake(0, size.height, size.width, size.height);
                self.scrollView.contentSize = CGSizeMake(size.width, pages * size.height);
                self.scrollView.contentOffset = CGPointMake(0, 0);
            }
        }
    }
    else if (pages == 3) {
        self.prevCell.frame = CGRectMake(0, 0, size.width, size.height);
        if (self.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
            self.cell.frame = CGRectMake(size.width, 0, size.width, size.height);
            self.nextCell.frame = CGRectMake(2 * size.width, 0, size.width, size.height);
            self.scrollView.contentSize = CGSizeMake(pages * size.width, size.height);
            self.scrollView.contentOffset = CGPointMake(size.width, 0);
        }
        else {
            self.cell.frame = CGRectMake(0, size.height, size.width, size.height);
            self.nextCell.frame = CGRectMake(0, 2 * size.height, size.width, size.height);
            self.scrollView.contentSize = CGSizeMake(size.width, pages * size.height);
            self.scrollView.contentOffset = CGPointMake(0, size.height);
        }
    }
    self.cell.contentInsets = contentInsets;
    self.nextCell.contentInsets = contentInsets;
    self.prevCell.contentInsets = contentInsets;
   
//    CGSize csize = self.scrollView.contentSize;
//    CGPoint offset = self.scrollView.contentOffset;
    
//    NSLog(@"offset.x=%f,pages=%ld,w=%f",offset.x,pages,csize.width);
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    CGSize size = scrollView.bounds.size;
    CGPoint contentOffset = scrollView.contentOffset;
    
    if (self.dragVector == _YZHScrollViewDragVectorNext) {
        if (self.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
            if (contentOffset.x == self.dragToOffset.x ||
                (self.lastScrollOffset.x < self.dragToOffset.x && contentOffset.x > self.dragToOffset.x)) {
                [self loadViewTo:YES];
            }
        }
        else {
            if (contentOffset.y == self.dragToOffset.y ||
                (self.lastScrollOffset.y < self.dragToOffset.y && contentOffset.y > self.dragToOffset.y)) {
                [self loadViewTo:YES];
            }
        }
    }
    else if (self.dragVector == _YZHScrollViewDragVectorPrev)
    {
        if (self.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
            if (contentOffset.x == self.dragToOffset.x ||
                (self.lastScrollOffset.x > self.dragToOffset.x && contentOffset.x < self.dragToOffset.x)) {
                [self loadViewTo:NO];
            }
        }
        else {
            if (contentOffset.y == self.dragToOffset.y ||
                (self.lastScrollOffset.y > self.dragToOffset.y && contentOffset.y < self.dragToOffset.y)) {
                [self loadViewTo:NO];
            }
        }
    }
    self.lastScrollOffset = contentOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.dragFromOffset = scrollView.contentOffset;
    if ([self.delegate respondsToSelector:@selector(loopScrollViewWillBeginDragging:)]) {
        [self.delegate loopScrollViewWillBeginDragging:self];
    }
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //在这里最好判断下contentOffset是否是scrollView看整数倍
    CGSize size = scrollView.bounds.size;
    CGSize contentSize = scrollView.contentSize;
    CGPoint contentOffset = *targetContentOffset;
    self.dragToOffset = contentOffset;

    _YZHScrollViewDragVector dragVector = _YZHScrollViewDragVectorNone;
    if (self.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
        CGFloat x = fmax(self.dragFromOffset.x, 0);
        x = fmin(x, contentSize.width - size.width);
        self.dragFromOffset = CGPointMake(x, 0);
        if (contentOffset.x == 0 || contentOffset.x == size.width || contentOffset.x == 2 * size.width ) {
            if (self.dragToOffset.x > self.dragFromOffset.x) {
                dragVector = _YZHScrollViewDragVectorNext;
            }
            else if (self.dragToOffset.x < self.dragFromOffset.x) {
                dragVector = _YZHScrollViewDragVectorPrev;
            }
            else {
                dragVector = _YZHScrollViewDragVectorNone;
            }
        }
        else {
            dragVector = _YZHScrollViewDragVectorNone;
        }
    }
    else {
        CGFloat y = fmax(self.dragFromOffset.y, 0);
        y = fmin(y, contentSize.height - size.height);
        self.dragFromOffset = CGPointMake(0, y);
        
        if (contentOffset.y == 0 || contentOffset.y == size.height || contentOffset.y == 2 * size.height) {
            if (self.dragToOffset.y > self.dragFromOffset.y) {
                dragVector = _YZHScrollViewDragVectorNext;
            }
            else if (self.dragToOffset.y < self.dragFromOffset.y) {
                dragVector = _YZHScrollViewDragVectorPrev;
            }
            else {
                dragVector = _YZHScrollViewDragVectorNone;
            }
        }
        else {
            dragVector = _YZHScrollViewDragVectorNone;
        }
    }
//    NSLog(@"from.x=%f,to.x=%f,vector=%ld",self.dragFromOffset.x,self.dragToOffset.x,dragVector);
    self.dragVector = dragVector;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(loopScrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate loopScrollViewDidEndDragging:self willDecelerate:decelerate];
    }
}

#pragma mark public
- (void)setSeparatorSpace:(CGFloat)separatorSpace
{
    _separatorSpace = separatorSpace;
    self.scrollView.frame = [self pri_getScrollViewFrameWithFrame:self.bounds];
    [self loadViewWithModel:self.cell.model];
}


- (void)loadViewWithModel:(id<YZHLoopCellModelProtocol>)model
{
    if (model == nil) {
        return;
    }
    id<UIScrollViewDelegate> delegate = self.scrollView.delegate;
    self.scrollView.delegate = nil;
    //按如下(prev,cell,next)顺序放入
    if (self.prevCell) {
        [self.prevCell removeFromSuperview];
        [self.cacheCells addObject:self.prevCell];
    }
    if (self.cell) {
        [self.cell removeFromSuperview];
        [self.cacheCells addObject:self.cell];
    }
    if (self.nextCell) {
        [self.nextCell removeFromSuperview];
        [self.cacheCells addObject:self.nextCell];
    }
    
    //按如下（cell,prev,next）顺序add
    NSInteger pages = 0;
    YZHLoopCell *cell = [self pri_cellWithModel:model];
    if (cell) {
        ++pages;
        [self.scrollView addSubview:cell];
    }
    self.cell = cell;
    
    YZHLoopCell *prevCell = [self pri_nextCell:NO withCurrentShowModel:model];
    if (prevCell) {
        ++pages;
        [self.scrollView addSubview:prevCell];
    }
    self.prevCell = prevCell;
    
    YZHLoopCell *nextCell = [self pri_nextCell:YES withCurrentShowModel:model];
    if (nextCell) {
        ++pages;
        [self.scrollView addSubview:nextCell];
    }
    self.nextCell = nextCell;
    
    [self pri_adjustCellFrame:pages];
    
    self.scrollView.delegate = delegate;
}

- (void)loadViewTo:(BOOL)next
{
    id<YZHLoopCellModelProtocol> model = self.cell.model;

    if (next) {
        model = self.nextCell.model;
    }
    else {
        model = self.prevCell.model;
    }
    if (model == nil) {
        return;
    }
    
    [self loadViewWithModel:model];
    self.dragVector = _YZHScrollViewDragVectorNone;
}

- (void)reloadData
{
    [self loadViewWithModel:self.cell.model];
}

- (YZHLoopCell*)currentShowCell
{
    return self.cell;
}

- (CGSize)pageSize
{
    return self.scrollView.bounds.size;
}

- (CGRect)cellContentViewFrame
{
    CGRect frame = self.scrollView.bounds;
    if (self.scrollDirection == YZHLoopViewScrollDirectionHorizontal) {
        return CGRectInset(frame, self.separatorSpace/2, 0);
    }
    else {
        return CGRectInset(frame, 0, self.separatorSpace/2);
    }
}

@end
