//
//  YZHHoverView.m
//  OfficeLensDemo
//
//  Created by yuan on 2017/5/2.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHHoverView.h"
#import "YZHButton.h"
#import "YZHHoverActionCell.h"
#import "YZHKitType.h"

const CGFloat timeInterval = 0.5;
//const CGFloat normalAlpha = 0.2;


@implementation YZHHoverActionModel

-(instancetype)initWithImage:(UIImage*)image title:(NSString*)title hoverActionBlock:(YZHHoverActionBlock)hoverActionBlock
{
    self = [super init];
    if (self) {
        self.hoverImage = image;
        self.hoverTitle = title;
        self.hoverActionBlock = hoverActionBlock;
    }
    return self;
}

-(instancetype)initWithImageName:(NSString*)imageName title:(NSString*)title hoverActionBlock:(YZHHoverActionBlock)hoverActionBlock
{
    self = [super init];
    if (self) {
        self.hoverImage = [UIImage imageNamed:imageName];
        self.hoverTitle = title;
        self.hoverActionBlock = hoverActionBlock;
    }
    return self;
}

@end



/******************************************************************************
 *YZHHoverView
 ******************************************************************************/

@interface YZHHoverView () <UIGestureRecognizerDelegate,UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray<YZHHoverActionModel*> *actionItems;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) UIView *showInView;

/* <#注释#> */
@property (nonatomic, strong) YZHHoverActionModel *hoverActionModel;
@end


@implementation YZHHoverView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupDefaultValue];
        [self _setupGesture];
        [self _setupChildView];
    }
    return self;
}

-(void)_setupDefaultValue
{
    self.delayToNormalTimeInterval = 5;
    self.normalAlpha = 0.1;
    self.expandShowItemCnt = 5;
    self.edgeSpace = 3;
    self.autoAdjustNormalPosition = YES;
    _isExpand = NO;
    self.flexDirection = YZHHoverViewFlexDirectionAny;
    
    self.hoverActionModel = [[YZHHoverActionModel alloc] init];
}


-(void)_setupGesture
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panAction:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}

-(UICollectionViewFlowLayout*)flowLayout
{
    if (_flowLayout == nil) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
    }
    return _flowLayout;
}

-(UICollectionView*)collectionView
{
    if (_collectionView== nil) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = self.backgroundColor;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.collectionView registerClass:[YZHHoverActionCell class] forCellWithReuseIdentifier:NSSTRING_FROM_CLASS(YZHHoverActionCell)];
    }
    return _collectionView;
}

-(void)_resetNewCollectionViewWithItemSize:(CGSize)itemSize scrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    self.flowLayout.itemSize = itemSize;
    self.flowLayout.scrollDirection = scrollDirection;
    [self.flowLayout invalidateLayout];
    
    if (self.collectionView.superview == nil) {
        [self addSubview:self.collectionView];
    }
}

