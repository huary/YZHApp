//
//  UIView+YZHAddForUIGestureRecognizer.m
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIView+YZHAddForUIGestureRecognizer.h"
#import <objc/runtime.h>
#import "YZHKitMacro.h"

#define MAX_TIME_INTERVAL           (30.0)
#define MIN_TIME_INTERVAL           (0.01)

/****************************************************
 *YZHIntervalGestureRecognizerActionOptionsInfo
 ****************************************************/
@implementation YZHIntervalGestureRecognizerActionOptionsInfo

+(YZHIntervalGestureActionTimingFunctionBlock)YZHIntervalGestureRecognizerActionTimingFunctionLinearBlock
{
    YZHIntervalGestureActionTimingFunctionBlock linearBlock = ^(NSTimeInterval elapsedTime,NSTimeInterval lastTimeInterval){
        lastTimeInterval = MAX(lastTimeInterval, MIN_TIME_INTERVAL);
        lastTimeInterval = MIN(lastTimeInterval, MAX_TIME_INTERVAL);
        return lastTimeInterval;
    };
    return linearBlock;
}

+(YZHIntervalGestureActionTimingFunctionBlock)YZHIntervalGestureRecognizerActionTimingFunctionEaseInBlock
{
    CGFloat changeRatio = 0.8;
    YZHIntervalGestureActionTimingFunctionBlock easeInBlock = ^(NSTimeInterval elapsedTime,NSTimeInterval lastTimeInterval){
        lastTimeInterval = lastTimeInterval * changeRatio;
        lastTimeInterval = MAX(lastTimeInterval, MIN_TIME_INTERVAL);
        lastTimeInterval = MIN(lastTimeInterval, MAX_TIME_INTERVAL);
        return lastTimeInterval;
    };
    return easeInBlock;
}

+(YZHIntervalGestureActionTimingFunctionBlock)YZHIntervalGestureRecognizerActionTimingFunctionEaseOutBlock
{
    CGFloat changeRatio = 1.25;
    YZHIntervalGestureActionTimingFunctionBlock easeOutBlock = ^(NSTimeInterval elapsedTime,NSTimeInterval lastTimeInterval){
        lastTimeInterval = lastTimeInterval * changeRatio;
        lastTimeInterval = MAX(lastTimeInterval, MIN_TIME_INTERVAL);
        lastTimeInterval = MIN(lastTimeInterval, MAX_TIME_INTERVAL);
        return lastTimeInterval;
    };
    return easeOutBlock;
}

-(YZHIntervalGestureActionTimingFunctionBlock)timingFunctionBlock
{
    if (_timingFunctionBlock != nil) {
        return _timingFunctionBlock;
    }
    
    //    BOOL cond = (self.actionOptions == YZHIntervalGestureRecognizerActionOptionsBeginChangeEnd || self.actionOptions == YZHIntervalGestureRecognizerActionOptionsBeginChangesEnd || self.actionOptions == YZHIntervalGestureRecognizerActionOptionsCustom);
    //    if (!cond) {
    //        return nil;
    //    }
    
    if (self.timingFunction == YZHIntervalGestureRecognizerActionTimingFunctionLinear) {
        self.timingFunctionBlock = [YZHIntervalGestureRecognizerActionOptionsInfo YZHIntervalGestureRecognizerActionTimingFunctionLinearBlock];
    }
    else if (self.timingFunction == YZHIntervalGestureRecognizerActionTimingFunctionEaseIn)
    {
        self.timingFunctionBlock = [YZHIntervalGestureRecognizerActionOptionsInfo YZHIntervalGestureRecognizerActionTimingFunctionEaseInBlock];
    }
    else if (self.timingFunction == YZHIntervalGestureRecognizerActionTimingFunctionEaseOut)
    {
        self.timingFunctionBlock = [YZHIntervalGestureRecognizerActionOptionsInfo YZHIntervalGestureRecognizerActionTimingFunctionEaseOutBlock];
    }
    return _timingFunctionBlock;
}

@end


/****************************************************
 *UIGestureRecognizerBlockTarget
 ****************************************************/
@interface UIGestureRecognizerBlockTarget : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIGestureRecognizer *gestureRecognizer;

@property (nonatomic, copy) YZHGestureRecognizerBlock gestureBlock;
@property (nonatomic, copy) YZHGestureRecognizerShouldBeginBlock gestureShouldBeginBlock;

@property (nonatomic, strong) YZHIntervalGestureRecognizerActionOptionsInfo *actionOptionsInfo;

//@property (nonatomic, assign) NSTimeInterval lastTimeInterval;
//@property (nonatomic, assign) NSTimeInterval elapsedTimeInterval;

