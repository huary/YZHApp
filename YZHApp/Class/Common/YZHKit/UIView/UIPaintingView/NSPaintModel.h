//
//  NSPaintModel.h
//  UIPaintingViewDemo
//
//  Created by yuan on 2018/2/1.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IS_VALID_PLAY_ID(PLAY_ID)         (PLAY_ID > 0)

typedef NS_ENUM(NSInteger, NSPaintStatus)
{
    NSPaintStatusBegan,
    NSPaintStatusMove,
    NSPaintStatusEnd,
};

//存储文件操作
typedef id(^NSPaintDataExecuteBlock)(void);
typedef void(^NSPaintDataExecuteCompletionBlock)(id result);


/***********************************************************************
 *NSPaintPlayInfo
 ***********************************************************************/
@interface NSPaintPlayInfo : NSObject <NSCoding>

/* <#name#> */
@property (nonatomic, assign) int64_t playId;

//开始播放时间，格林威治绝对时间,单位为秒
@property (nonatomic, assign) NSTimeInterval playTime;

-(instancetype)initWithPlayId:(int64_t)playId playTime:(NSTimeInterval)playTime;
@end






/***********************************************************************
 *GLLinePoint
 ***********************************************************************/
@interface GLLinePoint : NSObject

@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGFloat lineWidth;

-(instancetype)initWithPoint:(CGPoint)point lineWidth:(CGFloat)lineWidth;
@end





/***********************************************************************
 *NSPaintPoint
 ***********************************************************************/
@interface NSPaintPoint : NSObject <NSCoding>

//坐标点
@property (nonatomic, assign) CGPoint point;
//根据这个触摸压力反应线的粗细,0-100
@property (nonatomic, assign) CGFloat pressure;
//写得状态
@property (nonatomic, assign) NSPaintStatus status;
//时间，格林威治绝对时间,单位为秒
@property (nonatomic, assign) NSTimeInterval timeInterval;
//lineWidth,如果指定了lineWidth，优先考虑lineWidth
@property (nonatomic, assign) CGFloat lineWidth;

-(instancetype)initWithPoint:(CGPoint)point status:(NSPaintStatus)stauts lineWidth:(CGFloat)lineWidth;

-(instancetype)initWithPoint:(CGPoint)point pressure:(CGFloat)pressure status:(NSPaintStatus)stauts timeInterval:(NSTimeInterval)timeInterval;

-(CGFloat)getLineWidth:(CGFloat)maxLineWidth;

//to.timeInterval - from.timeInterval;
+(NSTimeInterval)getTimeIntervalFrom:(NSPaintPoint*)from to:(NSPaintPoint*)to;

@end

/***********************************************************************
 *NSPaintPoint(PlayBack)
 ***********************************************************************/
@interface NSPaintPoint (PlayBack)
//开始播放的时间
@property (nonatomic, strong) NSPaintPlayInfo *startPlay;

@end





/***********************************************************************
 *NSPaintStroke
 *绘画的笔画，单次存入的最小单元
 ***********************************************************************/
@interface NSPaintStroke : NSObject <NSCoding>
/*strokeId从1开始计数,初始化的默认值为0，为0的时候加入到event的时候就是就是自动为strokeId分配一个值
 （按已经已经加入的最后一个strokeId+1来进行计算）
 */
@property (nonatomic, assign) NSUInteger strokeId;
//笔的颜色
@property (nonatomic, strong) UIColor *strokeColor;

-(instancetype)initWithEventId:(uint64_t)eventId;
-(instancetype)initWithEventId:(uint64_t)eventId strokeColor:(UIColor *)strokeColor;

-(NSArray<NSPaintPoint*>*)paintPoints;
-(void)addPaintPoint:(NSPaintPoint*)paintPoint;

+(NSPaintStroke*)loadWithEventId:(uint64_t)eventId strokeId:(NSUInteger)strokeId;

//返回的时间为秒
-(NSTimeInterval)startTimeInterval;
-(NSTimeInterval)endTimeInterval;
//就是endTimeInterval-startTimeInterval
-(NSTimeInterval)paintTimeInterval;

-(CGRect)getPaintStrokeRectWithLineWidth:(CGFloat)lineWidth;
-(CGRect)getPaintStrokeRectFromPointIndex:(NSInteger)fromIndex toPointIndex:(NSInteger)toIndex withLineWidth:(CGFloat)lineWidth;


@end

/***********************************************************************
 *NSPaintStroke (PlayBack)
 *回放时需要用到，存储上一次绘制的点
 ***********************************************************************/
