//
//  YZHLoopScrollView.h
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/5.
//  Copyright © 2019 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHLoopCell.h"


typedef NS_ENUM(NSInteger, YZHLoopViewScrollDirection)
{
    YZHLoopViewScrollDirectionHorizontal        = 0,
    YZHLoopViewScrollDirectionVertical          = 1,
};

@class YZHLoopScrollView;

NS_ASSUME_NONNULL_BEGIN

@protocol YZHLoopScrollViewDelegate <NSObject>

//这个代理方法后会自动给cell设置model
-(YZHLoopCell *_Nullable)loopScrollView:(YZHLoopScrollView * _Nonnull)loopScrollView cellForModel:(id<YZHLoopCellModelProtocol>_Nullable)model withReusableCell:(YZHLoopCell *_Nullable)reusableCell;

//这个代理方法后不会给cell设置model,在返回cell的时候，cell的model已经赋值（因为不知道model）
-(YZHLoopCell *_Nullable)loopScrollView:(YZHLoopScrollView * _Nonnull)loopScrollView nextCellWithCurrentShowModel:(id<YZHLoopCellModelProtocol>_Nullable)currentShowModel withReusableCell:(YZHLoopCell *_Nullable)reusableCell;

//这个代理方法后不会给cell设置model,在返回cell的时候，cell的model已经赋值（因为不知道model）
-(YZHLoopCell *_Nullable)loopScrollView:(YZHLoopScrollView * _Nonnull)loopScrollView prevCellWithCurrentShowModel:(id<YZHLoopCellModelProtocol>_Nullable)currentShowModel withReusableCell:(YZHLoopCell *_Nullable)reusableCell;

- (void)loopScrollViewWillBeginDragging:(YZHLoopScrollView * _Nonnull)loopScrollView;

- (void)loopScrollViewDidEndDragging:(YZHLoopScrollView * _Nonnull)loopScrollView willDecelerate:(BOOL)decelerate;

@end


@interface YZHLoopScrollView : UIView

/** separatorSpace 为显示页之间的间隔，默认为0 */
@property (nonatomic, assign) CGFloat separatorSpace;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, weak) id<YZHLoopScrollViewDelegate> delegate;

/** 滚动的方向 */
@property (nonatomic, assign) YZHLoopViewScrollDirection scrollDirection;

- (void)loadViewWithModel:(id<YZHLoopCellModelProtocol>)model;

- (void)loadViewTo:(BOOL)next;

- (void)reloadData;

- (YZHLoopCell*)currentShowCell;

- (CGSize)pageSize;

- (CGRect)cellContentViewFrame;

@end

NS_ASSUME_NONNULL_END
