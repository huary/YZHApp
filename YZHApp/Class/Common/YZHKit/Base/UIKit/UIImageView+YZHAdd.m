//
//  UIImageView+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIImageView+YZHAdd.h"
#import "YZHCGUtil.h"

@implementation UIImageView (YZHAdd)

-(CGSize)contentImageSize
{
    return [[self class] image:self.image contentSizeInSize:self.bounds.size contentMode:self.contentMode];
}

-(CGSize)contentImageSizeInSize:(CGSize)size
{
    return [[self class] image:self.image contentSizeInSize:size contentMode:self.contentMode];
}

+(CGSize)image:(UIImage*)image contentSizeInSize:(CGSize)inSize contentMode:(UIViewContentMode)contentMode
{
    return rectWithContentMode(inSize, image.size, contentMode).size;
}


@end
