//
//  YZHExcelItemCell.m
//  YZHApp
//
//  Created by yuan on 2017/7/17.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHExcelItemCell.h"
#import "YZHKitType.h"
#import "UIView+YZHAdd.h"
#import "CALayer+YZHAdd.h"

@interface YZHExcelItemCell ()

@property (nonatomic, strong) CALayer *firstSeparatorLine;
@property (nonatomic, strong) CALayer *separatorLine;
@property (nonatomic, strong) UIView *excelCellView;

@end

@implementation YZHExcelItemCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupDefaultValue];
        [self _setupCellChildView];
    }
    return self;
}

-(void)_setupDefaultValue
{
    self.verticalLineWidth = 1.0;
    self.verticalLineColor = BLACK_COLOR;
}

-(CALayer*)_createSeparatorLine
{
    CALayer *separatorLine = [[CALayer alloc] init];
    separatorLine.backgroundColor = self.verticalLineColor.CGColor;
    return separatorLine;
}

-(void)_setupCellChildView
{
    self.separatorLine = [self _createSeparatorLine];
    [self.contentView.layer addSublayer:self.separatorLine];
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    [self _updateSubViews];
}

-(void)_createFirstSeparatorLine
{
    if (self.indexPath == nil) {
        return;
    }
    if (self.indexPath.hz_excelColumn != 0) {
        return;
    }
    if (self.firstSeparatorLine == nil) {
        self.firstSeparatorLine = [self _createSeparatorLine];
        [self.contentView.layer addSublayer:self.firstSeparatorLine];
    }
}

-(void)_updateSubViews
{
    CGSize size = self.bounds.size;
    
    [self _createFirstSeparatorLine];
    
    CGFloat verticalLineWidth = self.verticalLineWidth;
    if (self.verticalLineType == NSExcelSeparatorLineTypeNone) {
        verticalLineWidth = 0;
    }

    CGFloat x = 0;
    CGFloat cellWidth = size.width - verticalLineWidth;
    if (self.indexPath.hz_excelColumn == 0) {
        self.firstSeparatorLine.hidden = NO;
        self.firstSeparatorLine.hz_left = 0;
        self.firstSeparatorLine.hz_size = CGSizeMake(verticalLineWidth, size.height);
        self.firstSeparatorLine.hz_bottom = self.contentView.hz_bottom;
        x = verticalLineWidth;
        cellWidth = cellWidth - verticalLineWidth;
        
        self.firstSeparatorLine.backgroundColor = self.verticalLineColor.CGColor;
    }
    else {
        self.firstSeparatorLine.hidden = YES;
    }
    
    self.excelCellView.frame = CGRectMake(x, 0, cellWidth, size.height);
    self.separatorLine.hz_size = CGSizeMake(verticalLineWidth, size.height);
    self.separatorLine.hz_bottom = self.contentView.hz_bottom;
    self.separatorLine.hz_right = self.contentView.hz_right;
    self.separatorLine.backgroundColor = self.verticalLineColor.CGColor;
}

-(UIView*)reusableExcelCellSubView
{
    return self.excelCellView;
}

-(void)addExcelCellView:(UIView*)excelCellView
{
    if (self.excelCellView != excelCellView)
    {
        [self.excelCellView removeFromSuperview];
        self.excelCellView = excelCellView;
        if (excelCellView != nil) {
            [self.contentView addSubview:excelCellView];
        }
    }
    [self _updateSubViews];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if ([self.cellDelegate respondsToSelector:@selector(excelItemCell:touchesBegan:withEvent:)]) {
        [self.cellDelegate excelItemCell:self touchesBegan:touches withEvent:event];
    }
}

@end
