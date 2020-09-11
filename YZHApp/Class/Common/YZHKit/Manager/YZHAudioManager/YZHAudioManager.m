//
//  YZHAudioManager.m
//  wits
//
//  Created by yuan on 2018/7/30.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHAudioManager.h"
#import "YZHKitType.h"
#import "YZHWeakProxy.h"

NSNotificationName const YZHAudioManagerDidFinishPlayingNotification = @"YZHAudioManagerDidFinishPlayingNotification";

static YZHAudioPlayOption *defaultPlayOption_s = nil;
static YZHAudioManager *shareAudioManager_s = nil;

@implementation YZHAudioPlayOption

+ (instancetype)defaultPlayOption
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultPlayOption_s = [YZHAudioPlayOption new];
        defaultPlayOption_s.defaultSessionCategory = AVAudioSessionCategoryPlayback;
        defaultPlayOption_s.enableProximityMonitoring = YES;
    });
    return defaultPlayOption_s;
}

@end

@interface YZHAudioManager () <AVAudioRecorderDelegate,AVAudioPlayerDelegate>
/* <#注释#> */
@property (nonatomic, strong) NSString *audioRecordeFilePath;

/* <#注释#> */
@property (nonatomic, strong) NSURL *audioPlayURL;

/* <#注释#> */
@property (nonatomic, strong) NSTimer *timer;

/* <#name#> */
@property (nonatomic, assign) NSTimeInterval currentDuration;

/* <#name#> */
@property (nonatomic, assign) NSTimeInterval startRecordDuration;

/** 播放option */
@property (nonatomic, strong) YZHAudioPlayOption *playOption;

/** 是否增加observer的 */
@property (nonatomic, assign) BOOL addSensorObserver;

@end

@implementation YZHAudioManager

@synthesize audioRecorder = _audioRecorder;
@synthesize audioPlayer = _audioPlayer;

+(instancetype)shareAudioManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareAudioManager_s = [[super allocWithZone:NULL] init];
        [shareAudioManager_s pri_setupDefault];
    });
    return shareAudioManager_s;
}

+(id)allocWithZone:(struct _NSZone *)zone
{
    return [YZHAudioManager shareAudioManager];
}

-(id)copyWithZone:(struct _NSZone *)zone
{
    return [YZHAudioManager shareAudioManager];
}

- (void)pri_setupDefault
{
//    self.playOption = [YZHAudioPlayOption defaultPlayOption];
}

+(NSDictionary*)_audioRecorderSettingsForRecordeFileFormat:(NSString*)format
{
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setObject:@(8000.0) forKey:AVSampleRateKey];
    //默认mp3
    AudioFormatID formatId = kAudioFormatMPEGLayer3;
    NSString *lowerFormat = [format lowercaseString];
    if ([lowerFormat isEqualToString:@"mp3"]) {
        formatId = kAudioFormatMPEGLayer3;
    }
    else if ([lowerFormat isEqualToString:@"wav"]) {
        formatId = kAudioFormatLinearPCM;
    }
    [settings setObject:@(formatId) forKey:AVFormatIDKey];
    [settings setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    [settings setObject:@(1) forKey:AVNumberOfChannelsKey];
    return settings;
}

-(AVAudioRecorder*)audioRecorder
{
    if (_audioRecorder == nil) {
        NSString *ext = [self.audioRecordeFilePath pathExtension];
        if (!IS_AVAILABLE_NSSTRNG(ext)) {
            ext = @"mp3";
            self.audioRecordeFilePath = NEW_STRING_WITH_FORMAT(@"%@.%@",self.audioRecordeFilePath,ext);
        }
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:NSURL_FROM_FILE_PATH(self.audioRecordeFilePath) settings:[YZHAudioManager _audioRecorderSettingsForRecordeFileFormat:ext] error:&error];
        NSLog(@"error=%@",error);
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        [_audioRecorder prepareToRecord];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
        [[AVAudioSession sharedInstance] setActive:YES error:NULL];
        [self _endRecorderTimer];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:[YZHWeakProxy proxyWithTarget:self] selector:@selector(_updateMetersAction:) userInfo:nil repeats:YES];
    }
    return _audioRecorder;
}

- (void)pri_setupPlayAudioSession
{
    if (self.playOption.enableProximityMonitoring) {
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                sizeof(sessionCategory),
                                &sessionCategory);
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride);
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
}

