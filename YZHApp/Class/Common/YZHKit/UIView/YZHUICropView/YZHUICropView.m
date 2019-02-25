//
//  YZHUICropView.m
//  YZHUICropView
//
//  Created by yuan on 2018/5/16.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "YZHUICropView.h"
#import "UIView+YZHAddForUIGestureRecognizer.h"
#import "YZHKitType.h"
#import <objc/runtime.h>

/*********************************************************************
 *UIPointView
 *********************************************************************/

@interface UIPointView : UIView
/** point */
@property (nonatomic, strong, readonly) UIView *point;

/** name */
@property (nonatomic, assign) CGFloat pointWidth;

@end

@implementation UIPointView

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupChildView];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupChildView];
    }
    return self;
}

-(void)_setupChildView
{
    self.backgroundColor = CLEAR_COLOR;
    _point = [UIView new];
    [self addSubview:self.point];
}

-(void)setPointWidth:(CGFloat)pointWidth
{
    _pointWidth = pointWidth;
    CGFloat x = (self.bounds.size.width - pointWidth)/2;
    CGFloat y = (self.bounds.size.height - pointWidth)/2;
    self.point.frame = CGRectMake(x, y, pointWidth, pointWidth);
    self.point.layer.cornerRadius = pointWidth/2;
}

@end


/*********************************************************************
 *UIView (UIPointView)
 *********************************************************************/
@interface UIView (UIPointView)

@property (nonatomic, strong) NSMutableArray<UIPointView*> *pointViews;

@end

@implementation UIView (UIPointView)

-(void)setPointViews:(NSMutableArray<UIPointView *> *)pointViews
{
    objc_setAssociatedObject(self, @selector(pointViews), pointViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray<UIPointView*>*)pointViews
{
    NSMutableArray *pointViews = objc_getAssociatedObject(self, _cmd);
    if (pointViews == nil) {
        pointViews = [NSMutableArray array];
        self.pointViews = pointViews;
    }
    return pointViews;
}

@end



/*********************************************************************
 *UIView (YZHUICropView)
 *********************************************************************/
@interface YZHUICropView ()

/** shapeLayer */
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

/** cropOverView */
@property (nonatomic, weak) UIView *cropOverView;

/** pointA */
@property (nonatomic, strong) UIPointView *pointA;
/** pointB */
@property (nonatomic, strong) UIPointView *pointB;
/** pointC */
@property (nonatomic, strong) UIPointView *pointC;
/** pointD */
@property (nonatomic, strong) UIPointView *pointD;

/** pointE */
@property (nonatomic, strong) UIPointView *pointE;
/** pointF */
@property (nonatomic, strong) UIPointView *pointF;
/** pointG */
@property (nonatomic, strong) UIPointView *pointG;
/** pointH */
@property (nonatomic, strong) UIPointView *pointH;

/** lineA */
@property (nonatomic, strong) UIView *lineA;

/** lineB */
@property (nonatomic, strong) UIView *lineB;

/** lineC */
@property (nonatomic, strong) UIView *lineC;

/** lineD */
@property (nonatomic, strong) UIView *lineD;

/** rect */
@property (nonatomic, assign) CGRect rect;

/** <#name#> */
@property (nonatomic, assign) CGPoint startMovePoint;

/** <#name#> */
@property (nonatomic, assign) CGFloat panPointWidth;

/** <#name#> */
@property (nonatomic, assign) CGFloat panPointWidthMaxRatio;

@end

@implementation YZHUICropView

-(instancetype)initWithCropOverView:(UIView*)cropOverView
{
    self = [super init];
    if (self) {
        self.cropOverView = cropOverView;
        [self _setupDefaultValue];
        [self _setupChildView];
    }
    return self;
}

-(void)_setupDefaultValue
{
    self.lineWidth = 2;
    self.pointWidth = 20;
    self.panPointWidth = 80;
    self.panPointWidthMaxRatio = 0.25;
    self.lineColor = BLACK_COLOR;
    self.pointColor = [WHITE_COLOR colorWithAlphaComponent:0.6];
    self.dragPointColor = [RED_COLOR colorWithAlphaComponent:0.6];
    self.outColor = [GRAY_COLOR colorWithAlphaComponent:0.3];
}

-(UIView*)_createLine:(NSLineViewTag)tag
{
    UIView *line = [UIView new];
    line.tag = tag;
    return line;
}

-(UIPointView*)_createPointView:(NSInteger)tag
{
    UIPointView *point = [UIPointView new];
    point.tag = tag;
    WEAK_SELF(weakSelf);
    [point addPanGestureRecognizerBlock:^(UIGestureRecognizer *gesture) {
        [weakSelf _pointPanAction:(UIPanGestureRecognizer*)gesture];
    }];
    return point;
}

-(void)_setupChildView
{
    self.backgroundColor = CLEAR_COLOR;
    
    self.lineA = [self _createLine:NSLineViewTagA];
    [self addSubview:self.lineA];
    
    self.lineB = [self _createLine:NSLineViewTagB];
    [self addSubview:self.lineB];
    
    self.lineC = [self _createLine:NSLineViewTagC];
    [self addSubview:self.lineC];
    
    self.lineD = [self _createLine:NSLineViewTagD];
    [self addSubview:self.lineD];
    
    self.pointA = [self _createPointView:NSPointViewTagA];
    [self addSubview:self.pointA];
    
    self.pointB = [self _createPointView:NSPointViewTagB];
    [self addSubview:self.pointB];
    
    self.pointC = [self _createPointView:NSPointViewTagC];
    [self addSubview:self.pointC];
    
    self.pointD = [self _createPointView:NSPointViewTagD];
    [self addSubview:self.pointD];
    
    
    self.pointE = [self _createPointView:NSPointViewTagE];
    [self addSubview:self.pointE];
    
    self.pointF = [self _createPointView:NSPointViewTagF];
    [self addSubview:self.pointF];
    
    self.pointG = [self _createPointView:NSPointViewTagG];
    [self addSubview:self.pointG];
    
    self.pointH = [self _createPointView:NSPointViewTagH];
    [self addSubview:self.pointH];
    
    [self.cropOverView addSubview:self];
    
    self.shapeLayer = [CAShapeLayer new];
    [self.layer addSublayer:self.shapeLayer];
    
    [self.lineA.pointViews addObject:self.pointA];
    [self.lineA.pointViews addObject:self.pointB];
    [self.lineA.pointViews addObject:self.pointE];
    
    [self.lineB.pointViews addObject:self.pointB];
    [self.lineB.pointViews addObject:self.pointC];
    [self.lineB.pointViews addObject:self.pointF];
    
    [self.lineC.pointViews addObject:self.pointC];
    [self.lineC.pointViews addObject:self.pointD];
    [self.lineC.pointViews addObject:self.pointG];
    
    [self.lineD.pointViews addObject:self.pointD];
    [self.lineD.pointViews addObject:self.pointA];
    [self.lineD.pointViews addObject:self.pointH];
    
    [self _layoutChildViews];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self _layoutChildViews];
}

