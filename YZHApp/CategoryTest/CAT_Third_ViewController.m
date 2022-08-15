//
//  CAT_Third_ViewController.m
//  YZHApp
//
//  Created by bytedance on 2021/11/25.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "CAT_Third_ViewController.h"
#import "UIViewController+YZHNavigation.h"

@interface UIShapeView : UIView

@property (nonatomic, strong) UIBezierPath *path;

@end

@implementation UIShapeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [super setBackgroundColor:CLEAR_COLOR];
    }
    return self;
}

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (void)setPath:(UIBezierPath *)path {
    _path = path;
    ((CAShapeLayer*)self.layer).path = path.CGPath;
    ((CAShapeLayer*)self.layer).strokeColor = [UIColor purpleColor].CGColor;
    ((CAShapeLayer*)self.layer).lineWidth = 10;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
//    [super setBackgroundColor:[UIColor orangeColor]];
    ((CAShapeLayer*)self.layer).fillColor = CLEAR_COLOR.CGColor;//backgroundColor.CGColor;
}

@end

@interface CAT_Third_ViewController ()

@property (nonatomic, strong) UIShapeView *shapeView;

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, strong) UIButton *btn;

@property (nonatomic, strong) UIButton *btn2;

@end

@implementation CAT_Third_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self pri_setupNavgationBar];
    
    [self pri_setupSubviews];
}

- (void)pri_setupNavgationBar {
    if (!self.level) {
        UIButton *btn = nil;
        self.hz_navigationBarViewBackgroundColor = [UIColor redColor];
//        btn = [self hz_addNavigationLeftItemWithImage:nil title:@"left" isReset:YES actionBlock:nil];
//        
//        [btn setTitle:@"首页Left" forState:UIControlStateNormal];
//        self.btn = btn;
//        
//        self.btn2 = [self hz_addNavigationLeftItemWithImage:nil title:@"Left-2" isReset:NO actionBlock:nil];
//        
//        
//        btn = [[self hz_addNavigationRightItemsWithTitles:@[@"right"] isReset:YES actionBlock:nil] firstObject];
//        [btn setTitle:@"首页RightItem" forState:UIControlStateNormal];
        
        
//        [self hz_setupItemsSpace:20 left:YES];
//        [self hz_setupItemsSpace:20 left:NO];
//        [self hz_setupItemEdgeSpace:30 left:YES];
//        [self hz_setupItemEdgeSpace:30 left:NO];
        
        [self hz_addNavigationLeftItemWithImage:nil title:@"L" isReset:YES actionBlock:nil];
        [self hz_addNavigationRightItemsWithTitles:@[@"R"] isReset:YES actionBlock:nil];

        [self hz_addNavigationLeftItemsWithTitles:@[@"L-1",@"L-2",] isReset:YES actionBlock:^(UIViewController *viewController, UIView *itemView) {
            NSLog(@"left.btn=%ld",itemView.tag);
        }];
        [self hz_addNavigationRightItemsWithTitles:@[@"R-1",@"R-2"] isReset:NO actionBlock:^(UIViewController *viewController, UIView *itemView) {
            NSLog(@"right.btn=%ld",itemView.tag);
        }];
        return;
    }
    
    self.hz_navigationBarViewBackgroundColor = [UIColor purpleColor];

    [self hz_addNavigationFirstLeftBackItemWithTitle:@"返回" actionBlock:^(UIViewController *viewController, UIView *itemView) {
        [viewController.navigationController popViewControllerAnimated:YES];
    }];
    
    YZHNavigationController *nav = (YZHNavigationController*)self.navigationController;
    self.hz_navigationTitle = [NSString stringWithFormat:@"%ld-level-%ld",nav.hz_navigationBarAndItemStyle,self.level];
}

- (UIShapeView *)shapeView {
    if (!_shapeView) {
        _shapeView = [[UIShapeView alloc] initWithFrame:CGRectMake(25, 100, self.view.hz_width - 50, 500)];
    }
    return _shapeView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if (self.level == 0) {
//        [self pri_enter];
//    }
    [self pri_testShapeView];
}

- (void)pri_enter {
    CAT_Third_ViewController *vc = [[self class] new];
    vc.level = self.level + 1;
    vc.hz_navigationEnable = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pri_setupSubviews {
    [self.view addSubview:self.shapeView];
    self.shapeView.backgroundColor = RED_COLOR;
}

- (void)pri_testShapeView {
    
    NSMutableDictionary *dict = @{@"1":@"1"}.mutableCopy;
    [dict addEntriesFromDictionary:@{@"1":@"2"}];
    NSLog(@"dict=%@",dict);
    
    CGFloat tl = arc4random() % 11;
    CGFloat tr = arc4random() % 23;
    CGFloat bl = arc4random() % 31;
    CGFloat br = arc4random() % 41;
    self.shapeView.path = [UIBezierPath hz_bezierPathWithRoundedRect:self.shapeView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadiusList:@[@(tl),@(tr),@(bl),@(br)]];
    
//    self.shapeView.hz_size = self.shapeView.bounds.size;
    self.shapeView.frame = CGRectMake(20, 200, self.view.hz_width - 40, 600);
    self.shapeView.backgroundColor = [UIColor yellowColor];
}

@end
