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
#import "NSObject+YZHTimer.h"

#define COUNT_DOWN_KEY  @"COUNT_DOWN"

@interface YZHAudioController ()
/* <#注释#> */
@property (nonatomic, strong) YZHAudioRecordView *audioRecordView;

/* <#name#> */
@property (nonatomic, assign) YZHAudioRecordState prevState;

/* <#name#> */
@property (nonatomic, assign) YZHAudioRecordState state;

/* <#注释#> */
@property (nonatomic, strong) YZHTimer *timer;

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
//    [self _startTimer:YES];
    [self _prevStartTimer];
}

-(void)updateRecordViewWithState:(YZHAudioRecordState)state title:(NSString*)title
{
    [self updateRecordViewWithState:state title:title delayEnd:0];
}

-(void)updateRecordViewWithState:(YZHAudioRecordState)state title:(NSString*)title delayEnd:(NSTimeInterval)delayEnd
{
    BOOL OK = [self _updateRecordeViewWithState:state];
//    NSLog(@"OK=%d,state=%ld,prevState=%ld",OK,state,self.prevState);
    if (self.state == YZHAudioRecordStateRecording) {
        self.audioRecordView.normalView.titleLabel.backgroundColor = CLEAR_COLOR;
    }
    else if (self.state == YZHAudioRecordStateCancel) {
        self.audioRecordView.normalView.titleLabel.backgroundColor = RGB(138, 39, 41);
        self.audioRecordView.normalView.imageView.image = [UIImage imageNamed:@"release_to_cancel"];
    }
    else if (self.state == YZHAudioRecordStateCountDown) {
        [self timer];
    }
    else if (self.state == YZHAudioRecordStateTooShort) {
        if (!OK) {
            return;
        }
        [self _cancelPrevStartTimer];
        self.audioRecordView.normalView.titleLabel.backgroundColor = CLEAR_COLOR;
        self.audioRecordView.normalView.imageView.image = [UIImage imageNamed:@"record_too_short"];
        
        [self _doEndAction:delayEnd];
    }
    else if (self.state == YZHAudioRecordStateEnd || self.state == YZHAudioRecordStateAbort) {
        if (self.prevState == YZHAudioRecordStateTooShort) {
            return;
        }
        [self _cancelPrevStartTimer];
        [self _doEndAction:delayEnd];
    }
    self.audioRecordView.powerView.titleLabel.text = title;
    self.audioRecordView.normalView.titleLabel.text = title;
    self.audioRecordView.countDownView.titleLabel.text = title;
}

-(void)updateRecordViewWithPower:(CGFloat)power
{
    if (self.state == YZHAudioRecordStateRecording) {
        [self.audioRecordView.powerView updateWithPower:power];
    }
}

-(YZHAudioRecordState)recordState
{
    return self.state;
}

-(void)_doEndAction:(NSTimeInterval)delay
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_endAction) object:nil];
    [self performSelector:@selector(_endAction) withObject:nil afterDelay:delay];
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
        if (_timer == nil /*&& self.state != YZHAudioRecordStateTooShort && self.state != YZHAudioRecordStateEnd && self.state != YZHAudioRecordStateAbort*/) {
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
            self.audioRecordView.powerView.hidden = YES;
            self.audioRecordView.normalView.hidden = YES;
            self.audioRecordView.countDownView.hidden = NO;
    }
    else if (recordState == YZHAudioRecordStateTooShort || recordState == YZHAudioRecordStateEnd || recordState == YZHAudioRecordStateAbort) {
        self.audioRecordView.powerView.hidden = YES;
        self.audioRecordView.normalView.hidden = NO;
        self.audioRecordView.countDownView.hidden = YES;
    }
    if (OK) {
        self.prevState = self.state;
        self.state = recordState;
    }
    return OK;
}


-(void)_prevStartTimer
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_startTimer) object:nil];
    NSTimeInterval delay = self.maxRecordDuration - self.countDown;
    [self performSelector:@selector(_startTimer) withObject:nil afterDelay:delay];
}

-(void)_cancelPrevStartTimer
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_startTimer) object:nil];
    [self _endTimer];
}

-(void)_startTimer
{
    NSString *tilte = nil;
    [self updateRecordViewWithState:YZHAudioRecordStateCountDown title:tilte];
}

-(YZHTimer*)timer
{
    if (!_timer) {
        if (self.state != YZHAudioRecordStateCountDown) {
            return nil;
        }
 
        NSInteger countDown = self.countDown;
        self.audioRecordView.countDownView.countDownLabel.text = NEW_STRING_WITH_FORMAT(@"%@",@(countDown));
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:@(countDown-1) forKey:COUNT_DOWN_KEY];
        
        _timer = [self addTimerInterval:1.0 actionBlock:^(id object, YZHTimer *timer) {
            [(YZHAudioController*)object _timerAction:timer];
        }];
        _timer.userInfo = userInfo;
    }
    return _timer;
}

-(void)_timerAction:(YZHTimer*)timer
{
    NSMutableDictionary *userInfo = timer.userInfo;
    NSInteger cnt = [[userInfo objectForKey:COUNT_DOWN_KEY] integerValue];
    if (cnt <= 0) {
        if (self.finishCountDownBlock) {
            self.finishCountDownBlock(self);
        }
        [self dismiss];
        return;
    }
    self.audioRecordView.countDownView.countDownLabel.text = NEW_STRING_WITH_FORMAT(@"%@",@(cnt));
    [userInfo setObject:@(cnt-1) forKey:COUNT_DOWN_KEY];
}

-(void)_endTimer
{
    [self cancelTimer:self.timer];
    self.timer = nil;
}

-(void)_endAction
{
    [self dismiss];
}

-(void)_dismissAction
{
    if (self.dismissBlock) {
        self.dismissBlock(self);
    }
    self.showDate = nil;
    self.state = YZHAudioRecordStateNULL;
    self.prevState = YZHAudioRecordStateNULL;
    [self _endTimer];
}

-(void)dismiss
{
    [self _dismissAction];
    [self.audioRecordView dismiss];
    _audioRecordView = nil;
}

@end
