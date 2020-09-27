//
//  YZHUICalendarView.m
//  YZHUICalendarViewDemo
//
//  Created by yuan on 2018/8/8.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHUICalendarView.h"
#import "YZHUICalendarTitleView.h"
#import "YZHUICalendarItemCell.h"
#import "YZHCalendarItemModel.h"
#import "YZHKitType.h"
#import "UIView+YZHAdd.h"

@interface YZHUICalendarView () <YZHUICalendarTitleViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource>

/* <#注释#> */
@property (nonatomic, strong) YZHUICalendarTitleView *titleView;

/* <#注释#> */
@property (nonatomic, strong) UIView *line;

/* <#注释#> */
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

/* <#注释#> */
@property (nonatomic, strong) UICollectionView *collectionView;

/* <#name#> */
@property (nonatomic, assign) NSInteger firstDayWeekDay;

/* <#注释#> */
@property (nonatomic, copy) NSArray<YZHCalendarItemModel*> *weekDays;

/* <#注释#> */
@property (nonatomic, copy) NSArray<YZHCalendarItemModel*> *monthDays;


@end

@implementation YZHUICalendarView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupChildView];
        
//        self.dateComponents = nil;
    }
    return self;
}

-(NSArray<YZHCalendarItemModel*>*)weekDays
{
    if (_weekDays == nil) {
        NSArray *weeks = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
        NSMutableArray *weekDays = [NSMutableArray array];
        UIFont *font = FONT(12);
        UIColor *textColor = BLACK_COLOR;
        for (NSString *day in weeks) {
            YZHControlTextViewModel *textModel = [[YZHControlTextViewModel alloc] initWithText:day font:font textColor:textColor backgroundColor:nil];
            YZHCalendarItemModel *itemModel = [[YZHCalendarItemModel alloc] initWithTextModel:textModel];
            itemModel.canSelected = NO;
            [weekDays addObject:itemModel];
        }
        _weekDays = [weekDays copy];
    }
    return _weekDays;
}

-(UICollectionViewFlowLayout*)flowLayout
{
    if (_flowLayout == nil) {
//        CGFloat w = floor(self.width/7);
        CGFloat w = self.hz_width/7;
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake(w, w);
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
    }
    return _flowLayout;
}

-(void)_setupChildView
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = self.bounds.size.width;
    CGFloat h = 45;
    self.titleView = [[YZHUICalendarTitleView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    self.titleView.delegate = self;
    [self addSubview:self.titleView];
    
    x = 0;
    y = self.titleView.hz_bottom;
    h = SINGLE_LINE_WIDTH;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    line.backgroundColor = RGB_WITH_INT_WITH_NO_ALPHA(0xdddddd);
    [self addSubview:line];
    self.line = line;
    
    x = 0;
    y = line.hz_bottom;
    h = self.hz_height - y;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(x, y, w, h) collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = WHITE_COLOR;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[YZHUICalendarItemCell class] forCellWithReuseIdentifier:NSSTRING_FROM_CLASS(YZHUICalendarItemCell)];
    [self addSubview:self.collectionView];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleView.hz_width = self.hz_width;
    self.line.hz_width = self.hz_width;
    
    if (_dateComponents == nil) {
        self.dateComponents = _dateComponents;        
    }
}

-(NSInteger)_getFirstWeekDayOfMonth:(NSDateComponents*)dateComponents
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = dateComponents.year;
    comps.month = dateComponents.month;
    comps.day = 1;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:comps];
    
    return [calendar components:NSCalendarUnitWeekday fromDate:date].weekday - 1;
}

-(NSDateComponents*)_dateComponentsForDate:(NSDate*)date
{
    if (date == nil) {
        date = [NSDate date];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
}

-(NSDateComponents*)_dateComponentsForDateComponents:(NSDateComponents*)dateComponents nextMonth:(BOOL)nextMonth
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.year = dateComponents.year;
    comps.month = dateComponents.month;
    comps.day = 1;
    if (nextMonth) {
        if (comps.month < 12) {
            comps.month += 1;
        }
        else {
            comps.year += 1;
            comps.month = 1;
        }
    }
    else {
        if (comps.month > 1) {
            comps.month -= 1;
        }
        else {
            comps.year -= 1;
            comps.month = 12;
        }
    }
    return comps;
}

