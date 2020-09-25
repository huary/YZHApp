//
//  YZHUIPageScrollView.m
//  YZHUIPageScrollViewDemo
//
//  Created by yuan on 16/12/6.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "YZHUIPageScrollView.h"
#import "YZHUITitleButtonItem.h"
#import "CALayer+YZHAdd.h"
#import "YZHKitType.h"

NSString *const YZHPageTitleNormalColorKey = TYPE_STR(YZHPageTitleNormalColorKey);
NSString *const YZHPageTitleSelectedColorKey = TYPE_STR(YZHPageTitleSelectedColorKey);
NSString *const YZHPageTitleNormalFontKey = TYPE_STR(YZHPageTitleNormalFontKey);
NSString *const YZHPageTitleSelectedFontKey = TYPE_STR(YZHPageTitleSelectedFontKey);
NSString *const YZHPageTitleSelectedScaleRatioKey = TYPE_STR(YZHPageTitleSelectedScaleRatioKey);
NSString *const YZHPageTitleNormalBackgroundColorKey = TYPE_STR(YZHPageTitleNormalBackgroundColorKey);
//NSString *const YZHPageTitleSelectedBackgroundColorKey = TYPE_STR(YZHPageTitleSelectedBackgroundColorKey);

static const CGFloat defaultButtonWidth = 65;
static const CGFloat defaultButtonHeight = 40;

static const CGFloat defaultButtonTitleFontNM = 16;
static const CGFloat defaultButtonTitleFontHL = 20;

static const CGFloat defaultButtonSelectedScaleRatio = 1.25;
static const CGFloat defaultAnimateTime = 0.8;
static const CGFloat defaultMinDifferOffsetRatioDoDidSelectAction = 0.1;//0.05;

//-----------------------------UIPageContentOffset-----------------------------
@interface UIPageContentOffset : NSObject

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat length;
@end

@implementation UIPageContentOffset

@end


//-----------------------------YZHUIPageScrollView-----------------------------
@interface YZHUIPageScrollView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) YZHUITitleButtonItem *lastSelectButtonItem;

@property (nonatomic, assign) NSInteger numberOfPages;


@property (nonatomic, assign) CGPoint maxContentOffset;
@property (nonatomic, strong) NSMutableArray *buttonContentOffsetInfos;
@property (nonatomic, strong) NSMutableArray *pageViewContentOffsetInfos;

@end

@implementation YZHUIPageScrollView

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefaultValue];
        [self _setupChildView];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setupDefaultValue];
        [self _setupChildView];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupDefaultValue];
        [self _setupChildView];
    }
    return self;
}

-(void)_setupDefaultValue
{
    _buttonContentOffsetInfos = [NSMutableArray array];
    _pageViewContentOffsetInfos = [NSMutableArray array];
    self.scrollIndicatorLineWidth = 2.0;
    self.autoAdjustToCenter = YES;
}

-(void)_setupChildView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = NO;
    _scrollView.backgroundColor = WHITE_COLOR;
    _scrollView.showsHorizontalScrollIndicator  =NO;
    [self addSubview:_scrollView];
    
    _scrollIndicatorLine = [[CALayer alloc] init];
    _scrollIndicatorLine.backgroundColor = RED_COLOR.CGColor;
    [self.scrollView.layer addSublayer:_scrollIndicatorLine];
}

