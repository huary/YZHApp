//
//  NSPaintModel.m
//  UIPaintingViewDemo
//
//  Created by yuan on 2018/2/1.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "NSPaintModel.h"
#import <objc/runtime.h>
#import "YZHKitType.h"
#import "YZHUtil.h"

#define EVENT_DIR_NAME      @"event"
#define STROKE_DIR_NAME     @"stroke"
#define INVALID_PLAY_ID     (0LL)

#define IS_VALID_STROKE_ID(STROKE_ID)       (STROKE_ID > 0)
#define IS_VALID_EVENT_ID(EVENT_ID)         (EVENT_ID > 0)


typedef NS_ENUM(NSInteger, NSTimeActionType)
{
    NSTimeActionTypeTotal   = (1 << 0),
    NSTimeActionTypeFind    = (1 << 1),
    //began，end
    NSTimeActionTypeBE      = (1 << 2),
};


/***********************************************************************
 *NSPaintPlayInfo
 ***********************************************************************/
@implementation NSPaintPlayInfo

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.playId = USEC_FROM_DATE_SINCE1970([NSDate date]);
    }
    return self;
}

-(instancetype)initWithPlayId:(int64_t)playId playTime:(NSTimeInterval)playTime
{
    self = [self init];
    if (self) {
        self.playId = playId;
        self.playTime = playTime;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.playId = [aDecoder decodeInt64ForKey:TYPE_STR(playId)];
        self.playTime = [aDecoder decodeDoubleForKey:TYPE_STR(playTime)];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.playId forKey:TYPE_STR(playId)];
    [aCoder encodeDouble:self.playTime forKey:TYPE_STR(playTime)];
}

@end







/***********************************************************************
 *GLLinePoint
 ***********************************************************************/
@implementation GLLinePoint

-(instancetype)initWithPoint:(CGPoint)point lineWidth:(CGFloat)lineWidth
{
    self = [super init];
    if (self) {
        self.point = point;
        self.lineWidth = lineWidth;
    }
    return self;
}

@end








/***********************************************************************
 *NSPaintPoint
 ***********************************************************************/
@implementation NSPaintPoint

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.point = [aDecoder decodeCGPointForKey:TYPE_STR(point)];
        self.pressure = [aDecoder decodeDoubleForKey:TYPE_STR(pressure)];
        self.status = [aDecoder decodeIntegerForKey:TYPE_STR(status)];
        self.timeInterval = [aDecoder decodeDoubleForKey:TYPE_STR(timeInterval)];
        self.lineWidth = [aDecoder decodeFloatForKey:TYPE_STR(lineWidth)];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeCGPoint:self.point forKey:TYPE_STR(point)];
    [aCoder encodeDouble:self.pressure forKey:TYPE_STR(pressure)];
    [aCoder encodeInteger:self.status forKey:TYPE_STR(status)];
    [aCoder encodeDouble:self.timeInterval forKey:TYPE_STR(timeInterval)];
    [aCoder encodeFloat:self.lineWidth forKey:TYPE_STR(lineWidth)];
}

-(instancetype)initWithPoint:(CGPoint)point status:(NSPaintStatus)stauts lineWidth:(CGFloat)lineWidth
{
    self = [super init];
    if (self) {
        self.point = point;
        self.status = stauts;
        self.lineWidth = lineWidth;
    }
    return self;
}

-(instancetype)initWithPoint:(CGPoint)point pressure:(CGFloat)pressure status:(NSPaintStatus)stauts timeInterval:(NSTimeInterval)timeInterval
{
    self = [super init];
    if (self) {
        self.point = point;
        self.pressure = pressure;
        self.status = stauts;
        self.timeInterval = timeInterval;
    }
    return self;
}

-(CGFloat)getLineWidth:(CGFloat)maxLineWidth
{
    if (self.lineWidth > 0) {
        return self.lineWidth;
    }
    return self.pressure * maxLineWidth / 100;
}

+(NSTimeInterval)getTimeIntervalFrom:(NSPaintPoint*)from to:(NSPaintPoint*)to
{
    return to.timeInterval - from.timeInterval;
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"point=%@,pressure=%f,status=%@,timerInterval=%f",NSStringFromCGPoint(self.point),self.pressure,@(self.status),self.timeInterval];
}

@end

/***********************************************************************
 *NSPaintPoint(PlayBack)
 ***********************************************************************/
@implementation NSPaintPoint (PlayBack)

-(void)setStartPlay:(NSPaintPlayInfo *)startPlay
{
    objc_setAssociatedObject(self, @selector(startPlay), startPlay, OBJC_ASSOCIATION_RETAIN);
}

-(NSPaintPlayInfo*)startPlay
{
    return objc_getAssociatedObject(self, _cmd);
}

@end





/***********************************************************************
 *NSPaintStroke
 *绘画的笔画，单次存入的最小单元
 ***********************************************************************/
@interface NSPaintStroke ()
@property (nonatomic, assign) uint64_t eventId;

@property (nonatomic, strong) NSMutableArray<NSPaintPoint*> *strokePoints;

-(void)save;
-(void)deleteFromFile;
+(void)deleteWithEventId:(uint64_t)eventId strokeId:(NSUInteger)strokeId;

-(NSInteger)getPointIndexForTimeInterval:(NSTimeInterval)timeInterval fromIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx;
@end

@implementation NSPaintStroke

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.eventId = [aDecoder decodeInt64ForKey:TYPE_STR(eventId)];
        self.strokeId = [aDecoder decodeIntegerForKey:TYPE_STR(strokeId)];
        self.strokeColor = [aDecoder decodeObjectForKey:TYPE_STR(strokeColor)];
        self.strokePoints = [aDecoder decodeObjectForKey:TYPE_STR(paintStroke)];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.eventId forKey:TYPE_STR(eventId)];
    [aCoder encodeInteger:self.strokeId forKey:TYPE_STR(strokeId)];
    [aCoder encodeObject:self.strokeColor forKey:TYPE_STR(strokeColor)];
    [aCoder encodeObject:self.strokePoints forKey:TYPE_STR(paintStroke)];
}

