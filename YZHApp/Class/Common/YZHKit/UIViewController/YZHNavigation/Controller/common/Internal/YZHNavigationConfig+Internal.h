//
//  YZHNavigationConfig+Internal.h
//  YZHNavigationKit
//
//  Created by bytedance on 2022/4/7.
//

#import "YZHNavigationConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZHNavigationConfig ()

//0.8
@property (nonatomic, assign) CGFloat itemWWithItemHRatio;

//默认为[UIFont fontWithName:@"Helvetica-Bold" size:17.0]
@property (nonatomic, strong) UIFont *navigationTitleFont;

//默认为nil
@property (nonatomic, strong) UIImage *leftBackImage;

@end

NS_ASSUME_NONNULL_END
