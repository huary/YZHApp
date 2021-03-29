//
//  YZHImageCellModel.h
//  
//
//  Created by yuan on 2020/8/31.
//  Copyright © 2020 lizhi. All rights reserved.
//

#import "YZHImageBrowser.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZHImageCellModel : NSObject <YZHImageCellModelProtocol>

@property (nonatomic, copy) YZHImageCellUpdateBlock updateBlock;

//该model绑定的cell
@property (nonatomic, weak) YZHImageCell *bindImageCell;

/** imageView的contentMode */
@property (nonatomic, assign) UIViewContentMode imageViewContentMode;

/** 是否已经到尽头 */
@property (nonatomic, assign) BOOL isEnd;

@property (nonatomic, strong) id target;

@end

NS_ASSUME_NONNULL_END
