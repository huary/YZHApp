//
//  YZHUIProgressView.m
//  YZHUIAlertViewDemo
//
//  Created by yuan on 2017/6/9.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUIProgressView.h"
#import "YZHUIGraphicsImage.h"
#import "YZHKitType.h"

static YZHUIProgressView *_shareProgressView_s = NULL;

@interface YZHUIProgressView ()


@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

/** imageHeightRatio */
@property (nonatomic, assign) CGFloat imageHeightRatio;
/** indicatorViewSize */
@property (nonatomic, assign) CGSize indicatorViewSize;

/** closeBtn */
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation YZHUIProgressView

@synthesize alertView = _alertView;

+(instancetype)shareProgressView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareProgressView_s = [[YZHUIProgressView alloc] init];
    });
    return _shareProgressView_s;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefaultValue];
        [self _setupChildView];
    }
    return self;
}

-(void)_setupDefaultValue
{
    self.contentInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    self.midSpaceWithTopBottomInsetsRatio = 0.4;
    self.indicatorViewSize = CGSizeMake(40, 40);
    self.customContentSize = CGSizeZero;
    self.canClose = YES;
}

-(YZHUIAlertView*)alertView
{
    if (_alertView == nil) {
        _alertView = [[YZHUIAlertView alloc] initWithTitle:nil alertViewStyle:YZHUIAlertViewStyleAlertForce];
        _alertView.backgroundColor = CLEAR_COLOR;
        _alertView.customContentAlertView = self;
        _alertView.animateDuration = 0.0f;
    }
    return _alertView;
}

-(void)_setupChildView
{
    _animationView = [[UIImageView alloc] init];
    self.animationView.backgroundColor = CLEAR_COLOR;
    self.animationView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.animationView];
    
    _titleView = [[UILabel alloc] init];
    self.titleView.font = FONT(18);
    self.titleView.backgroundColor = CLEAR_COLOR;
    self.titleView.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleView];
    
    self.backgroundColor = BLACK_COLOR;
    
    _progressViewStyle = YZHUIProgressViewStyleIndicator;
    [self _updateIndicatorView];
    
    [self setContentColor:WHITE_COLOR];
    
    UIButton *closeBtn = [self _createCloseBtn];
    [self addSubview:closeBtn];
    self.closeButton = closeBtn;
}

-(void)setCustomView:(UIView *)customView
{
    if (_customView != customView) {
        _customView = customView;
        if (customView) {
            [self addSubview:customView];
        }
    }
}

-(void)_doClearAnimationView
{
    [self.animationView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.animationView stopAnimating];
    self.animationView.animationImages = nil;
    self.animationView.image = nil;
}

-(void)_updateIndicatorView
{
    [self _doClearAnimationView];
    if (_progressViewStyle == YZHUIProgressViewStyleIndicator)
    {
        [self.indicatorView removeFromSuperview];
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.indicatorView.color = self.contentColor;
        [self.indicatorView startAnimating];
        [self.animationView addSubview:self.indicatorView];
    }
}

-(UIImage*)_createCloseImage:(UIColor*)strokeColor
{
    CGSize graphicsSize = CGSizeMake(10, 10);
    YZHUIGraphicsImageContext *ctx = [[YZHUIGraphicsImageContext alloc] initWithBeginBlock:^(YZHUIGraphicsImageContext *context) {
        context.beginInfo = [[YZHUIGraphicsImageBeginInfo alloc] init];
        context.beginInfo.lineWidth = 2.0;
        context.beginInfo.graphicsSize = graphicsSize;
    } runBlock:^(YZHUIGraphicsImageContext *context) {
        CGContextMoveToPoint(context.ctx, 0, 0);
        CGContextAddLineToPoint(context.ctx, graphicsSize.width, graphicsSize.height);
        CGContextMoveToPoint(context.ctx, graphicsSize.width, 0);
        CGContextAddLineToPoint(context.ctx, 0, graphicsSize.height);
    } endPathBlock:nil];
    return [ctx createGraphicesImageWithStrokeColor:strokeColor];
}

-(UIButton*)_createCloseBtn
{
    CGFloat w = 20;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, w, w);
    button.layer.cornerRadius = w/2;
    [button setImage:[self _createCloseImage:RED_COLOR] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_closeAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)_closeAction:(UIButton*)sender
{
    [self dismiss];
}

-(void)setProgressViewStyle:(YZHUIProgressViewStyle)progressViewStyle
{
    _progressViewStyle = progressViewStyle;
    [self _updateIndicatorView];
}

-(void)setContentColor:(UIColor *)contentColor
{
    if (_contentColor != contentColor) {
        _contentColor = contentColor;
        self.titleView.textColor = contentColor;
        self.indicatorView.color = contentColor;
    }
}

-(void)setShowTimeInterval:(NSTimeInterval)showTimeInterval
{
    _showTimeInterval = showTimeInterval;
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_doTimeoutAction) object:nil];
    if (showTimeInterval > 0) {
        [self performSelector:@selector(_doTimeoutAction) withObject:nil afterDelay:showTimeInterval];
    }
    else {
        self.timeoutBlock = nil;
    }
}

