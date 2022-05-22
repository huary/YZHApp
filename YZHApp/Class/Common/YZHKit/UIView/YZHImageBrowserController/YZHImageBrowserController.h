//
//  YZHImageBrowserController.h
//  
//
//  Created by yuan on 2020/8/31.
//  Copyright © 2020 lizhi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHImageBrowser.h"

NS_ASSUME_NONNULL_BEGIN

@class YZHImageBrowserController;
typedef void(^YZHImageBrowserControllerFetchCompletionBlock)(id currModel, BOOL next, NSArray *list);
//在主线程调用fetchCompletionBlock
typedef void(^YZHImageBrowserControllerFetchBlock)(id currModel, BOOL next, YZHImageBrowserControllerFetchCompletionBlock fetchCompletionBlock);

typedef void(^YZHImageBrowserControllerUpdateCellBlock)(id model, YZHImageCell *imageCell);

typedef void(^YZHImageBrowserControllerDismissBlock)(YZHImageBrowserController *imageBrowserController);

typedef void(^YZHImageBrowserControllerUpdatePageBlock)(YZHImageBrowserController *imageBrowserController, NSUInteger currentPage, NSUInteger totalPage);

@interface YZHImageBrowserController : NSObject

/// 通过当前的模型，寻找上下图片模型（如果只有一张图片可以展示的话，可以为nil）
@property (nonatomic, copy, nullable) YZHImageBrowserControllerFetchBlock fetchBlock;

/// 给ImageCell更新图片
@property (nonatomic, copy, nullable) YZHImageBrowserControllerUpdateCellBlock updateCellBlock;

/// 当前展示的cell
@property (nonatomic, copy, nullable) YZHImageBrowserControllerUpdateCellBlock currentShowCellBlock;

/// dismissBlock可以为nil
@property (nonatomic, copy, nullable) YZHImageBrowserControllerDismissBlock dismissBlock;

/// updatePageBlock - 更新页数
@property (nonatomic, copy, nullable) YZHImageBrowserControllerUpdatePageBlock updatePageBlock;

/// 当前页数（如果不需要显示页码，则不用设置）
@property (nonatomic, assign) NSUInteger currentPage;

/// 总页数（如果不需要显示页码，则不用设置）
@property (nonatomic, assign) NSUInteger totalPage;

- (YZHImageBrowser *)imageBrowser;

/// 预览图片
/// @param inView 展示的父view
/// @param fromView 显示缩略图的view
/// @param image 展示的图片（如果未下载完成，可以用缩略图；如果已下载完成，可以直接使用下载完的图片）
/// @param model 当前图片模型，可以是imageName，可以是url，可以是image，业务自定义，主要用于自定义updateCell展示的时候用
- (void)showInView:(UIView *_Nullable)inView fromView:(UIView *_Nullable)fromView image:(UIImage *_Nullable)image model:(id _Nullable)model;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
