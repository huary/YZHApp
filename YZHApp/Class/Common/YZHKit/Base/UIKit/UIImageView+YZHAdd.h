//
//  UIImageView+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (YZHAdd)

-(CGSize)hz_contentImageSize;

-(CGSize)hz_contentImageSizeInSize:(CGSize)size;

+(CGSize)hz_image:(UIImage*)image contentSizeInSize:(CGSize)inSize contentMode:(UIViewContentMode)contentMode;


@end
