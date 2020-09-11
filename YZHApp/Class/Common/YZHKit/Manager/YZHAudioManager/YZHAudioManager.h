//
//  YZHAudioManager.h
//  wits
//
//  Created by yuan on 2018/7/30.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

UIKIT_EXTERN NSNotificationName const YZHAudioManagerDidFinishPlayingNotification;

@class YZHAudioManager;

typedef void(^YZHAudioManagerEndPlayBlock)(YZHAudioManager* audioManager, NSURL *URL, NSTimeInterval duration);

@protocol YZHAudioManagerDelegate <NSObject>

-(void)audioManager:(YZHAudioManager *)audioManager audioRecorderUpdateMeters:(float)meters;

-(void)audioManager:(YZHAudioManager *)audioManager endRecordFilePath:(NSString*)filePath duration:(NSTimeInterval)duration;

-(void)audioManager:(YZHAudioManager *)audioManager audioPlayerUpdateMeters:(float)meters;

-(void)audioManager:(YZHAudioManager *)audioManager endPlayURL:(NSURL*)URL duration:(NSTimeInterval)duration;

@end

@interface YZHAudioPlayOption : NSObject

/** 默认扬声器播放 */
@property (nonatomic, strong) AVAudioSessionCategory defaultSessionCategory;

/** 默认启用传感器进行听筒扬声器切换 */
@property (nonatomic, assign) BOOL enableProximityMonitoring;

+ (instancetype)defaultPlayOption;

@end

@interface YZHAudioManager : NSObject

/* <#注释#> */
@property (nonatomic, strong, readonly) AVAudioRecorder *audioRecorder;

/* <#注释#> */
@property (nonatomic, strong, readonly) AVAudioPlayer *audioPlayer;

/* <#注释#> */
@property (nonatomic, weak) id<YZHAudioManagerDelegate> delegate;

@property (nonatomic, copy) YZHAudioManagerEndPlayBlock endPlayBlock;

/** 播放option */
//@property (nonatomic, strong) YZHAudioPlayOption *playOption;


+(instancetype)shareAudioManager;

/*
 * 进来录音，
 * filePath是存储录音的路径
 * duration是录音时长
 * < 0表示没时间限制
 * == 0默认为60
 * > 0 用户录音的时长
 */
-(void)startRecordWithFilePath:(NSString *)filePath duration:(NSTimeInterval)duration;
/*
 * 结束录音
 */
-(void)endRecord;

-(NSTimeInterval)recordDuration;
/*
 * 进行播放录音
 */
-(void)playAudioWithURL:(NSURL*)url;

/*
 * 进行播放录音
 */
-(void)playAudioWithURL:(NSURL*)url playOption:(YZHAudioPlayOption*)playOption;

/*
 * 结束录音播放
 */
-(void)endPlay;

@end
