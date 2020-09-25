//
//  YZHUINavigationController.m
//  YZHUINavigationController
//
//  Created by yuan on 16/11/17.
//  Copyright (c) 2016年 yzh. All rights reserved.
//

#import "YZHUINavigationController.h"
#import "YZHUINavigationItemView.h"
#import "YZHBaseAnimatedTransition.h"
#import "YZHTimer.h"
#import "YZHKitType.h"
#import "UIImage+YZHAdd.h"
#import "NSMapTable+YZHAdd.h"

#import <objc/runtime.h>

#define MIN_PERCENT_PUSH_VIEWCONTROLLER     (0.15)
#define MIN_PERCENT_POP_VIEWCONTROLLER      (0.2)

NSNotificationName const YZHUINavigationBarAttributeChangNotification = TYPE_STR(YZHUINavigationBarAttributeChangNotification);

NSString * const YZHUINavigationBarBoundsKey = TYPE_STR(YZHUINavigationBarBoundsKey);
NSString * const YZHUINavigationBarCenterPointKey = TYPE_STR(YZHUINavigationBarCenterPointKey);


typedef void(^YZHUINavigationControllerActionCompletionBlock)(YZHUINavigationController *navigationController);


@interface UIViewController (YZHUINavigationControllerAction)

@property (nonatomic, copy) YZHUINavigationControllerActionCompletionBlock popCompletionBlock;
@property (nonatomic, copy) YZHUINavigationControllerActionCompletionBlock pushCompletionBlock;

@end

@implementation UIViewController (YZHUINavigationControllerAction)

-(void)setPopCompletionBlock:(YZHUINavigationControllerActionCompletionBlock)popCompletionBlock
{
    objc_setAssociatedObject(self, @selector(popCompletionBlock), popCompletionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHUINavigationControllerActionCompletionBlock)popCompletionBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setPushCompletionBlock:(YZHUINavigationControllerActionCompletionBlock)pushCompletionBlock
{
    objc_setAssociatedObject(self, @selector(pushCompletionBlock), pushCompletionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(YZHUINavigationControllerActionCompletionBlock)pushCompletionBlock
{
    return objc_getAssociatedObject(self, _cmd);
}

@end


@interface YZHUINavigationController () <UIGestureRecognizerDelegate,UINavigationControllerDelegate>

//创建新的navigationBarView
@property (nonatomic, strong) YZHUINavigationBarView *navigationBarView;

//创建新的NavigationItem，此Item为rootItem，以后每个ViewController上的Item都是以此为根节点
@property (nonatomic, strong) YZHUINavigationItemView *navigationItemRootContentView;

//ViewController上面NavigationItem对应表
@property (nonatomic, strong) NSMapTable *navigationItemViewWithVCMapTable;

//创建百分比驱动动画对象
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *transition;

//是否处在手势交互的状态
@property (nonatomic, assign) BOOL isInteractive;

//push的手势
@property (nonatomic, strong) UIPanGestureRecognizer *pushPan;

//pop的收拾
@property (nonatomic, strong) UIPanGestureRecognizer *popPan;

@property (nonatomic, strong) UIViewController *lastTopVC;

@property (nonatomic, assign) NSTimeInterval latestTransitionDuration;

@property (nonatomic, strong) YZHTimer *updateTransitionTimer;

@end

@implementation YZHUINavigationController


-(instancetype)init
{
    if (self = [super init]) {
        [self _setupDefaultValue];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self _setupDefaultValue];
    }
    return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self _setupDefaultValue];
    }
    return self;
}

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super initWithRootViewController:rootViewController]) {
        [self _setupDefaultValue];
    }
    return self;
}

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController navigationControllerBarAndItemStyle:(UINavigationControllerBarAndItemStyle)barAndItemStyle
{
    _navigationControllerBarAndItemStyle = barAndItemStyle;
    if (self = [super initWithRootViewController:rootViewController]) {
        [self _setupDefaultValue];
    }
    return self;
}

