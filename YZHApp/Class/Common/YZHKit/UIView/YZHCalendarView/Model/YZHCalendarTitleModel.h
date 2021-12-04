//
//  YZHCalendarTitleModel.h
//  YZHCalendarViewDemo
//
//  Created by yuan on 2018/8/8.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YZHCalendarTitleModel : NSObject

/* <#注释#> */
@property (nonatomic, strong) NSString *title;

/* <#注释#> */
@property (nonatomic, strong) NSString *rightTitle;

@property (nonatomic, strong) NSDateComponents *dateComponents;

-(instancetype)initWithDateComponents:(NSDateComponents*)dateComponents;

@end
