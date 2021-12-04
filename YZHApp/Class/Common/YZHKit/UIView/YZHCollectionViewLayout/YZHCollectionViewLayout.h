//
//  YZHCollectionViewLayout.h
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


@class YZHCollectionViewLayout;
@protocol YZHCollectionCellItemLayoutProtocol;

typedef CGSize(^YZHCollectionCellItemSizeBlock)(NSIndexPath *indexPath,id<YZHCollectionCellItemLayoutProtocol> target);
typedef CGFloat(^YZHCollectionCellItemMinRowSpacingBlock)(NSIndexPath *indexPath,id<YZHCollectionCellItemLayoutProtocol> target);
typedef CGFloat(^YZHCollectionCellItemMinLineSpacingBlock)(NSIndexPath *indexPath,id<YZHCollectionCellItemLayoutProtocol> target);
typedef UICollectionViewLayoutAttributes*(^YZHCollectionCellItemLayoutAttributesBlock)(NSIndexPath *indexPath,id<YZHCollectionCellItemLayoutProtocol> target);


@protocol YZHCollectionCellItemLayoutProtocol <NSObject>

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
@property (nonatomic, copy) YZHCollectionCellItemSizeBlock sizeBlock;
@property (nonatomic, copy) YZHCollectionCellItemMinRowSpacingBlock rowSpacingBlock;
@property (nonatomic, copy) YZHCollectionCellItemMinLineSpacingBlock lineSpacingBlock;
/*
 *自定义的布局方式，如果是提供了这种自定义布局的block,优先选择自定义的布局，不需要提供layoutAdjustLineSpacing这种属性
 */
@property (nonatomic, copy) YZHCollectionCellItemLayoutAttributesBlock layoutAttributesBlock;
@end



@protocol YZHCollectionViewLayoutDelegate <UICollectionViewDelegateFlowLayout>
@optional
-(CGSize)YZHCollectionViewLayout:(YZHCollectionViewLayout*)layout sizeForItemAtIndexPath:(NSIndexPath*)indexPath;
-(CGFloat)YZHCollectionViewLayout:(YZHCollectionViewLayout *)layout minRowSpacingForItemAtIndexPath:(NSIndexPath*)indexPath;
-(CGFloat)YZHCollectionViewLayout:(YZHCollectionViewLayout *)layout minLineSpacingForItemAtIndexPath:(NSIndexPath*)indexPath;
//也可以只要如下一个接口
-(UICollectionViewLayoutAttributes*)YZHCollectionViewLayout:(YZHCollectionViewLayout *)layout layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath;
@end



@interface YZHCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign) NSCellAlignment cellAlignment;

/** <#name#> */
@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, weak) id <YZHCollectionViewLayoutDelegate>delegate;

/*
 *这个boudingRectSize希望获得width或者heigh值的话，就需要传CGFLOAT_MAX的参数，可以两个都是CGFLOAT_MAX
 */
+(CGSize)collectionViewSingleSectionContentSizeForCellItems:(NSArray<id<YZHCollectionCellItemLayoutProtocol>>*)cellItems boundingRectWithSize:(CGSize)boundingRectSize layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions;
@end
