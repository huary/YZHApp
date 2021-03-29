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

@interface YZHImageBrowserController : NSObject

//如果只有一张图片可以展示的话，可以为nil
@property (nonatomic, copy, nullable) YZHImageBrowserControllerFetchBlock fetchBlock;

@property (nonatomic, copy, nullable) YZHImageBrowserControllerUpdateCellBlock updateCellBlock;

@property (nonatomic, copy, nullable) YZHImageBrowserControllerDismissBlock dismissBlock;

- (YZHImageBrowser *)imageBrowser;

- (void)showInView:(UIView *_Nullable)inView
          fromView:(UIView *_Nullable)fromView
             image:(UIImage *_Nullable)image
             model:(id _Nullable)model;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