-(void)_layoutSubPageViews
{
    self.lastSelectButtonItem = nil;
    self.numberOfPages = 0;
    self.maxContentOffset = CGPointZero;
    [self.buttonContentOffsetInfos removeAllObjects];
    [self.pageViewContentOffsetInfos removeAllObjects];
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat totalWidth = 0;
    CGFloat totalHeight = 0;
    int i = 0;
    
    if ([self.delegate respondsToSelector:@selector(numberOfPagesInPageScrollView:)]) {
        _numberOfPages = [self.delegate numberOfPagesInPageScrollView:self];
    }
    for (i = 0; i < _numberOfPages; ++i) {
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;
        NSString *title = @"";
        if (UIPAGESCROLL_DIRECTION_IS_HORIZONTAL(self.scrollDirection)) {
            x = totalWidth;
            y = 0;
            if (self.titleItemWidth > 0) {
                width = self.titleItemWidth;
            }
            else
            {
                width = defaultButtonWidth;
            }
            height = self.frame.size.height;
        }
        else
        {
            x = 0;
            y = totalHeight;
            width = self.frame.size.width;
            if (self.titleItemHeight > 0) {
                height = self.titleItemHeight;
            }
            else
            {
                height = defaultButtonHeight;
            }
        }
        UIPageContentOffset *newOffset = [[UIPageContentOffset alloc] init];
        UIPageContentOffset *oldOffset = [[UIPageContentOffset alloc] init];
        
        UIPageContentOffset *pageViewNewOffset = [[UIPageContentOffset alloc] init];
        UIPageContentOffset *pageViewOldOffset = [[UIPageContentOffset alloc] init];
        
        if (i > 0) {
            oldOffset = self.buttonContentOffsetInfos[i-1];
            if (self.pageViewContentOffsetInfos.count >= i) {
                pageViewOldOffset = self.pageViewContentOffsetInfos[i-1];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(pageScrollView:titleForRowAtIndex:)]) {
            title = [self.delegate pageScrollView:self titleForRowAtIndex:i];
        }
        CGSize size = [self _getPageTitleSizeWithText:title];
        
        if (UIPAGESCROLL_DIRECTION_IS_HORIZONTAL(self.scrollDirection)) {
            if ([self.delegate respondsToSelector:@selector(pageScrollView:widthForRowAtIndex:)]) {
                width = [self.delegate pageScrollView:self widthForRowAtIndex:i];
            }
            else
            {
                width = size.width;
            }
            if ([self.delegate respondsToSelector:@selector(pageScrollView:pageSizeForRowAtIndex:)]) {
                CGSize pageViewSize = [self.delegate pageScrollView:self pageSizeForRowAtIndex:i];
                
                pageViewNewOffset.offset = pageViewOldOffset.offset + pageViewOldOffset.length;
                pageViewNewOffset.length = pageViewSize.width;
                
                [self.pageViewContentOffsetInfos addObject:pageViewNewOffset];
            }
            newOffset.offset = oldOffset.offset + oldOffset.length;
            newOffset.length = width;
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(pageScrollView:heightForRowAtIndex:)]) {
                height = [self.delegate pageScrollView:self heightForRowAtIndex:i];
            }
            else
            {
                height = size.height;
            }
            if ([self.delegate respondsToSelector:@selector(pageScrollView:pageSizeForRowAtIndex:)]) {
                CGSize pageSize = [self.delegate pageScrollView:self pageSizeForRowAtIndex:i];
                pageViewNewOffset.offset = pageViewOldOffset.offset + pageViewOldOffset.length;
                pageViewNewOffset.length = pageSize.height;
                [self.pageViewContentOffsetInfos addObject:pageViewNewOffset];
            }
            
            newOffset.offset = oldOffset.offset + oldOffset.length;
            newOffset.length = height;
        }
        self.buttonContentOffsetInfos[i] = newOffset;
        
        CGRect frame = CGRectMake(x, y, width, height);
        YZHUITitleButtonItem *btnItem = [YZHUITitleButtonItem buttonItemWithTitle:title];
        btnItem.frame = frame;
        btnItem.backgroundColor = [self _pageTitleNormalBackgroundColor];
        btnItem.tag = i + 1;
        btnItem.titleLabel.textColor = [self _pageTitleNormalColor];
        btnItem.titleLabel.font = [self _pageTitleNormalFont];
        
        [btnItem addTarget:self action:@selector(_scrollViewDidSelectPage:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:btnItem];
        
        totalWidth += width;
        totalHeight += height;
        
        if (i == 0) {
            [self _scrollViewDidSelectPage:btnItem];
        }
    }
    
    if (UIPAGESCROLL_DIRECTION_IS_HORIZONTAL(self.scrollDirection))
    {
        self.scrollView.contentSize = CGSizeMake(totalWidth, self.bounds.size.height);
        self.maxContentOffset = CGPointMake(totalWidth - self.bounds.size.width, 0);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(self.bounds.size.width, totalHeight);
        self.maxContentOffset = CGPointMake(0, totalHeight - self.bounds.size.height);
    }
    [self.scrollView.layer hz_bringSubLayerToFront:self.scrollIndicatorLine];
}

