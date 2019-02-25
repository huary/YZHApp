//
//  UIPaintingView.h
//  UIPaintingViewDemo
//
//  Created by yuan on 2018/1/31.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "GLPaintingView.h"
#import "NSPaintModel.h"

@class UIPaintingView;
@protocol UIPaintViewDelegate <GLPaintingViewDelegate>

@optional;
-(void)paintingView:(UIPaintingView*)paintingView startPlayPaintStroke:(NSPaintStroke*)paintStroke;
-(void)paintingView:(UIPaintingView*)paintingView playingPintStroke:(NSPaintStroke*)paintStroke paintPoint:(NSPaintPoint*)paintPoint;
-(void)paintingView:(UIPaintingView*)paintingView endPlayPaintStroke:(NSPaintStroke*)paintStroke;
@end


/***********************************************************************
 *UIPaintingView
 ***********************************************************************/
@interface UIPaintingView : GLPaintingView

@property (nonatomic, strong) NSPaintEvent *paintEvent;

@property (nonatomic, assign) CGFloat maxLineWidth;

@property (nonatomic, weak) id<UIPaintViewDelegate> delegate;

//播放速率，默认为1.0
@property (nonatomic, assign) CGFloat playRatio;

//在进行render的时候会将touchPaintEnabled设置为NO,结束的时候会还原touchPaintEnabled的值
-(void)renderWithPoint:(NSPaintPoint*)paintPoint;
-(void)renderWithPoint:(NSPaintPoint*)paintPoint addToEvent:(BOOL)addToEvent;
-(void)renderWithStroke:(NSPaintStroke*)stroke addToEvent:(BOOL)addToEvent;

//在进行播放的时候会将touchPaintEnabled设置为NO，在结束或停止播放的时候还原
-(void)playBack:(BOOL)fromStart;
//停止播放
-(void)stopPlay;

//在进行undo的时候会将touchPaintEnabled设置为NO,结束的时候会还原touchPaintEnabled的值
-(void)undo;

-(void)undoFaster;

//在进行redo的时候会将touchPaintEnabled设置为NO,结束的时候会还原touchPaintEnabled的值
-(void)redo;

//在进行erase的时候会将touchPaintEnabled设置为NO,结束的时候会还原touchPaintEnabled的值
-(void)erase;

//删除绘画，连数据也一起删除
-(void)deletePaint;

-(void)deleteLastStroke;

-(void)fastPlayBack:(NSInteger)displayStrokesPerSecond;

@end







/***********************************************************************
 *UIPaintingView (PlayBack)
 ***********************************************************************/
@interface UIPaintingView (PlayBack)

@property (nonatomic, assign) int64_t playId;

@end
