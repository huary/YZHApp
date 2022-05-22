//
//  YZHPageScrollView.h
//  YZHPageScrollViewDemo
//
//  Created by yuan on 16/12/6.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIPageScrollDirection)
{
    UIPageScrollNull                = 0,
    UIPageScrollHorizontal          = 1,
    UIPageScrollVertical            = 2,
};

#define UIPAGYZHROLL_DIRECTION_IS_HORIZONTAL(DIR)       ((DIR) == UIPageScrollNull || (DIR) ==UIPageScrollHorizontal)

UIKIT_EXTERN NSString *const YZHPageTitleNormalColorKey;
UIKIT_EXTERN NSString *const YZHPageTitleSelectedColorKey;
UIKIT_EXTERN NSString *const YZHPageTitleNormalFontKey;
UIKIT_EXTERN NSString *const YZHPageTitleSelectedFontKey; //这个暂时不用
UIKIT_EXTERN NSString *const YZHPageTitleSelectedScaleRatioKey;
UIKIT_EXTERN NSString *const YZHPageTitleNormalBackgroundColorKey;


struct CGPageScrollInfo
{
    NSInteger index;
    CGFloat offset;
    CGFloat length;
    CGFloat progress;
};
typedef struct CGPageScrollInfo CGPageScrollInfo;

CG_INLINE CGPageScrollInfo
CGPageScrollInfoMake(NSInteger index, CGFloat offset, CGFloat length, CGFloat progress)
{
    CGPageScrollInfo pageScrollInfo;
    pageScrollInfo.index = index;
    pageScrollInfo.offset = offset;
    pageScrollInfo.length = length;
    pageScrollInfo.progress = progress;
    return pageScrollInfo;
}

@class YZHPageScrollView;

@protocol UIPageScrollViewDelegate <NSObject>
@optional
-(NSInteger)numberOfPagesInPageScrollView:(YZHPageScrollView *)pageScrollView;
-(CGFloat)pageScrollView:(YZHPageScrollView *)pageScrollView widthForRowAtIndex:(NSInteger)index;
-(CGFloat)pageScrollView:(YZHPageScrollView *)pageScrollView heightForRowAtIndex:(NSInteger)index;
-(NSString*)pageScrollView:(YZHPageScrollView *)pageScrollView titleForRowAtIndex:(NSInteger)index;
-(void)pageScrollView:(YZHPageScrollView *)pageScrollView didSelectedForRowAtIndex:(NSInteger)index;
//这个主要是针对UIPageScrollVertical的UIPageScrollView使用
-(CGSize)pageScrollView:(YZHPageScrollView *)pageScrollView pageSizeForRowAtIndex:(NSInteger)index;
//
//-(CGFloat)pageScrollView:(YZHPageScrollView *)pageScrollView widthForIndicatorLineAtIndex:(NSInteger)index;

-(void)pageScrollView:(YZHPageScrollView *)pageScrollView fromPageScrollInfo:(CGPageScrollInfo)fromPageScrollInfo toPageScrollInfo:(CGPageScrollInfo)toPageScrollInfo;
@end


@interface YZHPageScrollView : UIView

@property (nonatomic, strong, readonly) CALayer *scrollIndicatorLine;
/** scrollIndicatorLineWidth default is 2.0 */
@property (nonatomic, assign) CGFloat scrollIndicatorLineWidth;
/** autoAdjustToCenter default is YES */
@property (nonatomic, assign) BOOL autoAdjustToCenter;

//滚动的方向，默认为UIPageScrollNull，UIPageScrollNull同UIPageScrollHorizontal
@property (nonatomic, assign) UIPageScrollDirection scrollDirection;
//代理对象
@property (nonatomic, weak) id<UIPageScrollViewDelegate> delegate;
//滚动的title的属性，包含以上特性
@property (nonatomic, copy) NSDictionary *titleTextAttributes;
//针对那种UIPageScrollHorizontal每一个titleItem都是一样宽度的时候使用
@property (nonatomic, assign) CGFloat titleItemWidth;
//这个主要是针对UIPageScrollVertical的UIPageScrollView使用,每一个titleItem都是一样的高度
@property (nonatomic, assign) CGFloat titleItemHeight;
//关联的pageSize,一定要设置，否则会出现错误
@property (nonatomic, assign) CGSize relatePageSize;

//设置pageview滚动的位置
-(void)setUIPageScrollViewContentOffset:(CGPoint)contentOffset withAnimation:(BOOL)animate;

//重新加载设置
-(void)reloadData;

@end
