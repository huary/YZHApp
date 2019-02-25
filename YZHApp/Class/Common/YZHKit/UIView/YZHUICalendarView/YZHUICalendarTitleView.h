//
//  YZHUICalendarTitleView.h
//  YZHUICalendarViewDemo
//
//  Created by yuan on 2018/8/8.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHUICalendarTitleModel.h"

@class YZHUICalendarTitleView;

@protocol YZHUICalendarTitleViewDelegate <NSObject>

-(void)calendarTitleView:(YZHUICalendarTitleView*)titleView didClickPrevAction:(YZHUICalendarTitleModel*)titleModel;

-(void)calendarTitleView:(YZHUICalendarTitleView*)titleView didClickNextAction:(YZHUICalendarTitleModel*)titleModel;
@end


@interface YZHUICalendarTitleView : UIView

@property (nonatomic, weak) id<YZHUICalendarTitleViewDelegate> delegate;

@property (nonatomic, strong) YZHUICalendarTitleModel *titleModel;

@end