-(void)_setupDefaultValue
{
    self.popGestureEnabled = YES;
    self.transitionDuration = 0.25;
    self.hidesTabBarAfterPushed = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.navigationControllerBarAndItemStyle == UINavigationControllerBarAndItemDefaultStyle)
    {
//        [self _printView:self.navigationBar withIndex:0];
    }
    else if (self.navigationControllerBarAndItemStyle == UINavigationControllerBarAndItemGlobalBarWithDefaultItemStyle)
    {
        [self _clearOldUINavigationBarView];
        [self _createNavigationBarView:NO];
    }
    else if (self.navigationControllerBarAndItemStyle == UINavigationControllerBarAndItemGlobalBarItemStyle)
    {
        [self _clearOldUINavigationBarView];
        [self _createNavigationItemRootContentView];
    }
    else if (self.navigationControllerBarAndItemStyle == UINavigationControllerBarAndItemViewControllerBarItemStyle)
    {
        self.navigationBar.hidden = YES;
    }
    else if (self.navigationControllerBarAndItemStyle == UINavigationControllerBarAndItemViewControllerBarWithDefaultItemStyle)
    {
        [self _clearOldUINavigationBarView];
    }
    
    [self _createPanGestureAction];
    
    [self _addObserverNavigationBar:YES];
}

-(void)_addObserverNavigationBar:(BOOL)add
{
    if (add) {
        [self.navigationBar addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.navigationBar addObserver:self forKeyPath:@"transform" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.navigationBar addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.navigationBar addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
    }
    else {
        [self.navigationBar removeObserver:self forKeyPath:@"frame"];
        [self.navigationBar removeObserver:self forKeyPath:@"transform"];
        [self.navigationBar removeObserver:self forKeyPath:@"center"];
        [self.navigationBar removeObserver:self forKeyPath:@"bounds"];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
//    NSLog(@"keyPath=%@,change=%@",keyPath,change);
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if ([keyPath isEqualToString:@"center"]) {
        CGPoint center = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        if (center.y > 0) {
            if (self.navigationControllerBarAndItemStyle == UINavigationControllerBarAndItemViewControllerBarItemStyle) {
                self.navigationBar.hidden = YES;
            }
            else if (self.navigationControllerBarAndItemStyle == UINavigationControllerBarAndItemViewControllerBarWithDefaultItemStyle) {
            }
        }
        [userInfo setObject:[NSValue valueWithCGPoint:center] forKey:YZHUINavigationBarCenterPointKey];
    }
    else if ([keyPath isEqualToString:@"bounds"]) {
        CGRect bounds = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        [userInfo setObject:[NSValue valueWithCGRect:bounds] forKey:YZHUINavigationBarBoundsKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:YZHUINavigationBarAttributeChangNotification object:nil userInfo:userInfo];
}

-(void)resetNavigationBarAndItemViewFrame:(CGRect)frame
{
    if (self.navigationBarView) {
        self.navigationBarView.frame = frame;
    }
    if (self.navigationItemRootContentView) {
        self.navigationItemRootContentView.frame = self.navigationBarView.bounds;
    }
    [self.navigationItemViewWithVCMapTable enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YZHUINavigationItemView * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.frame = self.navigationItemRootContentView.bounds;
    }];
}

//创建事件处理
-(UIPercentDrivenInteractiveTransition*)transition
{
    if (_transition == nil) {
        _transition = [[UIPercentDrivenInteractiveTransition alloc] init];
    }
    return _transition;
}

-(void)_createPanGestureAction
{
    self.isInteractive = NO;
    
    self.pushPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePushAction:)];
    self.pushPan.delegate = self;
    self.pushPan.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.pushPan];
    
    self.popPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePopAction:)];
    self.popPan.delegate = self;
    self.popPan.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.popPan];
    
    self.delegate = self;
}