-(void)_doTimeoutAction
{
    if (self.timeoutBlock) {
        YZHUIProgressTimeoutBlock timeoutBlock = self.timeoutBlock;
        self.timeoutBlock = nil;
        timeoutBlock(self);
    }
    else
    {
        [self dismiss];
    }
}

-(void)_doCompletionBlock:(BOOL)finished
{
    if (self.completionBlock) {
        self.completionBlock(self, self.dismissTag, finished);
        _completionBlock = nil;
    }
}

-(void)setCompletionBlock:(YZHUIProgressDismissCompletionBlock)completionBlock
{
    _completionBlock = completionBlock;
    WEAK_SELF(weakSelf);
    self.alertView.dismissCompletionBlock = ^(YZHUIAlertView *alertView ,BOOL finished) {
        [weakSelf _doCompletionBlock:finished];
    };
}

-(CGSize)_getContentSizeByContentWithImageViewRect:(CGRect*)imageViewRect titleRect:(CGRect*)titleRect
{
    [self.titleView sizeToFit];
    [self.animationView sizeToFit];
    CGSize titleSize = self.titleView.bounds.size;
    CGSize animationSize = self.animationView.bounds.size;
    if (CGSizeEqualToSize(animationSize, CGSizeZero)) {
        animationSize = self.indicatorViewSize;
    }
    
    CGFloat width = MAX(animationSize.width, titleSize.width) + self.contentInsets.left + self.contentInsets.right;
    
    /** midSpaceWithTopBottomInsetsRatio,中间的距离,默认为0.4
     * 总共的空白区域为2top + 2bottom，
     * 中间空白区域为 (1-midSpaceWithTopBottomInsetsRatio) *（top+bottom）,值越大的话相距越近，上下越高，
     * top的高度为 top*(1 + midRatio) = X;
     * mid的高度为 （top+bottom）* （1 - midRatio）= Y;
     * bottom的的高度为 bottom * (1 + midRatio) = Z;
     * 通过已知的X,Y,Z高度可以求得如下：
     * top = (X+Y+Z)*X/(2 * (X+Z))
     * bottom = (X+Y+Z)*Z/(2 * (X+Z))
     * midRatio = (X-Y+Z)/(X+Y+Z)
     * 根据默认的contentInsets=UIEdgeInsetsMake(15, 15, 15, 15),可以求知
     * top = 21,bottom = 21, mid = 18,
     */
    CGFloat midRatio = self.midSpaceWithTopBottomInsetsRatio;
    CGFloat titleHeight = titleSize.height + self.contentInsets.bottom * 2 * (1 + midRatio);
    CGFloat imageHeight = animationSize.height + self.contentInsets.top * 2 * (1 + midRatio);
    CGFloat height = titleSize.height + animationSize.height + 2 * (self.contentInsets.top + self.contentInsets.bottom);
    if (CGSizeEqualToSize(titleSize, CGSizeZero)) {
        titleHeight = 0;
        imageHeight = animationSize.height +  self.contentInsets.top + self.contentInsets.bottom;
        height = imageHeight;
    }
    
    if (imageViewRect) {
        *imageViewRect = CGRectMake(0, 0, width, imageHeight);
    }
    if (titleRect) {
        CGFloat y = height - titleHeight;
        *titleRect = CGRectMake(0, y, width, titleHeight);
    }
    return CGSizeMake(width, height);
}

