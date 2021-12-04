//
//  YZHCalendarTitleView.h
//  YZHCalendarViewDemo
//
//  Created by yuan on 2018/8/8.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHCalendarTitleModel.h"

@class YZHCalendarTitleView;

@protocol YZHCalendarTitleViewDelegate <NSObject>

-(void)calendarTitleView:(YZHCalendarTitleView*)titleView didClickPrevAction:(YZHCalendarTitleModel*)titleModel;

-(void)calendarTitleView:(YZHCalendarTitleView*)titleView didClickNextAction:(YZHCalendarTitleModel*)titleModel;
@end


@interface YZHCalendarTitleView : UIView

@property (nonatomic, weak) id<YZHCalendarTitleViewDelegate> delegate;

@property (nonatomic, strong) YZHCalendarTitleModel *titleModel;

@end