-(void)_setupChildView
{
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleRightMargin;

    [self _resetNewCollectionViewWithItemSize:CGSizeZero scrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    _hoverButton = [YZHButton buttonWithType:UIButtonTypeCustom];
    self.hoverButton.tag = 1;
    [self addSubview:self.hoverButton];
    [self.hoverButton addTarget:self action:@selector(_hoverBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.hoverActionModel.button = self.hoverButton;
    
    self.frame = [self _adjustFrameWithFrame:self.frame];
}

-(void)_hoverBtnAction:(YZHButton*)button
{
    if ([self _isInExtension]) {
        [self hoverShrink];
    }
    else
    {
        [self hoverExpand];
    }
//    if (self.hoverAction) {
//
//        YZHHoverActionModel *actionModel = [[YZHHoverActionModel alloc] initWithImage:button.imageView.image title:button.titleLabel.text hoverActionBlock:self.hoverAction];
//
//        self.hoverAction(self, actionModel, 0);
//    }
}


-(void)layoutSubviews
{
    CGSize size = [self _getHoverImageViewBounds].size;
    self.layer.cornerRadius = size.width/2;
    self.clipsToBounds = YES;
    
    self.hoverButton.layer.cornerRadius =size.width/2;
    self.hoverButton.clipsToBounds = YES;
    
    [self bringSubviewToFront:self.hoverButton];
    
    if (self.actionItemWidth <= 0) {
        self.actionItemWidth = size.width;
    }
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected) {
        self.alpha = 1.0;
        [self _changeAlphaAnimate];
    }
}

-(CGRect)_getHoverImageViewBounds
{
    CGSize size = self.bounds.size;
    CGFloat min = MIN(size.width, size.height);
    return CGRectMake(0, 0, min, min);
}

-(CGRect)_getHoverImageViewFrame
{
    CGRect frame = self.hoverButton.frame;//self.frame;
    frame = [self convertRect:frame toView:self.superview];
    return frame;
}

-(NSDictionary*)_getSelectFrameInfo
{
    CGRect frame = self.frame;
    
    NSInteger showItemsCnt = self.actionItems.count;
    showItemsCnt = MAX(1, showItemsCnt);
    showItemsCnt = MIN(self.expandShowItemCnt, showItemsCnt);
    
    CGSize hoverBtnSize = [self _getHoverImageViewBounds].size;
    CGFloat min = self.actionItemWidth;
    CGFloat max = hoverBtnSize.width + showItemsCnt * min;
    
    CGSize showInViewSize = self.showInView.bounds.size;
    YZHHoverViewFlexDirection flexDir = YZHHoverViewFlexDirectionRight;
    CGFloat rotateAngle = 0;
    
    if (frame.origin.x + max < showInViewSize.width && TYPE_AND(self.flexDirection, YZHHoverViewFlexDirectionRight)) {
        frame.size = CGSizeMake(max, frame.size.height);
        flexDir = YZHHoverViewFlexDirectionRight;
        rotateAngle = M_PI_2;
    }
    else if (frame.origin.x - max + min > 0 && TYPE_AND(self.flexDirection, YZHHoverViewFlexDirectionLeft))
    {
        frame = CGRectMake(frame.origin.x - max + min, frame.origin.y, max, frame.size.height);
        flexDir = YZHHoverViewFlexDirectionLeft;
        rotateAngle = -M_PI_2;
    }
    else if (frame.origin.y + max < showInViewSize.height && TYPE_AND(self.flexDirection, YZHHoverViewFlexDirectionDown))
    {
        frame.size = CGSizeMake(frame.size.width, max);
        flexDir = YZHHoverViewFlexDirectionDown;
        rotateAngle = -M_PI;
    }
    else if (frame.origin.y - max + min > 0 && TYPE_AND(self.flexDirection, YZHHoverViewFlexDirectionUp))
    {
        frame = CGRectMake(frame.origin.x, frame.origin.y-max + min, frame.size.width, max);
        flexDir = YZHHoverViewFlexDirectionUp;
        rotateAngle = M_PI;
    }
    else
    {
        if (TYPE_AND(self.flexDirection, YZHHoverViewFlexDirectionUp)) {
            max = MIN(showInViewSize.height, max);
            flexDir = YZHHoverViewFlexDirectionUp;
            frame = CGRectMake(frame.origin.x, 0, frame.size.width, max);
            rotateAngle = M_PI;
        }
        else if (TYPE_AND(self.flexDirection, YZHHoverViewFlexDirectionDown)) {
            max = MIN(showInViewSize.height, max);
            flexDir = YZHHoverViewFlexDirectionDown;
            frame = CGRectMake(frame.origin.x, showInViewSize.height - max, frame.size.width, max);
            rotateAngle = -M_PI;
        }
        else if (TYPE_AND(self.flexDirection, YZHHoverViewFlexDirectionRight)) {
            max = MIN(showInViewSize.width, max);
            flexDir = YZHHoverViewFlexDirectionRight;
            frame = CGRectMake(showInViewSize.width - max, frame.origin.y, max, frame.size.height);
            rotateAngle = M_PI_2;
        }
        else if (TYPE_AND(self.flexDirection, YZHHoverViewFlexDirectionLeft)) {
            max = MIN(showInViewSize.width, max);
            flexDir = YZHHoverViewFlexDirectionLeft;
            frame = CGRectMake(0, frame.origin.y, max, frame.size.height);
            rotateAngle = -M_PI_2;
        }
    }
    NSDictionary *dict = @{TYPE_STR(HoverViewFlexDirection):@(flexDir),TYPE_STR(HoverViewFrame):[NSValue valueWithCGRect:frame],TYPE_STR(HoverViewRotateAngle):@(rotateAngle)};
    return dict;
}

-(BOOL)_isInExtension
{
    return self.isExpand;
}

-(void)_changeAlphaAnimate
{
    if (self.delayToNormalTimeInterval > 0) {
        [UIView animateWithDuration:timeInterval delay:self.delayToNormalTimeInterval options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.alpha = self.normalAlpha;
        } completion:nil];
    }
}

-(void)hoverShrink
{
    self.alpha = 1.0;
    
    _isExpand = NO;

//    [self bringSubviewToFront:self.hoverButton];
//    [self sendSubviewToBack:self.collectionView];
    
    CGRect frame = [self _getHoverImageViewFrame];
    CGRect bounds = [self _getHoverImageViewBounds];
    [UIView animateWithDuration:timeInterval animations:^{
        self.frame = frame;
        self.hoverButton.frame = bounds;
        self.collectionView.alpha = 0;
    } completion:^(BOOL finished) {
        self.collectionView.frame = CGRectZero;
    }];
    [self _changeAlphaAnimate];
    
    if (self.hoverAction) {
        self.hoverAction(self, self.hoverActionModel, 0);
    }
}

-(void)hoverExpand
{
    self.alpha = 1.0;
    
    _isExpand = YES;
    
    [self _updateHoverView];
    
    [self _changeAlphaAnimate];
    
    [self.collectionView reloadData];
    
    if (self.hoverAction) {
        self.hoverAction(self, self.hoverActionModel, 0);
    }
}

-(void)_updateHoverView
{
    NSDictionary *info = [self _getSelectFrameInfo];
    CGSize hoverBtnSize = [self _getHoverImageViewBounds].size;
    
    CGRect hoverBtnFrame = CGRectMake(0, 0, hoverBtnSize.width, hoverBtnSize.height);
    CGRect collectionViewFrame = CGRectZero;
    
    CGRect frame = [info[TYPE_STR(HoverViewFrame)] CGRectValue];
    
    YZHHoverViewFlexDirection flexDir = [info[TYPE_STR(HoverViewFlexDirection)] integerValue];
    if (flexDir == YZHHoverViewFlexDirectionLeft || flexDir == YZHHoverViewFlexDirectionRight) {
        
        [self _resetNewCollectionViewWithItemSize:CGSizeMake(self.actionItemWidth, hoverBtnSize.height) scrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        if (flexDir == YZHHoverViewFlexDirectionLeft) {
            collectionViewFrame = CGRectMake(0, 0, frame.size.width - hoverBtnSize.width, hoverBtnSize.height);
            hoverBtnFrame = CGRectMake(frame.size.width - hoverBtnSize.width, 0, hoverBtnSize.width, hoverBtnSize.height);
        }
        else
        {
            collectionViewFrame = CGRectMake(hoverBtnSize.width, 0, frame.size.width-hoverBtnSize.width, hoverBtnSize.height);
        }
    }
    else if (flexDir == YZHHoverViewFlexDirectionUp || flexDir == YZHHoverViewFlexDirectionDown)
    {
        [self _resetNewCollectionViewWithItemSize:CGSizeMake(hoverBtnSize.width,self.actionItemWidth) scrollDirection:UICollectionViewScrollDirectionVertical];
        
        if (flexDir == YZHHoverViewFlexDirectionUp) {
            collectionViewFrame = CGRectMake(0, 0, hoverBtnSize.width, frame.size.height - hoverBtnSize.height);
            hoverBtnFrame = CGRectMake(0, frame.size.height - hoverBtnSize.height, hoverBtnSize.width, hoverBtnSize.height);
        }
        else
        {
            collectionViewFrame = CGRectMake(0, hoverBtnSize.height, hoverBtnSize.width, frame.size.height - hoverBtnSize.height);
        }
    }
    //    [self bringSubviewToFront:self.hoverButton];
    //    [self sendSubviewToBack:self.collectionView];
    
    self.collectionView.frame = collectionViewFrame;
    
    [UIView animateWithDuration:timeInterval animations:^{
        self.frame = frame;
        self.hoverButton.frame = hoverBtnFrame;
        self.collectionView.alpha = 1.0;
    }];
}

-(void)setFrame:(CGRect)frame
{
    frame = [self _adjustFrameWithFrame:frame];
    super.frame = frame;
}

-(CGRect)_adjustFrameWithFrame:(CGRect)frame
{
    if (self.showInView == nil) {
        return frame;
    }
    CGSize size = self.showInView.bounds.size;
    CGRect bounds = [self _getHoverImageViewBounds];
    
    CGFloat x = frame.origin.x;
    x = MAX(self.edgeSpace, x);
    x = MIN(x, size.width - bounds.size.width - self.edgeSpace);
    x = MAX(self.edgeSpace, x);
    
    CGFloat y = frame.origin.y;
    y = MAX(self.edgeSpace, y);
    y = MIN(y, size.height - bounds.size.height - self.edgeSpace);
    y = MAX(self.edgeSpace, y);
    
    if (!self.autoAdjustNormalPosition) {
        return CGRectMake(x, y, frame.size.width, frame.size.height);
    }
    if ((x > self.edgeSpace && (x + bounds.size.width + self.edgeSpace) < size.width) && (y > self.edgeSpace && (y + bounds.size.height + self.edgeSpace) < size.height)) {
#if 1
        CGFloat top = CGRectGetMidY(frame);
        CGFloat left = CGRectGetMidX(frame);
        CGFloat bottom = size.height - top;
        CGFloat right = size.width - left;
        

        CGFloat shiftX = 0;
        CGFloat shiftY = 0;
        if (top < bottom) {
            shiftY = -top;
        }
        else {
            shiftY = bottom;
        }
        
        if (left < right) {
            shiftX = -left;
        }
        else {
            shiftX = right;
        }
        
        if (fabs(shiftX) < fabs(shiftY)) {
            if (shiftX <= 0) {
                x = self.edgeSpace;
            }
            else {
                x = size.width - frame.size.width - self.edgeSpace;
            }
        }
        else {
            if (shiftY <= 0) {
                y = self.edgeSpace;
            }
            else {
                y = size.height - frame.size.height - self.edgeSpace;
                
            }
        }
#else
        CGFloat shiftX = 0;
        CGFloat shiftY = 0;
        if (CGRectGetMidX(frame) < size.width/2) {
            shiftX = x;
            if (CGRectGetMidY(frame) < size.height/2) {
                shiftY = y;
                if (shiftX < shiftY) {
                    x = 0;
                }
                else
                {
                    y = 0;
                }
            }
            else
            {
                shiftY = size.height -CGRectGetMaxY(frame);
                if (shiftX < shiftY) {
                    x = 0;
                }
                else
                {
                    y = size.height - frame.size.height;
                }
            }
        }
        else
        {
            shiftX = size.width - CGRectGetMaxX(frame);
            if (CGRectGetMidY(frame) < size.height/2) {
                shiftY = y;
                if (shiftX < shiftY) {
                    x = size.width - frame.size.width;
                }
                else
                {
                    y = 0;
                }
            }
            else
            {
                shiftY = size.height -CGRectGetMaxY(frame);
                if (shiftX < shiftY) {
                    x = size.width - frame.size.width;
                }
                else
                {
                    y = size.height - frame.size.height;
                }
            }
        }
#endif
    }
    return CGRectMake(x, y, frame.size.width, frame.size.height);
}

-(void)_panAction:(UIPanGestureRecognizer*)pan
{
    CGPoint point = [pan locationInView:self.showInView];
    CGRect bounds = [self _getHoverImageViewBounds];
    
    CGSize size = self.showInView.bounds.size;

    CGFloat x = point.x - bounds.size.width/2;
    x = MAX(self.edgeSpace, x);
    x = MIN(x, size.width - bounds.size.width - self.edgeSpace);
    CGFloat y = point.y - bounds.size.height/2;
    y = MAX(self.edgeSpace, y);
    y = MIN(y, size.height - bounds.size.height - self.edgeSpace);
    CGRect frame =  CGRectMake(x, y, bounds.size.width, bounds.size.height);
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self hoverShrink];
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {
        super.frame = frame;
    }
    else if (pan.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:timeInterval animations:^{
            self.frame = frame;
        }];
        [self _changeAlphaAnimate];
    }
}

