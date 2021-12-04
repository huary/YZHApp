//
//  YZHButton.m
//  YZHButton
//
//  Created by yuan on 2017/7/14.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHButton.h"
#import "YZHKitType.h"
#import "NSObject+YZHAddForKVO.h"

/**********************************************************
 *YZHButtonStateInfo
 **********************************************************/
@interface YZHButtonStateInfo : NSObject

@property (nonatomic, strong) UIColor *backgroundColor;

/* <#name#> */
@property (nonatomic, assign) NSInteger state;

@end

@implementation YZHButtonStateInfo
-(instancetype)initWithBackgroundColor:(UIColor*)backgroundColor state:(NSInteger)state
{
    self = [super init];
    if (self) {
        self.backgroundColor = backgroundColor;
        self.state = state;
    }
    return self;
}
@end


/**********************************************************
 *YZHButtonStateInfo
 **********************************************************/
@interface YZHButton ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber*, UIColor*> *backgroundColorStateInfo;
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, UIColor*> *borderColorStateInfo;
@property (nonatomic, strong) NSMutableDictionary<NSNumber*, NSNumber*> *borderWidthStateInfo;

@end

@implementation YZHButton

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self _setupDefault];
        [self _addKVOForState:YES];
    }
    return self;
}

-(void)_setupDefault
{
    self.layoutChangeBounds = YES;
    self.layoutStyle = -1;
}

-(void)_addKVOForState:(BOOL)add
{
    if (add) {
        [self hz_addKVOObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:NULL];
        [self hz_addKVOObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:NULL];
        [self hz_addKVOObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:NULL];
    }
    else {
        [self hz_removeKVOObserver:self forKeyPath:@"enabled" context:NULL];
        [self hz_removeKVOObserver:self forKeyPath:@"selected" context:NULL];
        [self hz_removeKVOObserver:self forKeyPath:@"highlighted" context:NULL];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [self _updateStateInfo];
}

-(void)_updateStateInfo
{
    UIControlState state = self.state;
    UIColor *bgColor = self.backgroundColorStateInfo[@(state)];
    
    UIColor *borderColor = self.borderColorStateInfo[@(state)];
    
    CGFloat borderWidth = [self.borderWidthStateInfo[@(state)] floatValue];
    
    if (bgColor) {
//        self.backgroundColor = bgColor;
        [super setBackgroundColor:bgColor];
    }
    
    self.layer.borderWidth = MAX(borderWidth, 0);
    
    if (borderColor) {
        self.layer.borderColor = borderColor.CGColor;
    }
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self _layoutImageTitleView];    
}