-(CGSize)_getContentSizeWithImageViewRect:(CGRect*)imageViewRect titleRect:(CGRect*)titleRect
{
    if (CGSizeEqualToSize(self.customContentSize, CGSizeZero)) {
        return [self _getContentSizeByContentWithImageViewRect:imageViewRect titleRect:titleRect];
    }
    else {
        CGRect titleRectTmp = CGRectZero;
        CGRect imageViewRectTmp = CGRectZero;
        CGSize contentSize = [self _getContentSizeByContentWithImageViewRect:&imageViewRectTmp titleRect:&titleRectTmp];
        CGFloat heightRatio = 1.0;
        if (contentSize.height > 0) {
            heightRatio = self.customContentSize.height / contentSize.height;
        }
        titleRectTmp.size.width = self.customContentSize.width;
        titleRectTmp.size.height = titleRectTmp.size.height * heightRatio;
        titleRectTmp.origin.x = 0;
        titleRectTmp.origin.y = titleRectTmp.origin.y * heightRatio;
        
        imageViewRectTmp.size.width = self.customContentSize.width;
        imageViewRectTmp.size.height = imageViewRectTmp.size.height * heightRatio;
        imageViewRectTmp.origin.x = 0;
        imageViewRectTmp.origin.y = imageViewRectTmp.origin.y * heightRatio;
        
        if (imageViewRect) {
            *imageViewRect = imageViewRectTmp;
        }
        
        if (titleRect) {
            *titleRect = titleRectTmp;
        }
        
        return self.customContentSize;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect imageRect = CGRectZero;
    CGRect titleRect = CGRectZero;
    CGSize size = [self _getContentSizeWithImageViewRect:&imageRect titleRect:&titleRect];
    self.frame = CGRectMake(0, 0, size.width, size.height);
    self.titleView.frame = titleRect;
    self.animationView.frame = imageRect;
    
    if (self.customView) {
        self.customView.frame = self.bounds;
    }
    
    if (self.indicatorView) {
        self.indicatorView.frame = self.animationView.bounds;
    }
    self.closeButton.hidden = !self.canClose;
}

-(void)_doUpdateAnimationImages:(NSArray<UIImage*>*)animationImages
{
    if (IS_AVAILABLE_NSSET_OBJ(animationImages)) {
        [self _doClearAnimationView];
    }
    if (animationImages.count > 1) {
        self.animationView.animationImages = animationImages;
        [self.animationView startAnimating];
    }
    else if (animationImages.count == 1)
    {
        self.animationView.image = [animationImages firstObject];
    }
}

-(void)setOutSideUserInteractionEnabled:(BOOL)outSideUserInteractionEnabled
{
    _outSideUserInteractionEnabled = outSideUserInteractionEnabled;
    self.alertView.outSideUserInteractionEnabled = outSideUserInteractionEnabled;
}

-(void)progressShowInView:(UIView*)view withAnimationImages:(NSArray<UIImage *> *)animationImages
{
    [self _updateIndicatorView];
    [self _doUpdateAnimationImages:animationImages];
    [self _doUpdateProgressView];
    
    _isShowing = YES;
    [self.alertView alertShowInView:view];
}

-(void)progressShowTitleText:(NSString*)titleText
{
    [self progressShowInView:nil titleText:titleText];
}

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText
{
    [self progressShowInView:view titleText:titleText showTimeInterval:0 timeoutBlock:nil];
}

-(void)progressShowTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self progressShowTitleText:titleText showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)progressShowTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    [self progressShowInView:nil titleText:titleText showTimeInterval:showTimeInterval timeoutBlock:timeoutBlock];
}

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self progressShowInView:view titleText:titleText showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    [self progressShowInView:view titleText:titleText animationImages:nil showTimeInterval:showTimeInterval timeoutBlock:timeoutBlock];
}

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages
{
    [self progressShowTitleText:titleText animationImages:animationImages showTimeInterval:0 timeoutBlock:nil];
}

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self progressShowTitleText:titleText animationImages:animationImages showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)progressShowTitleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    [self progressShowInView:nil titleText:titleText animationImages:animationImages showTimeInterval:showTimeInterval timeoutBlock:timeoutBlock];
}

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self progressShowInView:view titleText:titleText animationImages:animationImages showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)progressShowInView:(UIView *)view titleText:(NSString*)titleText animationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    self.titleView.text = titleText;
    self.showTimeInterval = showTimeInterval;
    self.timeoutBlock = timeoutBlock;
    [self progressShowInView:view withAnimationImages:animationImages];
}

-(void)_doUpdateProgressView
{
    CGSize size = [self _getContentSizeWithImageViewRect:NULL titleRect:NULL];
    self.alertView.bounds = CGRectMake(0, 0, size.width, size.height);
}

-(void)updateTitleText:(NSString*)titleText
{
    self.titleView.text = titleText;
    [self _doUpdateProgressView];
}

-(void)updateTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self updateTitleText:titleText showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)updateTitleText:(NSString*)titleText showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    self.titleView.text = titleText;
    self.showTimeInterval = showTimeInterval;
    self.timeoutBlock = timeoutBlock;
    [self _doUpdateProgressView];
}

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages
{
    [self _doUpdateAnimationImages:animationImages];
    [self _doUpdateProgressView];
}

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self updateAnimationImages:animationImages showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)updateAnimationImages:(NSArray<UIImage*>*)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    self.showTimeInterval = showTimeInterval;
    self.timeoutBlock = timeoutBlock;
    [self _doUpdateAnimationImages:animationImages];
    [self _doUpdateProgressView];
}

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage*>*)animationImages
{
    self.titleView.text = titleText;
    [self _doUpdateAnimationImages:animationImages];
    [self _doUpdateProgressView];
}

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage *> *)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval
{
    [self updateTitleText:titleText animationImages:animationImages showTimeInterval:showTimeInterval timeoutBlock:nil];
}

-(void)updateTitleText:(NSString *)titleText animationImages:(NSArray<UIImage *> *)animationImages showTimeInterval:(NSTimeInterval)showTimeInterval timeoutBlock:(YZHUIProgressTimeoutBlock)timeoutBlock
{
    self.titleView.text = titleText;
    self.timeoutBlock = timeoutBlock;
    self.showTimeInterval = showTimeInterval;
    [self _doUpdateAnimationImages:animationImages];
    [self _doUpdateProgressView];
}

-(void)_dismissAction
{
    _isShowing = NO;
    _alertView = nil;
    self.showTimeInterval = 0;
}

-(void)dismiss
{
    //这里不能用self.alertView,因为这里重写了get方法
    [_alertView dismiss];
    [self _dismissAction];
}

-(void)removeFromSuperview
{
    [self dismiss];
    [super removeFromSuperview];
}

-(void)dealloc
{
    NSLog(@"YZHUIProgressView--------dealloc");
}
@end
