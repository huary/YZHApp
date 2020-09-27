//
//  NSString+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2019/1/1.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (YZHAdd)

-(CGFloat)hz_getWidthWithFont:(UIFont *)font;

-(CGFloat)hz_getHeightByWidth:(CGFloat)width font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode;

- (CGSize)hz_sizeForFont:(UIFont *)font size:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
