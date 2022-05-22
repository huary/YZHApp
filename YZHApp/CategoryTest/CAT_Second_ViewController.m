//
//  CAT_Second_ViewController.m
//  YZHApp
//
//  Created by bytedance on 2021/11/25.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "CAT_Second_ViewController.h"
#import "UIViewController+YZHNavigation.h"

@interface UITestView : UIView

@property (nonatomic, strong) dispatch_block_t block;

@end

@implementation UITestView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.block();
    NSLog(@"%s",__FUNCTION__);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    NSLog(@"%s",__FUNCTION__);
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"%s",__FUNCTION__);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"%s",__FUNCTION__);
}


@end

@interface CAT_Second_ViewController ()

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UITestView *testView;

@end

@implementation CAT_Second_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 120, self.view.hz_width - 50, 500)];
//    self.imageView.contentMode = UIViewContentModeCenter;
//    self.imageView.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:self.imageView];
    [self pri_setupNavgationBar];
    
    [self pri_setupSubviews];
    
}

- (UITestView *)testView {
    if (!_testView) {
        _testView = [[UITestView alloc] initWithFrame:CGRectMake(25, 100, self.view.hz_width - 50, 500)];
        _testView.backgroundColor = [UIColor purpleColor];
        
        __block BOOL shouldLongPress = YES;
        [_testView hz_addLongPressGestureRecognizerBlock:^(UIGestureRecognizer *gesture) {
            NSLog(@"long press");
        } shouldBeginBlock:^BOOL(UIGestureRecognizer *gesture) {
            return shouldLongPress;
        }];
        _testView.block = ^{
            shouldLongPress = NO;
        };
    }
    return _testView;
}

- (void)pri_setupNavgationBar {
    UIButton *btn = nil;
    if (!self.level) {
        self.hz_navigationBarViewBackgroundColor = [UIColor redColor];
        btn = [self hz_addNavigationLeftItemWithImage:nil title:@"left" isReset:YES actionBlock:nil];
        
        [btn setTitle:@"hello world" forState:UIControlStateNormal];
        
        [self hz_addNavigationRightItemsWithTitles:@[@"right"] isReset:YES actionBlock:nil];
        return;
    }
    
    self.hz_navigationBarViewBackgroundColor = [UIColor purpleColor];

    
    [self hz_addNavigationFirstLeftBackItemWithTitle:@"返回" actionBlock:^(UIViewController *viewController, UIView *itemView) {
        [viewController.navigationController popViewControllerAnimated:YES];
    }];
    
    YZHNavigationController *nav = (YZHNavigationController*)self.navigationController;
    self.hz_navigationTitle = [NSString stringWithFormat:@"%ld-level-%ld",nav.hz_navigationBarAndItemStyle,self.level];
}

- (void)pri_setupSubviews {
    [self.view addSubview:self.testView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if (self.level == 0) {
//        [self pri_enter];
//    }
    
    [self pri_testGraph];
}

- (void)pri_enter {
    CAT_Second_ViewController *vc = [[self class] new];
    vc.level = self.level + 1;
    vc.hz_navigationEnable = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

/// <#Description#>
- (void)pri_testGraph {
    YZHGraphicsContext *ctx = [[YZHGraphicsContext alloc] initWithBeginBlock:^(YZHGraphicsContext *context) {
        context.beginInfo = [[YZHGraphicsBeginInfo alloc] init];
        context.beginInfo.lineWidth = 1.0;
        context.beginInfo.graphicsSize = CGSizeMake(300, 300);
    } runBlock:^(YZHGraphicsContext *context) {
//        if (backgroundColor) {
//            CGContextSetFillColorWithColor(context.ctx, backgroundColor.CGColor);
//            CGContextFillRect(context.ctx, CGRectMake(0, 0, size.width, size.height));
//        }
        
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        [path moveToPoint:CGPointMake(size.width/2, 0)];
//        [path addLineToPoint:CGPointMake(size.width/2, size.height)];
//
//        [path moveToPoint:CGPointMake(0, size.height/2)];
//        [path addLineToPoint:CGPointMake(size.width, size.height/2)];
//
//        [path applyTransform:transform];
//
//        CGContextAddPath(context.ctx, path.CGPath);
//        CGContextDrawPath(context.ctx, kCGPathStroke);
        CGRect rect = CGRectMake(0, 0, 300, 300);
#if 0
//        CGContextSetFillColorWithColor(context.ctx, [UIColor redColor].CGColor);
//        CGContextFillRect(context.ctx, rect);
        [RED_COLOR setFill];

        
        UIBezierPath *path = [UIBezierPath hz_bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadiusList:@[@(10),@(20),@(20),@(20)]];
        CGContextAddPath(context.ctx, path.CGPath);
        CGContextDrawPath(context.ctx, kCGPathFill);
        
        CGContextSetFillColorWithColor(context.ctx, [UIColor purpleColor].CGColor);
        UIBezierPath *tmp = [UIBezierPath hz_bezierPathWithRoundedRect:CGRectMake(0, 0, 300, 120) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadiusList:@[@(10),@(20),@(0),@(0)]];
        CGContextAddPath(context.ctx, tmp.CGPath);
        CGContextDrawPath(context.ctx, kCGPathFill);
#endif
        
        
//        CGContextAddPath(context.ctx, path.CGPath);

        
        UIBezierPath *borderPath = [UIBezierPath hz_borderBezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadiusList:@[@(10),@(1),@(10),@(10)] borderWidth:1.0];
        [borderPath closePath];
        CGContextAddPath(context.ctx, borderPath.CGPath);

        
    } endPathBlock:nil];
    UIImage *image = [ctx createGraphicesImageWithStrokeColor:RED_COLOR];
    
    self.imageView.image = image;
    self.imageView.layer.cornerRadius = 1.0;
    self.imageView.layer.borderWidth = 1.0;
    self.imageView.layer.borderColor = RED_COLOR.CGColor;
}

- (void)pri_setupLongPress {
    [self.view hz_addLongPressGestureRecognizerBlock:^(UIGestureRecognizer *gesture) {
       NSLog(@"long presee")
    }];
}

@end
