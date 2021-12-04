//
//  YZHPopCellProtocol.h
//  YZHPopViewDemo
//
//  Created by yuan on 2018/9/10.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YZHPopCellProtocol <NSObject>

-(UIView*)subContentView;

-(void)addSubContentView:(UIView*)subContentView;

@end
