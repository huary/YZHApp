//
//  UIResponder+YZHRefreshAction.m
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "UIResponder+YZHRefreshAction.h"
#import <objc/runtime.h>

@implementation UIResponder (YZHRefreshAction)

-(void)setHz_refreshModel:(id)hz_refreshModel
{
    objc_setAssociatedObject(self, @selector(hz_refreshModel), hz_refreshModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)hz_refreshModel
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setHz_refreshBlock:(YZHRefreshBlock)hz_refreshBlock
{
    objc_setAssociatedObject(self, @selector(hz_refreshBlock), hz_refreshBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHRefreshBlock)hz_refreshBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setHz_didBindBlock:(YZHRefreshViewDidBindBlock)hz_didBindBlock
{
    objc_setAssociatedObject(self, @selector(hz_didBindBlock), hz_didBindBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHRefreshViewDidBindBlock)hz_didBindBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)hz_bindRefreshModel:(id)refreshModel
{
    [self hz_bindRefreshModel:refreshModel forKey:nil];
}

-(void)hz_bindRefreshModel:(id)refreshModel forKey:(id)key
{
    if (key == nil) {
//        key = @([self hash]);//[NSValue valueWithPointer:(__bridge void*)self];
        key = [NSString stringWithFormat:@"hz_%p",self];
    }
    BOOL r = YES;
    UIResponder<YZHRefreshViewProtocol> *responder = (UIResponder<YZHRefreshViewProtocol> *)self;
    //refresh
    if ([self respondsToSelector:@selector(hz_refreshViewWithModel:)]) {
        UIResponder<YZHRefreshViewProtocol> *target = nil;
        if ([self conformsToProtocol:@protocol(YZHRefreshViewProtocol)]) {
            target = (UIResponder<YZHRefreshViewProtocol>*)self;
        }
        r = [target hz_refreshViewWithModel:refreshModel];
    }
    else if (self.hz_refreshBlock) {
        r = self.hz_refreshBlock(responder, refreshModel);
    }
    
    //清除view上旧的model对view的弱应用
    [self.hz_refreshModel hz_clearRefreshView:self];
    //bind
    self.hz_refreshModel = refreshModel;
//    if (r) {
        [refreshModel hz_addRefreshView:responder forKey:key];
//    }
    
    //did bind
    if ([self respondsToSelector:@selector(hz_refreshViewDidBindModel:withKey:)]) {
        UIResponder<YZHRefreshViewProtocol> *target = nil;
        if ([self conformsToProtocol:@protocol(YZHRefreshViewProtocol)]) {
            target = (UIResponder<YZHRefreshViewProtocol>*)self;
        }
        [target hz_refreshViewDidBindModel:refreshModel withKey:key];
    }
    else if (self.hz_didBindBlock) {
        self.hz_didBindBlock(responder, refreshModel, key);
    }
    
}

@end

