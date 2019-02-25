//
//  UIImageView+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIImageView+YZHAdd.h"

@implementation UIImageView (YZHAdd)

-(CGSize)contentImageSize
{
    if (self.image == nil) {
        return CGSizeZero;
    }
    if (self.image.size.width == 0 || self.image.size.height == 0) {
        return CGSizeZero;
    }
    if (self.bounds.size.height == 0 || self.bounds.size.height == 0) {
        return CGSizeZero;
    }
    
    CGFloat wRatio = self.image.size.width / self.bounds.size.width;
    CGFloat hRatio = self.image.size.height / self.bounds.size.height;
    
    CGSize contentSize = self.bounds.size;
    UIViewContentMode contentModel = self.contentMode;
    switch (contentModel) {
        case UIViewContentModeScaleAspectFit:
        {
            CGFloat minRatio = MIN(wRatio, hRatio);
            contentSize = CGSizeMake(self.image.size.width * minRatio, self.image.size.height * minRatio);
            break;
        }
        case UIViewContentModeCenter: {
            contentSize =self.image.size;
            break;
        }
        default:
            break;
    }
    return contentSize;
}

@end
