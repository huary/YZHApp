//
//  YZHCalendarView.h
//  YZHCalendarViewDemo
//
//  Created by yuan on 2018/8/8.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YZHCalendarView;
@protocol YZHCalendarViewDelegate <NSObject>
-(BOOL)calendarView:(YZHCalendarView *)calendarView shouldShowDotForDateComponents:(NSDateComponents*)dateComponents;

-(void)calendarView:(YZHCalendarView *)calendarView didSelectedDateComponents:(NSDateComponents*)dateComponents;

-(void)calendarView:(YZHCalendarView *)calendarView updateToSize:(CGSize)size;

-(void)calendarView:(YZHCalendarView *)calendarView didClickTitleAction:(BOOL)toNextMonth;

@end

@interface YZHCalendarView : UIView

/* <#注释#> */
@property (nonatomic, weak) id<YZHCalendarViewDelegate> delegate;

/* <#注释#> */
@property (nonatomic, strong) NSDateComponents *dateComponents;

@end