-(CGSize)_getPageTitleSizeWithText:(NSString*)title
{
    if (!IS_AVAILABLE_NSSTRNG(title)) {
        return CGSizeZero;
    }

    CGSize normalSize = [title sizeWithAttributes:@{NSFontAttributeName:[self _pageTitleNormalFont]}];
    CGFloat maxWidth = normalSize.width;
    CGFloat maxHeight = normalSize.height;
    CGFloat pageScaleRatio = [self _pageTitleSelectedScaleRatio];
    if (pageScaleRatio > 1.0) {
        maxWidth = maxWidth * pageScaleRatio;
    }
    maxWidth += 20;
    
    CGFloat minWidth = defaultButtonWidth;
    CGFloat minHeight = defaultButtonHeight;
    
    if (self.numberOfPages > 0) {
        CGFloat minWidthTmp = self.bounds.size.width / self.numberOfPages;
        CGFloat minHeightTmp = self.bounds.size.height / self.numberOfPages;
        
        minWidth = MAX(minWidth, minWidthTmp);
        minHeight = MAX(minHeight, minHeightTmp);
    }
    
    maxWidth = MAX(maxWidth, minWidth);
    maxHeight = MAX(maxHeight, minHeight);
    CGSize retSize = CGSizeMake(maxWidth, maxHeight);
    return retSize;
}

-(UIColor*)_pageTitleNormalColor
{
    if (self.titleTextAttributes) {
        UIColor *normalColor = [self.titleTextAttributes objectForKey:YZHPageTitleNormalColorKey];
        if (normalColor) {
            return normalColor;
        }
    }
    return BLACK_COLOR;
}

-(UIColor*)_pageTitleSelectedColor
{
    if (self.titleTextAttributes) {
        UIColor *selectedColor = [self.titleTextAttributes objectForKey:YZHPageTitleSelectedColorKey];
        if (selectedColor) {
            return selectedColor;
        }
    }
    return RED_COLOR;
}

-(UIFont*)_pageTitleNormalFont
{
    if (self.titleTextAttributes) {
        UIFont *font = [self.titleTextAttributes objectForKey:YZHPageTitleNormalFontKey];
        if (font) {
            return font;
        }
    }
    return FONT(defaultButtonTitleFontNM);
}

-(UIFont*)_pageTitleSelectedFont
{
    if (self.titleTextAttributes) {
        UIFont *font = [self.titleTextAttributes objectForKey:YZHPageTitleSelectedFontKey];
        if (font) {
            return font;
        }
    }
    return FONT(defaultButtonTitleFontHL);
}

-(CGFloat)_pageTitleSelectedScaleRatio
{
    if (self.titleTextAttributes) {
        NSNumber *number = [self.titleTextAttributes objectForKey:YZHPageTitleSelectedScaleRatioKey];
        return [number floatValue];

    }
    return defaultButtonSelectedScaleRatio;
}

-(UIColor*)_pageTitleNormalBackgroundColor
{
    if (self.titleTextAttributes) {
        UIColor *color = [self.titleTextAttributes objectForKey:YZHPageTitleNormalBackgroundColorKey];
        if (color) {
            return color;
        }
    }
    return WHITE_COLOR;
}

-(UIColor*)_scrollIndicatorLineColor
{
    return [self _pageTitleSelectedColor];
}

