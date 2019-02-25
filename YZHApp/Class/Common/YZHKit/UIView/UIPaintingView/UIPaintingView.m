//
//  UIPaintingView.m
//  UIPaintingViewDemo
//
//  Created by yuan on 2018/1/31.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "UIPaintingView.h"
#import <objc/runtime.h>
#import "YZHKitType.h"

#define USE_TIMER                        (0)
#if USE_TIMER
#import "NSWeakProxy.h"
#endif


@interface UIPaintingView ()
//freq should be 1 - 60;
@property (nonatomic, assign) CGFloat displayFreq;
@property (nonatomic, assign) BOOL isPlaying;

/** name */
@property (nonatomic, assign) BOOL playTouchPaintEnabled;

#if USE_TIMER
/** timer */
@property (nonatomic, strong) NSTimer *playTimer;
#endif

@end

/***********************************************************************
 *UIPaintingView
 ***********************************************************************/
@implementation UIPaintingView

@dynamic delegate;

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setUpDefaultValue];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setUpDefaultValue];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setUpDefaultValue];
    }
    return self;
}

-(void)_setUpDefaultValue
{
    self.touchPaintEnabled = NO;
    
    //1-60
    self.displayFreq = 20;
    self.playRatio = 1.0;
}

-(CGFloat)_getFreqTimeInterval
{
    return 1.0/self.displayFreq;
}

-(void)renderWithPoint:(NSPaintPoint*)paintPoint
{
    [self renderWithPoint:paintPoint addToEvent:YES];
}

-(void)renderWithPoint:(NSPaintPoint*)paintPoint addToEvent:(BOOL)addToEvent
{
    BOOL touchEnable = self.touchPaintEnabled;
    self.touchPaintEnabled = NO;
    [self _renderWithPoint:paintPoint present:YES addNewStroke:addToEvent lineColor:nil];
    self.touchPaintEnabled = touchEnable;
}

-(void)renderWithStroke:(NSPaintStroke*)stroke addToEvent:(BOOL)addToEvent
{
    BOOL touchEnable = self.touchPaintEnabled;
    self.touchPaintEnabled = NO;
    
    [self _renderStroke:stroke addToEvent:addToEvent];
    
    self.touchPaintEnabled = touchEnable;
}

-(void)_renderStroke:(NSPaintStroke*)stroke addToEvent:(BOOL)addToEvent
{
    self.paintEvent.lastRenderStroke = stroke;
    NSArray<NSPaintPoint*> *strokePoints  = [stroke paintPoints];
    for (NSPaintPoint *point in strokePoints) {
        [self _renderWithPoint:point present:NO addNewStroke:addToEvent lineColor:stroke.strokeColor];
    }
    self.paintEvent.lastRenderStroke.strokeId = stroke.strokeId;
}

-(BOOL)_shouldDisplayPoint:(NSPaintPoint*)point forPaintStroke:(NSPaintStroke*)stroke
{
    if (point.status != NSPaintStatusMove) {
        return YES;
    }
    NSTimeInterval timerInterval = [NSPaintPoint getTimeIntervalFrom:stroke.lastDisplayPoint to:point];
    if (timerInterval >= [self _getFreqTimeInterval]) {
        return YES;
    }
    return NO;
}

-(void)_checkLastRenderPaintStrokeWithPaintPoint:(NSPaintPoint*)paintPoint force:(BOOL)force strokeColor:(UIColor*)strokeColor
{
    if (!strokeColor) {
        strokeColor = self.brushColor;
    }
    if (self.paintEvent.lastRenderStroke == nil || force) {
        NSPaintStroke *newStroke = [[NSPaintStroke alloc] initWithEventId:self.paintEvent.eventId strokeColor:strokeColor];
        [newStroke addPaintPoint:paintPoint];
        self.paintEvent.lastRenderStroke = newStroke;
    }
}

