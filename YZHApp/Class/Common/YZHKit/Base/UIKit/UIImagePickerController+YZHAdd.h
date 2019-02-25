//
//  UIImagePickerController+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UIInterfaceOrientationMask(^SupportedInterfaceOrientationsBlock)(UIImagePickerController *imagePickerController);


@interface UIImagePickerController (YZHAdd)

@property (nonatomic, assign) NSUInteger tag;

@property (nonatomic, copy) SupportedInterfaceOrientationsBlock orientationsBlock;

@end
