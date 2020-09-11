//
//  YZHUICollectionViewLayout.h
//  YZHApp
//
//  Created by yuan on 2017/7/6.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSCellAlignment)
{
    NSCellAlignmentLeft     = 0,
    NSCellAlignmentCenter   = 1,
    NSCellAlignmentRight    = 2,
};

UIKIT_EXTERN NSString * const NSCellAlignmentKey;
UIKIT_EXTERN NSString * const NSCollectionEdgeInsetsKey;


@class YZHUICollectionViewLayout;
@protocol YZHUICollectionCellItemLayoutProtocol;

typedef CGSize(^YZHUICollectionCellItemSizeBlock)(NSIndexPath *indexPath,id<YZHUICollectionCellItemLayoutProtocol> target);
typedef CGFloat(^YZHUICollectionCellItemMinRowSpacingBlock)(NSIndexPath *indexPath,id<YZHUICollectionCellItemLayoutProtocol> target);
typedef CGFloat(^YZHUICollectionCellItemMinLineSpacingBlock)(NSIndexPath *indexPath,id<YZHUICollectionCellItemLayoutProtocol> target);
typedef UICollectionViewLayoutAttributes*(^YZHUICollectionCellItemLayoutAttributesBlock)(NSIndexPath *indexPath,id<YZHUICollectionCellItemLayoutProtocol> target);


@protocol YZHUICollectionCellItemLayoutProtocol <NSObject>

/*
 *这种layoutAttribute这个属性是必须提供的
 */
@required
@property (nonatomic, strong) UICollectionViewLayoutAttributes *layoutAttribute;

@optional
/*
 *系统按照最后一个item.frame来选择下一个的布局方式，这种布局方式可以必须提供layoutAdjustLineSpacing属性，
 *这种布局方式可以选择布局的对齐方式，在layoutOptions中添加NSCellAlignmentKey的对应NSCellAlignment对齐方式
 */
@property (nonatomic, assign) CGFloat layoutAdjustLineSpacing;
@property (nonatomic, copy) YZHUICollectionCellItemSizeBlock sizeBlock;
@property (nonatomic, copy) YZHUICollectionCellItemMinRowSpacingBlock rowSpacingBlock;
@property (nonatomic, copy) YZHUICollectionCellItemMinLineSpacingBlock lineSpacingBlock;
/*
 *自定义的布局方式，如果是提供了这种自定义布局的block,优先选择自定义的布局，不需要提供layoutAdjustLineSpacing这种属性
 */
@property (nonatomic, copy) YZHUICollectionCellItemLayoutAttributesBlock layoutAttributesBlock;
@end



@protocol YZHUICollectionViewLayoutDelegate <UICollectionViewDelegateFlowLayout>
@optional
-(CGSize)YZHUICollectionViewLayout:(YZHUICollectionViewLayout*)layout sizeForItemAtIndexPath:(NSIndexPath*)indexPath;
-(CGFloat)YZHUICollectionViewLayout:(YZHUICollectionViewLayout *)layout minRowSpacingForItemAtIndexPath:(NSIndexPath*)indexPath;
-(CGFloat)YZHUICollectionViewLayout:(YZHUICollectionViewLayout *)layout minLineSpacingForItemAtIndexPath:(NSIndexPath*)indexPath;
//也可以只要如下一个接口
-(UICollectionViewLayoutAttributes*)YZHUICollectionViewLayout:(YZHUICollectionViewLayout *)layout layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath;
@end



@interface YZHUICollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign) NSCellAlignment cellAlignment;

/** <#name#> */
@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, weak) id <YZHUICollectionViewLayoutDelegate>delegate;

/*
 *这个boudingRectSize希望获得width或者heigh值的话，就需要传CGFLOAT_MAX的参数，可以两个都是CGFLOAT_MAX
 */
+(CGSize)collectionViewSingleSectionContentSizeForCellItems:(NSArray<id<YZHUICollectionCellItemLayoutProtocol>>*)cellItems boundingRectWithSize:(CGSize)boundingRectSize layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions;
@end
