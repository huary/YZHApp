//
//  YZHUIExcelViewType.m
//  YZHApp
//
//  Created by yuan on 2017/7/18.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIExcelViewType.h"

@implementation NSExcelRowScrollInfo

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)_setUpScrollDefaultValue
{
    self.scrollType = NSExcelRowScrollTypeNull;
    self.driveScrollRowIndex = -1;
    self.scrollContentOffset = CGPointZero;
}

-(id)copyWithZone:(NSZone *)zone
{
    NSExcelRowScrollInfo *new = [[NSExcelRowScrollInfo alloc] init];
    new.scrollType = self.scrollType;
    new.driveScrollRowIndex = self.driveScrollRowIndex;
    new.scrollContentOffset = self.scrollContentOffset;
    return new;
}

-(void)setScrollState:(NSExcelRowScrollState)scrollState
{
    _scrollState = scrollState;
    if (scrollState == NSExcelRowScrollStateEnd) {
//        NSLog(@"setScrollState-End,rowIndex=%ld",self.driveScrollRowIndex);
        self.scrollType = NSExcelRowScrollTypeNull;
        self.driveScrollRowIndex = -1;
    }
}

@end