-(void)_handlePushAction:(UIPanGestureRecognizer*)sender
{
    CGFloat tx = [sender translationInView:self.view].x;
    CGFloat percent = tx / CGRectGetWidth(self.view.frame);
    CGFloat vx = [sender velocityInView:self.view].x;
    
    percent = - MIN(percent, 0);
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.isInteractive = YES;
        if ([self.navDelegate respondsToSelector:@selector(YZHUINavigationController:pushNextViewControllerForViewController:)]) {
            UIViewController *nextVC = [self.navDelegate YZHUINavigationController:self pushNextViewControllerForViewController:self.viewControllers.lastObject];
            [self pushViewController:nextVC animated:YES];
        }
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        [self.transition updateInteractiveTransition:percent];
    }
    else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
    {
        if ([self.navDelegate respondsToSelector:@selector(YZHUINavigationController:updateInteractiveTransition:forPanGesture:operation:completion:)]) {
            WEAK_SELF(weakSelf);
            [self.navDelegate YZHUINavigationController:self updateInteractiveTransition:self.transition forPanGesture:sender operation:UINavigationControllerOperationPush completion:^(BOOL finish) {
                weakSelf.isInteractive = NO;
            }];
        }
        else {
            if (vx > 0 || tx >= 0 || percent < MIN_PERCENT_PUSH_VIEWCONTROLLER) {
                [self.transition cancelInteractiveTransition];
                self.isInteractive = NO;
            }else{
                /*调用updateInteractiveTransition:1.0再来调用finish在iOS9.3.5系统上不会出现有黑边（随机）的情况
                 *这样调用更为安全吧
                 */
//                [self.transition updateInteractiveTransition:1.0];
//                [self.transition finishInteractiveTransition];
                
                NSTimeInterval duration = self.latestTransitionDuration;
                if ([self.navDelegate respondsToSelector:@selector(YZHUINavigationController:doFinishInteractiveTransitionDurationForPercent:operation:)]) {
                    duration = [self.navDelegate YZHUINavigationController:self doFinishInteractiveTransitionDurationForPercent:percent operation:UINavigationControllerOperationPush];
                }
                [self _doUpdateInteractiveTransitionToFinish:percent duration:duration];
            }
        }
    }
}

-(void)_handlePopAction:(UIPanGestureRecognizer*)sender
{
    CGFloat tx = [sender translationInView:self.view].x;
    CGFloat percent = tx / CGRectGetWidth(self.view.frame);
    CGFloat vx = [sender velocityInView:self.view].x;
    
    percent = MAX(percent, 0);
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.isInteractive = YES;
        [self popViewControllerAnimated:YES];
    }else if (sender.state == UIGestureRecognizerStateChanged) {
        [self.transition updateInteractiveTransition:percent];
    }else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        if ([self.navDelegate respondsToSelector:@selector(YZHUINavigationController:updateInteractiveTransition:forPanGesture:operation:completion:)]) {
            WEAK_SELF(weakSelf);
            [self.navDelegate YZHUINavigationController:self updateInteractiveTransition:self.transition forPanGesture:sender operation:UINavigationControllerOperationPop completion:^(BOOL finish) {
                weakSelf.isInteractive = NO;
            }];
        }
        else {
            
            if (vx < 0 || percent < MIN_PERCENT_POP_VIEWCONTROLLER) {
                [self.transition cancelInteractiveTransition];
                self.isInteractive = NO;
                
            }else{
//                [self.transition updateInteractiveTransition:1.0];
//                [self.transition finishInteractiveTransition];
                NSTimeInterval duration = self.latestTransitionDuration;
                if ([self.navDelegate respondsToSelector:@selector(YZHUINavigationController:doFinishInteractiveTransitionDurationForPercent:operation:)]) {
                    duration = [self.navDelegate YZHUINavigationController:self doFinishInteractiveTransitionDurationForPercent:percent operation:UINavigationControllerOperationPop];
                }
                [self _doUpdateInteractiveTransitionToFinish:percent duration:duration];
            }
        }
        
    }
}

-(void)_doUpdateInteractiveTransitionToFinish:(CGFloat)fromPercent duration:(NSTimeInterval)duration
{
    NSTimeInterval interval = 0.01;
    NSInteger stepCnt = (NSInteger)(duration/interval + 0.5);
    CGFloat stepPercent = 1 - fromPercent;
    if (stepCnt > 0) {
        stepPercent = stepPercent / stepCnt;
    }
    __block CGFloat percent = fromPercent;
    WEAK_SELF(wealSelf);
    self.updateTransitionTimer = [YZHTimer timerWithTimeInterval:interval repeat:YES fireBlock:^(YZHTimer *timer) {
        percent += stepPercent;
        percent = MIN(1.0, percent);
        [wealSelf.transition updateInteractiveTransition:percent];
        if (percent >= 1.0) {
            [wealSelf.transition finishInteractiveTransition];
            wealSelf.isInteractive = NO;
            [timer invalidate];
            wealSelf.updateTransitionTimer = nil;
        }
    }];
}