-(NSMutableArray<NSPaintPoint*>*)strokePoints
{
    if (_strokePoints == nil) {
        _strokePoints = [NSMutableArray array];
    }
    return _strokePoints;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.strokeId = 0;
    }
    return self;
}

-(instancetype)initWithEventId:(uint64_t)eventId
{
    self = [self init];
    if (self) {
        self.eventId = eventId;
    }
    return self;
}

-(instancetype)initWithEventId:(uint64_t)eventId strokeColor:(UIColor *)strokeColor {
    
    self = [self initWithEventId:eventId];
    if (self) {
        self.strokeColor = strokeColor;
    }
    return self;
}

-(NSArray<NSPaintPoint*>*)paintPoints
{
    return [self.strokePoints copy];
}

-(void)addPaintPoint:(NSPaintPoint*)paintPoint
{
    if (paintPoint) {
        [self.strokePoints addObject:paintPoint];        
    }
}

+(NSString*)_saveKey:(uint64_t)eventId strokeId:(NSUInteger)strokeId
{
    return NEW_STRING_WITH_FORMAT(@"%@/%@/%@_%@/%@",EVENT_DIR_NAME,@(eventId),@(eventId),@(strokeId),STROKE_DIR_NAME);
}

-(void)save
{
    if (!IS_VALID_EVENT_ID(self.eventId) || !IS_VALID_STROKE_ID(self.strokeId)) {
        return;
    }
    [YZHUtil saveObject:self to:[[self class] _saveKey:self.eventId strokeId:self.strokeId]];
}

-(void)deleteFromFile
{
    [YZHUtil removeObjectFrom:[[self class] _saveKey:self.eventId strokeId:self.strokeId]];
}

+(void)deleteWithEventId:(uint64_t)eventId strokeId:(NSUInteger)strokeId
{
    [YZHUtil removeObjectFrom:[[self class] _saveKey:eventId strokeId:strokeId]];
}

+(NSPaintStroke*)loadWithEventId:(uint64_t)eventId strokeId:(NSUInteger)strokeId
{
    id obj = (NSPaintStroke*)[YZHUtil loadObjectFrom:[[self class] _saveKey:eventId strokeId:strokeId]];
    return obj;
}


-(NSTimeInterval)startTimeInterval
{
    if (!IS_AVAILABLE_NSSET_OBJ(self.strokePoints)) {
        return 0;
    }
    NSPaintPoint *first = [self.strokePoints firstObject];
    return first.timeInterval;
}

-(NSTimeInterval)endTimeInterval
{
    if (!IS_AVAILABLE_NSSET_OBJ(self.strokePoints)) {
        return 0;
    }
    NSPaintPoint *last = [self.strokePoints lastObject];
    return last.timeInterval;
}

-(NSTimeInterval)paintTimeInterval
{
    if (!IS_AVAILABLE_NSSET_OBJ(self.strokePoints)) {
        return 0;
    }
    NSTimeInterval time = [self endTimeInterval] - [self startTimeInterval];
    return time;
}

-(NSInteger)getPointIndexForTimeInterval:(NSTimeInterval)timeInterval fromIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx
{
    if (fromIdx > toIdx) {
        return 0;
    }
    fromIdx = MAX(fromIdx, 0);
    toIdx = MIN(toIdx, self.paintPoints.count);
    
    NSInteger findIdx = (fromIdx + toIdx)/2;
    if (findIdx >= self.strokePoints.count) {
        return -1;
    }
    NSPaintPoint *findObj = self.strokePoints[findIdx];
    NSPaintPoint *nextObj = nil;
    if (findIdx + 1 < self.strokePoints.count) {
        nextObj = self.strokePoints[findIdx + 1];
    }
    else {
        return findIdx;
    }
    
    NSPaintPoint *first = self.strokePoints[0];
    NSTimeInterval start = [NSPaintPoint getTimeIntervalFrom:first to:findObj];
    NSTimeInterval end = [NSPaintPoint getTimeIntervalFrom:first to:nextObj];
    if (timeInterval >= start && timeInterval <= end) {
        return findIdx;
    }
    else if (timeInterval < start) {
        return [self getPointIndexForTimeInterval:timeInterval fromIndex:fromIdx toIndex:findIdx];
    }
    else if (timeInterval > end) {
        return [self getPointIndexForTimeInterval:timeInterval fromIndex:findIdx toIndex:toIdx];
    }
    return -1;
}

-(CGRect)_getPaintStrokeRectFromIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx maxLineWidth:(CGFloat)maxLineWidth
{
    if (fromIdx > toIdx) {
        return CGRectZero;
    }
    fromIdx = MAX(fromIdx, 0);
    toIdx = MIN(toIdx, self.paintPoints.count);
    CGFloat minX = CGFLOAT_MAX;
    CGFloat minY = CGFLOAT_MAX;
    CGFloat maxX = CGFLOAT_MIN;
    CGFloat maxY = CGFLOAT_MIN;
    
    maxLineWidth = MAX(1.0, maxLineWidth);
    for (NSUInteger idx = fromIdx; idx < toIdx; ++idx) {
        NSPaintPoint *tmp = self.paintPoints[idx];
        minX = MIN(tmp.point.x, minX);
        minY = MIN(tmp.point.y, minY);
        
        maxX = MAX(tmp.point.x, maxX);
        maxY = MAX(tmp.point.y, maxY);
        
        maxLineWidth = MAX(maxLineWidth, tmp.lineWidth);
    }
    
    CGFloat diff = maxLineWidth/2;
    diff = MAX(1.0, diff);
    
    minX = minX - diff;
    minY = minY - diff;
    maxX = maxX + diff;
    maxY = maxY + diff;
    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

-(CGRect)getPaintStrokeRectWithLineWidth:(CGFloat)lineWidth
{
    return [self _getPaintStrokeRectFromIndex:0 toIndex:NSIntegerMax maxLineWidth:lineWidth];
}

-(CGRect)getPaintStrokeRectFromPointIndex:(NSInteger)fromIndex toPointIndex:(NSInteger)toIndex withLineWidth:(CGFloat)lineWidth
{
    return [self _getPaintStrokeRectFromIndex:fromIndex toIndex:toIndex maxLineWidth:lineWidth];
}

@end

/***********************************************************************
 *NSPaintStroke (PlayBack)
 *回放时需要用到，存储上一次绘制的点
 ***********************************************************************/

@implementation NSPaintStroke (PlayBack)


-(void)setLastPaintPoint:(NSPaintPoint *)lastPaintPoint
{
    objc_setAssociatedObject(self, @selector(lastPaintPoint), lastPaintPoint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSPaintPoint*)lastPaintPoint
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setLastDisplayPoint:(NSPaintPoint *)lastDisplayPoint
{
    objc_setAssociatedObject(self, @selector(lastDisplayPoint), lastDisplayPoint, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSPaintPoint*)lastDisplayPoint
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setStartPlay:(NSPaintPlayInfo *)startPlay
{
    objc_setAssociatedObject(self, @selector(startPlay), startPlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSPaintPlayInfo*)startPlay
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setEndPlay:(NSPaintPlayInfo *)endPlay
{
    objc_setAssociatedObject(self, @selector(endPlay), endPlay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSPaintPlayInfo*)endPlay
{
    return objc_getAssociatedObject(self, _cmd);
}

@end







/***********************************************************************
 *NSPaintEventConfig
 *整个一次画画的配置
 ***********************************************************************/
@implementation NSPaintEventConfig

-(instancetype)initWithAdjacentPointsMaxTimeInterval:(NSTimeInterval)adjacentPointsMaxTimeInterval adjacentStrokesMaxFreeTimeInterval:(NSTimeInterval)adjacentStrokesMaxFreeTimeInterval
{
    self = [super init];
    if (self) {
        self.adjacentPointsMaxTimeInterval = adjacentPointsMaxTimeInterval;
        self.adjacentStrokesMaxFreeTimeInterval = adjacentStrokesMaxFreeTimeInterval;
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.adjacentPointsMaxTimeInterval = [aDecoder decodeDoubleForKey:TYPE_STR(adjacentPointsMaxTimeInterval)];
        self.adjacentStrokesMaxFreeTimeInterval = [aDecoder decodeDoubleForKey:TYPE_STR(adjacentStrokesMaxFreeTimeInterval)];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:self.adjacentPointsMaxTimeInterval forKey:TYPE_STR(adjacentPointsMaxTimeInterval)];
    [aCoder encodeDouble:self.adjacentStrokesMaxFreeTimeInterval forKey:TYPE_STR(adjacentStrokesMaxFreeTimeInterval)];
}

@end







/***********************************************************************
 *NSPaintEvent
 *整个一次画画的所有的笔记
 ***********************************************************************/
@interface NSPaintEvent()

@property (nonatomic, strong) NSMutableArray<NSNumber*> *strokeIds;

-(void)save;

-(void)deleteFromFile;
+(void)deleteWithEventId:(uint64_t)eventId;
@end

@implementation NSPaintEvent

+(NSString*)_saveKey:(uint64_t)eventId
{
    return NEW_STRING_WITH_FORMAT(@"%@/%@/%@", EVENT_DIR_NAME, @(eventId), @(eventId));
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.eventId = USEC_FROM_DATE_SINCE1970([NSDate date]);
        self.eventConfig = [[NSPaintEventConfig alloc] initWithAdjacentPointsMaxTimeInterval:2 adjacentStrokesMaxFreeTimeInterval:5];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.eventId = [aDecoder decodeInt64ForKey:TYPE_STR(eventId)];
        self.strokeIds = [aDecoder decodeObjectForKey:TYPE_STR(strokeIds)];
        self.eventConfig = [aDecoder decodeObjectForKey:TYPE_STR(eventConfig)];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.eventId forKey:TYPE_STR(eventId)];
    [aCoder encodeObject:self.strokeIds forKey:TYPE_STR(strokeIds)];
    [aCoder encodeObject:self.eventConfig forKey:TYPE_STR(eventConfig)];
}

-(NSMutableArray<NSNumber*>*)strokeIds
{
    if (_strokeIds == nil) {
        _strokeIds = [NSMutableArray array];
    }
    return _strokeIds;
}

-(NSArray<NSNumber*>*)paintStrokeIds
{
    return [self.strokeIds copy];
}

-(BOOL)_haveInForStrokeId:(NSUInteger)strokeId
{
    __block BOOL have = NO;
    [self.strokeIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj unsignedIntegerValue] == strokeId) {
            have = YES;
            *stop = YES;
        }
    }];
    return have;
}

-(NSUInteger)_firstOrLastStrokeId:(BOOL)isFirst
{
    if (!IS_AVAILABLE_NSSET_OBJ(self.strokeIds)) {
        return 0;
    }
    if (isFirst) {
        return [[self.strokeIds firstObject] unsignedIntegerValue];
    }
    else {
        return [[self.strokeIds lastObject] unsignedIntegerValue];
    }
}

-(NSUInteger)_getStrokeIdForCurrentStrokeId:(NSUInteger)strokeId isNext:(BOOL)isNext
{
    __block BOOL haveFind = NO;
    __block NSUInteger findIdx = 0;
    [self.strokeIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj unsignedIntegerValue] == strokeId) {
            findIdx = idx;
            haveFind = YES;
            *stop = YES;
        }
    }];
    if (haveFind == NO) {
        return 0;
    }
    NSUInteger retStrokeId = 0;
    if (isNext) {
        NSUInteger newIdx = findIdx + 1;
        if (newIdx >= self.strokeIds.count) {
            return 0;
        }
        retStrokeId = [self.strokeIds[newIdx] unsignedIntegerValue];
    }
    else {
        if (findIdx <= 0) {
            return 0;
        }
        retStrokeId = [self.strokeIds[findIdx-1] unsignedIntegerValue];
    }
    return retStrokeId;
}

