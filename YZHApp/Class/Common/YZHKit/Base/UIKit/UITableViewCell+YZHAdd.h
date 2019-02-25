//
//  UITableViewCell+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (YZHAdd)

@property (nonatomic, weak) NSIndexPath *indexPath;

-(void)setSeparatorLineInsets:(UIEdgeInsets)insets;


@end
