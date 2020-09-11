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

- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didTapImageCell:(YZHImageCell *)imageCell;

- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didDoubleTapImageCell:(YZHImageCell *)imageCell;

- (void)imageBrowser:(YZHImageBrowser * _Nonnull)imageBrowser didLongPressImageCell:(YZHImageCell *)imageCell;

- (void)imageBrowserDidDismiss:(YZHImageBrowser * _Nonnull)imageBrowser;
@end

@interface YZHImageBrowser : NSObject

@property (nonatomic, strong, readonly) YZHImageBrowserView *imageBrowserView;

@property (nonatomic, weak) id<YZHImageBrowserDelegate> delegate;

@property (nonatomic, assign) CGFloat minZoomScale;

@property (nonatomic, assign) CGFloat maxZoomScale;

@property (nonatomic, assign) CGFloat separatorSpace;

@property (nonatomic, assign) NSTimeInterval animateTimeInterval;

/*默认为-1，（YZHImageBrowserActionOptionsSingleTapDismiss|YZHImageBrowserActionOptionsDoubleTapZoomScale） */
@property (nonatomic, assign) YZHImageBrowserActionOptions actionOptions;

//默认为YZHImageCell,自定义需要继承自YZHImageCell
@property (nonatomic, assign) Class imageCellClass;



- (YZHImageCell*)currentShowCell;

- (void)showInView:(UIView * _Nullable)showInView fromView:(UIImageView * _Nullable)fromView withModel:(id<YZHImageCellModelProtocol>)model;

- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
