//
//  YZHImageBrowser.h
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/6.
//  Copyright © 2019 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YZHImageCell.h"
#import "YZHImageBrowserView.h"
#import "YZHImageCellModelProtocol.h"

typedef NS_OPTIONS(NSInteger, YZHImageBrowserActionOptions)
{
    YZHImageBrowserActionOptionsSingleTapDismiss    = (1 << 0),
    YZHImageBrowserActionOptionsDoubleTapZoomScale  = (1 << 1),
};

NS_ASSUME_NONNULL_BEGIN
@class YZHImageBrowser;
@protocol YZHImageBrowserDelegate <NSObject>

- (id<YZHImageCellModelProtocol> _Nullable)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser
                           newModelWithCurrentShowModel:(id<YZHImageCellModelProtocol>_Nullable)currentShowModel
                                          possibleModel:(id<YZHImageCellModelProtocol>_Nullable)possibleModel;

- (id<YZHImageCellModelProtocol> _Nullable)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser
                          nextModelWithCurrentShowModel:(id<YZHImageCellModelProtocol>_Nullable)currentShowModel
                                          possibleModel:(id<YZHImageCellModelProtocol>_Nullable)possibleModel;

- (id<YZHImageCellModelProtocol> _Nullable)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser
                          prevModelWithCurrentShowModel:(id<YZHImageCellModelProtocol>_Nullable)currentShowModel
                                          possibleModel:(id<YZHImageCellModelProtocol>_Nullable)possibleModel;

///即将添加到父view上
- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser willDisplayCell:(YZHImageCell *)imageCell;

///已经添加到父view上，并且frame已经调整完成
- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didDisplayCell:(YZHImageCell *)imageCell;

/// scrollView即将开始拖拽
- (void)imageBrowserWillBeginDragging:(YZHImageBrowser * _Nonnull)imageBrowser;

/// scrollView即将结束拖拽
- (void)imageBrowserWillEndDragging:(YZHImageBrowser * _Nonnull)imageBrowser dragVector:(YZHScrollViewDragVector)dragVector;

/// scrollView已经结束拖拽
- (void)imageBrowserDidEndDragging:(YZHImageBrowser * _Nonnull)imageBrowser willDecelerate:(BOOL)decelerate;

/// 进行transition拖拽时需要返回的UIView
- (UIView *_Nullable)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser willDragToDismissForCell:(YZHImageCell *)imageCell;

/// 进行transition拖拽后进行的恢复（没有dismiss）
- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didEndDragToRecoverForCell:(YZHImageCell *)imageCell;

/// 点击ImageCell
- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didTapImageCell:(YZHImageCell *)imageCell;

/// 双击ImageCell
- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didDoubleTapImageCell:(YZHImageCell *)imageCell;

/// 长按ImageCell
- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didLongPressImageCell:(YZHImageCell *)imageCell;

/// 图片预览器已经dismiss
- (void)imageBrowserDidDismiss:(YZHImageBrowser * _Nonnull)imageBrowser;

/// 当前页数回调
- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser currentPage:(NSUInteger)currentPage totalPage:(NSUInteger)totalPage;

@end


@class YZHImageBrowserAnimationContext;
typedef void(^YZHImageBrowserWillAnimateBlock)(YZHImageBrowser *imageBrowser,YZHImageBrowserAnimationContext *context);
typedef void(^YZHImageBrowserAnimationBlock)(YZHImageBrowser *imageBrowser,YZHImageBrowserAnimationContext *context);
typedef void(^YZHImageBrowserDidAnimateBlock)(YZHImageBrowser *imageBrowser,YZHImageBrowserAnimationContext *context);

@interface YZHImageBrowserAnimationContext : NSObject
/** 这个是showInView传进来的showInView */
@property (nonatomic, strong) UIView *showInView;

/** 需要在willAnimateBlock时赋值的 */
@property (nonatomic, strong) UIView *animationView;

/** 需要在willAnimateBlock时赋值的 */
@property (nonatomic, assign) CGRect animationViewEndFrame;

/** 即将开始展示动画 */
@property (nonatomic, copy) YZHImageBrowserWillAnimateBlock willAnimateBlock;

/** 自定义展示动画 */
@property (nonatomic, copy) YZHImageBrowserAnimationBlock animationBlock;

/** 完成展示动画 */
@property (nonatomic, copy) YZHImageBrowserDidAnimateBlock didAnimateBlock;

@end

@interface YZHImageBrowser : NSObject

@property (nonatomic, strong, readonly) YZHImageBrowserView *imageBrowserView;

@property (nonatomic, weak) id<YZHImageBrowserDelegate> delegate;

/// 最小允许的缩小值
@property (nonatomic, assign) CGFloat minZoomScale;

/// 最大允许的缩小值
@property (nonatomic, assign) CGFloat maxZoomScale;

/// 显示页之间的间隔
@property (nonatomic, assign) CGFloat separatorSpace;

/// 展示 & 消失动画时长
@property (nonatomic, assign) NSTimeInterval animateDuration;

/// 展示 & 消失animationOptions
@property (nonatomic, assign) UIViewAnimationOptions animationOptions;

/*默认为-1，（YZHImageBrowserActionOptionsSingleTapDismiss|YZHImageBrowserActionOptionsDoubleTapZoomScale） */
@property (nonatomic, assign) YZHImageBrowserActionOptions actionOptions;

//默认为YZHImageCell,自定义需要继承自YZHImageCell
@property (nonatomic, assign) Class imageCellClass;

@property (nonatomic, assign) NSUInteger currentPage;

@property (nonatomic, assign) NSUInteger totalPage;

- (UIView *)showInView;

- (UIView *)fromView;

- (YZHImageCell*)currentShowCell;

- (void)showInView:(UIView * _Nullable)showInView
          fromView:(UIView * _Nullable)fromView
             image:(UIImage * _Nullable)image
         withModel:(id<YZHImageCellModelProtocol>)model;

- (void)showInView:(UIView * _Nullable)showInView
          fromView:(UIView * _Nullable)fromView
         withModel:(id<YZHImageCellModelProtocol>)model
  animationContext:(YZHImageBrowserAnimationContext *)animationContext;

- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
