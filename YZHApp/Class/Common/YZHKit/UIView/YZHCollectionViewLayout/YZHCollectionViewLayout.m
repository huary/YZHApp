//
//  YZHCollectionViewLayout.m
//  YZHApp
//
//  Created by yuan on 2017/7/6.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHCollectionViewLayout.h"
#import "YZHKitType.h"

NSString * const NSCellAlignmentKey = TYPE_STR(NSCellAlignmentKey);
NSString * const NSCollectionEdgeInsetsKey = TYPE_STR(NSCollectionEdgeInsetsKey);

@interface YZHCollectionViewLayout ()

@property (nonatomic, assign) CGFloat lastAdjustLineSpacing;
@property (nonatomic, assign) CGRect lastItemFrame;

@property (nonatomic, assign) CGFloat totalItemWidth;
@property (nonatomic, assign) CGFloat totalItemHeight;
@property (nonatomic, strong) NSMutableArray *itemAttrs;

@end

@implementation YZHCollectionViewLayout

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setUpDefaultValue];
    }
    return self;
}

-(void)_setUpDefaultValue
{
    _totalItemHeight = 0;
    _itemAttrs = [NSMutableArray array];
    _lastItemFrame = CGRectZero;
    _lastAdjustLineSpacing = 0;
}

-(void)prepareLayout
{
    [super prepareLayout];
    [self _setUpDefaultValue];
    

    CGFloat totalWidth = 0;
    CGFloat totalHeight = 0;
    NSInteger sectionCnt = [self.collectionView numberOfSections];
    sectionCnt = MAX(sectionCnt, 1);
    for (NSInteger section =0; section < sectionCnt; ++section) {
        NSInteger count = [self.collectionView numberOfItemsInSection:section];
        
        CGFloat sectionWidth = 0;
        CGFloat sectionHeight = 0;

        for (NSInteger i = 0; i < count; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
            
            UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (layoutAttributes) {
                [_itemAttrs addObject:layoutAttributes];                
            }
            
            sectionWidth = CGRectGetMaxX(layoutAttributes.frame);
            sectionHeight = CGRectGetMaxY(layoutAttributes.frame);
        }
        
        UIEdgeInsets insets = [YZHCollectionViewLayout _collectionViewLayout:self insetsAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] layoutOptions:nil];
        
        sectionWidth += insets.right;
        sectionHeight += insets.bottom;
        
        totalWidth += sectionWidth;
        totalHeight += sectionHeight;
    }
//    NSLog(@"totalWidth=%f,totalHeight=%f",totalWidth,totalHeight);
    self.totalItemWidth = MAX(totalWidth, self.collectionView.bounds.size.width);
    self.totalItemHeight = MAX(totalHeight, self.collectionView.bounds.size.height);
}

-(CGSize)collectionViewContentSize
{
    if (CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
        CGSize size = CGSizeMake(self.totalItemWidth, self.totalItemHeight);
        return size;
    }
    return self.contentSize;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(YZHCollectionViewLayout:layoutAttributesForItemAtIndexPath:)]) {
        return [self.delegate YZHCollectionViewLayout:self layoutAttributesForItemAtIndexPath:indexPath];
    }
    
    UICollectionViewLayoutAttributes *layoutAttributes = [YZHCollectionViewLayout _layoutAttributesForItem:self.delegate atIndexPath:indexPath cellItems:nil boundingRectWithSize:self.collectionView.bounds.size layoutOptions:nil layoutTarget:self];
    
    return layoutAttributes;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    return _itemAttrs;
}


+(BOOL)_canLayoutForItem:(id<YZHCollectionCellItemLayoutProtocol>)cellItem
{
    if ([cellItem respondsToSelector:@selector(layoutAttributesBlock)] && cellItem.layoutAttributesBlock) {
        return YES;
    }
    else {
        BOOL sizeOK = ([cellItem respondsToSelector:@selector(sizeBlock)] && cellItem.sizeBlock);
//        BOOL rowSpaceOK = ([cellItem respondsToSelector:@selector(rowSpacingBlock)] && cellItem.rowSpacingBlock);
//        BOOL lineSpaceOK = ([cellItem respondsToSelector:@selector(lineSpacingBlock)] && cellItem.lineSpacingBlock);
        if (sizeOK) {
            return YES;
        }
    }
    return NO;
}


