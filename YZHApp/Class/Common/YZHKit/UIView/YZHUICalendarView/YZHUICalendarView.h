//
//  YZHUICalendarView.h
//  YZHUICalendarViewDemo
//
//  Created by yuan on 2018/8/8.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YZHUICalendarView;
@protocol YZHUICalendarViewDelegate <NSObject>
-(BOOL)calendarView:(YZHUICalendarView *)calendarView shouldShowDotForDateComponents:(NSDateComponents*)dateComponents;

-(void)calendarView:(YZHUICalendarView *)calendarView didSelectedDateComponents:(NSDateComponents*)dateComponents;

-(void)calendarView:(YZHUICalendarView *)calendarView updateToSize:(CGSize)size;

-(void)calendarView:(YZHUICalendarView *)calendarView didClickTitleAction:(BOOL)toNextMonth;

@end

@interface YZHUICalendarView : UIView

/* <#注释#> */
@property (nonatomic, weak) id<YZHUICalendarViewDelegate> delegate;

/* <#注释#> */
@property (nonatomic, strong) NSDateComponents *dateComponents;

@end