-(void)_scrollViewDidSelectPageWithoutDidSelectedEvent:(YZHUITitleButtonItem*)selectBtnItem
{
    if (self.lastSelectButtonItem == selectBtnItem) {
        return;
    }
    self.lastSelectButtonItem.titleLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);

    self.lastSelectButtonItem.titleLabel.textColor = [self _pageTitleNormalColor];
    
    NSInteger currentSelectedIndex = selectBtnItem.tag - 1;
    
    UIPageContentOffset *currentOffset = self.buttonContentOffsetInfos[currentSelectedIndex];
    
    CGRect lineFrame = CGRectZero;
    if (UIPAGESCROLL_DIRECTION_IS_HORIZONTAL(self.scrollDirection))
    {
        if (self.autoAdjustToCenter) {
            CGFloat shiftOffsetX = 0;
            //相对与父类UI的位置
            shiftOffsetX = currentOffset.offset + currentOffset.length/2;
            //在中心线时的偏移量
            shiftOffsetX = shiftOffsetX - self.bounds.size.width/2;
            //shiftOffsetX不能小于0
            shiftOffsetX = MAX(0, shiftOffsetX);
            //shiftOffsetX不能大于最大移动值
            shiftOffsetX = MIN(self.maxContentOffset.x, shiftOffsetX);
            //        NSLog(@"shiftOffsetX=%f",shiftOffsetX);
            [UIView animateWithDuration:defaultAnimateTime animations:^{
                self.scrollView.contentOffset = CGPointMake(shiftOffsetX, 0);
            }];
        }
        
        lineFrame = CGRectMake(currentOffset.offset, self.scrollView.bounds.size.height - self.scrollIndicatorLineWidth, currentOffset.length, self.scrollIndicatorLineWidth);
    }
    else
    {
        if (self.autoAdjustToCenter) {
            CGFloat shiftOffsetY = 0;
            //相对与父类UI的位置
            shiftOffsetY = currentOffset.offset + currentOffset.length/2;
            //在中心线时的偏移量
            shiftOffsetY = shiftOffsetY - self.bounds.size.height/2;
            //shiftOffsetX不能小于0
            shiftOffsetY = MAX(0, shiftOffsetY);
            //shiftOffsetX不能大于最大移动值
            shiftOffsetY = MIN(self.maxContentOffset.y, shiftOffsetY);
            [UIView animateWithDuration:defaultAnimateTime animations:^{
                self.scrollView.contentOffset = CGPointMake(0, shiftOffsetY);
            }];
        }
        
        lineFrame = CGRectMake(self.scrollView.bounds.size.width - self.scrollIndicatorLineWidth, currentOffset.offset, self.scrollIndicatorLineWidth,currentOffset.length);

    }
    self.lastSelectButtonItem = selectBtnItem;
    
    CGFloat scaleRatio = [self _pageTitleSelectedScaleRatio];
    self.lastSelectButtonItem.titleLabel.transform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);

    self.lastSelectButtonItem.titleLabel.textColor = [self _pageTitleSelectedColor];
    
    if (self.scrollIndicatorLine.backgroundColor == nil) {
        self.scrollIndicatorLine.backgroundColor = [self _scrollIndicatorLineColor].CGColor;
    }
    self.scrollIndicatorLine.frame = lineFrame;
}

-(void)_scrollViewDidSelectPage:(YZHUITitleButtonItem*)selectBtnItem
{
    if (self.lastSelectButtonItem == selectBtnItem) {
        return;
    }
    NSInteger currentSelectedIndex = selectBtnItem.tag - 1;
    if ([self.delegate respondsToSelector:@selector(pageScrollView:didSelectedForRowAtIndex:)]) {
        [self.delegate pageScrollView:self didSelectedForRowAtIndex:currentSelectedIndex];
    }
    
    [self _scrollViewDidSelectPageWithoutDidSelectedEvent:selectBtnItem];
}

-(NSInteger)_getSelectPageIndexFromPageContentOffset:(CGPoint)contentOffset
{
    NSInteger selectIndex = 0;
    if (self.pageViewContentOffsetInfos.count == self.numberOfPages) {
        CGFloat shiftLength = 0;
        if (UIPAGESCROLL_DIRECTION_IS_HORIZONTAL(self.scrollDirection)) {
            shiftLength = contentOffset.x;
        }
        else
        {
            shiftLength = contentOffset.y;
        }
        for (NSInteger i = 0; i < self.numberOfPages; ++i) {
            UIPageContentOffset *offset = self.pageViewContentOffsetInfos[i];
            if (shiftLength >= offset.offset && shiftLength < offset.offset + offset.length)
            {
                selectIndex = i;
                break;
            }
        }
    }
    else
    {
        CGFloat currentRatio = 0;
        if (UIPAGESCROLL_DIRECTION_IS_HORIZONTAL(self.scrollDirection)) {
            currentRatio =  contentOffset.x / self.relatePageSize.width;//self.bounds.size.width;
        }
        else
        {
            currentRatio = contentOffset.y / self.relatePageSize.height;//self.bounds.size.height;
        }
        selectIndex = (NSInteger)floor(currentRatio);
    }
    return selectIndex;
}