-(void)_renderWithPoint:(NSPaintPoint*)paintPoint present:(BOOL)present addNewStroke:(BOOL)addNew lineColor:(UIColor*)lineColor
{
    CGFloat lineWidth = [paintPoint getLineWidth:self.maxLineWidth];
    if (paintPoint.status == NSPaintStatusBegan) {
        [self _checkLastRenderPaintStrokeWithPaintPoint:paintPoint force:YES strokeColor:lineColor];

        GLLinePoint *from = [[GLLinePoint alloc] initWithPoint:paintPoint.point lineWidth:lineWidth];
        [self renderLineFromPoint:from toPoint:from lineColor:lineColor present:present];
    }
    else if (paintPoint.status == NSPaintStatusMove) {
        [self _checkLastRenderPaintStrokeWithPaintPoint:paintPoint force:NO strokeColor:lineColor];

        NSPaintPoint *lastPoint = self.paintEvent.lastRenderStroke.lastPaintPoint;
        CGFloat lastLineWidth = [lastPoint getLineWidth:self.maxLineWidth];
        GLLinePoint *from = [[GLLinePoint alloc] initWithPoint:lastPoint.point lineWidth:lastLineWidth];
        
        GLLinePoint *to = [[GLLinePoint alloc] initWithPoint:paintPoint.point lineWidth:lineWidth];
        
        if (present) {
            if (![self _shouldDisplayPoint:paintPoint forPaintStroke:self.paintEvent.lastRenderStroke]) {
                present = NO;
            }
        }
        
        [self renderLineFromPoint:from toPoint:to lineColor:lineColor present:present];
        
        [self.paintEvent.lastRenderStroke addPaintPoint:paintPoint];
    }
    else {
        [self _checkLastRenderPaintStrokeWithPaintPoint:paintPoint force:NO strokeColor:lineColor];
        
        NSPaintPoint *lastPoint = self.paintEvent.lastRenderStroke.lastPaintPoint;
        CGFloat lastLineWidth = [lastPoint getLineWidth:self.maxLineWidth];
        GLLinePoint *from = [[GLLinePoint alloc] initWithPoint:lastPoint.point lineWidth:lastLineWidth];
        
        GLLinePoint *to = [[GLLinePoint alloc] initWithPoint:paintPoint.point lineWidth:lineWidth];
        
        [self renderLineFromPoint:from toPoint:to lineColor:lineColor present:present];
        
        [self.paintEvent.lastRenderStroke addPaintPoint:paintPoint];
        if (addNew) {
            [[NSPaintManager sharePaintManager] addPaintStrokeInCurrentCacheEvent:self.paintEvent.lastRenderStroke];
        }
    }
    self.paintEvent.lastRenderStroke.lastPaintPoint = paintPoint;
    if (present) {
        self.paintEvent.lastRenderStroke.lastDisplayPoint = paintPoint;
    }
}

-(CGFloat)_getPlayDiffTimeInterval:(NSTimeInterval)timeInterval
{
    if (self.playRatio > 0) {
        timeInterval = timeInterval/self.playRatio;
    }
    if (timeInterval < 1.0/ 100) {
        timeInterval = 0;
    }
    return timeInterval;
}

