//
//  UITabBarItem+UIButton.h
//  YZHApp
//
//  Created by yuan on 2018/3/2.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,NSBadgeType)
{
    //直接hidden
    NSBadgeTypeNULL     = -1,
    //会根据需要显示的badgeValue判断是否显示(IS_AVAILABLE_NSSTRNG(realShowValue))
    NSBadgeTypeDefault  = 0,
    //直接展示小圆圈
    NSBadgeTypeDot      = 1,
};

typedef NS_ENUM(NSInteger,NSButtonImageTitleStyle)
{
    NSButtonImageTitleStyleVertical      = 0,
    NSButtonImageTitleStyleHorizontal    = 1,
};

struct CGRange {
    CGFloat offset;
    CGFloat length;
};
typedef struct CG_BOXABLE CGRange CGRange;

CG_INLINE CGRange
CGRangeMake(CGFloat offset, CGFloat length)
{
    CGRange R; R.offset = offset; R.length = length; return R;
}

CG_INLINE bool
CGRangeEqualToRange(CGRange r1, CGRange r2)
{
    return r1.offset == r2.offset && r1.length == r2.length;
}

CG_INLINE bool
CGRangeEqualToZero(CGRange r)
{
    return r.offset <= CGFLOAT_MIN && r.length <= CGFLOAT_MIN;
}


typedef NSString*(^UITabBarItemBadgeBlock)(UIButton *badgeButton, NSString *badgeValue, NSBadgeType *badgeType);

@interface UITabBarItem (UIButton)

@property (nonatomic, assign) NSButtonImageTitleStyle hz_buttonStyle;

//这个一般不用设置的。
@property (nonatomic, assign) CGPoint hz_buttonItemOrigin;

@property (nonatomic, assign) CGSize hz_buttonItemSize;

@property (nonatomic, assign) CGRange hz_imageRange;
@property (nonatomic, assign) CGRange hz_titleRange;

@property (nonatomic, strong) UIColor *hz_normalBackgroundColor;
@property (nonatomic, strong) UIColor *hz_selectedBackgroundColor;
@property (nonatomic, strong) UIColor *hz_highlightedBackgroundColor;

/** 10.0以前设置badge的color */
@property (nonatomic, strong) UIColor *hz_badgeBackgroundColor;

@property (nonatomic, copy) NSDictionary<NSNumber *,NSDictionary<NSString *,id>*> *hz_badgeStateTextAttributes;

@property (nonatomic, copy) UITabBarItemBadgeBlock hz_badgeValueUpdateBlock;

@end
