//
//  UITraitCollectionView.m
//  LZGameBox
//
//  Created by yuan on 2020/3/23.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "UITraitCollectionView.h"

@interface UITraitCollectionView ()

/** <#注释#> */
@property (nonatomic, strong) NSMutableDictionary<id,YZHTraitCollectionValueChangedBlock> *blockInfo;
@end

@implementation UITraitCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
    }
    return self;
}

- (NSMutableDictionary<id,YZHTraitCollectionValueChangedBlock>*)blockInfo
{
    if (_blockInfo == nil) {
        _blockInfo = [NSMutableDictionary dictionary];
    }
    return _blockInfo;
}

- (void)addTraitCollectionValueChangedBlock:(YZHTraitCollectionValueChangedBlock)block forKey:(id<NSCopying>)key
{
    if (block && key) {
        [self.blockInfo setObject:block forKey:key];
    }
}

- (void)removeTraitCollectionValueChangeBlockForKey:(id<NSCopying>)key
{
    if (key) {
        [self.blockInfo removeObjectForKey:key];
    }
}

- (BOOL)existsValueChangedBlockForKey:(id<NSCopying>)key
{
    return [self.blockInfo objectForKey:key] != nil;
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            
            [self.blockInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YZHTraitCollectionValueChangedBlock  _Nonnull obj, BOOL * _Nonnull stop) {
                obj(self, key);
            }];
        }
    }
    NSLog(@"========%s========",__FUNCTION__);
}

@end