+(CGSize)collectionViewSingleSectionContentSizeForCellItems:(NSArray<id<YZHCollectionCellItemLayoutProtocol>>*)cellItems boundingRectWithSize:(CGSize)boundingRectSize layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions
{
    NSInteger i = 0;
    CGFloat totalWidth = 0;
    CGFloat totalHeight = 0;
    CGFloat maxW = 0;
    CGFloat maxH = 0;
    CGFloat minW = 0;
    CGFloat minH = 0;
    for (id<YZHCollectionCellItemLayoutProtocol> cellItem in cellItems) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i++ inSection:0];
        UICollectionViewLayoutAttributes *layoutAttributes = cellItem.layoutAttribute;
        if ([cellItem respondsToSelector:@selector(layoutAttributesBlock)] && cellItem.layoutAttributesBlock) {
            layoutAttributes = cellItem.layoutAttributesBlock(indexPath,cellItem);
        }
        else {
            if ([[self class] _canLayoutForItem:cellItem]) {
                layoutAttributes = [YZHCollectionViewLayout _layoutAttributesForItem:cellItem atIndexPath:indexPath cellItems:cellItems boundingRectWithSize:boundingRectSize layoutOptions:layoutOptions layoutTarget:nil];
            }
        }
        cellItem.layoutAttribute = layoutAttributes;
        totalWidth = MAX(CGRectGetMaxX(layoutAttributes.frame), totalWidth);
        totalHeight = MAX(CGRectGetMaxY(layoutAttributes.frame), totalHeight);
        maxW = MAX(maxW, CGRectGetWidth(layoutAttributes.frame));
        maxH = MAX(maxH, CGRectGetHeight(layoutAttributes.frame));
        
        minW = MIN(minW, CGRectGetWidth(layoutAttributes.frame));
        minH = MIN(minH, CGRectGetHeight(layoutAttributes.frame));
    }
    UIEdgeInsets insets = [YZHCollectionViewLayout _collectionViewLayout:nil insetsAtIndexPath:nil layoutOptions:layoutOptions];
    totalHeight += insets.bottom;
    totalWidth += insets.right;

    if (boundingRectSize.width == CGFLOAT_MAX && boundingRectSize.height == CGFLOAT_MAX) {
        return CGSizeMake(totalWidth, totalHeight);
    }
    else if (boundingRectSize.width == CGFLOAT_MAX) {
        return CGSizeMake(totalWidth, boundingRectSize.height);
    }
    else if (boundingRectSize.height == CGFLOAT_MAX) {
        return CGSizeMake(boundingRectSize.width, totalHeight);
    }
    return CGSizeMake(totalWidth, totalHeight);
}


