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

@property (nonatomic, strong) id hz_refreshModel;

@property (nonatomic, copy) YZHUIRefreshBlock hz_refreshBlock;

@property (nonatomic, copy) YZHUIRefreshViewDidBindBlock hz_didBindBlock;

//这里是通过模型来找到对应绑定的view进行刷新。
-(void)hz_bindRefreshModel:(id)refreshModel;

-(void)hz_bindRefreshModel:(id)refreshModel forKey:(id)key;

@end