-(void)_layoutChildViews
{
    self.frame = self.cropOverView.bounds;

    [self _layoutAllPointViews];
    
    [self _updateLine];
    
    self.shapeLayer.frame = self.bounds;
}

-(void)_layoutAllPointViews
{
    [self _layoutPointView:self.pointA];
    [self _layoutPointView:self.pointB];
    [self _layoutPointView:self.pointC];
    [self _layoutPointView:self.pointD];
    [self _layoutPointView:self.pointE];
    [self _layoutPointView:self.pointF];
    [self _layoutPointView:self.pointG];
    [self _layoutPointView:self.pointH];
}

-(void)_layoutPointView:(UIPointView*)pointView
{
    if (!CGSizeEqualToSize(pointView.bounds.size, CGSizeZero)) {
        return;
    }
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = self.panPointWidth;
    CGFloat h = self.panPointWidth;
    
    CGFloat W = self.bounds.size.width;
    CGFloat H = self.bounds.size.height;
    
    CGFloat minWH = MIN(W, H);
    minWH = minWH * self.panPointWidthMaxRatio;
    
    w = MIN(minWH, w);
    h = w;
    self.panPointWidth = w;
    
    CGFloat halfWidth = 0;//self.lineWidth/2;
    switch (pointView.tag) {
        case NSPointViewTagA: {
            x = -w/2 + halfWidth;
            y = -h/2 + halfWidth;
            break;
        }
        case NSPointViewTagB: {
            x = W - w/2 - halfWidth;
            y = -h/2 + halfWidth;
            break;
        }
        case NSPointViewTagC: {
            x = W - w/2 - halfWidth;
            y = H - h/2 - halfWidth;
            break;
        }
        case NSPointViewTagD: {
            x = -w/2 + halfWidth;
            y = H - h/2 - halfWidth;
            break;
        }
        case NSPointViewTagE: {
            x = (W - w)/2;
            y = -h/2 + halfWidth;
            break;
        }
        case NSPointViewTagF: {
            x = W - w/2 - halfWidth;
            y = (H - h)/2;
            break;
        }
        case NSPointViewTagG: {
            x = (W - w)/2;
            y = H - h/2 - halfWidth;
            break;
        }
        case NSPointViewTagH: {
            x = -w/2 + halfWidth;
            y = (H - h)/2;
            break;
        }
        default:
            break;
    }
    pointView.frame = CGRectMake(x, y, w, h);
    pointView.pointWidth = self.pointWidth;
    pointView.point.backgroundColor = self.pointColor;
}