#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if ([panGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
        if (panGestureRecognizer == self.pushPan) {
            UIViewController *topVC = self.viewControllers.lastObject;
            if ([self.navDelegate respondsToSelector:@selector(YZHUINavigationController:pushNextViewControllerForViewController:)]) {
                UIViewController *nextVC = [self.navDelegate YZHUINavigationController:self pushNextViewControllerForViewController:topVC];
                return nextVC != nil && velocity.x < 0;
            }
            return NO;
        }
        else
        {
            if (self.popGestureEnabled == NO) {
                return NO;
            }
            else {
                YZHUIViewController *topVC = (YZHUIViewController *)self.viewControllers.lastObject;
                if ([topVC isKindOfClass:[YZHUIViewController class]] && !topVC.popGestureEnabled) {
                    return NO;
                }
            }
            return self.viewControllers.count > 1 && velocity.x > 0;
        }
    }
    return YES;
}

#pragma mark UINavigationControllerDelegate
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.lastTopVC == viewController) {
        if ([self.navDelegate respondsToSelector:@selector(YZHUINavigationController:didPushViewController:)]) {
            [self.navDelegate YZHUINavigationController:self didPushViewController:viewController];
        }
        if (self.lastTopVC.pushCompletionBlock) {
            self.lastTopVC.pushCompletionBlock(self);
        }
    }
    else
    {
        if ([self.navDelegate respondsToSelector:@selector(YZHUINavigationController:didPopViewController:)]) {
            [self.navDelegate YZHUINavigationController:self didPopViewController:self.lastTopVC];
        }
        if (self.lastTopVC.popCompletionBlock) {
            self.lastTopVC.popCompletionBlock(self);
        }
    }
    self.lastTopVC = nil;

}

-(id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.isInteractive ? self.transition : nil;
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    NSTimeInterval transitionDuration = self.transitionDuration;
    if (operation == UINavigationControllerOperationPush) {
        self.lastTopVC = toVC;
        if ([self.navDelegate respondsToSelector:@selector(YZHUINavigationController:willPushViewController:)]) {
            [self.navDelegate YZHUINavigationController:self willPushViewController:toVC];
        }
    }
    else if (operation == UINavigationControllerOperationPop)
    {
        self.lastTopVC = fromVC;
        if ([self.navDelegate respondsToSelector:@selector(YZHUINavigationController:willPopViewController:)]) {
            [self.navDelegate YZHUINavigationController:self willPopViewController:fromVC];
        }
    }
    
    if ([self.lastTopVC isKindOfClass:[YZHUIViewController class]]) {
        YZHUIViewController *topVC = (YZHUIViewController*)self.lastTopVC;
        if (topVC.transitionDuration > 0) {
            transitionDuration = topVC.transitionDuration;
        }
    }
    
    YZHBaseAnimatedTransition *transition = [YZHBaseAnimatedTransition navigationController:self animationControllerForOperation:operation animatedTransitionStyle:YZHNavigationAnimatedTransitionStyleDefault];
    transition.transitionDuration = transitionDuration;
    self.latestTransitionDuration = transitionDuration;
    return transition;
}

#pragma mark override

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!animated) {
        UIViewController *fromVC = self.topViewController;
         [self setNavigationItemViewAlpha:0 minToHidden:YES forViewController:fromVC];
    }
    [super pushViewController:viewController animated:animated];
}

