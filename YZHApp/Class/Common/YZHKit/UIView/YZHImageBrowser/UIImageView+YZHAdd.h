//
//  UIImageView+YZHAdd.h
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/6.
//  Copyright © 2019 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (YZHAdd)

-(CGSize)contentImageSize;

-(CGSize)contentImageSizeInSize:(CGSize)size;

+(CGSize)image:(UIImage*)image contentSizeInSize:(CGSize)inSize contentMode:(UIViewContentMode)contentMode;

@end

NS_ASSUME_NONNULL_END
