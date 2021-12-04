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


typedef NS_ENUM(NSInteger, YZHGestureRecognizerState)
{
    YZHGestureRecognizerStateNull     = 0,
    YZHGestureRecognizerStateBegan    = 1,
    YZHGestureRecognizerStateChanged  = 2,
    YZHGestureRecognizerStateEnded    = 3,
};



/****************************************************
 *UIGestureRecognizer (GestureRecognizerInfo)
 ****************************************************/
@implementation UIGestureRecognizer (GestureRecognizerInfo)

- (void)setHz_state:(YZHGestureRecognizerState)hz_state
{
    objc_setAssociatedObject(self, @selector(hz_state), @(hz_state), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(YZHGestureRecognizerState)hz_state
{
    return (YZHGestureRecognizerState)[objc_getAssociatedObject(self, _cmd) integerValue];
}

-(void)setHz_userInfo:(NSDictionary *)hz_userInfo
{
    objc_setAssociatedObject(self, @selector(hz_userInfo), hz_userInfo, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSDictionary*)hz_userInfo
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
        [self pri_setupDefault];
    }
    return self;
}

-(void)pri_setupDefault
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
    self.gestureRecognizer.hz_userInfo = actionInfo;
    
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
                self.gestureRecognizer.hz_state = YZHGestureRecognizerStateBegan;
            }
            else if (self.gestureRecognizer.state == UIGestureRecognizerStateChanged) {
                if (option == YZHIntervalGestureRecognizerActionOptionsBeginChangeEnd) {
                    if (self.gestureRecognizer.hz_state == YZHGestureRecognizerStateBegan) {
                        self.gestureBlock(self.gestureRecognizer);
                        self.gestureRecognizer.hz_state = YZHGestureRecognizerStateChanged;
                    }
                    return;
                }
                else {
                    self.gestureBlock(self.gestureRecognizer);
                    self.gestureRecognizer.hz_state = YZHGestureRecognizerStateChanged;
                }
            }
            else if (self.gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                if (self.gestureRecognizer.hz_state == YZHGestureRecognizerStateChanged) {
                    self.gestureBlock(self.gestureRecognizer);
                    self.gestureRecognizer.hz_state = YZHGestureRecognizerStateEnded;
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

-(void)setHz_gestureTargets:(NSMutableArray<UIGestureRecognizerBlockTarget*> *)hz_gestureTargets
{
    objc_setAssociatedObject(self, @selector(hz_gestureTargets), hz_gestureTargets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray<UIGestureRecognizerBlockTarget*> *)hz_gestureTargets
{
    NSMutableArray *targets = objc_getAssociatedObject(self, _cmd);
    if (targets == nil) {
        targets = [NSMutableArray array];
        self.hz_gestureTargets = targets;
    }
    return targets;
}

-(void)hz_beforeDo
{
    self.userInteractionEnabled = YES;
}

-(UITapGestureRecognizer*)hz_addTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock
{
    return [self hz_addTapGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil];
}

-(UITapGestureRecognizer *)hz_addDoubleTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock
{
    return [self hz_addDoubleTapGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil];
}

-(UIPanGestureRecognizer *)hz_addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock
{
    return [self hz_addPanGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil];
}

-(UILongPressGestureRecognizer *)hz_addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock
{
    return [self hz_addLongPressGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil];
}

-(UILongPressGestureRecognizer *)hz_addLongPressGestureRecognizerBlockOnlyEnd:(YZHGestureRecognizerBlock)gestureBlock
{
    YZHIntervalGestureRecognizerActionOptionsInfo *actionOptionsInfo = [[YZHIntervalGestureRecognizerActionOptionsInfo alloc] init];
    actionOptionsInfo.actionOptions = YZHIntervalGestureRecognizerActionOptionsOnlyEnd;
    return [self hz_addLongPressGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil actionOptionsInfo:actionOptionsInfo];
}

-(UITapGestureRecognizer *)hz_addTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock
{
    [self hz_beforeDo];
    
    UIGestureRecognizerBlockTarget *target = [[UIGestureRecognizerBlockTarget alloc] initWithGestureBlock:gestureBlock shouldBeginBlock:shouldBeginBlock];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(gestureAction:)];
    
    target.gestureRecognizer = tapGesture;

    [self addGestureRecognizer:tapGesture];
    [self.hz_gestureTargets addObject:target];
    return tapGesture;
}

-(UITapGestureRecognizer *)hz_addDoubleTapGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock
{
    [self hz_beforeDo];
    
    UIGestureRecognizerBlockTarget *target = [[UIGestureRecognizerBlockTarget alloc] initWithGestureBlock:gestureBlock shouldBeginBlock:shouldBeginBlock];
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(gestureAction:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    for (UIGestureRecognizerBlockTarget *targetTmp in self.hz_gestureTargets) {
        if ([targetTmp.gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            UITapGestureRecognizer *singleTap = (UITapGestureRecognizer*)targetTmp.gestureRecognizer;
            if (singleTap.numberOfTapsRequired == 1) {
                [singleTap requireGestureRecognizerToFail:doubleTapGesture];
            }
        }
    }
    target.gestureRecognizer = doubleTapGesture;

    [self addGestureRecognizer:doubleTapGesture];
    [self.hz_gestureTargets addObject:target];
    
    return doubleTapGesture;
}

-(UIPanGestureRecognizer *)hz_addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock
{
    return [self hz_addPanGestureRecognizerBlock:gestureBlock shouldBeginBlock:shouldBeginBlock actionOptionsInfo:nil];
}

-(UILongPressGestureRecognizer *)hz_addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock
{
    YZHIntervalGestureRecognizerActionOptionsInfo *actionOptionsInfo = [[YZHIntervalGestureRecognizerActionOptionsInfo alloc] init];
    actionOptionsInfo.actionOptions = YZHIntervalGestureRecognizerActionOptionsOnlyOnce;
    return [self hz_addLongPressGestureRecognizerBlock:gestureBlock shouldBeginBlock:shouldBeginBlock actionOptionsInfo:actionOptionsInfo];
}

-(UIPanGestureRecognizer *)hz_addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo *)optionsInfo
{
    return [self hz_addPanGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil actionOptionsInfo:optionsInfo];
}

-(UILongPressGestureRecognizer *)hz_addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo *)optionsInfo
{
    return [self hz_addLongPressGestureRecognizerBlock:gestureBlock shouldBeginBlock:nil actionOptionsInfo:optionsInfo];
}

-(UIPanGestureRecognizer *)hz_addPanGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo *)optionsInfo
{
    [self hz_beforeDo];
    
    UIGestureRecognizerBlockTarget *target = [[UIGestureRecognizerBlockTarget alloc] initWithGestureBlock:gestureBlock shouldBeginBlock:shouldBeginBlock];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(gestureAction:)];
    
    target.actionOptionsInfo = optionsInfo;
    target.gestureRecognizer = panGesture;
    
    [self addGestureRecognizer:panGesture];
    [self.hz_gestureTargets addObject:target];
    return panGesture;
}

-(UILongPressGestureRecognizer *)hz_addLongPressGestureRecognizerBlock:(YZHGestureRecognizerBlock)gestureBlock shouldBeginBlock:(YZHGestureRecognizerShouldBeginBlock)shouldBeginBlock actionOptionsInfo:(YZHIntervalGestureRecognizerActionOptionsInfo *)optionsInfo
{
    [self hz_beforeDo];
    
    UIGestureRecognizerBlockTarget *target = [[UIGestureRecognizerBlockTarget alloc] initWithGestureBlock:gestureBlock shouldBeginBlock:shouldBeginBlock];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:@selector(gestureAction:)];
    longGesture.minimumPressDuration = DEFAULT_TIME_INTERVAL;
    
    target.actionOptionsInfo = optionsInfo;
    target.gestureRecognizer = longGesture;
    
    
    [self addGestureRecognizer:longGesture];
    [self.hz_gestureTargets addObject:target];
    
    return longGesture;
}

@end
