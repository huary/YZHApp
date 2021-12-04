//
//  YZHExcelViewRowCollectionViewLayout.m
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHExcelViewRowCollectionViewLayout.h"

@interface YZHExcelViewRowCollectionViewLayout ()

@property (nonatomic, assign) CGFloat lastX;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes*> *layoutAttributes;

@end

@implementation YZHExcelViewRowCollectionViewLayout

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setUpLayoutDefaultValue];
    }
    return self;
}

-(void)_setUpLayoutDefaultValue
{
    self.lastX = 0;
    [self.layoutAttributes removeAllObjects];
}

-(NSMutableArray<UICollectionViewLayoutAttributes*>*)layoutAttributes
{
    if (_layoutAttributes == nil) {
        _layoutAttributes = [NSMutableArray array];
    }
    return _layoutAttributes;
}

#pragma override
-(void)prepareLayout
{
    [super prepareLayout];
    [self _setUpLayoutDefaultValue];
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [self.layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
}

-(CGSize)collectionViewContentSize
{
    CGSize size = CGSizeMake(self.lastX, self.itemHeight);
    return size;
}

-(UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *layoutAttr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];

    CGRect frame =CGRectMake(self.lastX, 0, itemSize.width, itemSize.height);
    self.lastX += itemSize.width;
    layoutAttr.frame = frame;
    return layoutAttr;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.layoutAttributes;
}

@end
