//
//  NSString+YZHAdd.m
//  YZHApp
//
//  Created by yuan on 2019/1/1.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "NSString+YZHAdd.h"

@implementation NSString (YZHAdd)

-(CGFloat)getWidthWithFont:(UIFont *)font
{
    if (self.length == 0) {
        return 0;
    }
    CGSize size = [self sizeWithAttributes:@{NSFontAttributeName:font}];
    return size.width;
}

-(CGFloat)getHeightByWidth:(CGFloat)width font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    if (self.length == 0) {
        return 0;
    }
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = lineBreakMode;
    
    NSRange r = NSMakeRange(0, attributeString.length);
    [attributeString addAttribute:NSParagraphStyleAttributeName value:style range:r];
    [attributeString addAttribute:NSFontAttributeName value:font range:r];
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    
    CGRect rect = [attributeString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:options context:nil];
    
    return rect.size.height;
}

@end