-(void)_playBackRenderStroke:(NSPaintStroke*)stroke
{
    if (!self.isPlaying) {
        return ;
    }
    NSArray<NSPaintPoint*> *paintPoints = [stroke paintPoints];
    if (stroke == nil || !IS_AVAILABLE_NSSET_OBJ(paintPoints)) {
        return;
    }
    NSInteger index = 0;
    if (stroke.lastPaintPoint) {
        index = [paintPoints indexOfObject:stroke.lastPaintPoint] + 1;
    }
    if (index >= paintPoints.count) {
        return;
    }
    
    NSPaintPoint *paintPoint = paintPoints[index];
    //在开始播放的时候把touchPaintEnabled 设置为NO
    if ([self.paintEvent isFirstPaintStroke:stroke] && index == 0) {
        self.playTouchPaintEnabled = self.touchPaintEnabled;
        self.touchPaintEnabled = NO;
    }
    
    [self _renderWithPoint:paintPoint present:YES addNewStroke:NO lineColor:stroke.strokeColor];
    stroke.lastPaintPoint = paintPoint;
    self.paintEvent.lastRenderStroke.strokeId = stroke.strokeId;

    if (paintPoint.status == NSPaintStatusBegan) {
        if ([self.delegate respondsToSelector:@selector(paintingView:startPlayPaintStroke:)]) {
            [self.delegate paintingView:self startPlayPaintStroke:stroke];
        }
    }
    else if (paintPoint.status == NSPaintStatusMove) {
        if (self.paintEvent.lastRenderStroke.lastDisplayPoint == paintPoint) {
            if ([self.delegate respondsToSelector:@selector(paintingView:playingPintStroke:paintPoint:)]) {
                [self.delegate paintingView:self playingPintStroke:self.paintEvent.lastRenderStroke paintPoint:paintPoint];
            }
        }
    }
    else if (paintPoint.status == NSPaintStatusEnd) {
        //在开始播放的时候把touchPaintEnabled还原
        if ([self.paintEvent isLastPaintStroke:stroke]) {
            self.touchPaintEnabled = self.playTouchPaintEnabled;
        }
        
        if ([self.delegate respondsToSelector:@selector(paintingView:endPlayPaintStroke:)]) {
            [self.delegate paintingView:self endPlayPaintStroke:stroke];
        }
    }
    NSInteger nextIdx = index + 1;
    if (nextIdx < paintPoints.count) {
        NSPaintPoint *nextPoint = paintPoints[nextIdx];
        NSTimeInterval diff = [NSPaintPoint getTimeIntervalFrom:paintPoint to:nextPoint];
        diff = MIN(diff, self.paintEvent.eventConfig.adjacentPointsMaxTimeInterval);
        diff = [self _getPlayDiffTimeInterval:diff];
#if USE_TIMER
        [self _startPlayerTimer:diff selector:@selector(_playBackRenderStroke:) object:stroke];
#else
        [self performSelector:@selector(_playBackRenderStroke:) withObject:stroke afterDelay:diff];
#endif
    }
    else {
        NSPaintStroke *nextStroke = [[NSPaintManager sharePaintManager] nextPaintStrokeInCurrentCacheEventForStrokeId:stroke.strokeId];
        if (nextStroke == nil) {
            self.isPlaying = NO;
            return;
        }
        NSTimeInterval diff = [nextStroke startTimeInterval] - [stroke endTimeInterval];
        diff = MIN(diff, self.paintEvent.eventConfig.adjacentStrokesMaxFreeTimeInterval);
        diff = [self _getPlayDiffTimeInterval:diff];
#if USE_TIMER
        [self _startPlayerTimer:diff selector:@selector(_playBackWithPaintEvent:) object:self.paintEvent];
#else
        [self performSelector:@selector(_playBackWithPaintEvent:) withObject:self.paintEvent afterDelay:diff];
#endif
    }
}

-(void)_playBackWithPaintEvent:(NSPaintEvent*)paintEvent
{
    if (!self.isPlaying) {
        return;
    }
    if (paintEvent == nil || !IS_AVAILABLE_NSSET_OBJ([paintEvent paintStrokeIds])) {
        return;
    }
    
    NSPaintStroke *paintStroke = nil;
    if (paintEvent.lastRenderStroke) {
        paintStroke = [[NSPaintManager sharePaintManager] nextPaintStrokeInCurrentCacheEventForStrokeId:paintEvent.lastRenderStroke.strokeId];
    }
    else {
        paintStroke = [[NSPaintManager sharePaintManager] firstStrokeInCurrentCacheEvent];
    }
    if (paintStroke == nil) {
        self.isPlaying = NO;
        return;
    }
    paintStroke.lastPaintPoint = nil;
    [self _playBackRenderStroke:paintStroke];
}

