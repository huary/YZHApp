//
//  YZHLoopCell.h
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/5.
//  Copyright © 2019 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHLoopCellModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZHLoopCell : UIView

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, assign) CGPoint contentInsets;

@property (nonatomic, strong) id<YZHLoopCellModelProtocol> model;

@end

NS_ASSUME_NONNULL_END
