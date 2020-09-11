//
//  UIResponder+YZHUIRefreshAction.m
//  YZHApp
//
//  Created by yuan on 2019/6/18.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "UIResponder+YZHUIRefreshAction.h"
#import <objc/runtime.h>

@implementation UIResponder (YZHUIRefreshAction)

-(void)setRefreshModel:(id)refreshModel
{
    objc_setAssociatedObject(self, @selector(refreshModel), refreshModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)refreshModel
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setRefreshBlock:(YZHUIRefreshBlock)refreshBlock
{
    objc_setAssociatedObject(self, @selector(refreshBlock), refreshBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHUIRefreshBlock)refreshBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setDidBindBlock:(YZHUIRefreshViewDidBindBlock)didBindBlock
{
    objc_setAssociatedObject(self, @selector(didBindBlock), didBindBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHUIRefreshViewDidBindBlock)didBindBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)bindRefreshModel:(id)refreshModel
{
    [self bindRefreshModel:refreshModel forKey:nil];
}

-(void)bindRefreshModel:(id)refreshModel forKey:(id)key
{
    if (key == nil) {
        key = @([self hash]);//[NSValue valueWithPointer:(__bridge void*)self];
    }
    BOOL r = YES;
    UIResponder<YZHUIRefreshViewProtocol> *responder = (UIResponder<YZHUIRefreshViewProtocol> *)self;
    //refresh
    if ([self respondsToSelector:@selector(refreshViewWithModel:)]) {
        UIResponder<YZHUIRefreshViewProtocol> *target = nil;
        if ([self conformsToProtocol:@protocol(YZHUIRefreshViewProtocol)]) {
            target = (UIResponder<YZHUIRefreshViewProtocol>*)self;
        }
        r = [target refreshViewWithModel:refreshModel];
    }
    else if (self.refreshBlock) {
        r = self.refreshBlock(responder, refreshModel);
    }
    
    //bind
    self.refreshModel = refreshModel;
    if (r) {
        NSObject *obj = refreshModel;
        [obj hz_addRefreshView:responder forKey:key];
    }
    
    //did bind
    if ([self respondsToSelector:@selector(refreshViewDidBindModel:withKey:)]) {
        UIResponder<YZHUIRefreshViewProtocol> *target = nil;
        if ([self conformsToProtocol:@protocol(YZHUIRefreshViewProtocol)]) {
            target = (UIResponder<YZHUIRefreshViewProtocol>*)self;
        }
        [target refreshViewDidBindModel:refreshModel withKey:key];
    }
    else if (self.didBindBlock) {
        self.didBindBlock(responder, refreshModel, key);
    }
    
}

@end

