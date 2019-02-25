//
//  GLPaintingView.h
//  UIPaintingViewDemo
//
//  Created by yuan on 2018/1/31.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "NSPaintModel.h"

@class GLPaintingView;

@protocol GLPaintingViewDelegate <NSObject>

@optional;
-(BOOL)paintingView:(GLPaintingView*)paintingView touchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
-(BOOL)paintingView:(GLPaintingView*)paintingView touchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
-(BOOL)paintingView:(GLPaintingView *)paintingView touchEnded:(UITouch *)touch withEvent:(UIEvent *)event;

@end


@interface GLPaintingView : UIView

//default is 1.0
@property (nonatomic, assign) CGFloat brushWidth;
//default BLACK_COLOR
@property (nonatomic, copy) UIColor *brushColor;

//default is YES
@property (nonatomic, assign) BOOL touchPaintEnabled;

@property (nonatomic, weak) id<GLPaintingViewDelegate> delegate;

-(EAGLContext*)getGLContext;

//清空渲染的数据
-(void)clearFrameBuffer;

//清空局部区域的数据
-(void)clearFrameBufferInFrame:(CGRect)frame;

//将渲染好的数据显示到屏幕
-(void)presentRenderbuffer;
//进行渲染并,preset为yes就是显示到屏幕，NO的话就不显示到屏幕
-(void)renderLineFromPoint:(GLLinePoint*)from toPoint:(GLLinePoint*)to present:(BOOL)present;

-(void)renderLineFromPoint:(GLLinePoint*)from toPoint:(GLLinePoint*)to lineColor:(UIColor*)lineColor present:(BOOL)present;

//进行显示到屏幕的数据擦除
-(void)erase;

//将frame区域中的额数据擦除
-(void)eraseInFrame:(CGRect)frame;

/*
 *设置渲染混合模式
 *clear为YES时，brushColor为clear color就可以情况以前绘制的
 *clear为NO时，还原到原先的设置模式
 */
-(void)setGLBlendModel:(BOOL)clear;

-(BOOL)isInClearModel;

//获取当前渲染的场景。
-(UIImage*)snapshot;

@end
