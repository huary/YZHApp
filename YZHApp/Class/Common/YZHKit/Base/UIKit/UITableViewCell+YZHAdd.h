//
//  UITableViewCell+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (YZHAdd)

@property (nonatomic, weak) NSIndexPath *hz_indexPath;

-(void)hz_setSeparatorLineInsets:(UIEdgeInsets)insets;


@end
