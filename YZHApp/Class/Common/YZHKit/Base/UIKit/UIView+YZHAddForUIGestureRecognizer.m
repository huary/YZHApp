//
//  UIView+YZHAddForUIGestureRecognizer.m
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIView+YZHAddForUIGestureRecognizer.h"
#import <objc/runtime.h>
#import "YZHKitType.h"

#define DEFAULT_TIME_INTERVAL       (0.2)
#define MAX_TIME_INTERVAL           (30.0)
#define MIN_TIME_INTERVAL           (0.01)


NSString * const YZHIntervalActionLastTimeIntervalKey = TYPE_STR(YZHIntervalActionLastTimeInterval);
NSString * const YZHIntervalActionElapsedTimeIntervalKey = TYPE_STR(YZHIntervalActionElapsedTimeInterval);


typedef NS_ENUM(NSInteger, YZHUIGestureRecognizerState)
{
    YZHUIGestureRecognizerStateNull     = 0,
    YZHUIGestureRecognizerStateBegan    = 1,
    YZHUIGestureRecognizerStateChanged  = 2,
    YZHUIGestureRecognizerStateEnded    = 3,
};



/****************************************************
 *UIGestureRecognizer (GestureRecognizerInfo)
 ****************************************************/
@implementation UIGestureRecognizer (GestureRecognizerInfo)

