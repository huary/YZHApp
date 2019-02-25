//
//  YZHAudioManager.m
//  wits
//
//  Created by yuan on 2018/7/30.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHAudioManager.h"
#import "YZHWeakProxy.h"
#import "YZHKitType.h"

static YZHAudioManager *shareAudioManager_s = nil;

@interface YZHAudioManager () <AVAudioRecorderDelegate,AVAudioPlayerDelegate>
/* <#注释#> */
@property (nonatomic, strong) NSString *audioRecordeFilePath;

/* <#注释#> */
@property (nonatomic, strong) NSURL *audioPlayURL;

/* <#注释#> */
@property (nonatomic, strong) NSTimer *timer;

/* <#name#> */
@property (nonatomic, assign) NSTimeInterval currentDuration;

@end

@implementation YZHAudioManager

@synthesize audioRecorder = _audioRecorder;
@synthesize audioPlayer = _audioPlayer;

+(instancetype)shareAudioManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareAudioManager_s = [[super allocWithZone:NULL] init];
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
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:[YZHWeakProxy proxyWithTarget:self] selector:@selector(_updateMetersAction:) userInfo:nil repeats:YES];
    }
    return _audioRecorder;
}

-(AVAudioPlayer*)audioPlayer
{
    if (_audioPlayer == nil) {
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioPlayURL error:&error];
//        NSLog(@"error=%@",error);
        _audioPlayer.delegate = self;
        _audioPlayer.meteringEnabled = YES;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
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
    self.currentDuration = [self.audioRecorder currentTime];
    [self.audioRecorder stop];
    [self _endRecorderTimer];
    if ([self.delegate respondsToSelector:@selector(audioManager:endRecordFilePath:duration:)]) {
        [self.delegate audioManager:self endRecordFilePath:self.audioRecordeFilePath duration:self.currentDuration];
    }
    else {
        [[NSFileManager defaultManager] removeItemAtPath:self.audioRecordeFilePath error:NULL];
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
    [self endPlay];
    self.audioPlayURL = url;
    [self.audioPlayer play];
}

-(void)endPlay
{
    self.currentDuration = _audioPlayer.currentTime;
    [_audioPlayer stop];
    _audioPlayer = nil;
}

#pragma mark AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self _endRecorderTimer];
}

#pragma mark AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if ([self.delegate respondsToSelector:@selector(audioManager:endPlayURL:duration:)]) {
        [self.delegate audioManager:self endPlayURL:self.audioPlayURL duration:self.currentDuration];
    }
    self.audioPlayURL = nil;
    _audioPlayer = nil;
}

@end
