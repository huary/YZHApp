//
//  UIImageView+YZHAdd.m
//  YZHLoopScrollViewDemo
//
//  Created by yuan on 2019/8/6.
//  Copyright © 2019 yuan. All rights reserved.
//

#import "UIImageView+YZHAdd.h"

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
    if (image.size.width == 0 || image.size.height == 0) {
        return CGSizeZero;
    }
    
    CGFloat wRatio = inSize.width / image.size.width;
    CGFloat hRatio = inSize.height / image.size.height;
    
    CGSize contentSize = image.size;
    switch (contentMode) {
        case UIViewContentModeScaleAspectFit:{
            CGFloat minRatio = MIN(wRatio, hRatio);
            contentSize = CGSizeMake(image.size.width * minRatio, image.size.height * minRatio);
            break;
        }
        case UIViewContentModeScaleAspectFill:{
            CGFloat maxRatio = MAX(wRatio, hRatio);
            contentSize = CGSizeMake(image.size.width * maxRatio, image.size.height * maxRatio);
            break;
        }
        case UIViewContentModeCenter: {
            contentSize = image.size;
            break;
        }
        default:
            break;
    }
    return contentSize;
}


@end