-(NSMutableArray<YZHHoverActionModel*>*)actionItems
{
    if (_actionItems == nil) {
        _actionItems = [NSMutableArray array];
    }
    return _actionItems;
}

-(YZHHoverActionModel *)addHoverActionWithImage:(UIImage*)image title:(NSString*)title hoverActionBlock:(YZHHoverActionBlock)hoverActionBlock
{
    
    YZHHoverActionModel *action = [[YZHHoverActionModel alloc] initWithImage:image title:title hoverActionBlock:hoverActionBlock];
    [self.actionItems addObject:action];
    return action;
}

-(YZHHoverActionModel *)addHoverActionWithImageName:(NSString*)imageName title:(NSString*)title hoverActionBlock:(YZHHoverActionBlock)hoverActionBlock;
{
    return [self addHoverActionWithImage:[UIImage imageNamed:imageName] title:title hoverActionBlock:hoverActionBlock];
}

-(void)addHoverAction:(YZHHoverActionModel *)action
{
    if (action == nil) {
        return;
    }
    if ([self.actionItems containsObject:action]) {
        return;
    }
    [self.actionItems addObject:action];
//    [self _updateHoverView];
//    [self.collectionView reloadData];
}

-(void)updateHoverAction:(YZHHoverActionModel *)action atIndex:(NSInteger)index
{
    if (!IS_IN_ARRAY_FOR_INDEX(self.actionItems, index)) {
        return;
    }
    if (action) {
        self.actionItems[index] = action;
    }
    else {

        [self.actionItems removeObjectAtIndex:index];
    }
}

