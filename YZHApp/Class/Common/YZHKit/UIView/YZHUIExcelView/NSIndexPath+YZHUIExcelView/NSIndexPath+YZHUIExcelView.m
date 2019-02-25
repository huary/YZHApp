//
//  NSIndexPath+YZHUIExcelView.m
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "NSIndexPath+YZHUIExcelView.h"
#import <objc/runtime.h>

@implementation NSIndexPath (YZHUIExcelView)

+(instancetype)indexPathForExcelRow:(NSInteger)excelRow excelColumn:(NSInteger)excelColoumn
{
    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
    indexPath.excelRow = excelRow;
    indexPath.excelColumn = excelColoumn;
    return indexPath;
}

-(void)setExcelRow:(NSInteger)excelRow
{
    excelRow = MAX(excelRow, 0);
    objc_setAssociatedObject(self, @selector(excelRow), @(excelRow), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)excelRow
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

-(void)setExcelColumn:(NSInteger)excelColumn
{
    excelColumn = MAX(excelColumn, 0);
    objc_setAssociatedObject(self, @selector(excelColumn), @(excelColumn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)excelColumn
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}



@end
