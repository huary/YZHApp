//
//  NSIndexPath+YZHExcelView.m
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "NSIndexPath+YZHExcelView.h"
#import <objc/runtime.h>

@implementation NSIndexPath (YZHExcelView)

+(instancetype)hz_indexPathForExcelRow:(NSInteger)excelRow excelColumn:(NSInteger)excelColoumn
{
    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
    indexPath.hz_excelRow = excelRow;
    indexPath.hz_excelColumn = excelColoumn;
    return indexPath;
}

-(void)setHz_excelRow:(NSInteger)hz_excelRow
{
    hz_excelRow = MAX(hz_excelRow, 0);
    objc_setAssociatedObject(self, @selector(hz_excelRow), @(hz_excelRow), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)hz_excelRow
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

-(void)setHz_excelColumn:(NSInteger)hz_excelColumn
{
    hz_excelColumn = MAX(hz_excelColumn, 0);
    objc_setAssociatedObject(self, @selector(hz_excelColumn), @(hz_excelColumn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)hz_excelColumn
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}



@end