-(void)updateHoverAction:(YZHHoverActionModel *)action withOldAction:(YZHHoverActionModel *)oldAction
{
    NSInteger index = [self.actionItems indexOfObject:oldAction];
    [self updateHoverAction:action atIndex:index];
}

-(void)updateHoverAction:(YZHHoverActionModel *)action withOldActionIdentity:(NSInteger)actionIdentity
{
    __block NSInteger findIdx = -1;
    [self.actionItems enumerateObjectsUsingBlock:^(YZHHoverActionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.actionIdentity == actionIdentity) {
            findIdx = idx;
            *stop = YES;
        }
    }];
    if (findIdx < 0) {
        [self addHoverAction:action];
        [self reloadData];
    }
    else {
        [self updateHoverAction:action atIndex:findIdx];
    }
}

-(void)reloadData
{
    [self _updateHoverView];
    [self.collectionView reloadData];
}

-(void)showInView:(UIView*)showInView
{
    self.showInView = showInView;
    if (!self.showInView) {
        self.showInView = [UIApplication sharedApplication].keyWindow;
    }
    [self.showInView addSubview:self];
    self.hoverButton.frame = [self _getHoverImageViewBounds];
    
    [self.collectionView reloadData];
}

#pragma mark UICollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.actionItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YZHHoverActionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSSTRING_FROM_CLASS(YZHHoverActionCell) forIndexPath:indexPath];
    YZHHoverActionModel *action = self.actionItems[indexPath.item];
    cell.actionModel = action;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YZHHoverActionModel *action = self.actionItems[indexPath.item];
    if (action.hoverActionBlock) {
        action.hoverActionBlock(self, action, indexPath.item + 1);
    }
    self.alpha = 1.0;
    [self _changeAlphaAnimate];
}

#pragma mark UIGestureRecognizerDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end