-(NSUInteger)addPaintStroke:(NSPaintStroke*)paintStroke
{
    if (paintStroke) {
        if (paintStroke.eventId != self.eventId) {
            return 0;
        }
        
        //不要坚持began和end
//        if (IS_AVAILABLE_NSSET_OBJ(paintStroke.strokePoints)) {
//            NSPaintPoint *first = [paintStroke.strokePoints firstObject];
//            NSPaintPoint *last = [paintStroke.strokePoints lastObject];
//            if (first.status != NSPaintStatusBegan || last.status != NSPaintStatusEnd) {
//                return 0;
//            }
//        }
        
        if (paintStroke.strokeId == 0) {
            NSUInteger strokeId = 1;
            if (IS_AVAILABLE_NSSET_OBJ(self.strokeIds)) {
                NSNumber *last = [self.strokeIds lastObject];
                strokeId = [last unsignedIntegerValue] + 1;
            }
            paintStroke.strokeId = strokeId;
            [self.strokeIds addObject:@(paintStroke.strokeId)];
        }
        else {
            if (![self _haveInForStrokeId:paintStroke.strokeId]) {
                [self.strokeIds addObject:@(paintStroke.strokeId)];
            }
        }
        [paintStroke save];
    }
    [self save];
    return paintStroke.strokeId;
}

-(NSUInteger)deletePaintStroke:(NSPaintStroke*)paintStroke
{
    if (paintStroke) {
        NSInteger strokeId = paintStroke.strokeId;
        [self.strokeIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj integerValue] == strokeId) {
                [self.strokeIds removeObject:obj];
            }
        }];
        [paintStroke deleteFromFile];
    }
    [self save];
    return paintStroke.strokeId;
}

//第一笔
-(NSPaintStroke*)firstPaintStroke
{
    if (!IS_AVAILABLE_NSSET_OBJ(self.strokeIds)) {
        return nil;
    }
    NSUInteger strokeId = [[self.strokeIds firstObject] unsignedIntegerValue];
    return [self paintStrokeForStrokeId:strokeId];
}

//最后一笔
-(NSPaintStroke*)lastPaintStroke
{
    if (!IS_AVAILABLE_NSSET_OBJ(self.strokeIds)) {
        return nil;
    }
    NSUInteger strokeId = [[self.strokeIds lastObject] unsignedIntegerValue];
    return [self paintStrokeForStrokeId:strokeId];
}

//从当前cache的event中获取strokeId的NSPaintStroke的对象
-(NSPaintStroke*)paintStrokeForStrokeId:(NSUInteger)strokeId
{
    if (strokeId == 0) {
        return nil;
    }
    
    if (self.eventId == [NSPaintManager sharePaintManager].currentCacheEvent.eventId) {
        NSPaintStroke *stroke = [[NSPaintManager sharePaintManager] paintStrokeOnlyInCurrentCacheEventForStrokeId:strokeId];
        if (stroke.eventId == self.eventId) {
            return stroke;
        }
    }
    
    NSPaintStroke *stroke = [NSPaintStroke loadWithEventId:self.eventId strokeId:strokeId];
    return stroke;
}

//从当前的strokeId获取下一个paintStroke
-(NSPaintStroke*)nextPaintStrokeForStrokeId:(NSUInteger)strokeId
{
    NSUInteger newStrokeId = [self _getStrokeIdForCurrentStrokeId:strokeId isNext:YES];
    return [self paintStrokeForStrokeId:newStrokeId];
}

//从当前的strokeId获取上一个paintStroke
-(NSPaintStroke*)prevPaintStrokeForStrokeId:(NSUInteger)strokeId
{
    NSUInteger newStrokeId = [self _getStrokeIdForCurrentStrokeId:strokeId isNext:NO];
    return [self paintStrokeForStrokeId:newStrokeId];
}

//是否是第一笔
-(BOOL)isFirstPaintStroke:(NSPaintStroke*)stroke
{
    if (!IS_AVAILABLE_NSSET_OBJ(self.strokeIds)) {
        return NO;
    }
    NSUInteger strokeId = [[self.strokeIds firstObject] unsignedIntegerValue];
    if (stroke.strokeId == strokeId) {
        return YES;
    }
    return NO;
}

//是否是最后一笔
-(BOOL)isLastPaintStroke:(NSPaintStroke*)stroke
{
    if (!IS_AVAILABLE_NSSET_OBJ(self.strokeIds)) {
        return NO;
    }
    NSUInteger strokeId = [[self.strokeIds lastObject] unsignedIntegerValue];
    if (stroke.strokeId == strokeId) {
        return YES;
    }
    return NO;
}

-(void)save
{
    [YZHUtil saveObject:self to:[[self class] _saveKey:self.eventId]];
}

