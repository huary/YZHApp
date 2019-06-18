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

-(void)setDidBandBlock:(YZHUIRefreshViewDidBandBlock)didBandBlock
{
    objc_setAssociatedObject(self, @selector(didBandBlock), didBandBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHUIRefreshViewDidBandBlock)didBandBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)bindToRefreshModel:(id)refreshModel
{
    [self bindToRefreshModel:refreshModel forKey:nil];
}

-(void)bindToRefreshModel:(id)refreshModel forKey:(id)key
{
    if (key == nil) {
        key = @([self hash]);//[NSValue valueWithPointer:(__bridge void*)self];
    }
    BOOL r = NO;
    //refresh
    if ([self respondsToSelector:@selector(refreshViewWithModel:)]) {
        UIResponder<YZHUIRefreshViewProtocol> *target = nil;
        if ([self conformsToProtocol:@protocol(YZHUIRefreshViewProtocol)]) {
            target = (UIResponder<YZHUIRefreshViewProtocol>*)self;
        }
        r = [target refreshViewWithModel:refreshModel];
    }
    else if (self.refreshBlock) {
        r = self.refreshBlock(self, refreshModel);
    }
    
    //bind
    self.refreshModel = refreshModel;
    if (r) {
        NSObject *obj = refreshModel;
        [obj hz_addRefreshView:self forKey:key];
    }
    
    //did band
    if ([self respondsToSelector:@selector(refreshViewDidBandToModel:)]) {
        UIResponder<YZHUIRefreshViewProtocol> *target = nil;
        if ([self conformsToProtocol:@protocol(YZHUIRefreshViewProtocol)]) {
            target = (UIResponder<YZHUIRefreshViewProtocol>*)self;
        }
        [target refreshViewDidBandToModel:refreshModel];
    }
    else if (self.didBandBlock) {
        self.didBandBlock(self, refreshModel);
    }
    
}

@end