+(UICollectionViewLayoutAttributes *)_layoutAttributesForItem:(id)target atIndexPath:(NSIndexPath*)indexPath cellItems:(NSArray<id<YZHCollectionCellItemLayoutProtocol>>*)cellItems boundingRectWithSize:(CGSize)boundingRectSize layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions layoutTarget:(YZHCollectionViewLayout*)layoutTarget
{
    UICollectionViewLayoutAttributes *layoutAttr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGRect frame = CGRectZero;
    //获取item的size
    CGSize itemSize = [YZHCollectionViewLayout _collectionCellItemSizeForItem:target layoutTarget:layoutTarget atIndexPath:indexPath];
    frame.size = itemSize;
    
    //获取inset
    UIEdgeInsets insets = [YZHCollectionViewLayout _collectionViewLayout:layoutTarget insetsAtIndexPath:indexPath layoutOptions:layoutOptions];
    
    //获取minRowSpacing，minLineSpacing
    CGFloat minLineSpacing = [YZHCollectionViewLayout _collectionCellItemLineSpacingForItem:target layoutTarget:layoutTarget atIndexPath:indexPath];
    CGFloat minRowSpacing = [YZHCollectionViewLayout _collectionCellItemRowSpacingForItem:target layoutTarget:layoutTarget atIndexPath:indexPath];
    
    CGSize collectionViewSize = boundingRectSize;
    if (layoutTarget) {
        collectionViewSize = layoutTarget.collectionView.bounds.size;
    }
    
    CGRect lastItemFrame = [YZHCollectionViewLayout _collectionLastItemFrameForLayoutTarget:layoutTarget cellItems:cellItems atIndexPath:indexPath];
    
    //定位x,y
    CGFloat originX = 0;
    CGFloat originY = 0;
    CGFloat remWidth = collectionViewSize.width - insets.left - insets.right;
    if (indexPath.item > 0) {
        remWidth = collectionViewSize.width - CGRectGetMaxX(lastItemFrame) - insets.right;
    }
    
    CGFloat adjustLineSpacing = [YZHCollectionViewLayout _collectionLayoutAdjustLineSpacingForTarget:target layoutTarget:layoutTarget];
    
    CGFloat itemLineSpacing = minLineSpacing;
    if (adjustLineSpacing > 0) {
        itemLineSpacing = adjustLineSpacing;
    }
    
    if (indexPath.item > 0 && remWidth >= itemSize.width + itemLineSpacing) {
        originX = CGRectGetMaxX(lastItemFrame) + itemLineSpacing;
        originY = lastItemFrame.origin.y;
    }
    else
    {
        originX = insets.left;
        originY = insets.top;
        if (indexPath.item > 0) {
            originY = CGRectGetMaxY(lastItemFrame) + minRowSpacing;
        }
        
        NSCellAlignment alignment = [YZHCollectionViewLayout _collectionCellAlignmentForLayoutTarget:layoutTarget layoutOptions:layoutOptions];
        
        if (alignment == NSCellAlignmentCenter || alignment == NSCellAlignmentRight) {
            layoutAttr.frame = CGRectMake(originX, originY, itemSize.width, itemSize.height);
            [YZHCollectionViewLayout _resetCollectionCellItemLayoutAttribute:layoutAttr forTarget:target layoutTarget:layoutTarget];
            
            CGPoint adjustPoint = [YZHCollectionViewLayout _adjustRowFirstItemOrignPointForItem:target atIndexPath:indexPath cellItems:cellItems boundingRectWithSize:boundingRectSize layoutOptions:layoutOptions layoutTarget:layoutTarget alignment:alignment];
            
            originX = adjustPoint.x;
            originY = adjustPoint.y;
        }
    }
    layoutAttr.frame = CGRectMake(originX, originY, itemSize.width, itemSize.height);
    [YZHCollectionViewLayout _resetCollectionCellItemLayoutAttribute:layoutAttr forTarget:target layoutTarget:layoutTarget];
    return layoutAttr;
}

+(CGSize)_collectionCellItemSizeForItem:(id)target layoutTarget:(YZHCollectionViewLayout*)layoutTarget atIndexPath:(NSIndexPath*)indexPath
{
    if ([target conformsToProtocol:@protocol(YZHCollectionCellItemLayoutProtocol)]) {
        id<YZHCollectionCellItemLayoutProtocol> newTarget = target;
        if (newTarget && [newTarget respondsToSelector:@selector(sizeBlock)] && newTarget.sizeBlock) {
            return newTarget.sizeBlock(indexPath, target);
        }
    }
    else if ([layoutTarget.delegate respondsToSelector:@selector(YZHCollectionViewLayout:sizeForItemAtIndexPath:)])
    {
        return [layoutTarget.delegate YZHCollectionViewLayout:layoutTarget sizeForItemAtIndexPath:indexPath];
    }
    return CGSizeZero;
}

+(UIEdgeInsets)_collectionViewLayout:(YZHCollectionViewLayout*)layoutTarget insetsAtIndexPath:(NSIndexPath*)indexPath layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if ([layoutTarget.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        insets = (UIEdgeInsets)[layoutTarget.delegate collectionView:layoutTarget.collectionView layout:layoutTarget insetForSectionAtIndex:indexPath.section];
    }
    else if (IS_AVAILABLE_NSSET_OBJ(layoutOptions))
    {
        insets = [[layoutOptions objectForKey:NSCollectionEdgeInsetsKey] UIEdgeInsetsValue];
    }
    return insets;
}