-(void)setYZHState:(YZHUIGestureRecognizerState)YZHState
{
    objc_setAssociatedObject(self, @selector(YZHState), @(YZHState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(YZHUIGestureRecognizerState)YZHState
{
    return (YZHUIGestureRecognizerState)[objc_getAssociatedObject(self, _cmd) integerValue];
}


-(void)setUserInfo:(NSDictionary *)userInfo
{
    objc_setAssociatedObject(self, @selector(userInfo), userInfo, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSDictionary*)userInfo
{
    return objc_getAssociatedObject(self, _cmd);
}

@end

/****************************************************
 *YZHIntervalGestureRecognizerActionOptionsInfo
 ****************************************************/
@implementation YZHIntervalGestureRecognizerActionOptionsInfo
-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefault];
    }
    return self;
}

-(void)_setupDefault
{
    _minActionTimeInterval = MIN_TIME_INTERVAL;
    _maxActionTimeInterval = MAX_TIME_INTERVAL;
    _easeInChangeRatio = 0.8;
    _easeOutChangeRatio = 1.25;
}

+(YZHIntervalGestureActionTimingFunctionBlock)linearTimingFunctionBlockForMin:(NSTimeInterval)min max:(NSTimeInterval)max
{
    YZHIntervalGestureActionTimingFunctionBlock linearBlock = ^(NSTimeInterval elapsedTime,NSTimeInterval lastTimeInterval){
        lastTimeInterval = MAX(lastTimeInterval, min);
        lastTimeInterval = MIN(lastTimeInterval, max);
        return lastTimeInterval;
    };
    return linearBlock;
}

+(YZHIntervalGestureActionTimingFunctionBlock)easeInTimingFunctionBlockForMin:(NSTimeInterval)min max:(NSTimeInterval)max changeRatio:(CGFloat)changeRatio
{
//    CGFloat changeRatio = 0.8;
    YZHIntervalGestureActionTimingFunctionBlock easeInBlock = ^(NSTimeInterval elapsedTime,NSTimeInterval lastTimeInterval){
        lastTimeInterval = lastTimeInterval * changeRatio;
        lastTimeInterval = MAX(lastTimeInterval, min);
        lastTimeInterval = MIN(lastTimeInterval, max);
        return lastTimeInterval;
    };
    return easeInBlock;
}

+(YZHIntervalGestureActionTimingFunctionBlock)easeOutTimingFunctionBlockForMin:(NSTimeInterval)min max:(NSTimeInterval)max changeRatio:(CGFloat)changeRatio
{
//    CGFloat changeRatio = 1.25;
    YZHIntervalGestureActionTimingFunctionBlock easeOutBlock = ^(NSTimeInterval elapsedTime,NSTimeInterval lastTimeInterval){
        lastTimeInterval = lastTimeInterval * changeRatio;
        lastTimeInterval = MAX(lastTimeInterval, min);
        lastTimeInterval = MIN(lastTimeInterval, max);
        return lastTimeInterval;
    };
    return easeOutBlock;
}

-(YZHIntervalGestureActionTimingFunctionBlock)timingFunctionBlock
{    
    if (_timingFunctionBlock != nil) {
        return _timingFunctionBlock;
    }
    
    NSTimeInterval min = self.minActionTimeInterval;
    NSTimeInterval max = self.maxActionTimeInterval;
    
    if (self.timingFunction == YZHIntervalGestureRecognizerActionTimingFunctionLinear) {
        self.timingFunctionBlock = [YZHIntervalGestureRecognizerActionOptionsInfo linearTimingFunctionBlockForMin:min max:max];
    }
    else if (self.timingFunction == YZHIntervalGestureRecognizerActionTimingFunctionEaseIn)
    {
        self.timingFunctionBlock = [YZHIntervalGestureRecognizerActionOptionsInfo easeInTimingFunctionBlockForMin:min max:max changeRatio:self.easeInChangeRatio];
    }
    else if (self.timingFunction == YZHIntervalGestureRecognizerActionTimingFunctionEaseOut)
    {
        self.timingFunctionBlock = [YZHIntervalGestureRecognizerActionOptionsInfo easeOutTimingFunctionBlockForMin:min max:max changeRatio:self.easeOutChangeRatio];
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
        self.gestureBlock(gestureRecognizer);
    }
    else
    {
//        NSLog(@"%s,gesture=%@",__FUNCTION__,self.gestureRecognizer);
        if (self.gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self _startIntervalAction];
        }
        else if (self.gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            
        }
        else if (self.gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self _startIntervalAction];
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
//    if (shouldBegin) {
//        [self startIntervalAction];
//    }
    return shouldBegin;
}

-(BOOL)_shouldDoStartIntervalActionFor:(YZHIntervalGestureRecognizerActionOptionsInfo*)optionsInfo
{
    if (optionsInfo == nil) {
        return NO;
    }
    YZHIntervalGestureRecognizerActionOptions options = optionsInfo.actionOptions;
    return (options != YZHIntervalGestureRecognizerActionOptionsDefault);
}

-(void)_startIntervalAction
{
    if (![self _shouldDoStartIntervalActionFor:self.actionOptionsInfo]) {
        return;
    }
    CGFloat lastTimeInterval = 0;
    if ([self.gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer*)self.gestureRecognizer;
        //如果某一次特殊的话，按特殊的时间来进行
        lastTimeInterval = longPress.minimumPressDuration;
    }
    CGFloat elapsedTimeInterval = lastTimeInterval;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[YZHIntervalActionLastTimeIntervalKey] = @(lastTimeInterval);
    dict[YZHIntervalActionElapsedTimeIntervalKey] = @(elapsedTimeInterval);
    [self _nextIntervalAction:dict];
}

-(BOOL)_shouldDoNextActionForGesture:(UIGestureRecognizer*)gesture
{
    if (!gesture) {
        return NO;
    }
    if (([gesture isKindOfClass:[UILongPressGestureRecognizer class]] ||
         [gesture isKindOfClass:[UIPanGestureRecognizer class]]) &&
        gesture.state >= UIGestureRecognizerStateBegan &&
        gesture.state <= UIGestureRecognizerStateEnded) {
        return YES;
    }
    return NO;
}

-(void)_nextIntervalAction:(NSDictionary*)actionInfo
{
    YZHIntervalGestureRecognizerActionOptionsInfo *actionOptionsInfo = self.actionOptionsInfo;
    
//    NSLog(@"gesture=%@",self.gestureRecognizer);
    self.gestureRecognizer.userInfo = actionInfo;
    
    YZHIntervalGestureRecognizerActionOptions option = actionOptionsInfo.actionOptions;
    if (self.gestureBlock && [self _shouldDoNextActionForGesture:self.gestureRecognizer])
    {
        if (option == YZHIntervalGestureRecognizerActionOptionsOnlyOnce) {
            if (self.gestureRecognizer.state == UIGestureRecognizerStateBegan) {
                self.gestureBlock(self.gestureRecognizer);
            }
        }
        else if (option == YZHIntervalGestureRecognizerActionOptionsOnlyEnd) {
            if (self.gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                self.gestureBlock(self.gestureRecognizer);
            }
        }
        else if (option == YZHIntervalGestureRecognizerActionOptionsBeginEnd)
        {
            if (self.gestureRecognizer.state == UIGestureRecognizerStateBegan) {
                self.gestureBlock(self.gestureRecognizer);
            }
            else if (self.gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                self.gestureBlock(self.gestureRecognizer);
            }
        }
        else if (option == YZHIntervalGestureRecognizerActionOptionsBeginChangeEnd ||
                 option == YZHIntervalGestureRecognizerActionOptionsBeginChangesEnd ||
                 option == YZHIntervalGestureRecognizerActionOptionsCustom)
        {
            if (self.gestureRecognizer.state == UIGestureRecognizerStateBegan) {
                self.gestureBlock(self.gestureRecognizer);
                self.gestureRecognizer.YZHState = YZHUIGestureRecognizerStateBegan;
            }
            else if (self.gestureRecognizer.state == UIGestureRecognizerStateChanged) {
                if (option == YZHIntervalGestureRecognizerActionOptionsBeginChangeEnd) {
                    if (self.gestureRecognizer.YZHState == YZHUIGestureRecognizerStateBegan) {
                        self.gestureBlock(self.gestureRecognizer);
                        self.gestureRecognizer.YZHState = YZHUIGestureRecognizerStateChanged;
                    }
                    return;
                }
                else {
                    self.gestureBlock(self.gestureRecognizer);
                    self.gestureRecognizer.YZHState = YZHUIGestureRecognizerStateChanged;
                }
            }
            else if (self.gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                if (self.gestureRecognizer.YZHState == YZHUIGestureRecognizerStateChanged) {
                    self.gestureBlock(self.gestureRecognizer);
                    self.gestureRecognizer.YZHState = YZHUIGestureRecognizerStateEnded;
                }
                return;
            }
            
            NSTimeInterval lastTimeInterval = [actionInfo[YZHIntervalActionLastTimeIntervalKey] doubleValue];
            NSTimeInterval elapsedTimeInterval = [actionInfo[YZHIntervalActionElapsedTimeIntervalKey] doubleValue];
            CGFloat nextTimeInterval = 0;
            if (actionOptionsInfo.timingFunctionBlock) {
                nextTimeInterval = actionOptionsInfo.timingFunctionBlock(elapsedTimeInterval,lastTimeInterval);
            }
            
            if (nextTimeInterval > 0 && nextTimeInterval <= actionOptionsInfo.minActionTimeInterval) {
                nextTimeInterval = actionOptionsInfo.minActionTimeInterval;
            }
            else if (nextTimeInterval > actionOptionsInfo.maxActionTimeInterval) {
                nextTimeInterval = actionOptionsInfo.maxActionTimeInterval;
            }
            else if (nextTimeInterval == 0)
            {
                self.gestureBlock(self.gestureRecognizer);
                return;
            }
            lastTimeInterval = nextTimeInterval;
//            NSLog(@"next=%f",nextTimeInterval);
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[YZHIntervalActionLastTimeIntervalKey] = @(lastTimeInterval);
            dict[YZHIntervalActionElapsedTimeIntervalKey] = @(elapsedTimeInterval + lastTimeInterval);
            
            [self performSelector:@selector(_nextIntervalAction:) withObject:dict afterDelay:lastTimeInterval];
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
    longGesture.minimumPressDuration = DEFAULT_TIME_INTERVAL;
    
    target.actionOptionsInfo = optionsInfo;
    target.gestureRecognizer = longGesture;
    
    
    [self addGestureRecognizer:longGesture];
    [self.gestureTargets addObject:target];
    
    return longGesture;
}

@end
