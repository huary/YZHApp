//
//  NSIndexPath+YZHExcelView.h
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (YZHExcelView)

+(instancetype)hz_indexPathForExcelRow:(NSInteger)excelRow excelColumn:(NSInteger)excelColoumn;

@property (nonatomic, assign, readonly) NSInteger hz_excelRow;
@property (nonatomic, assign, readonly) NSInteger hz_excelColumn;


@end
