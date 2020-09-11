//
//  UIResponder+YZHUIRefreshAction.h
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+YZHRefreshView.h"

@interface UIResponder (YZHUIRefreshAction)

@property (nonatomic, strong) id refreshModel;

@property (nonatomic, copy) YZHUIRefreshBlock refreshBlock;

@property (nonatomic, copy) YZHUIRefreshViewDidBindBlock didBindBlock;

//这里是通过模型来找到对应绑定的view进行刷新。
-(void)bindRefreshModel:(id)refreshModel;

-(void)bindRefreshModel:(id)refreshModel forKey:(id)key;

@end
