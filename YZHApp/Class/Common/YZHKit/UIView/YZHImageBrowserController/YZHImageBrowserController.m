//
//  YZHImageBrowserController.m
//
//
//  Created by yuan on 2020/8/31.
//  Copyright © 2020 lizhi. All rights reserved.
//

#import "YZHImageBrowserController.h"
#import "YZHImageCellModel.h"

@interface YZHImageBrowserController ()<YZHImageBrowserDelegate>

@property (nonatomic, strong) YZHImageBrowser *imageBrowser;

@property (nonatomic, strong) NSMutableArray<YZHImageCellModel*> *cacheList;

@end

@implementation YZHImageBrowserController

- (YZHImageBrowser *)imageBrowser
{
    if (_imageBrowser == nil) {
        _imageBrowser = [YZHImageBrowser new];
        _imageBrowser.animateDuration = 0.2;
        _imageBrowser.animationOptions = UIViewAnimationOptionCurveEaseInOut;
        _imageBrowser.imageBrowserView.minScaleToRemove = 0.75;
        _imageBrowser.delegate = self;
        _imageBrowser.imageBrowserView.loopScrollView.scrollDirection = YZHLoopViewScrollDirectionHorizontal;
        if (self.totalPage > 0 && self.currentPage > 0) {
            _imageBrowser.currentPage = self.currentPage;
            _imageBrowser.totalPage = self.totalPage;
        }
    }
    return _imageBrowser;
}

- (NSMutableArray<YZHImageCellModel*>*)cacheList
{
    if (!_cacheList) {
        _cacheList = [NSMutableArray array];
    }
    return _cacheList;
}

- (void)pri_prepareStart
{
    [_cacheList removeAllObjects];
}

- (void)showInView:(UIView *_Nullable)inView
          fromView:(UIView *_Nullable)fromView
             image:(UIImage *_Nullable)image
             model:(id _Nullable)model
{
    [self pri_prepareStart];
    YZHImageCellModel *cellModel = [self pri_cellModelForTarget:model];
    [self.cacheList addObject:cellModel];
    [self.imageBrowser showInView:inView fromView:fromView image:image withModel:cellModel];
}

- (void)dismiss
{
    [_imageBrowser dismiss];
    [self pri_dismissAction];
}

- (void)pri_dismissAction
{
    _imageBrowser = nil;
    [_cacheList removeAllObjects];
}

- (YZHImageCellModel *)pri_cellModelForTarget:(id)target
{
    YZHImageCellModel *cellModel = [YZHImageCellModel new];
    cellModel.target = target;
    cellModel.isEnd = target ? NO : YES;
    WEAK_SELF(weakSelf);
    cellModel.updateBlock = ^(id<YZHImageCellModelProtocol> model, YZHImageCell *imageCell) {
        YZHImageCellModel *tmp = (YZHImageCellModel *)model;
        [imageCell updateWithImage:nil];
        if (weakSelf.updateCellBlock) {
            weakSelf.updateCellBlock(tmp.target, imageCell);
        }
    };
    return cellModel;
}

- (YZHImageCellModel *)pri_findCellModelWithModel:(YZHImageCellModel *)model next:(BOOL)next
{
    NSInteger idx = [self.cacheList indexOfObject:model];
    if (idx == NSNotFound) {
        return nil;
    }
    
    if (next) {
        idx = idx + 1;
    }
    else {
        idx = idx - 1;
    }
    
    if (idx >= 0 && idx < self.cacheList.count) {
        return self.cacheList[idx];
    }
    return nil;
}

