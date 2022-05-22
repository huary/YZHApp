//
//  YZHNavigationConfig.m
//  YZHNavigationKit
//
//  Created by bytedance on 2022/4/7.
//

#import "YZHNavigationConfig+Internal.h"

@implementation YZHNavigationConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.itemMinWidth = 40;
        self.itemImageHRatio = 0.4;
        self.itemWWithItemHRatio = 0.8;
        self.leftBackItemHRatio = 0.55;
        self.leftBackItemMinWidth = 15;
        self.leftBackItemNormalWidth = 40;
        self.leftBackStrokeWidth = 2.5;
        
//        self.navigationDefaultEdgeSpace = 2;//12;
        self.navigationLeftEdgeSpace = 16;
        self.navigationRightEdgeSpace = 16;
        self.navigationLeftItemsSpace = 8;
        self.navigationRightItemsSpace = 8;
        
        self.leftButtonHAlignment = UIControlContentHorizontalAlignmentLeft;
        self.rightButtonHAlignment = UIControlContentHorizontalAlignmentRight;
        
        self.fixItemHToLayoutH = YES;

        self.navigationTitleFontBlock = ^UIFont * _Nullable(YZHNavigationConfig * _Nonnull config) {
            return [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
        };
        self.navigationTitleWidthBlock = ^CGFloat(YZHNavigationConfig * _Nonnull config, UIView *itemView) {
            CGFloat sw = itemView.hz_viewController.view.hz_width;
            if (sw < 1) {
                sw = [UIScreen mainScreen].bounds.size.width;
            }
            return sw - 96;
        };
        self.leftBackImageBlock = ^UIImage * _Nullable(YZHNavigationConfig * _Nonnull config) {
            return nil;
        };
    }
    return self;
}

- (UIFont *)navigationTitleFont {
    if (!_navigationTitleFont) {
        if (self.navigationTitleFontBlock) {
            _navigationTitleFont = self.navigationTitleFontBlock(self);
        }
        else {
            _navigationTitleFont = [UIFont fontWithName:@"Helvetica-Bold" size:17.0];
        }
    }
    return _navigationTitleFont;
}

- (UIImage *)leftBackImage {
    if (!_leftBackImage) {
        _leftBackImage = self.leftBackImageBlock(self);
    }
    return _leftBackImage;
}

@end