-(void)setDateComponents:(NSDateComponents *)dateComponents
{
    if (dateComponents == nil) {
        dateComponents = [self _dateComponentsForDate:nil];
    }

    _dateComponents = dateComponents;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    self.firstDayWeekDay = [self _getFirstWeekDayOfMonth:dateComponents];
    
    NSMutableArray *monthDays = [NSMutableArray array];
    
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    for (NSInteger i = 0; i < range.length; ++i) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        comps.year = dateComponents.year;
        comps.month = dateComponents.month;
        comps.day = i + 1;
        
        YZHCalendarItemModel *itemModel = [[YZHCalendarItemModel alloc] initWithDateComponents:comps];
        
        BOOL shouldShow = NO;//arc4random() & 1;
        if ([self.delegate respondsToSelector:@selector(calendarView:shouldShowDotForDateComponents:)]) {
            shouldShow = [self.delegate calendarView:self shouldShowDotForDateComponents:comps];
        }
        itemModel.haveBottomDot = shouldShow;
        [monthDays addObject:itemModel];
    }
    self.monthDays = monthDays;
    [self.collectionView reloadData];
        
    NSInteger totalCnt = self.weekDays.count + self.firstDayWeekDay - 1 + monthDays.count;
    NSInteger rowCnt = (totalCnt + 6)/ 7;
    CGFloat collectionViewHeight = rowCnt * self.flowLayout.itemSize.height;
    self.collectionView.hz_height = collectionViewHeight;
    
    CGFloat totalHeight = self.line.hz_bottom + collectionViewHeight;
    self.hz_height = totalHeight;
    
    if ([self.delegate respondsToSelector:@selector(calendarView:updateToSize:)]) {
        [self.delegate calendarView:self updateToSize:self.hz_size];
    }
    
    YZHUICalendarTitleModel *titleModel = [[YZHUICalendarTitleModel alloc] initWithDateComponents:dateComponents];
    self.titleView.titleModel = titleModel;
    
}

#pragma mark YZHUICalendarTitleViewDelegate
-(void)calendarTitleView:(YZHUICalendarTitleView *)titleView didClickPrevAction:(YZHUICalendarTitleModel *)titleModel
{
    if ([self.delegate respondsToSelector:@selector(calendarView:didClickTitleAction:)]) {
        [self.delegate calendarView:self didClickTitleAction:NO];
    }
    self.dateComponents = [self _dateComponentsForDateComponents:self.dateComponents nextMonth:NO];
}

-(void)calendarTitleView:(YZHUICalendarTitleView *)titleView didClickNextAction:(YZHUICalendarTitleModel *)titleModel
{
    if ([self.delegate respondsToSelector:@selector(calendarView:didClickTitleAction:)]) {
        [self.delegate calendarView:self didClickTitleAction:YES];
    }
    self.dateComponents = [self _dateComponentsForDateComponents:self.dateComponents nextMonth:YES];
}

#pragma mark UICollectionViewDelegate, UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.weekDays.count + self.firstDayWeekDay + self.monthDays.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YZHUICalendarItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSSTRING_FROM_CLASS(YZHUICalendarItemCell) forIndexPath:indexPath];
    YZHCalendarItemModel *itemModel = nil;
    
    NSInteger dayIndex = indexPath.item - self.weekDays.count - self.firstDayWeekDay + 1;
    if (IS_IN_ARRAY_FOR_INDEX(self.weekDays, indexPath.item)) {
        itemModel = self.weekDays[indexPath.item];
    }
    else if (IS_IN_ARRAY_FOR_INDEX(self.monthDays, dayIndex)) {
        itemModel = self.monthDays[dayIndex];
    }
    cell.itemModel = itemModel;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YZHCalendarItemModel *itemModel = nil;
    
    NSInteger dayIndex = indexPath.item - self.weekDays.count - self.firstDayWeekDay + 1;
    if (IS_IN_ARRAY_FOR_INDEX(self.weekDays, indexPath.item)) {
        itemModel = self.weekDays[indexPath.item];
    }
    else if (IS_IN_ARRAY_FOR_INDEX(self.monthDays, dayIndex)) {
        itemModel = self.monthDays[dayIndex];
    }
    if (itemModel.canSelected && itemModel.dateComponents && [self.delegate respondsToSelector:@selector(calendarView:didSelectedDateComponents:)]) {
        [self.delegate calendarView:self didSelectedDateComponents:itemModel.dateComponents];
    }
}

@end
