//
//  YZHAudioController.m
//  YZHAudioManagerDemo
//
//  Created by yuan on 2018/9/5.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHAudioController.h"
#import "YZHAudioRecordView.h"
#import "YZHWeakProxy.h"
#import "YZHKitType.h"

#define COUNT_DOWN_KEY  @"COUNT_DOWN"

@interface YZHAudioController ()
/* <#注释#> */
@property (nonatomic, strong) YZHAudioRecordView *audioRecordView;

/* <#name#> */
@property (nonatomic, assign) YZHAudioRecordState state;

/* <#注释#> */
@property (nonatomic, strong) NSTimer *timer;

/* <#name#> */
@property (nonatomic, strong) NSDate *showDate;

@end

@implementation YZHAudioController

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupDefaultValue];
    }
    return self;
}

-(void)_setupDefaultValue
{
}

-(YZHAudioRecordView*)audioRecordView
{
    if (!_audioRecordView) {
        CGFloat w = 150;
        CGFloat h = w;
        _audioRecordView = [[YZHAudioRecordView alloc] init];
        _audioRecordView.backgroundColor = [BLACK_COLOR colorWithAlphaComponent:0.3];
        _audioRecordView.alertView.frame = CGRectMake(0, 0, w, h);
    }
    return _audioRecordView;
}

-(void)showWithState:(YZHAudioRecordState)state title:(NSString*)title
{
    [self.audioRecordView.alertView alertShowInView:nil];
    [self updateRecordViewWithState:state title:title];
    if (state == YZHAudioRecordStateRecording) {
        [self updateRecordViewWithPower:0];        
    }
    self.showDate = [NSDate date];
    [self _startTimer:YES];
}

-(void)updateRecordViewWithState:(YZHAudioRecordState)state title:(NSString*)title
{
    [self _updateRecordeViewWithState:state];
    if (self.state == YZHAudioRecordStateRecording) {
        self.audioRecordView.normalView.titleLabel.backgroundColor = CLEAR_COLOR;
    }
    else if (self.state == YZHAudioRecordStateCancel) {
        self.audioRecordView.normalView.titleLabel.backgroundColor = RGB(138, 39, 41);
        self.audioRecordView.normalView.imageView.image = [UIImage imageNamed:@"release_to_cancel"];
    }
    else if (self.state == YZHAudioRecordStateCountDown) {
        [self _startTimer:NO];
    }
    else if (self.state == YZHAudioRecordStateTooShort) {
        self.audioRecordView.normalView.titleLabel.backgroundColor = CLEAR_COLOR;
        self.audioRecordView.normalView.imageView.image = [UIImage imageNamed:@"record_too_short"];
        
        [self _doEndAction:0.5];
    }
    else if (self.state == YZHAudioRecordStateEnd) {
        [self _doEndAction:0.1];
    }
    self.audioRecordView.powerView.titleLabel.text = title;
    self.audioRecordView.normalView.titleLabel.text = title;
    self.audioRecordView.countDownView.titleLabel.text = title;
}

-(void)updateRecordViewWithPower:(CGFloat)power
{
    [self _startTimer:NO];
    
    if (_timer == nil && self.state != YZHAudioRecordStateCancel) {
        [self _updateRecordeViewWithState:YZHAudioRecordStateRecording];
        [self.audioRecordView.powerView updateWithPower:power];
    }
}

-(YZHAudioRecordState)recordState
{
    return self.state;
}

-(void)_doEndAction:(NSTimeInterval)delay
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeOutAction) object:nil];
    [self performSelector:@selector(_timeOutAction) withObject:nil afterDelay:delay];
}