- (void)pri_setupObserver:(BOOL)add
{
    if (add) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        if ([UIDevice currentDevice].proximityMonitoringEnabled) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pri_sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
    }
    else {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        if ([UIDevice currentDevice].proximityMonitoringEnabled) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

- (void)pri_sensorStateChange:(NSNotification*)notification
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([[UIDevice currentDevice] proximityState] == YES)//黑屏
    {
        NSLog(@"Device is close to user");
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else//没黑屏幕
    {
        NSLog(@"Device is not close to user");
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    [audioSession setActive:YES error:nil];
}

-(AVAudioPlayer*)audioPlayer
{
    if (_audioPlayer == nil) {
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioPlayURL error:&error];
//        NSLog(@"error=%@",error);
        _audioPlayer.delegate = self;
        _audioPlayer.meteringEnabled = YES;
        _addSensorObserver = self.playOption.enableProximityMonitoring;
        [self pri_setupObserver:_addSensorObserver];
        [self pri_setupPlayAudioSession];
        [self _endRecorderTimer];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:[YZHWeakProxy proxyWithTarget:self] selector:@selector(_updateMetersAction:) userInfo:nil repeats:YES];
    }
    return _audioPlayer;
}

-(void)_updateMetersAction:(NSTimer*)timer
{
    if ([_audioRecorder isRecording]) {
        [self.audioRecorder updateMeters];
        float peakPower = [self.audioRecorder peakPowerForChannel:0];
//        NSLog(@"recorder-------peakPower=%f",peakPower);
        if ([self.delegate respondsToSelector:@selector(audioManager:audioRecorderUpdateMeters:)]) {
            [self.delegate audioManager:self audioRecorderUpdateMeters:peakPower];
        }
    }
    else if ([_audioPlayer isPlaying]) {
        [self.audioPlayer updateMeters];
        float peakPower = [self.audioPlayer peakPowerForChannel:0];
//        NSLog(@"player-------peakPower=%f",peakPower);
        if ([self.delegate respondsToSelector:@selector(audioManager:audioPlayerUpdateMeters:)]) {
            [self.delegate audioManager:self audioPlayerUpdateMeters:peakPower];
        }
    }
}

-(void)_endRecorderTimer
{
    [self.timer invalidate];
    self.timer = nil;
}


-(void)startRecordWithFilePath:(NSString *)filePath duration:(NSTimeInterval)duration
{
    self.audioRecordeFilePath = filePath;
    self.startRecordDuration = duration;
    
    NSInteger iDuration = duration;
    if (iDuration < 0) {
        [self.audioRecorder record];
        return;
    }
    else if (iDuration == 0) {
        duration = 60.0;
    }
    [self.audioRecorder recordForDuration:duration];
}

-(void)endRecord
{
    if (_audioRecorder.isRecording) {
        self.currentDuration = [_audioRecorder currentTime];
    }
    [_audioRecorder stop];
    [self _endRecorderTimer];
    if ([self.delegate respondsToSelector:@selector(audioManager:endRecordFilePath:duration:)]) {
        [self.delegate audioManager:self endRecordFilePath:self.audioRecordeFilePath duration:self.currentDuration];
    }
    _audioRecorder = nil;
}

-(NSTimeInterval)recordDuration
{
    if (self.audioRecorder.isRecording) {
        self.currentDuration = self.audioRecorder.currentTime;
    }
    return self.currentDuration;
}

-(void)playAudioWithURL:(NSURL*)url
{
    _playOption = [YZHAudioPlayOption defaultPlayOption];
    [self pri_startPlay:url];
}

/*
 * 进行播放录音
 */
-(void)playAudioWithURL:(NSURL*)url playOption:(YZHAudioPlayOption*)playOption
{
    _playOption = playOption;
    [self pri_startPlay:url];
}

-(void)pri_startPlay:(NSURL *)url
{
    [self endPlay];
    self.audioPlayURL = url;
    [self.audioPlayer play];
}

-(void)endPlay
{
    [_audioPlayer stop];
    _audioPlayer = nil;
    _audioPlayURL = nil;
    [self _endRecorderTimer];
    if (self.addSensorObserver) {
        [self pri_setupObserver:NO];
        self.addSensorObserver = NO;
    }
}

#pragma mark AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self _endRecorderTimer];
}

#pragma mark AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSURL *audioPlayURL = self.audioPlayURL;
    if (audioPlayURL) {
        [userInfo setObject:audioPlayURL forKey:TYPE_STR(playURL)];
    }
    NSTimeInterval duration = player.duration;
    [userInfo setObject:@(duration) forKey:TYPE_STR(duration)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YZHAudioManagerDidFinishPlayingNotification object:self userInfo:userInfo];
    
    //先进行stop
    [self endPlay];
    
    if ([self.delegate respondsToSelector:@selector(audioManager:endPlayURL:duration:)]) {
        [self.delegate audioManager:self endPlayURL:audioPlayURL duration:duration];
    }
    if (self.endPlayBlock) {
        self.endPlayBlock(self, audioPlayURL, duration);
    }
}

@end
