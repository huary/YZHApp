//
//  YZHAudioRecordView.h
//  YZHAudioManagerDemo
//
//  Created by yuan on 2018/9/5.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZHAlertView.h"

/****************************************************
 *<#标注#>
 ****************************************************/
@interface YZHAudioRecordBaseView : UIView
/* <#注释#> */
@property (nonatomic, strong) UILabel *titleLabel;

@end



/****************************************************
 *<#标注#>
 ****************************************************/
@interface YZHAudioRecordNormalView : YZHAudioRecordBaseView

/* <#注释#> */
@property (nonatomic, strong) UIImageView *imageView;

@end


/****************************************************
 *<#标注#>
 ****************************************************/
@interface YZHAudioRecordCountDownView : YZHAudioRecordBaseView

/* <#注释#> */
@property (nonatomic, strong) UILabel *countDownLabel;

@end


/****************************************************
 *<#标注#>
 ****************************************************/
@interface YZHAudioRecordPowerView : YZHAudioRecordBaseView

/* <#注释#> */
@property (nonatomic, strong) UIImageView *recordImageView;

/* <#注释#> */
@property (nonatomic, strong) UIImageView *powerView;

-(void)updateWithPower:(CGFloat)power;

@end



/****************************************************
 *<#标注#>
 ****************************************************/
@interface YZHAudioRecordView : UIView

@property (nonatomic, strong, readonly) YZHAlertView *alertView;

/* <#注释#> */
@property (nonatomic, strong) YZHAudioRecordNormalView *normalView;

/* <#注释#> */
@property (nonatomic, strong) YZHAudioRecordCountDownView *countDownView;

/* <#注释#> */
@property (nonatomic, strong) YZHAudioRecordPowerView *powerView;

-(void)dismiss;

@end