-(void)deleteFromFile
{
    [self.strokeIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [NSPaintStroke deleteWithEventId:self.eventId strokeId:[obj unsignedIntegerValue]];
    }];
    [YZHUtil removeObjectFrom:[[self class] _saveKey:self.eventId]];
}

+(void)deleteWithEventId:(uint64_t)eventId
{
    NSPaintEvent *event = [NSPaintEvent loadWithEventId:eventId];
    [event deleteFromFile];
}

+(NSPaintEvent*)loadWithEventId:(uint64_t)eventId
{
    id obj = (NSPaintEvent*)[YZHUtil loadObjectFrom:[[self class] _saveKey:eventId]];
    return obj;
}

/*
 *这个接口有如下功能
 *type取如下值
 *1、可以获取总的播放时间(type:1)
 *2、根据timeInterval获取stroke(type:2,timeinterval,stroke:不为空，)
 *3、获取stroke的start和end的timeInterval(type:3,stroke)
 */
-(NSTimeInterval)_getEventTimeInterval:(NSTimeActionType)actionType strokeTimeInterval:(NSTimeInterval)strokeTimeInterval findStroke:(NSPaintStroke**)findStroke
{
    NSTimeInterval totalTimeInterval = 0;
    if (!IS_AVAILABLE_NSSET_OBJ(self.strokeIds)) {
        return totalTimeInterval;
    }
    NSTimeInterval prevTotal = 0;
    NSPaintStroke *findObj = nil;
    
    for (NSNumber *obj in self.strokeIds) {
        NSUInteger strokeId = [obj unsignedIntegerValue];
        
        NSPaintStroke *stroke = [self paintStrokeForStrokeId:strokeId];
        
        prevTotal = totalTimeInterval;
        NSTimeInterval strokeTime = [stroke paintTimeInterval];
        strokeTime = MIN(strokeTime, self.eventConfig.adjacentPointsMaxTimeInterval);
        
        totalTimeInterval += strokeTime;
        
        if (TYPE_AND(actionType, NSTimeActionTypeBE)) {
            NSPaintStroke *findTmp = *findStroke;
            if (findTmp && findTmp.strokeId == strokeId) {
                findTmp.startPlay = [[NSPaintPlayInfo alloc] initWithPlayId:INVALID_PLAY_ID playTime:prevTotal];
                findTmp.endPlay = [[NSPaintPlayInfo alloc] initWithPlayId:INVALID_PLAY_ID playTime:totalTimeInterval];
                
                if (actionType == NSTimeActionTypeBE) {
                    break;
                }
            }
        }
        
        NSPaintStroke *nextStroke = [self nextPaintStrokeForStrokeId:stroke.strokeId];
        if (nextStroke) {
            NSTimeInterval freeDiff = [nextStroke startTimeInterval] - [stroke endTimeInterval];
            freeDiff = MIN(freeDiff, self.eventConfig.adjacentStrokesMaxFreeTimeInterval);
            totalTimeInterval += freeDiff;
        }
        
        if (TYPE_AND(actionType, NSTimeActionTypeFind)) {
            if (strokeTimeInterval >= prevTotal && strokeTimeInterval < totalTimeInterval) {
                findObj = stroke;
            }
            else if (strokeTimeInterval == totalTimeInterval) {
                if ([self.strokeIds lastObject] == obj) {
                    findObj = stroke;
                }
            }
            if (!TYPE_AND(actionType, NSTimeActionTypeTotal) && findObj) {
                break;
            }
        }
//        NSLog(@"strokeId=%ld,timeInterval=%f,pt=%f,tt=%f",strokeId,strokeTimeInterval,prevTotal,totalTimeInterval);
    }
    if (findStroke != NULL && TYPE_AND(actionType, NSTimeActionTypeFind)) {
        *findStroke = findObj;
    }
    return totalTimeInterval;
}

-(NSTimeInterval)getEventTimeInterval
{
    return [self _getEventTimeInterval:NSTimeActionTypeTotal strokeTimeInterval:-1 findStroke:NULL];
}

//获取落笔播放时间
-(NSTimeInterval)getStartPlayTimeIntervalForStroke:(NSPaintStroke*)stroke playId:(int64_t)playId
{
    if (stroke == nil) {
        return 0;
    }
    
//    if (!IS_VALID_PLAY_ID(playId) && playId == stroke.startPlay.playId) {
//        return stroke.startPlay.playTime;
//    }
    if (stroke.startPlay) {
        return stroke.startPlay.playTime;
    }
    [self _getEventTimeInterval:NSTimeActionTypeBE strokeTimeInterval:-1 findStroke:&stroke];
    stroke.startPlay.playId = playId;
    return stroke.startPlay.playTime;
}

//获取抬笔播放时间
-(NSTimeInterval)getEndPlayTimeIntervalForStroke:(NSPaintStroke*)stroke playId:(int64_t)playId
{
    if (stroke == nil) {
        return 0;
    }
//    if (!IS_VALID_PLAY_ID(playId) && playId == stroke.endPlay.playId) {
//        return stroke.endPlay.playTime;
//    }
    if (stroke.endPlay) {
        return stroke.endPlay.playTime;
    }
    [self _getEventTimeInterval:NSTimeActionTypeBE strokeTimeInterval:-1 findStroke:&stroke];
    stroke.endPlay.playId = playId;
    return stroke.endPlay.playTime;
}