//自定义
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)(YZHUINavigationController *navigationController))completion
{
    viewController.pushCompletionBlock = completion;
    [self pushViewController:viewController animated:animated];
    if (!animated) {
        viewController.pushCompletionBlock = nil;
        if (completion) {
            completion(self);
        }
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated completion:(void(^)(YZHUINavigationController *navigationController))completion
{
    UIViewController *VC = [super popViewControllerAnimated:animated];
    VC.popCompletionBlock = completion;
    return VC;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void(^)(YZHUINavigationController *navigationController))completion
{
    UIViewController *topVC = self.topViewController;
    topVC.popCompletionBlock = completion;
    NSArray *VCs = [super popToViewController:viewController animated:animated];
    return VCs;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated completion:(void(^)(YZHUINavigationController *navigationController))completion
{
    UIViewController *topVC = self.topViewController;
    topVC.popCompletionBlock = completion;
    NSArray *VCs = [super popToRootViewControllerAnimated:animated];
    return VCs;
}

//清空原有的navigationBar
-(void)_clearOldUINavigationBarView
{
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];
}

//创建新的navigationBarView
-(YZHUINavigationBarView*)_createNavigationBarView:(BOOL)atTop
{
    if (!IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_BAR_STYLE(self.navigationControllerBarAndItemStyle)) {
        return nil;
    }
    if (_navigationBarView == nil) {
        CGRect frame =  CGRectMake(SAFE_X, -STATUS_BAR_HEIGHT, SAFE_WIDTH, STATUS_NAV_BAR_HEIGHT);
        _navigationBarView = [[YZHUINavigationBarView alloc] initWithFrame:frame];
//        _navigationBarView.frame = frame;
        _navigationBarView.style = UIBarViewStyleNone;
        if (atTop) {
            [self.navigationBar addSubview:_navigationBarView];
        }
        else {
            if (IS_AVAILABLE_NSSET_OBJ(self.navigationBar.subviews)) {
                UIView *first = [self.navigationBar.subviews firstObject];
                [first addSubview:_navigationBarView];
//                [self.navigationBar insertSubview:_navigationBarView atIndex:0];
            }
            else {
                [self.navigationBar addSubview:_navigationBarView];
            }
        }
    }
    return _navigationBarView;
}

-(YZHUINavigationItemView*)_createNavigationItemRootContentView
{
    if (!IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(self.navigationControllerBarAndItemStyle)) {
        return nil;
    }
    [self _createNavigationBarView:YES];
    if (_navigationItemRootContentView == nil) {
        _navigationItemRootContentView = [[YZHUINavigationItemView alloc] initWithFrame:self.navigationBarView.bounds];
//        _navigationItemRootContentView.frame = self.navigationBarView.bounds;
        [self.navigationBarView addSubview:_navigationItemRootContentView];
    }
    return _navigationItemRootContentView;
}

-(NSMapTable*)navigationItemViewWithVCMapTable
{
    if (_navigationItemViewWithVCMapTable == nil) {
        _navigationItemViewWithVCMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return _navigationItemViewWithVCMapTable;
}

-(NSString*)getKeyFromVC:(UIViewController*)viewController
{
    return [[NSString alloc] initWithFormat:@"%@",@([viewController hash])];
}

//在viewController初始化的时候调用，此函数仅仅是创建了一个NavigationItemView，在push的时候添加
-(void)createNewNavigationItemViewForViewController:(UIViewController*)viewController
{
    if (viewController == nil) {
        return;
    }
    
    if (!IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(self.navigationControllerBarAndItemStyle)) {
        return;
    }
    
    YZHUINavigationItemView *navigationItemView = [self.navigationItemViewWithVCMapTable objectForKey:[self getKeyFromVC:viewController]];
    
    if (navigationItemView == nil) {
        navigationItemView = [[YZHUINavigationItemView alloc] initWithFrame:self.navigationItemRootContentView.bounds];
        
        [self.navigationItemViewWithVCMapTable setObject:navigationItemView forKey:[self getKeyFromVC:viewController]];

        [self addNewNavigationItemViewForViewController:viewController];
    }
}

-(void)addNewNavigationItemViewForViewController:(UIViewController*)viewController
{
    [self _doCheckNavigationItemView];
    YZHUINavigationItemView *navigationItemView = [self.navigationItemViewWithVCMapTable objectForKey:[self getKeyFromVC:viewController]];
    navigationItemView.frame = self.navigationItemRootContentView.bounds;
    [navigationItemView removeFromSuperview];
    [self.navigationItemRootContentView addSubview:navigationItemView];

}

//在viewController pop完成的时候调用，
-(void)removeNavigationItemViewForViewController:(UIViewController*)viewController
{
    if (viewController == nil) {
        return;
    }
    YZHUINavigationItemView *navigationItemView = [self.navigationItemViewWithVCMapTable objectForKey:[self getKeyFromVC:viewController]];
    if (navigationItemView == nil) {
        return;
    }
    [self _removeNavigationItemView:navigationItemView];
    
    [self _doCheckNavigationItemView];

}

-(void)_doCheckNavigationItemView
{
    NSMutableDictionary *outMutDict = [self.navigationItemViewWithVCMapTable mutableCopy];
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [self getKeyFromVC:obj];
        if ([outMutDict objectForKey:key]) {
            [outMutDict removeObjectForKey:key];
        }
    }];
    [outMutDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, YZHUINavigationItemView * _Nonnull obj, BOOL * _Nonnull stop) {
        [self _removeNavigationItemView:obj];
    }];
}