-(void)_changeTitleColorAndFontWithButtonContentOffset:(CGPoint)contentOffset withPageIndex:(NSInteger)selectIndex
{
    NSInteger nextIndex = selectIndex + 1;
    UIPageContentOffset *selectOffsetPoint = self.buttonContentOffsetInfos[selectIndex];
    if (selectOffsetPoint.length <= 0) {
        return;
    }
    CGFloat offset = contentOffset.x - selectOffsetPoint.offset;
    CGFloat nextOffsetRatio = offset / selectOffsetPoint.length;
    CGFloat selectOffsetRatio = 1 - nextOffsetRatio;
    
//    NSLog(@"sIndex=%ld,nIndex=%ld,R=%f,nR=%f",selectIndex,nextIndex,selectOffsetRatio,nextOffsetRatio);
    
    YZHUITitleButtonItem *selectBtnItem = (YZHUITitleButtonItem*)[self.scrollView viewWithTag:selectIndex+1];
    YZHUITitleButtonItem *nextBtnItem = (YZHUITitleButtonItem*)[self.scrollView viewWithTag:nextIndex + 1];
    
    CGFloat expandRatio = [self _pageTitleSelectedScaleRatio] - 1.0;
    CGFloat scale = 1.0 + selectOffsetRatio * expandRatio;
    CGFloat nextScale = 1.0 + nextOffsetRatio * expandRatio;
    selectBtnItem.titleLabel.transform = CGAffineTransformMakeScale(scale, scale);
    nextBtnItem.titleLabel.transform = CGAffineTransformMakeScale(nextScale, nextScale);
    
    CGFloat selectRed = 0;
    CGFloat selectGreen = 0;
    CGFloat selectBlue = 0;
    CGFloat selectAlpha = 0;
    
    CGFloat NormalRed = 0;
    CGFloat NormalGreen = 0;
    CGFloat NormalBlue = 0;
    CGFloat NormalAlpha = 0;
    
    CGFloat diffRed = 0;
    CGFloat diffGreen = 0;
    CGFloat diffBlue = 0;
    CGFloat diffAlpha = 0;
    
    [[self _pageTitleSelectedColor] getRed:&selectRed green:&selectGreen blue:&selectBlue alpha:&selectAlpha];
    [[self _pageTitleNormalColor] getRed:&NormalRed green:&NormalGreen blue:&NormalBlue alpha:&NormalAlpha];
    
    diffRed = selectRed - NormalRed;
    diffGreen = selectGreen - NormalGreen;
    diffBlue = selectBlue - NormalBlue;
    diffAlpha = selectAlpha - NormalAlpha;
    
    CGFloat redTmp = NormalRed + diffRed * selectOffsetRatio;
    CGFloat greenTmp = NormalGreen + diffGreen * selectOffsetRatio;
    CGFloat blueTmp = NormalBlue + diffBlue * selectOffsetRatio;
    CGFloat alphaTmp = NormalAlpha + diffAlpha * selectOffsetRatio;
    
    UIColor *selectColor = [UIColor colorWithRed:redTmp green:greenTmp blue:blueTmp alpha:alphaTmp];
    
    redTmp = NormalRed + diffRed * nextOffsetRatio;
    greenTmp = NormalGreen + diffGreen * nextOffsetRatio;
    blueTmp = NormalBlue + diffBlue * nextOffsetRatio;
    alphaTmp = NormalAlpha + diffAlpha * nextOffsetRatio;
    
    UIColor *nextColor = [UIColor colorWithRed:redTmp green:greenTmp blue:blueTmp alpha:alphaTmp];

    selectBtnItem.titleLabel.textColor = selectColor;
    nextBtnItem.titleLabel.textColor = nextColor;
    
    if (nextIndex < self.buttonContentOffsetInfos.count) {
        UIPageContentOffset *nextOffsetPoint = self.buttonContentOffsetInfos[nextIndex];
        
        CGFloat lineOffset = selectOffsetPoint.offset  + (1 - selectOffsetRatio) * selectOffsetPoint.length;
        CGFloat lineWidth = selectOffsetRatio * selectOffsetPoint.length + nextOffsetRatio * nextOffsetPoint.length;
        
        CGRect lineFrame = self.scrollIndicatorLine.frame;
        if (UIPAGESCROLL_DIRECTION_IS_HORIZONTAL(self.scrollDirection)) {
            lineFrame.origin.x = lineOffset;
            lineFrame.size.width = lineWidth;
        }
        else
        {
            lineFrame.origin.y = lineOffset;
            lineFrame.size.height = lineWidth;
        }
        self.scrollIndicatorLine.frame = lineFrame;
        
        
        if ([self.delegate respondsToSelector:@selector(pageScrollView:fromPageScrollInfo:toPageScrollInfo:)]) {
            CGPageScrollInfo from = CGPageScrollInfoMake(selectIndex, selectOffsetPoint.offset, selectOffsetPoint.length, selectOffsetRatio);
            
            CGPageScrollInfo to = CGPageScrollInfoMake(nextIndex, nextOffsetPoint.offset, nextOffsetPoint.length, nextOffsetRatio);
            [self.delegate pageScrollView:self fromPageScrollInfo:from toPageScrollInfo:to];            
        }
    }
    
}

