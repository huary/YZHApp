//
//  UIView+YZHUIRefreshAction.h
//  contact
//
//  Created by yuan on 2018/12/6.
//  Copyright © 2018年 gdtech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+YZHRefreshView.h"

@interface UIView (YZHUIRefreshAction)

@property (nonatomic, strong) id refreshModel;

@property (nonatomic, copy) YZHUIRefreshBlock refreshBlock;

@property (nonatomic, copy) YZHUIRefreshViewDidBandBlock didBandBlock;

//这里是通过模型来找到对应绑定的view进行刷新。
-(void)bindToRefreshModel:(id)refreshModel;

-(void)bindToRefreshModel:(id)refreshModel forKey:(id)key;

@end