-(void)_beginPlayBackWithPaintEvent:(NSPaintEvent*)paintEvent
{
    self.isPlaying = YES;
    [self _playBackWithPaintEvent:paintEvent];
}

-(void)_cancelPrevPlay
{
    self.isPlaying = NO;
#if USE_TIMER
    [self _invalidatePlayerTimer];
#else
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
#endif
}


-(void)playBack:(BOOL)fromStart
{
    [self _cancelPrevPlay];
    
    if (fromStart) {
        [self erase];
    }
    else {
        //将最后绘制的那一笔再绘制一次
        if (self.paintEvent.lastRenderStroke) {
            NSPaintStroke *prev = [[NSPaintManager sharePaintManager] prevPaintStrokeInCurrentCacheEventForStrokeId:self.paintEvent.lastRenderStroke.strokeId];
            if (prev) {
                self.paintEvent.lastRenderStroke = prev;
            }
        }
    }
    [self _beginPlayBackWithPaintEvent:self.paintEvent];
}

-(void)stopPlay
{
    [self _cancelPrevPlay];
    self.touchPaintEnabled = self.playTouchPaintEnabled;
}

-(NSUInteger)_undoLastStroke
{
    if (self.isPlaying) {
        return 0;
    }
    
    NSUInteger strokeId = 0;
    NSPaintStroke *last = self.paintEvent.lastRenderStroke;
    NSPaintStroke *prevStroke = nil;
    if (last == nil) {
        return 0;
    }
    else {
        strokeId = last.strokeId;
    }
    prevStroke = [[NSPaintManager sharePaintManager] prevPaintStrokeInCurrentCacheEventForStrokeId:strokeId];
    
#if 1
    [self clearFrameBuffer];
    NSUInteger prevStrokeId = prevStroke.strokeId;
    __block BOOL haveRend = NO;
    [[self.paintEvent paintStrokeIds] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger strokeId = [obj unsignedIntegerValue];
        if (strokeId <= prevStrokeId) {
            NSPaintStroke *stroke = [[NSPaintManager sharePaintManager] paintStrokeInCurrentCacheEventForStrokeId:[obj unsignedIntegerValue]];
            [self renderWithStroke:stroke addToEvent:NO];
            haveRend = YES;
        }
        else {
            *stop = YES;
        }
    }];
    [self presentRenderbuffer];
    if (!haveRend) {
        self.paintEvent.lastRenderStroke.lastPaintPoint = nil;
        self.paintEvent.lastRenderStroke = nil;
    }
#else
    [self _renderWithStroke:last lineColor:WHITE_COLOR];
    [self presentRenderbuffer];
    self.paintEvent.lastRenderStroke = prevStroke;
#endif
    return strokeId;
}

-(void)undo
{
    BOOL touchEnable = self.touchPaintEnabled;
    self.touchPaintEnabled = NO;
    [self _undoLastStroke];
    self.touchPaintEnabled = touchEnable;
}

-(NSUInteger)_undoFasterAction
{
    if (self.isPlaying) {
        return 0;
    }
    
    NSPaintStroke *last = self.paintEvent.lastRenderStroke;
    if (last == nil) {
        return 0;
    }
    NSPaintStroke *prev = [[NSPaintManager sharePaintManager] prevPaintStrokeInCurrentCacheEventForStrokeId:last.strokeId];
    
    CGFloat maxLineWidth = MAX(self.maxLineWidth, self.brushWidth);
    CGRect rect = [last getPaintStrokeRectWithLineWidth:maxLineWidth];
    NSArray *intersectsStrokeIds = [[NSPaintManager sharePaintManager] paintStrokeIdsForPointInRectInCurrentCacheEvent:rect exceptStrokeIds:@[@(last.strokeId)]];
    
    NSMutableArray *newStrokeIds = [NSMutableArray array];
    [intersectsStrokeIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj unsignedIntegerValue] < last.strokeId) {
            [newStrokeIds addObject:obj];
        }
    }];
    
    if (!IS_AVAILABLE_NSSET_OBJ(newStrokeIds)) {
        [self eraseInFrame:rect];
    }
    else {
        [self eraseInFrame:rect];
        [newStrokeIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSPaintStroke *stroke = [[NSPaintManager sharePaintManager] paintStrokeInCurrentCacheEventForStrokeId:[obj unsignedIntegerValue]];
            [self renderWithStroke:stroke addToEvent:NO];
        }];
        [self presentRenderbuffer];
    }
    self.paintEvent.lastRenderStroke = prev;
    return last.strokeId;
}