-(void)_layoutImageTitleView
{
    if (self.layoutStyle < 0) {
        return;
    }
    CGSize contentSize = self.bounds.size;
    
//    CGSize imageSize = self.currentImage.size;
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    if (CGSizeEqualToSize(imageSize, CGSizeZero) && CGSizeEqualToSize(titleSize, CGSizeZero)) {
        return;
    }
    CGSize titleFitSize = [self.titleLabel sizeThatFits:titleSize];
    if (titleFitSize.width > titleSize.width || titleFitSize.height > titleSize.height) {
        titleSize = titleFitSize;
    }
    
    CGFloat IX = 0;
    CGFloat IY = 0;
    CGFloat IW = 0;
    CGFloat IH = 0;
    
    CGFloat TX = 0;
    CGFloat TY = 0;
    CGFloat TW = 0;
    CGFloat TH = 0;
    
    CGFloat itemSpaceV = 0;
    CGFloat itemSpaceH = 0;
        
    NSInteger layoutStyle = TYPE_AND(self.layoutStyle, NSButtonLayoutStyleCustomMask);
    if (layoutStyle) {
        if (layoutStyle == NSButtonLayoutStyleCustomRatio) {
            TX = self.titleEdgeInsetsRatio.left * contentSize.width;
            TY = self.titleEdgeInsetsRatio.top * contentSize.height;
            TW = (1 - self.titleEdgeInsetsRatio.left - self.titleEdgeInsetsRatio.right) * contentSize.width;
            TH = (1 - self.titleEdgeInsetsRatio.top - self.titleEdgeInsetsRatio.bottom) * contentSize.height;
            
            IX = self.imageEdgeInsetsRatio.left * contentSize.width;
            IY = self.imageEdgeInsetsRatio.top * contentSize.height;
            IW = (1 - self.imageEdgeInsetsRatio.left - self.imageEdgeInsetsRatio.right) * contentSize.width;
            IH = (1 - self.imageEdgeInsetsRatio.top - self.imageEdgeInsetsRatio.bottom) * contentSize.height;
        }
        else if (layoutStyle == NSButtonLayoutStyleCustomInset)
        {
            TX = self.titleEdgeInsetsRatio.left;
            TY = self.titleEdgeInsetsRatio.top;
            TW = contentSize.width - TX - self.titleEdgeInsetsRatio.right;
            TH = contentSize.height - TY - self.titleEdgeInsetsRatio.bottom;
            
            IX = self.imageEdgeInsetsRatio.left;
            IY = self.imageEdgeInsetsRatio.top;
            IW = contentSize.width - IX - self.imageEdgeInsetsRatio.right;
            IH = contentSize.height - IY - self.imageEdgeInsetsRatio.bottom;
        }
    }
    else
    {
        if (TYPE_AND(self.layoutStyle, NSButtonLayoutStyleSpaceMask) == NSButtonLayoutStyleEQSpace) {
            itemSpaceV = (contentSize.height - imageSize.height - titleSize.height) / 3;
            itemSpaceH = (contentSize.width - imageSize.width - titleSize.width) / 3;
        }
        else if (TYPE_AND(self.layoutStyle, NSButtonLayoutStyleSpaceMask) == NSButtonLayoutStyleCustomSpace)
        {
            itemSpaceV = self.imageTitleSpace;
            itemSpaceH = self.imageTitleSpace;
        }
        
        switch (TYPE_AND(self.layoutStyle, NSButtonLayoutStyleMask)) {
            case NSButtonLayoutStyleLR:
            {
                
                IX = (contentSize.width- (imageSize.width + titleSize.width + itemSpaceH))/2;
                IY = (contentSize.height - imageSize.height)/2;
                IW = imageSize.width;
                IH = imageSize.height;

                TX = IX + IW + itemSpaceH;
                TY = (contentSize.height - titleSize.height)/2;
                TW = titleSize.width;
                TH = titleSize.height;
                break;
            }
            case NSButtonLayoutStyleRL:
            {
                TX = (contentSize.width - (imageSize.width + titleSize.width + itemSpaceH))/2;
                TY = (contentSize.height - titleSize.height)/2;
                TW = titleSize.width;
                TH = titleSize.height;
                
                IX = TX + TW + itemSpaceH;
                IY = (contentSize.height - imageSize.height)/2;
                IW = imageSize.width;
                IH = imageSize.height;
                
                break;
            }
            case NSButtonLayoutStyleUD:
            {
                IX = (contentSize.width - imageSize.width)/2;
                IY = (contentSize.height - (imageSize.height + titleSize.height + itemSpaceV))/2;
                IW = imageSize.width;
                IH = imageSize.height;
                
                TX = (contentSize.width - titleSize.width)/2;
                TY = IY + IH + itemSpaceV;
                TW = titleSize.width;
                TH = titleSize.height;
                break;
            }
            case NSButtonLayoutStyleDU:
            {
                TX = (contentSize.width - titleSize.width)/2;
                TY = (contentSize.height - (imageSize.height + titleSize.height + itemSpaceV))/2;
                TW = titleSize.width;
                TH = titleSize.height;
                
                IX = (contentSize.width - imageSize.width)/2;
                IY = TY + TH + itemSpaceV;
                IW = imageSize.width;
                IH = imageSize.height;
                break;
            }
            default:
                break;
        }
        
        if (TYPE_AND(self.contentAlignment, NSButtonContentAlignmentLeft)) {
            CGFloat shiftX = MIN(IX, TX);
            IX = IX - shiftX;
            TX = TX - shiftX;
        }
        else if (TYPE_AND(self.contentAlignment, NSButtonContentAlignmentRight))
        {
            CGFloat shiftX = contentSize.width - MAX(IX + IW, TX + TW);
            IX = IX + shiftX;
            TX = TX + shiftX;
        }
        
        if (TYPE_AND(self.contentAlignment, NSButtonContentAlignmentUp)) {
            CGFloat shiftY = MIN(IY, TY);
            IY = IY - shiftY;
            TY = TY - shiftY;
        }
        else if (TYPE_AND(self.contentAlignment, NSButtonContentAlignmentDown))
        {
            CGFloat shiftY = contentSize.height - MAX(IY + IH, TY + TH);
            IY = IY + shiftY;
            TY = TY + shiftY;
        }
    }
        
    self.imageView.frame = CGRectMake(IX, IY, IW, IH);
    self.titleLabel.frame = CGRectMake(TX, TY, TW, TH);
    if (self.circleCornerImageView) {
        self.imageView.layer.cornerRadius = MIN(IW, IH)/2;
    }
    if (self.layoutChangeBounds == NO) {
        return;
    }

    CGFloat minX = MIN(IX, TX);
    CGFloat maxX = MAX(CGRectGetMaxX(self.imageView.frame), CGRectGetMaxX(self.titleLabel.frame));
    CGFloat minY = MIN(IY, TY);
    CGFloat maxY = MAX(CGRectGetMaxY(self.imageView.frame), CGRectGetMaxY(self.titleLabel.frame));
    
    CGFloat W = maxX - minX;
    CGFloat H = maxY - minY;
    
    CGFloat maxW = MAX(contentSize.width, W);
    CGFloat maxH = MAX(contentSize.height, H);
    
    CGFloat x = (contentSize.width - maxW)/2;
    CGFloat y = (contentSize.height - maxH)/2;
    
    CGRect bounds = CGRectMake(x, y, maxW, maxH);
//    NSLog(@"bounds=%@",NSStringFromCGRect(bounds));

    self.bounds = bounds;
}

