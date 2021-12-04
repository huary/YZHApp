//
//  NSObject+YZHRefreshView.h
//  YZHApp
//
//  Created by yuan on 2018/12/6.
//  Copyright © 2018年 yuanzh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol YZHRefreshViewProtocol;

typedef BOOL(^YZHRefreshConditionBlock)(UIResponder<YZHRefreshViewProtocol> *refreshView, id model);
typedef BOOL(^YZHRefreshBlock)(UIResponder<YZHRefreshViewProtocol> *refreshView, id model);

typedef void(^YZHRefreshViewDidBindBlock)(UIResponder<YZHRefreshViewProtocol> *refreshView, id model, id key);

@protocol YZHRefreshViewProtocol <NSObject>

@optional

@property (nonatomic, strong) id hz_refreshModel;

//刷新block
@property (nonatomic, copy) YZHRefreshBlock hz_refreshBlock;

//绑定完成的block
@property (nonatomic, copy) YZHRefreshViewDidBindBlock hz_didBindBlock;

//刷新方法、同refreshBlock
-(BOOL)hz_refreshViewWithModel:(id)model;

//绑定完成的方法，和上面的didBindBlock同效
-(void)hz_refreshViewDidBindModel:(id)model withKey:(id)key;
@end



@interface NSObject (YZHRefreshView)

//对模型绑定刷新的view
-(void)hz_addRefreshView:(UIResponder<YZHRefreshViewProtocol>*)refreshView forKey:(id)key;

//刷新所有绑定的view
-(BOOL)hz_refresh;

//根据刷新条件刷新所有绑定的view
-(BOOL)hz_refresh:(YZHRefreshConditionBlock)condition;

//根据绑定的Key对view进行刷新
-(BOOL)hz_refreshViewWithKey:(id)key;


//通过指定View镜像刷新
-(BOOL)hz_refreshView:(UIResponder<YZHRefreshViewProtocol>*)refreshView;


//根据条件，对绑定的Key对view进行刷新
-(BOOL)hz_refreshViewWithKey:(id)key condition:(YZHRefreshConditionBlock)condition;


//根据条件，对view进行刷新
-(BOOL)hz_refreshView:(UIResponder<YZHRefreshViewProtocol>*)refreshView condition:(YZHRefreshConditionBlock)condition;


//获取指定的view
-(UIResponder<YZHRefreshViewProtocol>*)hz_refreshViewForKey:(id)key;

//获取所有绑定的View
-(NSArray<UIResponder<YZHRefreshViewProtocol>*>*)hz_allRefreshView;

//清空绑定的view
-(void)hz_clearRefreshView:(UIResponder*)refreshView;

//清空绑定的view
-(void)hz_clearRefreshViewForKey:(id)key;

//清空所有绑定的view
-(void)hz_clearAllRefreshView;

/*
 *这里是通过注册View,
 *有这个方法的原因是因为view绑定的model（弱应用）已经释放，而需要刷新这个view的模型是通过某一个Id（key）
 *来进行的，就可以通过那个id（key）找到对应刷新view，然后进行刷新。
 */
-(void)hz_registerView:(UIResponder*)view ForRegisterKey:(id)registerKey;

//通过在View中进行registerRefreshViewForRegisterKey来注册的view时的registerKey找到对应的
-(UIResponder*)hz_viewForRegisterKey:(id)registerKey;

//清除某一个注册的key
-(void)hz_clearRegisterViewForRegisterKey:(id)registerKey;

//清除所有的注册的view
-(void)hz_clearRegisterView;
@end
