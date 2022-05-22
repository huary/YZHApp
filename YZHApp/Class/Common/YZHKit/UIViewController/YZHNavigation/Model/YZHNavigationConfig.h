//
//  YZHNavigationConfig.h
//  YZHNavigationKit
//
//  Created by bytedance on 2022/4/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YZHNavigationConfig;
typedef CGFloat (^YZHNavigationTitleWidthBlock)(YZHNavigationConfig *config, UIView *itemView);
typedef UIFont *_Nullable(^YZHNavigationFontBlock)(YZHNavigationConfig *config);
typedef UIImage *_Nullable(^YZHNavigationImageBlock)(YZHNavigationConfig *config);

@interface YZHNavigationConfig : NSObject

//item的最小宽度，默认为40
@property (nonatomic, assign) CGFloat itemMinWidth;

//item的image高度与ItemViewLayout的高度比例，默认0.4
@property (nonatomic, assign) CGFloat itemImageHRatio;

//12,系统为12基值，此SDK默认为2
//@property (nonatomic, assign) CGFloat navigationDefaultEdgeSpace;

//16
@property (nonatomic, assign) CGFloat navigationLeftEdgeSpace;

//16
@property (nonatomic, assign) CGFloat navigationRightEdgeSpace;

//8
@property (nonatomic, assign) CGFloat navigationLeftItemsSpace;

//8
@property (nonatomic, assign) CGFloat navigationRightItemsSpace;

//默认left
@property (nonatomic, assign) UIControlContentHorizontalAlignment leftButtonHAlignment;

//默认right
@property (nonatomic, assign) UIControlContentHorizontalAlignment rightButtonHAlignment;

//底层通过CoreGraphics生成的返回箭头是一个等边直角三角形
//返回“<” item的高度与ItemViewLayout的高度比例，默认0.55
@property (nonatomic, assign) CGFloat leftBackItemHRatio;

//默认为15，在返回按钮没有标题时用此值
@property (nonatomic, assign) CGFloat leftBackItemMinWidth;

//默认为40，在返回按钮有标题时用此值
@property (nonatomic, assign) CGFloat leftBackItemNormalWidth;

//2.5, 返回按钮图像的笔宽
@property (nonatomic, assign) CGFloat leftBackStrokeWidth;

//是否修正item的高度和itemView的布局高度一致，默认为YES
@property (nonatomic, assign) BOOL fixItemHToLayoutH;

//设置导航栏的最宽宽度
//@property (nonatomic, assign) CGFloat navigationTitleMaxWidth;

//默认为[UIFont fontWithName:@"Helvetica-Bold" size:17.0]
@property (nonatomic, copy) YZHNavigationFontBlock navigationTitleFontBlock;

//默认
@property (nonatomic, copy) YZHNavigationTitleWidthBlock navigationTitleWidthBlock;

//默认为nil
@property (nonatomic, copy) YZHNavigationImageBlock leftBackImageBlock;

- (UIFont *)navigationTitleFont;

- (UIImage *)leftBackImage;
@end

NS_ASSUME_NONNULL_END