//改变titleLabel或者imageView的backgroundColor会影响layout
-(void)_forceUpdateLayout
{
    UIColor *backgroundColor = self.titleLabel.backgroundColor;
    if (!backgroundColor) {
        backgroundColor = CLEAR_COLOR;
    }
    self.titleLabel.backgroundColor = backgroundColor;
    
    backgroundColor = self.imageView.backgroundColor;
    if (!backgroundColor) {
        backgroundColor = CLEAR_COLOR;
    }
    self.imageView.backgroundColor = backgroundColor;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    [self setBackgroundColor:backgroundColor forState:self.state];
}

-(void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    [self _forceUpdateLayout];
}

-(void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    [self _forceUpdateLayout];
}

-(NSMutableDictionary<NSNumber*, UIColor*>*)backgroundColorStateInfo
{
    if (!_backgroundColorStateInfo) {
        _backgroundColorStateInfo = [NSMutableDictionary dictionary];
    }
    return _backgroundColorStateInfo;
}

-(NSMutableDictionary<NSNumber*, UIColor*>*)borderColorStateInfo
{
    if (!_borderColorStateInfo) {
        _borderColorStateInfo = [NSMutableDictionary dictionary];
    }
    return _borderColorStateInfo;
}

-(NSMutableDictionary<NSNumber*, NSNumber*>*)borderWidthStateInfo
{
    if (!_borderWidthStateInfo) {
        _borderWidthStateInfo = [NSMutableDictionary dictionary];
    }
    return _borderWidthStateInfo;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state
{
    if (backgroundColor == nil) {
        backgroundColor = CLEAR_COLOR;
    }
    [self.backgroundColorStateInfo setObject:backgroundColor forKey:@(state)];
    [self _updateStateInfo];
}

- (void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)state
{
    if (borderColor == nil) {
        borderColor = CLEAR_COLOR;
    }
    [self.borderColorStateInfo setObject:borderColor forKey:@(state)];
    [self _updateStateInfo];
}

- (void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)state
{
    borderWidth = MAX(borderWidth, 0);
    [self.borderWidthStateInfo setObject:@(borderWidth) forKey:@(state)];
    [self _updateStateInfo];
}


-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL should = YES;
    if (self.beginTrackingBlock) {
        should = self.beginTrackingBlock(self, touch, event);
    }
    return should;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(nullable UIEvent *)event
{
    BOOL should = YES;
    if (self.continueTrackingBlock) {
        should = self.continueTrackingBlock(self, touch, event);
    }
    return should;
}

- (void)endTrackingWithTouch:(nullable UITouch *)touch withEvent:(nullable UIEvent *)event
{
    if (self.endTrackingBlock) {
        self.endTrackingBlock(self, touch, event);
    }
}
- (void)cancelTrackingWithEvent:(nullable UIEvent *)event
{
    if (self.cancelTrackingBlock) {
        self.cancelTrackingBlock(self, event);
    }
}

-(void)dealloc
{
    [self _addKVOForState:NO];
}
@end
