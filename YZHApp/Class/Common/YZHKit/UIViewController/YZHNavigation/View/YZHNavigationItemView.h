//
//  YZHNavigationItemView.h
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSAttributedStringKey const YZHTitleAttributesTextName;

@interface YZHNavigationItemView : UIView

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) CGAffineTransform t;

//默认为8
@property (nonatomic, assign) CGFloat leftItemsSpace;

//默认为8
@property (nonatomic, assign) CGFloat rightItemsSpace;

//默认为20
@property (nonatomic, assign) CGFloat leftEdgeSpace;

//默认为20
@property (nonatomic, assign) CGFloat rightEdgeSpace;


@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *titleTextAttributes;

-(void)setLeftButtonItems:(NSArray*)leftButtonItems isReset:(BOOL)reset;
-(void)setRightButtonItems:(NSArray *)rightButtonItems isReset:(BOOL)reset;
@end