-(void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
    [self _updateLine];
}

-(void)setPointWidth:(CGFloat)pointWidth
{
    _pointWidth = pointWidth;
    [self _updateAllPointWidth];
}

-(void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    [self _updateLine];
}

-(void)setPointColor:(UIColor *)pointColor
{
    _pointColor = pointColor;
    [self _updateAllPointColor];
}

-(void)setOutColor:(UIColor *)outColor
{
    _outColor = outColor;
    [self _updateShapeLayer];
}

-(void)_updateAllPointWidth
{
    for (NSInteger tag = NSPointViewTagA; tag < NSPointViewTagMax; ++tag) {
        UIPointView *pointView = [self viewWithTag:tag];
        pointView.pointWidth = self.pointWidth;
    }
}

-(void)_updateAllPointColor
{
    for (NSInteger tag = NSPointViewTagA; tag < NSPointViewTagMax; ++tag) {
        UIPointView *pointView = [self viewWithTag:tag];
        pointView.point.backgroundColor = self.pointColor;
    }
}

-(void)_updatePointView:(UIView*)pointView fromX:(CGFloat)fromX transX:(CGFloat)transX
{
    CGRect frame = pointView.frame;
    frame.origin.x = fromX + transX;
    frame.origin.x = MAX(frame.origin.x, -self.panPointWidth/2);
    frame.origin.x = MIN(frame.origin.x, self.bounds.size.width - self.panPointWidth/2);
    pointView.frame = frame;
}

-(void)_updatePointView:(UIView*)pointView fromY:(CGFloat)fromY transY:(CGFloat)transY
{
    CGRect frame = pointView.frame;
    frame.origin.y = fromY + transY;
    frame.origin.y = MAX(frame.origin.y, -self.panPointWidth/2);
    frame.origin.y = MIN(frame.origin.y, self.bounds.size.height - self.panPointWidth/2);
    pointView.frame = frame;
}

-(void)_pointPanAction:(UIPanGestureRecognizer*)gesture
{
    NSInteger tag = gesture.view.tag;
    CGPoint trans = [gesture translationInView:self];
    
    UIPointView *view = (UIPointView*)gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.startMovePoint = gesture.view.frame.origin;
        view.point.backgroundColor = self.dragPointColor;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        view.point.backgroundColor = self.pointColor;
    }
    [self _updatePoint:tag trans:trans];
}

-(void)_updatePoint:(NSPointViewTag)tag trans:(CGPoint)trans
{
    UIPointView *view = [self viewWithTag:tag];
    CGRect frame = view.frame;
    CGFloat midX = CGRectGetMidX(frame);
    CGFloat midY = CGRectGetMidY(frame);
    CGFloat W = self.bounds.size.width;
    CGFloat H = self.bounds.size.height;
    if (midX < 0 || midX > W) {
        trans.x = 0;
    }
    if (midY < 0 || midY > H) {
        trans.y = 0;
    }
    
//    NSLog(@"trans=%@",NSStringFromCGPoint(trans));
    
    switch (tag) {
        case NSPointViewTagA: {
            [self _updatePointView:self.pointA fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointH fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointD fromX:self.startMovePoint.x transX:trans.x];
            
            [self _updatePointView:self.pointA fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointE fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointB fromY:self.startMovePoint.y transY:trans.y];
            break;
        }
        case NSPointViewTagB: {
            [self _updatePointView:self.pointB fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointF fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointC fromX:self.startMovePoint.x transX:trans.x];
            
            [self _updatePointView:self.pointB fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointE fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointA fromY:self.startMovePoint.y transY:trans.y];
            break;
        }
        case NSPointViewTagC: {
            [self _updatePointView:self.pointC fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointF fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointB fromX:self.startMovePoint.x transX:trans.x];
            
            [self _updatePointView:self.pointC fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointG fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointD fromY:self.startMovePoint.y transY:trans.y];
            break;
        }
        case NSPointViewTagD: {
            [self _updatePointView:self.pointD fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointH fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointA fromX:self.startMovePoint.x transX:trans.x];
            
            [self _updatePointView:self.pointD fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointG fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointC fromY:self.startMovePoint.y transY:trans.y];
            break;
        }
        case NSPointViewTagE: {
            [self _updatePointView:self.pointA fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointE fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointB fromY:self.startMovePoint.y transY:trans.y];
            break;
        }
            
        case NSPointViewTagF: {
            [self _updatePointView:self.pointB fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointF fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointC fromX:self.startMovePoint.x transX:trans.x];
            break;
        }
        case NSPointViewTagG: {
            [self _updatePointView:self.pointC fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointG fromY:self.startMovePoint.y transY:trans.y];
            [self _updatePointView:self.pointD fromY:self.startMovePoint.y transY:trans.y];
            break;
        }
        case NSPointViewTagH: {
            [self _updatePointView:self.pointD fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointH fromX:self.startMovePoint.x transX:trans.x];
            [self _updatePointView:self.pointA fromX:self.startMovePoint.x transX:trans.x];
            break;
        }
        default:
            break;
    }
    [self _updateMidPoint];
    [self _updateLine];
    [self _updateShapeLayer];
}

