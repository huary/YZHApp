//
//  YZHImageBrowserView.h
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/11.
//  Copyright © 2019 yuan. All rights reserved.
//

#import "YZHLoopTransitionView.h"
#import "YZHImageCell.h"

NS_ASSUME_NONNULL_BEGIN

@class YZHImageBrowserView;
@protocol YZHImageBrowserViewDelegate <YZHLoopTransitionViewDelegate>

//返回dismiss时，要消失的frame，相对于ImageBrowserView的frame
@optional
- (CGRect)imageBrowserView:(YZHImageBrowserView *_Nonnull)imageBrowserView dismissToFrameForCell:(YZHImageCell *)imageCell;

@end

@interface YZHImageBrowserView : YZHLoopTransitionView

@property (nonatomic, weak) id<YZHImageBrowserViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
