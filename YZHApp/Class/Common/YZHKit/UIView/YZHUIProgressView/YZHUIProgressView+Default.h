//
//  YZHUIProgressView+Default.h
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2017/6/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIProgressView.h"

@interface YZHUIProgressView (Default)

//默认1.0秒后dimiss
-(void)progressWithSuccessText:(NSString*)successText;
-(void)progressWithFailText:(NSString*)failText;

-(void)progressWithSuccessText:(NSString*)successText showTimeInterval:(NSTimeInterval)timeInterval;
-(void)progressWithFailText:(NSString*)failText showTimeInterval:(NSTimeInterval)timeInterval;

-(void)updateWithSuccessText:(NSString*)successText;
-(void)updateWithFailText:(NSString*)failText;

-(void)updateWithSuccessText:(NSString*)successText showTimeInterval:(NSTimeInterval)timeInterval;
-(void)updateWithFailText:(NSString*)failText showTimeInterval:(NSTimeInterval)timeInterval;

@end