-(instancetype)initWithGestureBlock:(YZHGestureRecognizerBlock)gestureBlock;
-(instancetype)initWithGestureBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)gestureShouldBeginBlock;

-(void)gestureAction:(UIGestureRecognizer*)gestureRecognizer;

@end

@implementation UIGestureRecognizerBlockTarget

-(instancetype)initWithGestureBlock:(YZHGestureRecognizerBlock)gestureBlock
{
    self = [super init];
    if (self) {
        _gestureBlock = gestureBlock;
    }
    return self;
}

-(instancetype)initWithGestureBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)gestureShouldBeginBlock
{
    self = [self initWithGestureBlock:gestureBlock];
    if (self) {
        self.gestureShouldBeginBlock = gestureShouldBeginBlock;
    }
    return self;
}

-(void)gestureAction:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.gestureBlock == nil) {
        return;
    }
    if (self.actionOptionsInfo == nil || self.actionOptionsInfo.actionOptions == YZHIntervalGestureRecognizerActionOptionsDefault)
    {
        gestureRecognizer.YZHState = YZHUIGestureRecognizerStateEnded;
        self.gestureBlock(gestureRecognizer);
    }
    else
    {
        //        NSLog(@"%s,state=%ld",__FUNCTION__,self.gestureRecognizer.YZHState);
        if (self.gestureRecognizer.YZHState != YZHUIGestureRecognizerStateEnded && self.gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            gestureRecognizer.YZHState = YZHUIGestureRecognizerStateEnded;
            self.gestureBlock(gestureRecognizer);
        }
    }
}

-(void)setGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    _gestureRecognizer = gestureRecognizer;
    _gestureRecognizer.delegate = self;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = YES;
    if (self.gestureShouldBeginBlock) {
        shouldBegin = self.gestureShouldBeginBlock(gestureRecognizer);
    }
    if (shouldBegin) {
        [self startIntervalAction];
    }
    return shouldBegin;
}

-(void)startIntervalAction
{
    if (self.actionOptionsInfo && self.actionOptionsInfo.actionOptions != YZHIntervalGestureRecognizerActionOptionsDefault && self.actionOptionsInfo.actionOptions != YZHIntervalGestureRecognizerActionOptionsOnlyEnd) {
        CGFloat lastTimeInterval = self.actionOptionsInfo.firstActionTimeInterval;
        if ([self.gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer*)self.gestureRecognizer;
            //如果某一次特殊的话，按特殊的时间来进行
            lastTimeInterval = longPress.minimumPressDuration;
        }
        CGFloat elapsedTimeInterval = 0;
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[TYPE_STR(YZHStateKey)] = @(YZHUIGestureRecognizerStateBegan);
        dict[TYPE_STR(YZHIntervalActionElapsedTimeIntervalKey)] = @(elapsedTimeInterval + lastTimeInterval);
        dict[TYPE_STR(YZHIntervalActionLastTimeIntervalKey)] = @(lastTimeInterval);
        
        if (lastTimeInterval > 0) {
            [self performSelector:@selector(nextIntervalAction:) withObject:dict afterDelay:lastTimeInterval];
        }
        else
        {
            [self nextIntervalAction:dict];
        }
    }
}