+(CGFloat)_collectionCellItemLineSpacingForItem:(id)target layoutTarget:(YZHCollectionViewLayout*)layoutTarget atIndexPath:(NSIndexPath*)indexPath
{
    if ([target conformsToProtocol:@protocol(YZHCollectionCellItemLayoutProtocol)]) {
        id<YZHCollectionCellItemLayoutProtocol> newTarget = target;
        if (newTarget && [newTarget respondsToSelector:@selector(lineSpacingBlock)] && newTarget.lineSpacingBlock) {
            return newTarget.lineSpacingBlock(indexPath, target);
        }
    }
    else if (([layoutTarget.delegate respondsToSelector:@selector(YZHCollectionViewLayout:minLineSpacingForItemAtIndexPath:)]))
    {
        return [layoutTarget.delegate YZHCollectionViewLayout:layoutTarget minLineSpacingForItemAtIndexPath:indexPath];
    }
    return 0;
}

+(CGFloat)_collectionCellItemRowSpacingForItem:(id)target layoutTarget:(YZHCollectionViewLayout*)layoutTarget atIndexPath:(NSIndexPath*)indexPath
{
    if ([target conformsToProtocol:@protocol(YZHCollectionCellItemLayoutProtocol)]) {
        id<YZHCollectionCellItemLayoutProtocol> newTarget = target;
        if (newTarget && [newTarget respondsToSelector:@selector(rowSpacingBlock)] && newTarget.rowSpacingBlock) {
            return newTarget.rowSpacingBlock(indexPath, target);
        }
    }
    else if (([layoutTarget.delegate respondsToSelector:@selector(YZHCollectionViewLayout:minRowSpacingForItemAtIndexPath:)]))
    {
        return [layoutTarget.delegate YZHCollectionViewLayout:layoutTarget minRowSpacingForItemAtIndexPath:indexPath];
    }
    return 0;
}

+(CGRect)_collectionLastItemFrameForLayoutTarget:(YZHCollectionViewLayout*)layoutTarget cellItems:(NSArray<id<YZHCollectionCellItemLayoutProtocol>>*)cellItems atIndexPath:(NSIndexPath*)indexPath
{
    if (layoutTarget) {
        return layoutTarget.lastItemFrame;
    }
    else
    {
        if (indexPath.item > 0) {
            NSInteger lastIndex = indexPath.item - 1;
            id<YZHCollectionCellItemLayoutProtocol> cellItem = [cellItems objectAtIndex:lastIndex];
            if ([cellItem respondsToSelector:@selector(layoutAttribute)]) {
                return cellItem.layoutAttribute.frame;
            }
        }
    }
    return CGRectZero;
}

+(CGRect)_collectionItemFrameForTarget:(id)target layoutTarget:(YZHCollectionViewLayout*)layoutTarget
{
    if ([target conformsToProtocol:@protocol(YZHCollectionCellItemLayoutProtocol)]) {
        id<YZHCollectionCellItemLayoutProtocol> newTarget = target;
        if ([newTarget respondsToSelector:@selector(layoutAttribute)]) {
            return newTarget.layoutAttribute.frame;
        }
    }
    else
    {
        return layoutTarget.lastItemFrame;
    }
    return CGRectZero;
}

+(void)_resetCollectionCellItemLayoutAttribute:(UICollectionViewLayoutAttributes*)layoutAttribute forTarget:(id)target layoutTarget:(YZHCollectionViewLayout*)layoutTarget
{
    if ([target conformsToProtocol:@protocol(YZHCollectionCellItemLayoutProtocol)]) {
        id<YZHCollectionCellItemLayoutProtocol> newTarget = target;
        if ([newTarget respondsToSelector:@selector(layoutAttribute)]) {
            newTarget.layoutAttribute = layoutAttribute;
        }
    }
    else
    {
        layoutTarget.lastItemFrame = layoutAttribute.frame;
    }
}

+(CGFloat)_collectionLayoutAdjustLineSpacingForTarget:(id)target layoutTarget:(YZHCollectionViewLayout*)layoutTarget
{
    if ([target conformsToProtocol:@protocol(YZHCollectionCellItemLayoutProtocol)]) {
        id<YZHCollectionCellItemLayoutProtocol> newTarget = target;
        if ([newTarget respondsToSelector:@selector(layoutAdjustLineSpacing)]) {
            return newTarget.layoutAdjustLineSpacing;
        }
    }
    else
    {
        return layoutTarget.lastAdjustLineSpacing;
    }
    return -1;
}