-(NSTimeInterval)getPointPlayTimeInterForStorke:(NSPaintStroke*)stroke point:(NSPaintPoint*)paintPoint playId:(int64_t)playId
{
    if (stroke == nil || paintPoint == nil) {
        return 0;
    }
//    if (!IS_VALID_PLAY_ID(playId) && playId == paintPoint.startPlay.playId) {
//        return paintPoint.startPlay.playTime;
//    }
    if (paintPoint.startPlay) {
        return paintPoint.startPlay.playTime;
    }
    NSTimeInterval start = [self getStartPlayTimeIntervalForStroke:stroke playId:playId];

    if (!IS_AVAILABLE_NSSET_OBJ([stroke paintPoints])) {
        return start;
    }
    NSPaintPoint *first = [[stroke paintPoints] firstObject];
    NSTimeInterval currentDiff = [NSPaintPoint getTimeIntervalFrom:first to:paintPoint];
    if (currentDiff < 0) {
        return start;
    }
    currentDiff = MIN(currentDiff, self.eventConfig.adjacentStrokesMaxFreeTimeInterval);
    NSTimeInterval playTime = start + currentDiff;
    paintPoint.startPlay = [[NSPaintPlayInfo alloc] initWithPlayId:playId playTime:playTime];
    return playTime;
}

-(BOOL)canSave
{
    return IS_AVAILABLE_NSSET_OBJ(self.strokeIds);
}

+(NSString*)getEventSnapshotImagePath
{
    NSString *path= [YZHUtil applicationStoreInfoDirectory:TYPE_STR(eventImg)];
    return path;
}

+(NSString*)getEventSnapshotImageNameForEventId:(uint64_t)eventId
{
    return NEW_STRING_WITH_FORMAT(@"%@.png",@(eventId));
}

+(NSString*)getEventSnapshotImageFullPathForEventId:(uint64_t)eventId
{
    return [[NSPaintEvent getEventSnapshotImagePath] stringByAppendingPathComponent:[NSPaintEvent getEventSnapshotImageNameForEventId:eventId]];
}

-(NSArray<NSNumber*>*)paintStrokeIdsForPointInRect:(CGRect)rect exceptStrokeIds:(NSArray<NSNumber*>*)exceptStrokeIds
{
    return [NSPaintEvent findPaintStrokeIdsFrom:self.paintStrokeIds eventId:self.eventId forPointInRect:rect exceptStrokeIds:exceptStrokeIds];
}

+(NSArray<NSNumber*>*)findPaintStrokeIdsFrom:(NSArray<NSNumber*>*)paintStrokeIds eventId:(uint64_t)eventId forPointInRect:(CGRect)rect exceptStrokeIds:(NSArray<NSNumber*>*)exceptStrokeIds
{
    NSMutableArray *findObj = [NSMutableArray array];
    [paintStrokeIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger strokeId = [obj unsignedIntegerValue];
        NSPaintStroke *stroke = [NSPaintStroke loadWithEventId:eventId strokeId:strokeId];
        __block BOOL isIn = NO;
        [stroke.paintPoints enumerateObjectsUsingBlock:^(NSPaintPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (CGRectContainsPoint(rect, obj.point)) {
                isIn = YES;
                *stop = YES;
            }
        }];
        if (isIn) {
            [exceptStrokeIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull except, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([except unsignedIntegerValue] == strokeId) {
                    isIn = NO;
                    *stop = YES;
                }
            }];
            if (isIn) {
                [findObj addObject:obj];
                
            }
        }
    }];
    return findObj;
}

@end

/***********************************************************************
 *NSPaintEvent (PlayBack)
 *回放时需要用到，存储上一次绘制的线
 ***********************************************************************/

@implementation NSPaintEvent (PlayBack)

