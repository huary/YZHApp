//
//  YZHCalendarItemModel.m
//  YZHCalendarViewDemo
//
//  Created by yuan on 2018/8/8.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHCalendarItemModel.h"

/**********************************************************************
 *YZHTextViewModel
 **********************************************************************/
@implementation YZHTextViewModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.textColor = BLACK_COLOR;
        self.backgroundColor = CLEAR_COLOR;
    }
    return self;
}

-(instancetype)initWithText:(NSString*)text font:(UIFont*)font
{
    self = [self init];
    if (self) {
        self.text = text;
        self.font = font;
    }
    return self;
}

-(instancetype)initWithText:(NSString*)text font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor
{
    self = [self initWithText:text font:font];
    if (self) {
        if (textColor) {
            self.textColor = textColor;
        }
        if (backgroundColor) {
            self.backgroundColor = backgroundColor;
        }
    }
    return self;
}
@end

/**********************************************************************
 *YZHControlTextViewModel
 **********************************************************************/
@implementation YZHControlTextViewModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.selectedTextColor = self.textColor;
    }
    return self;
}

@end


@implementation YZHCalendarItemModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.canSelected = YES;
    }
    return self;
}

-(instancetype)initWithDateComponents:(NSDateComponents*)dateComponents
{
    self = [self init];
    if (self) {
        self.dateComponents = dateComponents;
    }
    return self;
}

-(void)setDateComponents:(NSDateComponents *)dateComponents
{
    _dateComponents = dateComponents;
    if ([dateComponents isValidDateInCalendar:[NSCalendar currentCalendar]]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *date = [calendar dateFromComponents:dateComponents];
        BOOL isToday = [calendar isDateInToday:date];
        
        UIFont *font = SYS_FONT(12);
        UIColor *textColor = BLACK_COLOR;
        
        NSString *day = NEW_STRING_WITH_FORMAT(@"%@",@(dateComponents.day));
        if (isToday) {
            day = @"今天";
            textColor = RGB_WITH_INT_WITH_NO_ALPHA(0XF2266F);
        }
        else {
            textColor = BLACK_COLOR;
        }
        YZHControlTextViewModel *textModel = [[YZHControlTextViewModel alloc] initWithText:day font:font textColor:textColor backgroundColor:nil];
        textModel.selectedTextColor = WHITE_COLOR;
        self.textModel = textModel;
    }
}

-(instancetype)initWithTextModel:(YZHControlTextViewModel*)textModel
{
    self = [self init];
    if (self) {
        self.textModel = textModel;
    }
    return self;
}

@end