+(void)_resetCollectionLayoutAdjustLineSpacing:(CGFloat)adjustLineSpace forTarget:(id)target layoutTarget:(YZHCollectionViewLayout*)layoutTarget
{
    if ([target conformsToProtocol:@protocol(YZHCollectionCellItemLayoutProtocol)]) {
        id<YZHCollectionCellItemLayoutProtocol> newTarget = target;
        if ([newTarget respondsToSelector:@selector(layoutAdjustLineSpacing)]) {
            newTarget.layoutAdjustLineSpacing = adjustLineSpace;
        }
    }
    else
    {
        layoutTarget.lastAdjustLineSpacing = adjustLineSpace;
    }
}

+(NSCellAlignment)_collectionCellAlignmentForLayoutTarget:(YZHCollectionViewLayout*)layoutTarget layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions
{
    if (layoutTarget) {
        return layoutTarget.cellAlignment;
    }
    else if (IS_AVAILABLE_NSSET_OBJ(layoutOptions))
    {
        return [[layoutOptions objectForKey:NSCellAlignmentKey] integerValue];
    }
    return NSCellAlignmentLeft;
}

+(CGPoint)_adjustRowFirstItemOrignPointForItem:(id)target atIndexPath:(NSIndexPath*)indexPath cellItems:(NSArray<id<YZHCollectionCellItemLayoutProtocol>>*)cellItems boundingRectWithSize:(CGSize)boundingRectSize layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions layoutTarget:(YZHCollectionViewLayout*)layoutTarget alignment:(NSCellAlignment)alignment
{
    NSInteger index = indexPath.item;
    NSInteger itemCount = 1;
    CGRect lastFrame = [YZHCollectionViewLayout _collectionItemFrameForTarget:target layoutTarget:layoutTarget];
    CGFloat totalContentWidth = lastFrame.size.width;
    CGFloat totalLineSpacing = 0;
    
    UIEdgeInsets insets = [YZHCollectionViewLayout _collectionViewLayout:layoutTarget insetsAtIndexPath:indexPath layoutOptions:layoutOptions];
    
    CGSize collectionViewSize = boundingRectSize;
    NSInteger itemCnt = cellItems.count;
    if (layoutTarget) {
        collectionViewSize = layoutTarget.collectionView.bounds.size;
        itemCnt = [layoutTarget.collectionView numberOfItemsInSection:indexPath.section];
    }
    
    while (YES) {
        ++index;
        if (index >= itemCnt) {
            break;
        }
        
        id<YZHCollectionCellItemLayoutProtocol> nextTarget = cellItems[index];
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:index inSection:indexPath.section];
        
        CGRect frame = CGRectZero;
        CGSize itemSize = [YZHCollectionViewLayout _collectionCellItemSizeForItem:nextTarget layoutTarget:layoutTarget atIndexPath:nextIndexPath];
        frame.size = itemSize;
        
        CGFloat minLineSpacing = [YZHCollectionViewLayout _collectionCellItemLineSpacingForItem:nextTarget layoutTarget:layoutTarget atIndexPath:nextIndexPath];
        
        CGFloat remWidth = collectionViewSize.width - CGRectGetMaxX(lastFrame) - minLineSpacing - insets.right;
        
        if (remWidth < itemSize.width) {
            break;
        }
        lastFrame = CGRectMake(CGRectGetMaxX(lastFrame) + minLineSpacing, lastFrame.origin.y, itemSize.width, itemSize.height);
        
        totalContentWidth += itemSize.width;
        ++itemCount;
        totalLineSpacing += minLineSpacing;
    }
    
    CGFloat x = lastFrame.origin.x;
    if (alignment == NSCellAlignmentCenter) {
        x = (collectionViewSize.width - totalLineSpacing - totalContentWidth)/2;
        [YZHCollectionViewLayout _resetCollectionLayoutAdjustLineSpacing:x forTarget:target layoutTarget:layoutTarget];
    }
    else if (alignment == NSCellAlignmentRight)
    {
        x = collectionViewSize.width - insets.right - totalContentWidth - totalLineSpacing;
    }
    return CGPointMake(x, lastFrame.origin.y);
}
@end
