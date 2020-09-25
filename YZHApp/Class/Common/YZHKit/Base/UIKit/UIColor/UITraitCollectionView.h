//
//  UITraitCollectionView.h
//  LZGameBox
//
//  Created by yuan on 2020/3/23.
//  Copyright © 2020 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class UITraitCollectionView;
typedef void(^YZHTraitCollectionValueChangedBlock)(UITraitCollectionView *view, id<NSCopying> key);

@interface UITraitCollectionView : UIView

- (void)addTraitCollectionValueChangedBlock:(YZHTraitCollectionValueChangedBlock)block forKey:(id<NSCopying>)key;

- (void)removeTraitCollectionValueChangeBlockForKey:(id<NSCopying>)key;

- (BOOL)existsValueChangedBlockForKey:(id<NSCopying>)key;

@end

NS_ASSUME_NONNULL_END