-(void)undoFaster
{
    BOOL touchEnable = self.touchPaintEnabled;
    self.touchPaintEnabled = NO;
    
    [self _undoFasterAction];
    
    self.touchPaintEnabled = touchEnable;
}

-(void)redo
{
    if (self.isPlaying) {
        return;
    }
    
    BOOL touchEnable = self.touchPaintEnabled;
    self.touchPaintEnabled = NO;
    
    NSPaintStroke *last = self.paintEvent.lastRenderStroke;
    if ([[NSPaintManager sharePaintManager] isLastPaintStrokeInCurrentCacheEvent:last]) {
        return;
    }
    NSUInteger nextStrokeId = 1;
    if (last) {
        NSPaintStroke *nextStroke = [[NSPaintManager sharePaintManager] nextPaintStrokeInCurrentCacheEventForStrokeId:last.strokeId];
        nextStrokeId = nextStroke.strokeId;
    }
    NSUInteger lastStrokeId = last.strokeId;
    
    [[self.paintEvent paintStrokeIds] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger strokeId = [obj unsignedIntegerValue];
        if (strokeId <= lastStrokeId) {
            return ;
        }
        if (strokeId <= nextStrokeId) {
            NSPaintStroke *stroke = [[NSPaintManager sharePaintManager] paintStrokeInCurrentCacheEventForStrokeId:[obj unsignedIntegerValue]];
            [self renderWithStroke:stroke addToEvent:NO];
        }
        else {
            *stop = YES;
        }
    }];
    [self presentRenderbuffer];
    self.touchPaintEnabled = touchEnable;
}

-(void)erase
{
    BOOL touchEnable = self.touchPaintEnabled;
    self.touchPaintEnabled = NO;
    
    [super erase];
    self.paintEvent.lastRenderStroke.lastPaintPoint = nil;
    self.paintEvent.lastRenderStroke.lastDisplayPoint = nil;
    self.paintEvent.lastRenderStroke = nil;
    
    self.touchPaintEnabled = touchEnable;
}

-(void)deletePaint
{
    if (self.isPlaying) {
        [self stopPlay];
    }
    [[NSPaintManager sharePaintManager] deleteEventForEventId:self.paintEvent.eventId];
    [self erase];
}

-(void)deleteLastStroke
{
    if (self.isPlaying) {
        [self stopPlay];
    }
    if (!IS_AVAILABLE_NSSET_OBJ([self.paintEvent paintStrokeIds])) {
        return;
    }
#if 1
    NSUInteger lastStrokeId = [self _undoLastStroke];
    NSPaintStroke *stroke = [[NSPaintManager sharePaintManager] paintStrokeInCurrentCacheEventForStrokeId:lastStrokeId];
    [[NSPaintManager sharePaintManager] deletePaintStrokeInCurrentCacheEvent:stroke];
#else
    NSNumber *lastStrokeId = [self.paintEvent.strokeIds lastObject];
    NSInteger lastStrokeIdI = [lastStrokeId integerValue];
    [self clearFrameBuffer];

    [self.paintEvent.strokeIds enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSUInteger strokeId = [obj unsignedIntegerValue];
        if (strokeId < lastStrokeIdI) {
            NSPaintStroke *stroke = [[NSPaintManager sharePaintManager] paintStrokeForStrokeId:[obj unsignedIntegerValue]];
            [self renderWithStroke:stroke];
        }
        else {
            *stop = YES;
        }
    }];
    [self presentRenderbuffer];
    
     NSPaintStroke *stroke = [[NSPaintManager sharePaintManager] paintStrokeForStrokeId:lastStrokeIdI];
    [[NSPaintManager sharePaintManager] deletePaintStroke:stroke];
