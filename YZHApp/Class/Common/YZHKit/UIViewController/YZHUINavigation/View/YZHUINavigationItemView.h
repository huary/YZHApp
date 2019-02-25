//
//  YZHUINavigationItemView.h
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSAttributedStringKey const NSTitleAttributesTextName;

@interface YZHUINavigationItemView : UIView

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) CGAffineTransform t;

@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes;

-(void)setLeftButtonItems:(NSArray*)leftButtonItems isReset:(BOOL)reset;
-(void)setRightButtonItems:(NSArray *)rightButtonItems isReset:(BOOL)reset;
@end