-(void)setLastRenderStroke:(NSPaintStroke *)lastRenderStroke
{
    objc_setAssociatedObject(self, @selector(lastRenderStroke), lastRenderStroke, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSPaintStroke*)lastRenderStroke
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setLastDisplayStrokeTime:(NSTimeInterval)lastDisplayStrokeTime
{
    objc_setAssociatedObject(self, @selector(lastDisplayStrokeTime), @(lastDisplayStrokeTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSTimeInterval)lastDisplayStrokeTime
{
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

-(void)setFastPlayDisplayStrokesPerSecond:(NSInteger)fastPlayDisplayStrokesPerSecond
{
    objc_setAssociatedObject(self, @selector(fastPlayDisplayStrokesPerSecond), @(fastPlayDisplayStrokesPerSecond), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)fastPlayDisplayStrokesPerSecond
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

@end








/**************************************************************
 *NSPaintManager
 *************************************************************/
static NSPaintManager *_sharePaintManager_s = nil;
static dispatch_queue_t _paintDataQueue_s = NULL;

@interface NSPaintManager () <NSCacheDelegate>

//在用户登录的时候可以设置不同的storePathPrefix路径来存储不同的用户数据
@property (nonatomic, strong) NSString *storePathPrefix;
//这个其中的key就是eventId，他的Value不重要，现在value也是key中的只。
@property (nonatomic, strong) NSMutableDictionary<NSNumber*,NSNumber*> *allEventIdDict;
//这个存储的是按笔画来的
@property (nonatomic, strong) NSCache *eventMemoryCache;
//当前正在cache的event
@property (nonatomic, strong) NSPaintEvent *cacheEvent;

@end

@implementation NSPaintManager

+(instancetype)sharePaintManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharePaintManager_s = [[super allocWithZone:NULL] init];
        [_sharePaintManager_s _setUpDefaultValue];
    });
    return _sharePaintManager_s;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [NSPaintManager sharePaintManager];
}

-(id)copyWithZone:(struct _NSZone *)zone
{
    return [NSPaintManager sharePaintManager];
}


-(void)_setUpDefaultValue
{
    //没有用户登录时的数据
    self.storePathPrefix = TYPE_STR(public);
    
    [self _loadSelfData];
    
    [self _loadEventIdList];
}

-(void)_loadSelfData
{
}

-(void)_saveSelfData
{
}

-(NSMutableDictionary<NSNumber*,NSNumber*>*)allEventIdDict
{
    if (_allEventIdDict == nil) {
        _allEventIdDict = [NSMutableDictionary dictionary];
    }
    return _allEventIdDict;
}

-(void)_saveLastCacheEvent
{
    if (self.cacheEvent) {
        uint64_t eventId = self.cacheEvent.eventId;
        [self.allEventIdDict setObject:@(eventId) forKey:@(eventId)];
    }
    [self.cacheEvent save];
    [self _clearMemoryCache];
}

-(NSCache*)eventMemoryCache
{
    if (_eventMemoryCache == nil) {
        _eventMemoryCache = [[NSCache alloc] init];
        _eventMemoryCache.delegate = self;
        _eventMemoryCache.name = @"EventStrokeCache";
    }
    return _eventMemoryCache;
}

-(NSString*)storePathPrefix
{
    if (!IS_AVAILABLE_NSSTRNG(_storePathPrefix)) {
        _storePathPrefix = TYPE_STR(public);
    }
    return _storePathPrefix;
}

-(NSString*)_eventListSaveKay
{
    return NEW_STRING_WITH_FORMAT(@"PMData/%@_data",self.storePathPrefix);
}

-(void)_loadEventIdList
{
    self.allEventIdDict = (NSMutableDictionary*)[YZHUtil loadObjectFrom:[self _eventListSaveKay]];
}

-(void)_saveEventIdList
{
    [YZHUtil saveObject:self.allEventIdDict to:[self _eventListSaveKay]];
}

-(void)save
{
    [self _saveLastCacheEvent];
    
    [self _saveEventIdList];
        
    [self _saveSelfData];
}

-(void)loadEventIdDataFromPathPrefix:(NSString*)pathPrefix
{
    [self save];
    
    self.storePathPrefix = pathPrefix;
    
    [self _loadEventIdList];
    
    //清除缓存的东西，切换当前cache的event
    [self _clearMemoryCache];
    
    self.cacheEvent = nil;
}

-(NSPaintEvent*)currentCacheEvent
{
    return self.cacheEvent;
}

-(NSPaintEvent*)cacheForNewEvent
{
    NSPaintEvent *event = [[NSPaintEvent alloc] init];
    [self _saveLastCacheEvent];
    self.cacheEvent = event;
    return event;
}

-(NSPaintEvent*)cacheForEventId:(uint64_t)eventId
{
    if (self.cacheEvent.eventId == eventId) {
        return self.cacheEvent;
    }
    
    //将原来的进行存储
    [self _saveLastCacheEvent];
    
    //加载所有此eventId所有的stroke到cache里面
    NSPaintEvent *event = [NSPaintEvent loadWithEventId:eventId];
    [event.strokeIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSPaintStroke *stroke = [NSPaintStroke loadWithEventId:eventId strokeId:[obj unsignedIntegerValue]];
        if (stroke) {
            [self.eventMemoryCache setObject:stroke forKey:@(stroke.strokeId)];
        }
    }];
    self.cacheEvent = event;
    return event;
}

-(void)_clearMemoryCache
{
    self.eventMemoryCache.delegate = nil;
    [self.eventMemoryCache removeAllObjects];
    self.eventMemoryCache.delegate = self;
}

-(void)removeCurrentCacheEvent
{
    [self save];
    [self _clearMemoryCache];
    self.cacheEvent = nil;
}

-(NSUInteger)addPaintStrokeInCurrentCacheEvent:(NSPaintStroke*)paintStroke
{
    if (!paintStroke) {
        return 0;
    }
    if (self.cacheEvent.eventId != paintStroke.eventId) {
        return 0;
    }
    NSUInteger strokeId = [self.cacheEvent addPaintStroke:paintStroke];
    if (strokeId > 0) {
        [self.eventMemoryCache setObject:paintStroke forKey:@(paintStroke.strokeId)];
    }
    return strokeId;
}

-(NSUInteger)deletePaintStrokeInCurrentCacheEvent:(NSPaintStroke*)paintStroke
{
    if (!paintStroke) {
        return 0;
    }
    if (self.cacheEvent.eventId != paintStroke.eventId) {
        return 0;
    }
    NSUInteger strokeId = [self.cacheEvent deletePaintStroke:paintStroke];
    if (strokeId > 0) {
        [self.eventMemoryCache removeObjectForKey:@(paintStroke.strokeId)];
    }
    return strokeId;
}

-(NSPaintStroke*)paintStrokeInCurrentCacheEventForStrokeId:(NSUInteger)strokeId
{
    if (strokeId == 0) {
        return nil;
    }
    NSPaintStroke *stroke = [self.eventMemoryCache objectForKey:@(strokeId)];
    if (stroke == nil) {
        stroke = [self.cacheEvent paintStrokeForStrokeId:strokeId];
        if (stroke) {
            [self.eventMemoryCache setObject:stroke forKey:@(stroke.strokeId)];
        }
    }
    return stroke;
}

//从当前的strokeId获取下一个paintStroke
-(NSPaintStroke*)nextPaintStrokeInCurrentCacheEventForStrokeId:(NSUInteger)strokeId
{
    NSUInteger nextStrokeId = [self.cacheEvent _getStrokeIdForCurrentStrokeId:strokeId isNext:YES];
    return [self paintStrokeInCurrentCacheEventForStrokeId:nextStrokeId];
}

//从当前的strokeId获取上一个paintStroke
-(NSPaintStroke*)prevPaintStrokeInCurrentCacheEventForStrokeId:(NSUInteger)strokeId
{
    NSUInteger prevStrokeId = [self.cacheEvent _getStrokeIdForCurrentStrokeId:strokeId isNext:NO];
    return [self paintStrokeInCurrentCacheEventForStrokeId:prevStrokeId];
}

//从当前cache的event中获取strokeId的NSPaintStroke的对象，仅仅只是从cache中获取，有可能为空
-(NSPaintStroke*)paintStrokeOnlyInCurrentCacheEventForStrokeId:(NSUInteger)strokeId
{
    if (strokeId == 0) {
        return nil;
    }
    return [self.eventMemoryCache objectForKey:@(strokeId)];
}

-(NSPaintStroke*)firstStrokeInCurrentCacheEvent
{
    NSUInteger firstStrokeId = [self.cacheEvent _firstOrLastStrokeId:YES];
    return [self paintStrokeInCurrentCacheEventForStrokeId:firstStrokeId];
}


-(NSPaintStroke*)lastStrokeInCurrentCacheEvent
{
    NSUInteger lastStrokeId = [self.cacheEvent _firstOrLastStrokeId:YES];
    return [self paintStrokeInCurrentCacheEventForStrokeId:lastStrokeId];
}

//是否是第一笔
-(BOOL)isFirstPaintStrokeInCurrentCacheEvent:(NSPaintStroke*)stroke
{
    return [self.cacheEvent isFirstPaintStroke:stroke];

}

//是否是最后一笔
-(BOOL)isLastPaintStrokeInCurrentCacheEvent:(NSPaintStroke*)stroke
{
    return [self.cacheEvent isLastPaintStroke:stroke];
}

-(NSPaintStroke*)getStrokeForTimeInterval:(NSTimeInterval)timeInterval paintPointIndex:(NSUInteger*)paintPointIndex
{
    if (!IS_AVAILABLE_NSSET_OBJ(self.cacheEvent.strokeIds)) {
        return nil;
    }
    NSPaintStroke *stroke = nil;
    [self.cacheEvent _getEventTimeInterval:NSTimeActionTypeFind strokeTimeInterval:timeInterval findStroke:&stroke];
    
    if (paintPointIndex != NULL) {
        NSTimeInterval start = [self.cacheEvent getStartPlayTimeIntervalForStroke:stroke playId:-1];
        timeInterval = timeInterval - start;
        NSInteger idex = [stroke getPointIndexForTimeInterval:timeInterval fromIndex:0 toIndex:stroke.strokePoints.count-1];
        if (paintPointIndex) {
            *paintPointIndex = idex;
        }
    }
    
    return stroke;
}

//移除掉当前的cacheEvent
-(void)deleteCurrentCacheEvent
{
    [self deleteEventForEventId:self.cacheEvent.eventId];
}

//根据eventId移除Event
-(void)deleteEventForEventId:(uint64_t)eventId
{
    if (eventId == self.cacheEvent.eventId) {
        [self _clearMemoryCache];
        self.cacheEvent = nil;
    }
    [NSPaintEvent deleteWithEventId:eventId];
    [self.allEventIdDict removeObjectForKey:@(eventId)];
    [self save];
}

-(NSArray<NSNumber*>*)getAllEventId
{
    return [self.allEventIdDict allKeys];
}


-(NSArray<NSNumber*>*)paintStrokeIdsForPointInRectInCurrentCacheEvent:(CGRect)rect exceptStrokeIds:(NSArray<NSNumber*>*)exceptStrokeIds
{
    return [self findPaintStrokeIdsInCurrentCacheEventFrom:self.cacheEvent.paintStrokeIds forPointInRect:rect exceptStrokeIds:exceptStrokeIds];
}

-(NSArray<NSNumber*>*)findPaintStrokeIdsInCurrentCacheEventFrom:(NSArray<NSNumber*>*)paintStrokeIds forPointInRect:(CGRect)rect exceptStrokeIds:(NSArray<NSNumber*>*)exceptStrokeIds
{
    NSMutableArray *findObj = [NSMutableArray array];
    [paintStrokeIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger strokeId = [obj unsignedIntegerValue];
        NSPaintStroke *stroke = [self paintStrokeInCurrentCacheEventForStrokeId:strokeId];
        __block BOOL isIn = NO;
        [stroke.paintPoints enumerateObjectsUsingBlock:^(NSPaintPoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (CGRectContainsPoint(rect, obj.point)) {
                isIn = YES;
                *stop = YES;
            }
        }];
        if (isIn) {
            [exceptStrokeIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull except, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([except unsignedIntegerValue] == strokeId) {
                    isIn = NO;
                    *stop = YES;
                }
            }];
            
            if (isIn) {
                [findObj addObject:obj];
                
            }
        }
    }];
    return findObj;
}

+(dispatch_queue_t)_dataExecuteQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _paintDataQueue_s = dispatch_queue_create("paintDataQueue", DISPATCH_QUEUE_SERIAL);
    });
    return _paintDataQueue_s;
}

-(void)_addDataExecute:(NSPaintDataExecuteBlock)executeBlock inQueue:(dispatch_queue_t)queue completionBlock:(NSPaintDataExecuteCompletionBlock)completionBlock
{
    dispatch_async(queue, ^{
        id retObj = nil;
        if (executeBlock) {
            retObj = executeBlock();
        }
        if (completionBlock) {
            dispatch_async_in_main_queue(^{
                completionBlock(retObj);
            });
        }
    });
}

-(void)addDataExecuteBlock:(NSPaintDataExecuteBlock)executeBlock completionBlock:(NSPaintDataExecuteCompletionBlock)completionBlock;
{
    [self _addDataExecute:executeBlock inQueue:[[self class] _dataExecuteQueue] completionBlock:completionBlock];
}

#pragma mark NSCacheDelegate
-(void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    NSPaintStroke *stroke = obj;
    
    [stroke save];
}
@end