-(void)_removeNavigationItemView:(YZHUINavigationItemView*)navigationItemView
{
    if (navigationItemView == nil) {
        return;
    }
    [self.navigationItemViewWithVCMapTable enumerateKeysAndObjectsUsingBlock:^(id key, YZHUINavigationItemView *itemView, BOOL *stop) {
        if (itemView == navigationItemView) {
            [self.navigationItemViewWithVCMapTable removeObjectForKey:key];
            *stop = YES;
        }
    }];
    [navigationItemView removeFromSuperview];
}

-(void)setNavigationBarViewBackgroundColor:(UIColor *)navigationBarViewBackgroundColor
{
    _navigationBarViewBackgroundColor = navigationBarViewBackgroundColor;
    if (self.navigationBarView != nil) {
        self.navigationBarView.backgroundColor = navigationBarViewBackgroundColor;
    }
    else
    {
        self.navigationBar.barTintColor = navigationBarViewBackgroundColor;
    }
}

-(void)_printView:(UIView*)view withIndex:(NSInteger)index
{
    NSString *format = @"";
    for (int i = 0; i < index; ++i) {
        format = [NSString stringWithFormat:@"%@-",format];
    }
    NSLog(@"%@view=%@",format,view);
    for (UIView *subView in view.subviews) {
        [self _printView:subView withIndex:index+1];
    }
}

-(void)setNavigationBarBottomLineColor:(UIColor *)navigationBarBottomLineColor
{
    _navigationBarBottomLineColor = navigationBarBottomLineColor;
    if (self.navigationBarView != nil) {
        self.navigationBarView.bottomLine.backgroundColor = navigationBarBottomLineColor;
    }
    else {
        if (navigationBarBottomLineColor) {
            UIImage *image = [[UIImage new] createImageWithSize:CGSizeMake(self.navigationBar.bounds.size.width, SINGLE_LINE_WIDTH) tintColor:navigationBarBottomLineColor];
            [self.navigationBar setShadowImage:image];
        }
        else {
            [self.navigationBar setShadowImage:nil];
        }
    }
}

//-(UIColor*)navigationBarViewBackgroundColor
//{
//    if (self.navigationBarView != nil) {
//        return self.navigationBarView.backgroundColor;
//    }
//    return self.navigationBar.barTintColor;
//}

-(void)setNavigationBarViewAlpha:(CGFloat)navigationBarViewAlpha
{
    _navigationBarViewAlpha = navigationBarViewAlpha;
    if (self.navigationBarView != nil) {
        self.navigationBarView.alpha = navigationBarViewAlpha;
        if (navigationBarViewAlpha <= MIN_ALPHA_TO_HIDDEN) {
            self.navigationBarView.hidden = YES;
        }
        else {
            self.navigationBarView.hidden = NO;
        }
    }
    else
    {
        self.navigationBar.alpha = navigationBarViewAlpha;
        if (navigationBarViewAlpha <= MIN_ALPHA_TO_HIDDEN) {
            self.navigationBar.hidden = YES;
        }
        else {
            self.navigationBar.hidden = NO;
        }
    }
}

-(void)setBarViewStyle:(UIBarViewStyle)barViewStyle
{
    _barViewStyle = barViewStyle;
    if (self.navigationBarView != nil) {
        self.navigationBarView.style = barViewStyle;
    }
}