-(BOOL)_updateRecordeViewWithState:(YZHAudioRecordState)recordState
{
    BOOL OK = YES;
    if (recordState == YZHAudioRecordStateNULL) {
        self.audioRecordView.powerView.hidden = YES;
        self.audioRecordView.normalView.hidden = YES;
        self.audioRecordView.countDownView.hidden = YES;
    }
    else if (recordState == YZHAudioRecordStateRecording) {
        if (_timer == nil) {
            self.audioRecordView.powerView.hidden = NO;
            self.audioRecordView.normalView.hidden = YES;
            self.audioRecordView.countDownView.hidden = YES;
        }
        else {
            [self _updateRecordeViewWithState:YZHAudioRecordStateCountDown];
            OK = NO;
        }
    }
    else if (recordState == YZHAudioRecordStateCancel) {
        self.audioRecordView.powerView.hidden = YES;
        self.audioRecordView.normalView.hidden = NO;
        self.audioRecordView.countDownView.hidden = YES;
    }
    else if (recordState == YZHAudioRecordStateCountDown) {
        if ([self _canStartCountTimer]) {
            self.audioRecordView.powerView.hidden = YES;
            self.audioRecordView.normalView.hidden = YES;
            self.audioRecordView.countDownView.hidden = NO;
        }
        else {
            OK = NO;
        }
    }
    else if (recordState == YZHAudioRecordStateTooShort) {
        self.audioRecordView.powerView.hidden = YES;
        self.audioRecordView.normalView.hidden = NO;
        self.audioRecordView.countDownView.hidden = YES;
    }
    else if (recordState == YZHAudioRecordStateEnd) {
        self.audioRecordView.powerView.hidden = YES;
        self.audioRecordView.normalView.hidden = NO;
        self.audioRecordView.countDownView.hidden = YES;
    }
    if (OK) {
        self.state = recordState;
    }
    return OK;
}

-(NSTimer*)timer
{
    if (!_timer) {
        
        self.audioRecordView.powerView.hidden = YES;
        self.audioRecordView.normalView.hidden = YES;
        self.audioRecordView.countDownView.hidden = NO;
        
        NSDate *now = [NSDate date];
        NSTimeInterval diff = [now timeIntervalSinceDate:self.showDate];
        NSInteger countDown = ceil(self.maxRecordDuration - diff);
        
//        NSLog(@"countDown=%ld",countDown);
        self.audioRecordView.countDownView.countDownLabel.text = NEW_STRING_WITH_FORMAT(@"%@",@(countDown));

        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(countDown-1) forKey:COUNT_DOWN_KEY];
        _timer = [NSTimer timerWithTimeInterval:1 target:[YZHWeakProxy proxyWithTarget:self] selector:@selector(_timerAction:) userInfo:userInfo repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

    }
    return _timer;
}

-(BOOL)_canStartCountTimer
{
    if (self.showDate == nil) {
        return NO;
    }
    NSTimeInterval countDown = self.maxRecordDuration - self.countDown;
    NSDate *now = [NSDate date];
    NSTimeInterval diff = [now timeIntervalSinceDate:self.showDate];
    if (diff < countDown) {
        return NO;
    }
    return YES;
}

-(void)_startTimer:(BOOL)isStartShow
{
    if (isStartShow) {
        NSTimeInterval delay = self.maxRecordDuration - self.countDown;
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_startTimer:) object:@(NO)];
        [self performSelector:@selector(_startTimer:) withObject:@(NO) afterDelay:delay];
    }
    else {
        if ([self _canStartCountTimer]) {
            [self timer];
        }
    }
}

-(void)_timerAction:(NSTimer*)timer
{
    NSMutableDictionary *userInfo = timer.userInfo;
    NSInteger cnt = [[userInfo objectForKey:COUNT_DOWN_KEY] integerValue];
    if (cnt == 0) {
        [self dismiss];
        return;
    }
    self.audioRecordView.countDownView.countDownLabel.text = NEW_STRING_WITH_FORMAT(@"%@",@(cnt));
    [userInfo setObject:@(cnt-1) forKey:COUNT_DOWN_KEY];
}

-(void)_endTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)_timeOutAction
{
    [self dismiss];
}

-(void)_dimissAction
{
    if (self.completionBlock) {
        self.completionBlock(self);
    }
    self.showDate = nil;
    [self _endTimer];
}

-(void)dismiss
{
    [self _dimissAction];
    [self.audioRecordView dismiss];
    _audioRecordView = nil;
}

@end