@interface NSPaintStroke (PlayBack)

//上次绘制的
@property (nonatomic, strong) NSPaintPoint *lastPaintPoint;
//上次显示的
@property (nonatomic, strong) NSPaintPoint *lastDisplayPoint;

//开始播放时间
@property (nonatomic, strong) NSPaintPlayInfo *startPlay;
//结束播放时间
@property (nonatomic, strong) NSPaintPlayInfo *endPlay;

@end






/***********************************************************************
 *NSPaintEventConfig
 *整个一次画画的配置
 ***********************************************************************/
@interface NSPaintEventConfig : NSObject <NSCoding>

@property (nonatomic, assign) NSTimeInterval adjacentPointsMaxTimeInterval;
@property (nonatomic, assign) NSTimeInterval adjacentStrokesMaxFreeTimeInterval;

-(instancetype)initWithAdjacentPointsMaxTimeInterval:(NSTimeInterval)adjacentPointsMaxTimeInterval adjacentStrokesMaxFreeTimeInterval:(NSTimeInterval)adjacentStrokesMaxFreeTimeInterval;

@end






/***********************************************************************
 *NSPaintEvent
 *整个一次画画的所有的笔记
 ***********************************************************************/
@interface NSPaintEvent : NSObject <NSCoding>

//eventId就是创建的时间（微妙us）
@property (nonatomic, assign, readonly) uint64_t eventId;
//默认为adjacentPointsMaxTimeInterval:2,adjacentStrokesMaxFreeTimeInterval:5
@property (nonatomic, strong) NSPaintEventConfig *eventConfig;

-(instancetype)initWithEventId:(uint64_t)eventId;

-(NSArray<NSNumber*>*)paintStrokeIds;

//增加新的一笔，并进行保存，返回新的一笔StrokeId
-(NSUInteger)addPaintStroke:(NSPaintStroke*)paintStroke;
//删除其中的一笔，并进行保存，返回删除的笔StrokeId
-(NSUInteger)deletePaintStroke:(NSPaintStroke*)paintStroke;

//第一笔
-(NSPaintStroke*)firstPaintStroke;

//最后一笔
-(NSPaintStroke*)lastPaintStroke;

//从event中获取strokeId的NSPaintStroke的对象
-(NSPaintStroke*)paintStrokeForStrokeId:(NSUInteger)strokeId;

//从当前的strokeId获取下一个paintStroke
-(NSPaintStroke*)nextPaintStrokeForStrokeId:(NSUInteger)strokeId;

//从当前的strokeId获取上一个paintStroke
-(NSPaintStroke*)prevPaintStrokeForStrokeId:(NSUInteger)strokeId;

//是否是第一笔
-(BOOL)isFirstPaintStroke:(NSPaintStroke*)stroke;

//是否是最后一笔
-(BOOL)isLastPaintStroke:(NSPaintStroke*)stroke;

+(NSPaintEvent*)loadWithEventId:(uint64_t)eventId;

-(NSTimeInterval)getEventTimeInterval;
//获取落笔播放时间,playId为无效时(<=0),就是获取从事件的时间重新获取
-(NSTimeInterval)getStartPlayTimeIntervalForStroke:(NSPaintStroke*)stroke playId:(int64_t)playId;
//获取抬笔播放时间,playId为无效时(<=0),就是获取从事件的时间重新获取
-(NSTimeInterval)getEndPlayTimeIntervalForStroke:(NSPaintStroke*)stroke  playId:(int64_t)playId;
//获取某一笔某一个点的播放时间,playId为无效时(<=0),就是获取从事件的时间重新获取
-(NSTimeInterval)getPointPlayTimeInterForStorke:(NSPaintStroke*)stroke point:(NSPaintPoint*)paintPoint playId:(int64_t)playId;

-(BOOL)canSave;

+(NSString*)getEventSnapshotImagePath;
+(NSString*)getEventSnapshotImageNameForEventId:(uint64_t)eventId;
+(NSString*)getEventSnapshotImageFullPathForEventId:(uint64_t)eventId;

-(NSArray<NSNumber*>*)paintStrokeIdsForPointInRect:(CGRect)rect exceptStrokeIds:(NSArray<NSNumber*>*)exceptStrokeIds;

+(NSArray<NSNumber*>*)findPaintStrokeIdsFrom:(NSArray<NSNumber*>*)paintStrokeIds eventId:(uint64_t)eventId forPointInRect:(CGRect)rect exceptStrokeIds:(NSArray<NSNumber*>*)exceptStrokeIds;