-(void)_updateMidPoint
{
    CGFloat x = (CGRectGetMinX(self.pointA.frame) + CGRectGetMinX(self.pointB.frame))/2;
    CGFloat y = self.pointA.frame.origin.y;
    CGRect frame = self.pointE.frame;
    frame.origin = CGPointMake(x, y);
    self.pointE.frame = frame;
    
    x = self.pointB.frame.origin.x;
    y = (CGRectGetMinY(self.pointB.frame) + CGRectGetMinY(self.pointC.frame))/2;
    frame = self.pointF.frame;
    frame.origin = CGPointMake(x, y);
    self.pointF.frame = frame;
    
    x = (CGRectGetMinX(self.pointC.frame) + CGRectGetMinX(self.pointD.frame))/2;
    y = self.pointC.frame.origin.y;
    frame = self.pointG.frame;
    frame.origin = CGPointMake(x, y);
    self.pointG.frame = frame;
    
    x = self.pointA.frame.origin.x;
    y = (CGRectGetMinY(self.pointA.frame) + CGRectGetMinY(self.pointD.frame))/2;
    frame = self.pointF.frame;
    frame.origin = CGPointMake(x, y);
    self.pointH.frame = frame;
}

-(void)_updateLine
{
    CGFloat halfWidth = 0;//self.lineWidth/2;
    CGFloat lineWidth = 0;//self.lineWidth;
    CGFloat x = MIN(CGRectGetMidX(self.pointA.frame), CGRectGetMidX(self.pointB.frame)) - halfWidth;
    CGFloat y = CGRectGetMidY(self.pointA.frame) - halfWidth;
    CGFloat w = fabs(CGRectGetMidX(self.pointA.frame) - CGRectGetMidX(self.pointB.frame)) + lineWidth;
    CGFloat h = self.lineWidth;
    self.lineA.frame = CGRectMake(x, y, w, h);
    self.lineA.backgroundColor = self.lineColor;

    x = CGRectGetMidX(self.pointB.frame) - halfWidth;
    y = MIN(CGRectGetMidY(self.pointB.frame), CGRectGetMidY(self.pointC.frame)) - halfWidth;
    w = self.lineWidth;
    h = fabs(CGRectGetMidY(self.pointC.frame) - CGRectGetMidY(self.pointB.frame)) + lineWidth;
    self.lineB.frame = CGRectMake(x, y, w, h);
    self.lineB.backgroundColor = self.lineColor;

    x = MIN(CGRectGetMidX(self.pointC.frame), CGRectGetMidX(self.pointD.frame)) - halfWidth;
    y = CGRectGetMidY(self.pointC.frame) - halfWidth;
    w = fabs(CGRectGetMidX(self.pointC.frame) - CGRectGetMidX(self.pointD.frame)) + lineWidth;
    h = self.lineWidth;
    self.lineC.frame = CGRectMake(x, y, w, h);
    self.lineC.backgroundColor = self.lineColor;
    
    x = CGRectGetMidX(self.pointA.frame) - halfWidth;
    y = MIN(CGRectGetMidY(self.pointA.frame), CGRectGetMidY(self.pointD.frame)) - halfWidth;
    w = self.lineWidth;
    h = fabs(CGRectGetMidY(self.pointA.frame) - CGRectGetMidY(self.pointD.frame)) + lineWidth;
    self.lineD.frame = CGRectMake(x, y, w, h);
    self.lineD.backgroundColor = self.lineColor;
    
    CGRect frame = CGRectZero;
    if (self.lineA.frame.origin.y < self.lineC.frame.origin.y) {
        frame = self.lineC.frame;
        frame.origin.y -= self.lineWidth;
        self.lineC.frame = frame;

        frame = self.lineA.frame;
        frame.origin.x = MAX(frame.origin.x, 0);
        frame.origin.y = MAX(frame.origin.y, 0);
        self.lineA.frame = frame;
    }
    else {
        frame = self.lineA.frame;
        frame.origin.y -= self.self.lineWidth;
        self.lineA.frame = frame;

        frame = self.lineC.frame;
        frame.origin.x = MAX(frame.origin.x, 0);
        frame.origin.y = MAX(frame.origin.y, 0);
        self.lineC.frame = frame;
    }
    
    if (self.lineD.frame.origin.x < self.lineB.frame.origin.x) {
        frame = self.lineB.frame;
        frame.origin.x -= self.lineWidth;
        self.lineB.frame = frame;

        frame = self.lineD.frame;
        frame.origin.x = MAX(frame.origin.x, 0);
        frame.origin.y = MAX(frame.origin.y, 0);
        self.lineD.frame = frame;
    }
    else {
        frame = self.lineD.frame;
        frame.origin.x -= self.lineWidth;
        self.lineD.frame = frame;

        frame = self.lineB.frame;
        frame.origin.x = MAX(frame.origin.x, 0);
        frame.origin.y = MAX(frame.origin.y, 0);
        self.lineB.frame = frame;
    }
}