#endif
}

#if USE_TIMER
-(void)_startPlayerTimer:(NSTimeInterval)timeInterval selector:(SEL)aSelector object:(id)object
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (object) {
        [userInfo setObject:object forKey:TYPE_STR(object)];
    }
    if (aSelector) {
        [userInfo setObject:[NSValue valueWithPointer:aSelector] forKey:TYPE_STR(aSelector)];
    }
    self.playTimer = [NSTimer timerWithTimeInterval:timeInterval target:[NSWeakProxy proxyWithTarget:self] selector:@selector(_timerAction:) userInfo:userInfo repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.playTimer forMode:NSRunLoopCommonModes];
}

-(void)_timerAction:(NSTimer*)timer
{
    NSDictionary *userInfo = timer.userInfo;
    id object = [userInfo objectForKey:TYPE_STR(object)];
    SEL aSelector = [[userInfo objectForKey:TYPE_STR(aSelector)] pointerValue];
    [self performSelector:aSelector withObject:object];
}

-(void)_invalidatePlayerTimer
{
    [self.playTimer invalidate];
    self.playTimer = nil;
}
#endif

-(void)_fastPlayBackStroke:(NSPaintStroke*)stroke
{
    NSInteger displayStrokeFreq = self.paintEvent.fastPlayDisplayStrokesPerSecond;
    if (stroke == nil) {
        self.isPlaying = NO;
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(paintingView:startPlayPaintStroke:)]) {
        [self.delegate paintingView:self startPlayPaintStroke:stroke];
    }
    NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
    
    [self renderWithStroke:stroke addToEvent:NO];

    CGFloat freq = [self _getFreqTimeInterval];
    if (start - self.paintEvent.lastDisplayStrokeTime > freq || [self.paintEvent isLastPaintStroke:stroke]) {
        
//        NSLog(@"preset.strokeId=%ld",stroke.strokeId);
        
        [self presentRenderbuffer];
        self.paintEvent.lastDisplayStrokeTime = start;
    }
    
    NSPaintStroke *nextStroke = [self.paintEvent nextPaintStrokeForStrokeId:stroke.strokeId];
    if (nextStroke) {
        NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval elapsed = end - start;
        
        NSTimeInterval diff = 1.0/displayStrokeFreq - elapsed;
        //增加一个保护措施
        diff = MAX(diff, 1.0/10000);
//        diff = MAX(diff, 0);

        [self performSelector:@selector(_fastPlayBackStroke:) withObject:nextStroke afterDelay:diff];
    }
    else {
        self.isPlaying = NO;
    }
    if ([self.delegate respondsToSelector:@selector(paintingView:endPlayPaintStroke:)]) {
        [self.delegate paintingView:self endPlayPaintStroke:stroke];
    }
}

-(void)fastPlayBack:(NSInteger)displayStrokesPerSecond
{
    [self _cancelPrevPlay];
    [self erase];
    self.isPlaying = YES;
    self.paintEvent.fastPlayDisplayStrokesPerSecond = displayStrokesPerSecond;
    NSPaintStroke *first = [self.paintEvent firstPaintStroke];
    [self _fastPlayBackStroke:first];
}

@end




/***********************************************************************
 *UIPaintingView (PlayBack)
 ***********************************************************************/
@implementation UIPaintingView (PlayBack)


-(void)setPlayId:(int64_t)playId
{
    objc_setAssociatedObject(self, @selector(playId), @(playId), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(int64_t)playId
{
    return [objc_getAssociatedObject(self, _cmd) longLongValue];
}

@end
