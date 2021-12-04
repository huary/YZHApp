//
//  YZHCalendarTitleModel.m
//  YZHCalendarViewDemo
//
//  Created by yuan on 2018/8/8.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHCalendarTitleModel.h"
#import "YZHKitType.h"

@implementation YZHCalendarTitleModel

-(instancetype)initWithDateComponents:(NSDateComponents*)dateComponents
{
    self = [super init];
    if (self) {
        self.dateComponents = dateComponents;
    }
    return self;
}

-(void)setDateComponents:(NSDateComponents *)dateComponents
{
    _dateComponents = dateComponents;
    if ([dateComponents isValidDateInCalendar:[NSCalendar currentCalendar]]) {
        self.title = NEW_STRING_WITH_FORMAT(@"%ld年%ld月",dateComponents.year,dateComponents.month);
    }
}

@end
