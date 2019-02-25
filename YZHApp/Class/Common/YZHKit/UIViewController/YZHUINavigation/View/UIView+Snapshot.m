//
//  UIView+Snapshot.m
//  YZHUINavigationController
//
//  Created by yuan on 2018/6/14.
//  Copyright © 2018年 dlodlo. All rights reserved.
//

#import "UIView+Snapshot.h"

@implementation UIView (Snapshot)

-(UIImage*)snapshotImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    [self.layer renderInContext:ctx];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImageView*)snapshotImageView
{
    UIImage *image = [self snapshotImage];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.bounds;
    return imageView;
}

@end