-(void)setUIPageScrollViewContentOffset:(CGPoint)contentOffset withAnimation:(BOOL)animate
{
    CGPoint btnItemContentOffset = CGPointZero;
    NSInteger selectIndex = [self _getSelectPageIndexFromPageContentOffset:contentOffset];
    if (selectIndex < 0 || selectIndex >= self.buttonContentOffsetInfos.count) {
        return;
    }
    UIPageContentOffset *offset = self.buttonContentOffsetInfos[selectIndex];
    
    if (UIPAGESCROLL_DIRECTION_IS_HORIZONTAL(self.scrollDirection)) {
        CGFloat offsetX = 0;
        if (self.pageViewContentOffsetInfos.count == self.numberOfPages) {
            UIPageContentOffset *pageViewOffset = self.pageViewContentOffsetInfos[selectIndex];
            offsetX = contentOffset.x - pageViewOffset.offset;
            offsetX = offset.offset + offset.length * offsetX/pageViewOffset.length;
        }
        else
        {
            offsetX = contentOffset.x - selectIndex * self.relatePageSize.width;//self.bounds.size.width;
            offsetX = offset.offset + offset.length * offsetX/self.relatePageSize.width;//self.bounds.size.width;
        }
        btnItemContentOffset = CGPointMake(offsetX, 0);
    }
    else
    {
        CGFloat offsetY = 0;
        if (self.pageViewContentOffsetInfos.count == self.numberOfPages) {
            UIPageContentOffset *pageViewOffset = self.pageViewContentOffsetInfos[selectIndex];
            offsetY = contentOffset.y - pageViewOffset.offset;
            offsetY = offset.offset + offset.length * offsetY/pageViewOffset.length;
        }
        else
        {
            offsetY = contentOffset.y - selectIndex * self.relatePageSize.height;//self.bounds.size.height;
            offsetY = offset.offset + offset.length * offsetY/self.relatePageSize.height;//self.bounds.size.height;
        }
        btnItemContentOffset = CGPointMake(0, offsetY);
    }
    
//    NSLog(@"contentOffset.x=%f,selectIndex=%ld",contentOffset.x,selectIndex);
    [self _changeTitleColorAndFontWithButtonContentOffset:btnItemContentOffset withPageIndex:selectIndex];
    
    YZHUITitleButtonItem *selectBtnItem = (YZHUITitleButtonItem*)[self.scrollView viewWithTag:selectIndex+1];
    if (self.lastSelectButtonItem.tag < selectBtnItem.tag) {
        [self _scrollViewDidSelectPageWithoutDidSelectedEvent:selectBtnItem];
    }
    else if (self.lastSelectButtonItem.tag > selectBtnItem.tag)
    {
        //方法1，根据pageView的scroll的contentOffset来进行判断
//        if (contentOffset.x - selectIndex * self.bounds.size.width < 0.1) {
//            [self scrollViewDidSelectPageWithoutDidSelectedEvent:selectBtnItem];
//        }
        //方法2，根据buttonItem的offset来判断
        CGFloat diffOffset = 0;
        if (UIPAGESCROLL_DIRECTION_IS_HORIZONTAL(self.scrollDirection)) {
            diffOffset = btnItemContentOffset.x - offset.offset;
        }
        else
        {
            diffOffset = btnItemContentOffset.y - offset.offset;
        }
        if (diffOffset/offset.length <= defaultMinDifferOffsetRatioDoDidSelectAction) {
            [self _scrollViewDidSelectPageWithoutDidSelectedEvent:selectBtnItem];
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = self.scrollView.frame.size;
    [self _layoutSubPageViews];
}

-(void)reloadData
{
    [self _layoutSubPageViews];
}

@end