//设置NavigationItemView相关
-(void)setNavigationItemViewAlpha:(CGFloat)alpha minToHidden:(BOOL)minToHidden forViewController:(UIViewController*)viewController
{
    YZHUINavigationItemView *navigationItemView = [self.navigationItemViewWithVCMapTable objectForKey:[self getKeyFromVC:viewController]];
    if (navigationItemView) {
        navigationItemView.alpha = alpha;
        if (minToHidden) {
            if (alpha <= MIN_ALPHA_TO_HIDDEN) {
                navigationItemView.hidden = YES;
            }
            else {
                navigationItemView.hidden = NO;
            }
        }
    }
}

-(void)setNavigationItemViewTransform:(CGAffineTransform)transform forViewController:(UIViewController*)viewController
{
    YZHUINavigationItemView *navigationItemView = [self.navigationItemViewWithVCMapTable objectForKey:[self getKeyFromVC:viewController]];
    if (navigationItemView) {
        navigationItemView.t = transform;
    }
}

-(void)setNavigationItemTitle:(NSString*)title forViewController:(UIViewController*)viewController
{
    if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(self.navigationControllerBarAndItemStyle)) {
        YZHUINavigationItemView *navigationItemView = [self.navigationItemViewWithVCMapTable objectForKey:[self getKeyFromVC:viewController]];
        [navigationItemView setTitle:title];
    }
    else
    {
        self.navigationItem.title = title;
    }
}

-(void)setNavigationItemTitleTextAttributes:(NSDictionary<NSAttributedStringKey, id>*)textAttributes forViewController:(UIViewController*)viewController
{
    if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(self.navigationControllerBarAndItemStyle)) {
        YZHUINavigationItemView *navigationItemView = [self.navigationItemViewWithVCMapTable objectForKey:[self getKeyFromVC:viewController]];
        navigationItemView.titleTextAttributes = textAttributes;
    }
}

-(void)addNavigationItemViewLeftButtonItems:(NSArray*)leftButtonItems isReset:(BOOL)reset forViewController:(UIViewController *)viewController
{
    if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(self.navigationControllerBarAndItemStyle)) {
        YZHUINavigationItemView *navigationItemView = [self.navigationItemViewWithVCMapTable objectForKey:[self getKeyFromVC:viewController]];
        [navigationItemView setLeftButtonItems:leftButtonItems isReset:reset];
    }
    else if (IS_SYSTEM_DEFAULT_UINAVIGATIONCONTROLLER_ITEM_STYLE(self.navigationControllerBarAndItemStyle))
    {
        self.navigationItem.leftBarButtonItems = leftButtonItems;
    }
}

-(void)addNavigationItemViewRightButtonItems:(NSArray*)rightButtonItems isReset:(BOOL)reset forViewController:(UIViewController *)viewController
{
    if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_ITEM_STYLE(self.navigationControllerBarAndItemStyle)) {
        YZHUINavigationItemView *navigationItemView = [self.navigationItemViewWithVCMapTable objectForKey:[self getKeyFromVC:viewController]];
        [navigationItemView setRightButtonItems:rightButtonItems isReset:reset];
    }
    else if (IS_SYSTEM_DEFAULT_UINAVIGATIONCONTROLLER_ITEM_STYLE(self.navigationControllerBarAndItemStyle))
    {
        self.navigationItem.rightBarButtonItems = rightButtonItems;
    }
}

-(void)addNavigationBarCustomView:(UIView*)customView
{
    if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_BAR_STYLE(self.navigationControllerBarAndItemStyle)) {
        if (customView) {
            [self.navigationBarView addSubview:customView];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [self _addObserverNavigationBar:NO];
    [self.updateTransitionTimer invalidate];
    self.updateTransitionTimer = nil;
}

- (UIView *)navBarView
{
    if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_BAR_STYLE(self.navigationControllerBarAndItemStyle)) {
        return self.navigationBarView;
    }
    return self.navigationBar;
}

- (CGFloat)navBarTopLayout
{
    if (IS_CUSTOM_GLOBAL_UINAVIGATIONCONTROLLER_BAR_STYLE(self.navigationControllerBarAndItemStyle)) {
        return STATUS_BAR_HEIGHT;
    }
    return 0;
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