-(void)nextIntervalAction:(NSDictionary*)actionInfo
{
    YZHUIGestureRecognizerState state = [actionInfo[TYPE_STR(YZHStateKey)] integerValue];
    YZHIntervalGestureRecognizerActionOptionsInfo *actionOptionsInfo = self.actionOptionsInfo;
    NSTimeInterval elapsedTimeInterval = [actionInfo[TYPE_STR(YZHIntervalActionElapsedTimeIntervalKey)] doubleValue];
    NSTimeInterval lastTimeInterval = [actionInfo[TYPE_STR(YZHIntervalActionLastTimeIntervalKey)] doubleValue];
    
    self.gestureRecognizer.YZHState = state;
    
    if (self.gestureBlock && self.gestureRecognizer && ([self.gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [self.gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) && self.gestureRecognizer.state != UIGestureRecognizerStateEnded)
    {
        //        NSLog(@"%s,state=%ld",__FUNCTION__,self.gestureRecognizer.YZHState);
        if (actionOptionsInfo.actionOptions == YZHIntervalGestureRecognizerActionOptionsOnlyOnce) {
            if (self.gestureRecognizer.YZHState != YZHUIGestureRecognizerStateEnded) {
                self.gestureRecognizer.YZHState = YZHUIGestureRecognizerStateEnded;
                self.gestureBlock(self.gestureRecognizer);
            }
        }
        else if (actionOptionsInfo.actionOptions == YZHIntervalGestureRecognizerActionOptionsBeginEnd)
        {
            if (self.gestureRecognizer.YZHState == YZHUIGestureRecognizerStateBegan) {
                self.gestureBlock(self.gestureRecognizer);
            }
        }
        else if (actionOptionsInfo.actionOptions == YZHIntervalGestureRecognizerActionOptionsBeginChangeEnd)
        {
            if (self.gestureRecognizer.YZHState == YZHUIGestureRecognizerStateBegan) {
                self.gestureBlock(self.gestureRecognizer);
                self.gestureRecognizer.YZHState = YZHUIGestureRecognizerStateChanged;
                
                CGFloat nextTimeInterval = 0.0;
                if (actionOptionsInfo.timingFunctionBlock) {
                    nextTimeInterval = actionOptionsInfo.timingFunctionBlock(elapsedTimeInterval,lastTimeInterval);
                }
                if (nextTimeInterval > 0.0 && nextTimeInterval <= MIN_TIME_INTERVAL) {
                    nextTimeInterval = MIN_TIME_INTERVAL;
                }
                else if (nextTimeInterval == 0)
                {
                    self.gestureRecognizer.YZHState = YZHUIGestureRecognizerStateEnded;
                    self.gestureBlock(self.gestureRecognizer);
                    return;
                }
                else
                {
                    return;
                }
                lastTimeInterval = nextTimeInterval;
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                dict[TYPE_STR(YZHStateKey)] = @(YZHUIGestureRecognizerStateChanged);
                dict[TYPE_STR(YZHIntervalActionElapsedTimeIntervalKey)] = @(elapsedTimeInterval + lastTimeInterval);
                dict[TYPE_STR(YZHIntervalActionLastTimeIntervalKey)] = @(lastTimeInterval);
                
                [self performSelector:@selector(nextIntervalAction:) withObject:dict afterDelay:lastTimeInterval];
            }
            else if (self.gestureRecognizer.YZHState == YZHUIGestureRecognizerStateChanged)
            {
                self.gestureBlock(self.gestureRecognizer);
                self.gestureRecognizer.YZHState = YZHUIGestureRecognizerStateChanged;
            }
        }
        else if (actionOptionsInfo.actionOptions == YZHIntervalGestureRecognizerActionOptionsBeginChangesEnd || actionOptionsInfo.actionOptions == YZHIntervalGestureRecognizerActionOptionsCustom)
        {
            if (self.gestureRecognizer.YZHState == YZHUIGestureRecognizerStateBegan || self.gestureRecognizer.YZHState == YZHUIGestureRecognizerStateChanged) {
                self.gestureBlock(self.gestureRecognizer);
                self.gestureRecognizer.YZHState = YZHUIGestureRecognizerStateChanged;
                
                CGFloat nextTimeInterval = 0;
                if (actionOptionsInfo.timingFunctionBlock) {
                    nextTimeInterval = actionOptionsInfo.timingFunctionBlock(elapsedTimeInterval,lastTimeInterval);
                }
                if (nextTimeInterval > 0 && nextTimeInterval <= MIN_TIME_INTERVAL) {
                    nextTimeInterval = MIN_TIME_INTERVAL;
                }
                else if (nextTimeInterval == 0)
                {
                    self.gestureRecognizer.YZHState = YZHUIGestureRecognizerStateEnded;
                    self.gestureBlock(self.gestureRecognizer);
                    return;
                }
                else
                {
                    return;
                }
                lastTimeInterval = nextTimeInterval;
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                dict[TYPE_STR(YZHStateKey)] = @(YZHUIGestureRecognizerStateChanged);
                dict[TYPE_STR(YZHIntervalActionElapsedTimeIntervalKey)] = @(elapsedTimeInterval + lastTimeInterval);
                dict[TYPE_STR(YZHIntervalActionLastTimeIntervalKey)] = @(lastTimeInterval);
                
                [self performSelector:@selector(nextIntervalAction:) withObject:dict afterDelay:lastTimeInterval];
            }
        }
    }
}

@end


/****************************************************
 *UIView (YZHAddForUIGestureRecognizer)
 ****************************************************/
@implementation UIView (YZHAddForUIGestureRecognizer)

-(void)setGestureTargets:(NSMutableArray<UIGestureRecognizerBlockTarget*> *)gestureTargets
{
    objc_setAssociatedObject(self, @selector(gestureTargets), gestureTargets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray<UIGestureRecognizerBlockTarget*> *)gestureTargets
{
    NSMutableArray *targets = objc_getAssociatedObject(self, _cmd);
    if (targets == nil) {
        targets = [NSMutableArray array];
        self.gestureTargets = targets;
    }
    return targets;
}

-(void)beforeDo
{
    self.userInteractionEnabled = YES;
}

-(UITapGestureRecognizer*)addTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock
{
    return [self addTapGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil];
}

-(UITapGestureRecognizer *)addDoubleTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock
{
    return [self addDoubleTapGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil];
}

-(UIPanGestureRecognizer *)addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock
{
    return [self addPanGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil];
}

-(UILongPressGestureRecognizer *)addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock
{
    return [self addLongPressGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil];
}

-(UILongPressGestureRecognizer *)addLongPressGestureRecognizerBlockOnlyEnd:(YZHGestureRecognizerBlock)gestureBlock
{
    YZHIntervalGestureRecognizerActionOptionsInfo *actionOptionsInfo = [[YZHIntervalGestureRecognizerActionOptionsInfo alloc] init];
    actionOptionsInfo.actionOptions = YZHIntervalGestureRecognizerActionOptionsOnlyEnd;
    return [self addLongPressGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil actionOptionsInfo:actionOptionsInfo];
}

-(UITapGestureRecognizer *)addTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock
{
    [self beforeDo];
    
    UIGestureRecognizerBlockTarget *target = [[UIGestureRecognizerBlockTarget alloc] initWithGestureBlock:gestureBlock shouldBeginBlock:shouldBeginBlock];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(gestureAction:)];
    
    target.gestureRecognizer = tapGesture;
    
    [self addGestureRecognizer:tapGesture];
    [self.gestureTargets addObject:target];
    return tapGesture;
}

-(UITapGestureRecognizer *)addDoubleTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock
{
    [self beforeDo];
    
    UIGestureRecognizerBlockTarget *target = [[UIGestureRecognizerBlockTarget alloc] initWithGestureBlock:gestureBlock shouldBeginBlock:shouldBeginBlock];
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(gestureAction:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    for (UIGestureRecognizerBlockTarget *targetTmp in self.gestureTargets) {
        if ([targetTmp.gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            UITapGestureRecognizer *singleTap = (UITapGestureRecognizer*)targetTmp.gestureRecognizer;
            if (singleTap.numberOfTapsRequired == 1) {
                [singleTap requireGestureRecognizerToFail:doubleTapGesture];
            }
        }
    }
    target.gestureRecognizer = doubleTapGesture;
    
    [self addGestureRecognizer:doubleTapGesture];
    [self.gestureTargets addObject:target];
    
    return doubleTapGesture;
}

-(UIPanGestureRecognizer *)addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock
{
    return [self addPanGestureRecognizerBlock:gestureBlock shouldBeginBlock:shouldBeginBlock actionOptionsInfo:nil];
}

-(UILongPressGestureRecognizer *)addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock
{
    YZHIntervalGestureRecognizerActionOptionsInfo *actionOptionsInfo = [[YZHIntervalGestureRecognizerActionOptionsInfo alloc] init];
    actionOptionsInfo.actionOptions = YZHIntervalGestureRecognizerActionOptionsOnlyOnce;
    return [self addLongPressGestureRecognizerBlock:gestureBlock shouldBeginBlock:shouldBeginBlock actionOptionsInfo:actionOptionsInfo];
}

-(UIPanGestureRecognizer *)addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo *)optionsInfo
{
    return [self addPanGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil actionOptionsInfo:optionsInfo];
}

-(UILongPressGestureRecognizer *)addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo *)optionsInfo
{
    return [self addLongPressGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil actionOptionsInfo:optionsInfo];
}

-(UIPanGestureRecognizer *)addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo *)optionsInfo
{
    [self beforeDo];
    
    UIGestureRecognizerBlockTarget *target = [[UIGestureRecognizerBlockTarget alloc] initWithGestureBlock:gestureBlock shouldBeginBlock:shouldBeginBlock];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(gestureAction:)];
    
    target.actionOptionsInfo = optionsInfo;
    target.gestureRecognizer = panGesture;
    
    [self addGestureRecognizer:panGesture];
    [self.gestureTargets addObject:target];
    return panGesture;
}

-(UILongPressGestureRecognizer *)addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo *)optionsInfo
{
    [self beforeDo];
    
    UIGestureRecognizerBlockTarget *target = [[UIGestureRecognizerBlockTarget alloc] initWithGestureBlock:gestureBlock shouldBeginBlock:shouldBeginBlock];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:@selector(gestureAction:)];
//    longGesture.minimumPressDuration = DEFAULT_TIME_INTERVAL;
    
    target.actionOptionsInfo = optionsInfo;
    target.gestureRecognizer = longGesture;
    
    [self addGestureRecognizer:longGesture];
    [self.gestureTargets addObject:target];
    
    return longGesture;
}

@end
