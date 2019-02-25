//
//  YZHAudioRecordView.m
//  YZHAudioManagerDemo
//
//  Created by yuan on 2018/9/5.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHAudioRecordView.h"
#import "YZHKitType.h"

/****************************************************
 *<#标注#>
 ****************************************************/
@implementation YZHAudioRecordBaseView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupTitleView];
    }
    return self;
}

-(void)_setupTitleView
{
    self.titleLabel = [UILabel new];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = WHITE_COLOR;
    self.titleLabel.font = FONT(14);
    self.titleLabel.layer.cornerRadius = 2;
    self.titleLabel.layer.masksToBounds = YES;
    [self addSubview:self.titleLabel];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    CGFloat x = 7;
    CGFloat b = 7;
    CGFloat w = frame.size.width - 2 * x;
    CGFloat h = 25;
    CGFloat y = frame.size.height - h - b;
    self.titleLabel.frame = CGRectMake(x, y, w, h);
}


@end



/****************************************************
 *<#标注#>
 ****************************************************/
@implementation YZHAudioRecordNormalView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupImageView];
    }
    return self;
}

-(void)_setupImageView
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeCenter;
    [self addSubview:self.imageView];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.titleLabel.frame.origin.y;
    self.imageView.frame = CGRectMake(x, y, w, h);
}

@end


/****************************************************
 *<#标注#>
 ****************************************************/
@implementation YZHAudioRecordCountDownView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupCountDownView];
    }
    return self;
}

-(void)_setupCountDownView
{
    self.countDownLabel = [[UILabel alloc] init];
    self.countDownLabel.textColor = WHITE_COLOR;
    self.countDownLabel.font = FONT(80);
    self.countDownLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.countDownLabel];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.titleLabel.frame.origin.y;
    self.countDownLabel.frame = CGRectMake(x, y, w, h);
}

@end



/****************************************************
 *<#标注#>
 ****************************************************/
@interface YZHAudioRecordPowerView ()

/* <#注释#> */
@property (nonatomic, strong) CAShapeLayer *maskLayer;

/* <#name#> */
@property (nonatomic, assign) CGFloat power;

@end


@implementation YZHAudioRecordPowerView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupPowerView];
    }
    return self;
}

-(void)_setupPowerView
{
    self.recordImageView = [UIImageView new];
    self.recordImageView.image = [UIImage imageNamed:@"record"];
    self.recordImageView.contentMode = UIViewContentModeRight;
    self.recordImageView.backgroundColor = CLEAR_COLOR;
    [self addSubview:self.recordImageView];
    
    self.powerView = [UIImageView new];
    self.powerView.image = [UIImage imageNamed:@"record_ripple"];
    self.powerView.contentMode = UIViewContentModeLeft;
    self.powerView.backgroundColor = CLEAR_COLOR;
    [self addSubview:self.powerView];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w = self.frame.size.width * 0.55;
    CGFloat h = self.titleLabel.frame.origin.y;
    self.recordImageView.frame = CGRectMake(0, 0, w, h);
    
    CGFloat x = CGRectGetMaxX(self.recordImageView.frame) + 8;
    w = self.frame.size.width - x;
    self.powerView.frame = CGRectMake(x, 0, w, h);
    
    [self updateWithPower:self.power];
    
}

-(CAShapeLayer*)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [[CAShapeLayer alloc] init];
    }
    return _maskLayer;
}

-(void)updateWithPower:(CGFloat)power
{
    self.power = power;
    power = MAX(power, 0.1);
    if (CGSizeEqualToSize(self.powerView.frame.size, CGSizeZero)) {
        return;
    }
    
    CGSize imageSize = self.powerView.image.size;
    CGRect imageFrame = CGRectMake(0, (self.powerView.frame.size.height - imageSize.height)/2, imageSize.width, imageSize.height);
    
    CGFloat powerH = power * imageSize.height;
    CGFloat x = 0;
    CGFloat y = imageFrame.origin.y + (imageSize.height - powerH);
    CGFloat h = self.powerView.frame.size.height - y;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, self.powerView.frame.size.width, h)];
    self.maskLayer.path = path.CGPath;
    self.powerView.layer.mask = self.maskLayer;
}


@end




/****************************************************
 *<#标注#>
 ****************************************************/
@interface YZHAudioRecordView ()

@end


@implementation YZHAudioRecordView

@synthesize alertView = _alertView;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupRecordChildView];
    }
    return self;
}

-(void)_setupRecordChildView
{
    self.normalView = [YZHAudioRecordNormalView new];
    [self addSubview:self.normalView];
    
    self.countDownView = [YZHAudioRecordCountDownView new];
    [self addSubview:self.countDownView];
    
    self.powerView = [YZHAudioRecordPowerView new];
    [self addSubview:self.powerView];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.powerView.frame = self.bounds;
    self.normalView.frame = self.bounds;
    self.countDownView.frame = self.bounds;
}

-(YZHUIAlertView*)alertView
{
    if (_alertView == nil) {
        _alertView = [[YZHUIAlertView alloc] initWithTitle:nil alertViewStyle:YZHUIAlertViewStyleAlertForce];
        _alertView.backgroundColor = CLEAR_COLOR;
        _alertView.customContentAlertView = self;
        _alertView.coverColor = CLEAR_COLOR;
        _alertView.animateDuration = 0.0f;
        _alertView.effectView.hidden = YES;
    }
    return _alertView;
}

-(void)dismiss
{
    //这里不能用self.alertView,因为这里重写了get方法
    [_alertView dismiss];
    _alertView = nil;
}

-(void)removeFromSuperview
{
    [self dismiss];
    [super removeFromSuperview];
}

-(void)dealloc
{
    NSLog(@"audioRecordView------dealloc");
}

@end
