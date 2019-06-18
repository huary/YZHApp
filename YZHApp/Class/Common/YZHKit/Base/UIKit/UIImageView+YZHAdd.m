//
//  UIImageView+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIImageView+YZHAdd.h"
#import "UIImage+YZHAdd.h"

@implementation UIImageView (YZHAdd)

-(CGSize)contentImageSize
{
    return [self.image contentSizeInSize:self.bounds.size contentMode:self.contentMode];
}

@end
