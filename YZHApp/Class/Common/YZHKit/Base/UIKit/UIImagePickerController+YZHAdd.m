//
//  UIImagePickerController+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIImagePickerController+YZHAdd.h"
#import <objc/runtime.h>

@implementation UIImagePickerController (YZHAdd)

- (void)setHz_tag:(NSUInteger)hz_tag
{
    objc_setAssociatedObject(self, @selector(hz_tag), @(hz_tag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)hz_tag
{
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setHz_orientationsBlock:(YZHSupportedInterfaceOrientationsBlock)hz_orientationsBlock {
    objc_setAssociatedObject(self, @selector(hz_orientationsBlock), hz_orientationsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (YZHSupportedInterfaceOrientationsBlock)hz_orientationsBlock
{
    return objc_getAssociatedObject(self, _cmd);
}


-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.hz_orientationsBlock) {
        UIInterfaceOrientationMask mask = self.hz_orientationsBlock(self);
        if (mask >= UIInterfaceOrientationMaskPortrait && mask <= UIInterfaceOrientationMaskAll) {
            return mask;
        }
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