-(void)_updateShapeLayer
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *innerPath = [self cropBezierPathForType:NSCropRectTypeOut];
    [path appendPath:[innerPath bezierPathByReversingPath]];

    self.shapeLayer.path = path.CGPath;
    self.shapeLayer.fillColor = self.outColor.CGColor;
}

-(void)updatePoint:(NSPointViewTag)tag centerPoint:(CGPoint)centerPoint
{
    UIPointView *pointView = [self viewWithTag:tag];
    CGPoint old = pointView.center;
    CGPoint trans = CGPointMake(centerPoint.x - old.x, centerPoint.y - old.y);
    self.startMovePoint = pointView.frame.origin;
    [self _updatePoint:tag trans:trans];
}

-(void)updatePoint:(NSPointViewTag)tag hidden:(BOOL)hidden
{
    UIPointView *pointView = [self viewWithTag:tag];
    pointView.hidden = hidden;
}

-(void)updateLine:(NSLineViewTag)tag hiddent:(BOOL)hidden
{
    UIView *line = [self viewWithTag:tag];
    line.hidden = hidden;
    [line.pointViews enumerateObjectsUsingBlock:^(UIPointView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = hidden;
    }];
}

-(CGRect)cropRectForType:(NSCropRectType)type
{
    CGPoint aPoint = self.pointA.center;
    CGPoint bPoint = self.pointB.center;
    CGPoint cPoint = self.pointC.center;
    CGPoint dPoint = self.pointD.center;

    CGFloat minX = MIN(aPoint.x, bPoint.x);
    minX = MIN(minX, cPoint.x);
    minX = MIN(minX, dPoint.x);
    
    CGFloat minY = MIN(aPoint.y, bPoint.y);
    minY = MIN(minY, cPoint.y);
    minY = MIN(minY, dPoint.y);
    
    CGFloat maxX = MAX(aPoint.x, bPoint.x);
    maxX = MAX(maxX, cPoint.x);
    maxX = MAX(maxX, dPoint.x);
    
    CGFloat maxY = MAX(aPoint.y, bPoint.y);
    maxY = MAX(maxY, cPoint.y);
    maxY = MAX(maxY, dPoint.y);
    
    CGFloat w = maxX - minX;
    CGFloat h = maxY - minY;
    CGFloat lineWidth = self.lineWidth;
    CGFloat halfWidth = self.lineWidth/2;
    CGFloat doubleWidth = self.lineWidth * 2;
    if (type == NSCropRectTypeIn) {
        return CGRectMake(minX + lineWidth, minY + lineWidth, w - doubleWidth, h - doubleWidth);
    }
    else if (type == NSCropRectTypeMid) {
        return CGRectMake(minX + halfWidth, minY + halfWidth, w - lineWidth, h - lineWidth);
    }
    else {
        return CGRectMake(minX, minY, w, h);
    }
}

-(UIBezierPath*)cropBezierPathForType:(NSCropRectType)type
{
    CGRect rect = [self cropRectForType:type];
    return [UIBezierPath bezierPathWithRect:rect];
}
@end
