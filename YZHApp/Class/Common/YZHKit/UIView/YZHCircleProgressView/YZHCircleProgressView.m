//
//  YZHCircleProgressView.m
//  YZHApp
//
//  Created by yuan on 2019/1/24.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHCircleProgressView.h"
#import "YZHKitType.h"
#import "UIView+YZHAdd.h"

static CGFloat defaultProgressLineWidth_s = 5.0;

@interface YZHCircleProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *progressTrackLayer;

@end

@implementation YZHCircleProgressView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpChild];
    }
    return self;
}

-(void)setUpChild
{
    self.circleType = YZHCircleProgressViewTypeDefaultOnce;
    self.progressBorderWidth = 0;
    self.progressBorderColor = nil;
    
    self.progressLineWidth = defaultProgressLineWidth_s;
    self.progressInsideRadius = self.bounds.size.width/2 - self.progressBorderWidth - self.progressLineWidth;
    self.progressTrackLineWidth = self.progressLineWidth;
    self.progressTrackInsideRadius = self.progressInsideRadius;
    
    self.progressTrackLayer = [[CAShapeLayer alloc] init];
    self.progressTrackLayer.fillColor = nil;
    self.progressTrackLayer.frame = self.bounds;
    [self.layer addSublayer:self.progressTrackLayer];
    
    self.progressLayer =[[CAShapeLayer alloc] init];
    self.progressLayer.frame = self.bounds;
    self.progressLayer.fillColor = nil;
    [self.layer addSublayer:self.progressLayer];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
}

-(void)setProgressLineWidth:(CGFloat)progressLineWidth
{
    if (progressLineWidth <= 0.0) {
        progressLineWidth = defaultProgressLineWidth_s;
    }
    _progressLineWidth = progressLineWidth;
}

-(void)check
{
    if (self.progressLineWidth <= 0) {
        self.progressLineWidth = defaultProgressLineWidth_s;
    }
    
    if (self.progressInsideRadius < 0) {
        self.progressInsideRadius = self.bounds.size.width/2 - self.progressBorderWidth - self.progressLineWidth;
    }
    else if (self.progressBorderWidth + self.progressLineWidth + self.progressInsideRadius > self.bounds.size.width/2)
    {
        self.progressInsideRadius = self.bounds.size.width/2 - self.progressBorderWidth - self.progressLineWidth;
    }
    
    if (self.progressTrackLineWidth <= 0) {
        self.progressTrackLineWidth = self.progressLineWidth;
    }
    if (self.progressTrackInsideRadius < 0) {
        self.progressTrackInsideRadius = self.progressInsideRadius;
    }
    else if (self.progressBorderWidth + self.progressTrackInsideRadius + self.progressTrackLineWidth > self.bounds.size.width/2)
    {
        self.progressTrackInsideRadius = self.bounds.size.width/2 - self.progressBorderWidth - self.progressTrackLineWidth;
    }
}

-(void)setTrackLayer
{
    [self check];
    CGFloat trackLineWidth = self.progressTrackLineWidth;
    self.progressTrackLayer.lineWidth = trackLineWidth;
    
    CGFloat trackRadius = trackLineWidth/2 + self.progressTrackInsideRadius;
    //此函数的参数，center表示弧线原点的位置；radius表示弧度线宽中心点到原点的位置，如果lineWidth > radius 的话，那么radius表示线宽的宽度的一般，此时的内侧半径为lineWidth/2；startAngle表示开始的位置，endAngle表示结束的位置，正上的坐标点为-M_PI_2;clockwize表示顺时针还是逆时针
    UIBezierPath *trackPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y) radius:trackRadius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    self.progressTrackLayer.path = trackPath.CGPath;
    self.progressTrackLayer.strokeColor = self.progressTrackColor.CGColor;
}

-(void)setUpBorderLayer
{
    self.layer.borderWidth = self.progressBorderWidth;
    self.layer.borderColor = self.progressBorderColor.CGColor;
}

-(void)setUpProgressLayer
{
    if (self.progressBorderWidth > 0) {
//        self.layer.cornerRadius = self.bounds.size.width/2;
    }
    self.progressLayer.lineWidth = self.progressLineWidth;
    self.progressLayer.strokeColor = self.progressColor.CGColor;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self setUpBorderLayer];
    [self setTrackLayer];
    [self setUpProgressLayer];
    [self _updateLabelFrame];
}

-(void)_updateLabelFrame
{
    CGFloat w = MIN(self.hz_width, self.hz_height);
    w = w/sqrt(2);
    CGFloat h = w;
    CGFloat x = (self.hz_width - w)/2;
    CGFloat y = (self.hz_height - h)/2;
    self.titleLabel.frame = CGRectMake(x, y, w, h);
}

-(void)setProgressPathWithProgress:(CGFloat)progress
{
    [self check];
    
    CGFloat progressLineWidth = self.progressLineWidth;
    self.progressLayer.lineWidth = progressLineWidth;
    CGFloat progressRadius = progressLineWidth / 2 + self.progressInsideRadius;
    
    CGFloat endAngle = 2 * M_PI * progress - M_PI_2;
    
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y) radius:progressRadius startAngle:-M_PI_2 endAngle:endAngle clockwise:YES];
    //    NSLog(@"progress=%f,endAngle=%f",progress,endAngle);
    self.progressLayer.path = progressPath.CGPath;
    self.progressLayer.strokeColor = self.progressColor.CGColor;
}

-(void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (self.circleType == YZHCircleProgressViewTypeDefaultOnce) {
        [self setProgressPathWithProgress:progress];
        if (animated) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.fromValue = @0.0;
            animation.toValue = @(progress);
            animation.duration = 0.8;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:@"easeInEaseOut"];
            [self.progressLayer addAnimation:animation forKey:@"progress"];
        }
    }
    else if (self.circleType == YZHCircleProgressViewTypeInfinitePartRadian)
    {
        [self setProgressPathWithProgress:progress];
        self.progressLayer.lineCap = kCALineCapRound;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        animation.byValue = @(2*M_PI);
        animation.duration = 1.2;
        animation.repeatCount = MAXFLOAT;
        [self.progressLayer addAnimation:animation forKey:@"progress"];
    }
    else if (self.circleType == YZHCircleProgressViewTypeInfiniteAllRadian)
    {
        [self setProgressPathWithProgress:progress];
        
        CABasicAnimation *strokeEndAnimation = [self getStrokeAnimationWithTag:YES];
        CABasicAnimation *strokeStartAnimation = [self getStrokeAnimationWithTag:NO];
        CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
        groupAnimation.animations = @[strokeEndAnimation,strokeStartAnimation];
        groupAnimation.duration = 2.4;
        groupAnimation.repeatCount = MAXFLOAT;
        [self.progressLayer addAnimation:groupAnimation forKey:@"progressa"];
    }
}

-(CABasicAnimation*)getStrokeAnimationWithTag:(BOOL)strokeEnd
{
    CABasicAnimation *animation = nil;
    CFTimeInterval duration = 1.2;
    if (strokeEnd) {
        animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.beginTime = 0;
    }
    else
    {
        animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        animation.beginTime = duration;
    }
    animation.fromValue = @0.0;
    animation.toValue = @(1.0);
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:@"easeInEaseOut"];
    return animation;
}

-(void)stopAnimate
{
    [self.progressLayer removeAllAnimations];
}

-(void)dealloc
{
    [self.progressLayer removeAllAnimations];
    [self.progressLayer removeFromSuperlayer];
    self.progressLayer = nil;
    [self.progressTrackLayer removeFromSuperlayer];
    self.progressTrackLayer = nil;
}


@end
