//
//  YZHImageCellModelProtocol.h
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/6.
//  Copyright © 2019 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHImageCell.h"
#import "YZHLoopCellModelProtocol.h"

@protocol YZHImageCellModelProtocol;

typedef void(^YZHImageCellUpdateBlock)(id<YZHImageCellModelProtocol> model, YZHImageCell *imageCell);

@protocol YZHImageCellModelProtocol <YZHLoopCellModelProtocol>

@property (nonatomic, copy) YZHImageCellUpdateBlock updateBlock;

//该model绑定的cell
@property (nonatomic, weak) YZHImageCell *bindImageCell;

/** imageView的contentMode */
@property (nonatomic, assign) UIViewContentMode imageViewContentMode;

@end