@end

/***********************************************************************
 *NSPaintEvent (PlayBack)
 *回放时需要用到，存储上一次绘制的线
 ***********************************************************************/
@interface NSPaintEvent (PlayBack)

@property (nonatomic, strong) NSPaintStroke *lastRenderStroke;
/* <#name#> */
@property (nonatomic, assign) NSTimeInterval lastDisplayStrokeTime;
/* <#name#> */
@property (nonatomic, assign) NSInteger fastPlayDisplayStrokesPerSecond;

@end







/***********************************************************************
 *NSPaintStroke
 *管理整个所有的画画的记录
 *这个已经进行了cache，真正cache的对象是NSPaintStroke
 ***********************************************************************/
@interface NSPaintManager : NSObject

+(instancetype)sharePaintManager;

-(void)save;

/*
 *在切换用户的时候一定要调用这个方法,退出登录的时候也需要调用，此时pathPrefix传nil或者空字符串
 *
 */
//在切换用户的时候一定要调用这个方法
-(void)loadEventIdDataFromPathPrefix:(NSString*)pathPrefix;

//返回正在cache的对象
-(NSPaintEvent*)currentCacheEvent;

//创建一个新的cache的event
-(NSPaintEvent*)cacheForNewEvent;

//加载一个eventId的cache
-(NSPaintEvent*)cacheForEventId:(uint64_t)eventId;

//从cache中移除，不移除文件，这个会进行保存
-(void)removeCurrentCacheEvent;

//将一笔所有的点击加载到cache中，paintStroke中的点必须包含began,end这两个点，返回paintStrokeId
-(NSUInteger)addPaintStrokeInCurrentCacheEvent:(NSPaintStroke*)paintStroke;
-(NSUInteger)deletePaintStrokeInCurrentCacheEvent:(NSPaintStroke*)paintStroke;

//从当前cache的event中获取strokeId的NSPaintStroke的对象
-(NSPaintStroke*)paintStrokeInCurrentCacheEventForStrokeId:(NSUInteger)strokeId;

//从当前的strokeId获取下一个paintStroke
-(NSPaintStroke*)nextPaintStrokeInCurrentCacheEventForStrokeId:(NSUInteger)strokeId;

//从当前的strokeId获取上一个paintStroke
-(NSPaintStroke*)prevPaintStrokeInCurrentCacheEventForStrokeId:(NSUInteger)strokeId;

//从当前cache的event中获取strokeId的NSPaintStroke的对象，仅仅只是从cache中获取，有可能为空
-(NSPaintStroke*)paintStrokeOnlyInCurrentCacheEventForStrokeId:(NSUInteger)strokeId;

//第一笔
-(NSPaintStroke*)firstStrokeInCurrentCacheEvent;

//最后一笔
-(NSPaintStroke*)lastStrokeInCurrentCacheEvent;

//是否是第一笔
-(BOOL)isFirstPaintStrokeInCurrentCacheEvent:(NSPaintStroke*)stroke;

//是否是最后一笔
-(BOOL)isLastPaintStrokeInCurrentCacheEvent:(NSPaintStroke*)stroke;

//根据相对第一笔开始时的时长获取到此时间是在哪一笔
-(NSPaintStroke*)getStrokeForTimeInterval:(NSTimeInterval)timeInterval paintPointIndex:(NSUInteger*)paintPointIndex;

/*
 *移除掉当前的cacheEvent
 *注意：这个是删除了存储
 */
-(void)deleteCurrentCacheEvent;

/*
 *根据eventId移除Event
 *注意：这个是删除了存储
 */
-(void)deleteEventForEventId:(uint64_t)eventId;

//获取所有的event的Id
-(NSArray<NSNumber*>*)getAllEventId;

-(NSArray<NSNumber*>*)paintStrokeIdsForPointInRectInCurrentCacheEvent:(CGRect)rect exceptStrokeIds:(NSArray<NSNumber*>*)exceptStrokeIds;

-(NSArray<NSNumber*>*)findPaintStrokeIdsInCurrentCacheEventFrom:(NSArray<NSNumber*>*)paintStrokeIds forPointInRect:(CGRect)rect exceptStrokeIds:(NSArray<NSNumber*>*)exceptStrokeIds;

-(void)addDataExecuteBlock:(NSPaintDataExecuteBlock)executeBlock completionBlock:(NSPaintDataExecuteCompletionBlock)completionBlock;

@end
