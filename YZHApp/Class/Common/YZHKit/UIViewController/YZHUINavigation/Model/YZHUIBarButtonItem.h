//
//  YZHUIBarButtonItem.h
//  yzy
//
//  Created by yuan on 2018/2/7.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YZHUIBarButtonItem : UIBarButtonItem

-(instancetype)initWithCustomView:(UIView *)customView target:(id)target action:(SEL)action;
@end