- (YZHImageCellModel *)pri_cellModelForCurrentShowModel:(YZHImageCellModel* _Nullable)currentShowModel possibleModel:(YZHImageCellModel *_Nullable)possibleModel next:(BOOL)next
{
    if (!currentShowModel) {
        return nil;
    }
    YZHImageCellModel *findObj = [self pri_findCellModelWithModel:currentShowModel next:next];
    if (findObj) {
        if (findObj.isEnd) {
            return nil;
        }
        return findObj;
    }
    if (!self.fetchBlock) {
        return nil;
    }
    
    __block BOOL asyncFetch = NO;
    __block YZHImageCellModel *findObjTmp = [self pri_cellModelForTarget:nil];
    WEAK_SELF(weakSelf);
    self.fetchBlock(currentShowModel.target, next, ^(id  _Nonnull currModel, BOOL next, NSArray * _Nonnull list) {
        STRONG_SELF_NIL_RETURN(strongSelf, );
        if (list.count > 0) {
            NSInteger idx = [strongSelf.cacheList indexOfObject:currentShowModel];
            
            NSMutableArray *newList = [NSMutableArray array];
            for (id model in list) {
                [newList addObject:[strongSelf pri_cellModelForTarget:model]];
            }
            
            if (next) {
                if (idx != NSNotFound) {
                    [strongSelf.cacheList replaceObjectsInRange:NSMakeRange(idx + 1, strongSelf.cacheList.count - idx - 1) withObjectsFromArray:newList];
                }
                else {
                    [strongSelf.cacheList addObjectsFromArray:newList];
                }
            }
            else {
                if (idx != NSNotFound) {
                    [strongSelf.cacheList replaceObjectsInRange:NSMakeRange(0, idx) withObjectsFromArray:newList];
                }
                else {
                    [strongSelf.cacheList insertObjects:newList atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newList.count)]];
                }
            }
        }
        else {
            YZHImageCellModel *endModel = [YZHImageCellModel new];
            endModel.isEnd = YES;
            if (next) {
                YZHImageCellModel *last = [strongSelf.cacheList lastObject];
                if (!last.isEnd) {
                    [strongSelf.cacheList addObject:endModel];
                }
            }
            else {
                YZHImageCellModel *first = [strongSelf.cacheList firstObject];
                if (!first.isEnd) {
                    [strongSelf.cacheList insertObject:endModel atIndex:0];
                }
            }
        }
        if (asyncFetch) {
            dispatch_async_in_main_queue(^{
                [strongSelf.imageBrowser.imageBrowserView.loopScrollView reloadData];
            });
        }
        else {
            findObjTmp = [strongSelf pri_findCellModelWithModel:currentShowModel next:next];
        }
    });
    asyncFetch = YES;
    if (findObjTmp.isEnd) {
        return nil;
    }
    return findObjTmp;
}

#pragma mark - YZHImageBrowserDelegate
- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didDoubleTapImageCell:(nonnull YZHImageCell *)imageCell {
    
}

- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didLongPressImageCell:(nonnull YZHImageCell *)imageCell {
    
}

- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didTapImageCell:(nonnull YZHImageCell *)imageCell {
    
}

- (void)imageBrowser:(YZHImageBrowser *)imageBrowser currentPage:(NSUInteger)currentPage totalPage:(NSUInteger)totalPage {
    if (self.updatePageBlock) {
        self.updatePageBlock(self, currentPage, totalPage);
    }
}

- (id<YZHImageCellModelProtocol> _Nullable)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser newModelWithCurrentShowModel:(id<YZHImageCellModelProtocol> _Nullable)currentShowModel possibleModel:(id<YZHImageCellModelProtocol> _Nullable)possibleModel {
    if (currentShowModel && [self.cacheList containsObject:(YZHImageCellModel*)currentShowModel]) {
        return currentShowModel;
    }
    else {
        return nil;
    }
}

- (id<YZHImageCellModelProtocol> _Nullable)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser nextModelWithCurrentShowModel:(id<YZHImageCellModelProtocol> _Nullable)currentShowModel possibleModel:(id<YZHImageCellModelProtocol> _Nullable)possibleModel {
    return [self pri_cellModelForCurrentShowModel:(YZHImageCellModel*)currentShowModel possibleModel:(YZHImageCellModel*)possibleModel next:YES];
}

- (id<YZHImageCellModelProtocol> _Nullable)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser prevModelWithCurrentShowModel:(id<YZHImageCellModelProtocol> _Nullable)currentShowModel possibleModel:(id<YZHImageCellModelProtocol> _Nullable)possibleModel {
    return [self pri_cellModelForCurrentShowModel:(YZHImageCellModel*)currentShowModel possibleModel:(YZHImageCellModel*)possibleModel next:NO];
}

- (void)imageBrowserDidDismiss:(YZHImageBrowser *)imageBrowser
{
    if (_imageBrowser == imageBrowser) {
        [self pri_dismissAction];
        if (self.dismissBlock) {
            self.dismissBlock(self);
        }
    }
}

- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser willDisplayCell:(nonnull YZHImageCell *)imageCell {
    
}

- (void)imageBrowser:(YZHImageBrowser *)imageBrowser didDisplayCell:(YZHImageCell *)imageCell {
    YZHImageCellModel *tmp = (YZHImageCellModel *)imageCell.model;
    if (self.currentShowCellBlock) {
        self.currentShowCellBlock(tmp.target, imageCell);
    }
}

- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didEndDragToRecoverForCell:(nonnull YZHImageCell *)imageCell {
    
}

- (UIView * _Nullable)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser willDragToDismissForCell:(nonnull YZHImageCell *)imageCell {
    return nil;
}


- (void)imageBrowserDidEndDragging:(YZHImageBrowser * _Nonnull)imageBrowser willDecelerate:(BOOL)decelerate {
    
}


- (void)imageBrowserWillBeginDragging:(YZHImageBrowser * _Nonnull)imageBrowser {
    
}


- (void)imageBrowserWillEndDragging:(YZHImageBrowser * _Nonnull)imageBrowser dragVector:(YZHScrollViewDragVector)dragVector {
}


@end
