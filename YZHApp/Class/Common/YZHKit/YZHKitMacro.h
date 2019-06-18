//
//  Macro.h
//  yxx_ios
//
//  Created by victor siu on 17/3/20.
//  Copyright © 2017年 yuanzh. All rights reserved.
//

#import <pthread.h>
#import "UIView+UIViewController.h"

#ifndef Macro_h
#define Macro_h

#define __DEBUG__                                DEBUG

//日志打印
#ifdef DEBUG
#   define NSLog(fmt, ...)                       NSLog(fmt, ##__VA_ARGS__);
#else
#   define NSLog(...)
#endif

//导航栏的常量宏定义，这个和系统一致
#define NAVIGATION_ITEM_VIEW_SUBVIEWS_LEFT_SPACE                                (20)
#define NAVIGATION_ITEM_VIEW_SUBVIEWS_RIGHT_SPACE                               (20)
#define CUSTOM_NAVIGATION_ITEM_VIEW_SUBVIEWS_ITEM_SPACE                         (8)
#define SYSTEM_NAVIGATION_ITEM_VIEW_SUBVIEWS_ITEM_SPACE                         (8)
#define NAVIGATION_ITEM_VIEW_LEFT_BACK_ITEM_IMAGE_WITH_TITLE_SPACE              (5)

#define NAVIGATION_ITEM_MIN_WIDTH                                               (40)
#define NAVIGATION_ITEM_IMAGE_HEIGHT_WITH_NAVIGATION_BAR_HEIGHT_RATIO           (0.4)
#define NAVIGATION_ITEM_LEFT_BACK_HEIGHT_WITH_NAVIGATION_BAR_HEIGHT_RATIO       (0.55)
#define NAVIGATION_ITEM_TITLE_FONT             [UIFont fontWithName:@"Helvetica-Bold" size:17.0]

//常用的基础宏定义
#define TYPE_AND(VA,VB)                        ((VA)&(VB))
#define TYPE_OR(VA,VB)                         ((VA)|(VB))
#define TYPE_LS(VA,LN)                         ((VA) << (LN))
#define TYPE_RS(VA,RN)                         ((VA) >> (RN))
#define TYPE_NOT(VAL)                          (!(VAL))
#define TYPE_INT_MASK                          (-1)

#define IS_EVEN_INTEGER(V)                     (TYPE_AND(V,1) == 0)
#define IS_ODD_INTEGER(V)                      TYPE_AND(V,1)

#define TYPE_STR(NAME)                          @#NAME

//屏幕尺寸大小和导航栏的一些宏定义
#define SCREEN_BOUNDS                          [UIScreen mainScreen].bounds
#define SCREEN_SCALE                           [UIScreen mainScreen].scale

#define SCREEN_WIDTH                           [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT                          [UIScreen mainScreen].bounds.size.height



#define AVAILABLE_IOS_V(IOS_V)                 ({ \
                                                    BOOL OK = NO; \
                                                    if(@available(iOS IOS_V,*)) \
                                                        OK = YES; \
                                                    OK; \
                                                })
#define AVAILABLE_IOS_11                        AVAILABLE_IOS_V(11.0)

#define SAFE_INSETS                            (AVAILABLE_IOS_11 ? [[UIApplication sharedApplication].windows firstObject].safeAreaInsets : UIEdgeInsetsZero)
#define SAFE_X                                 (AVAILABLE_IOS_11 ? SAFE_INSETS.left : 0)
#define SAFE_Y                                 (AVAILABLE_IOS_11 ? SAFE_INSETS.top : 0)
#define SAFE_BOTTOM                            (AVAILABLE_IOS_11 ? SAFE_INSETS.bottom : 0)
#define SAFE_RIGHT                             (AVAILABLE_IOS_11 ? SAFE_INSETS.right : 0)

#define SAFE_WIDTH                             (AVAILABLE_IOS_11 ? SCREEN_WIDTH - SAFE_INSETS.left - SAFE_INSETS.right : SCREEN_WIDTH)
#define SAFE_HEIGHT                            (AVAILABLE_IOS_11 ? SCREEN_HEIGHT - SAFE_INSETS.top - SAFE_INSETS.bottom : SCREEN_HEIGHT)
#define SAFE_SIZE                              CGSizeMake(SAFE_WIDTH,SAFE_HEIGHT)
#define SAFE_FRAME                             CGRectMake(SAFE_X,SAFE_Y,SAFE_WIDTH,SAFE_HEIGHT)
#define SAFE_BOUNDS                            CGRectMake(0,0,SAFE_WIDTH,SAFE_HEIGHT)


#define STATUS_BAR_ORIENTATION                 [UIApplication sharedApplication].statusBarOrientation
#define STATUS_BAR_FRAME                       [[UIApplication sharedApplication] statusBarFrame]
#define TAB_BAR_FRAME                          [YZHTabBarController shareTabBarController].tabBar.frame

#define STATUS_BAR_HEIGHT                      [[UIApplication sharedApplication] statusBarFrame].size.height


#define CONST_NAV_BAR_HEIGHT                   (44)

#define NAV_BAR_FRAME                          ([self isKindOfClass:[UINavigationController class]] ? ((UINavigationController*)self).navigationBar.frame : ([self isKindOfClass:[UIViewController class]] ? ((UIViewController*)self).navigationController.navigationBar.frame : ([self isKindOfClass:[UIView class]] ? ((UIView*)self).viewController.navigationController.navigationBar.frame : CGRectMake(SAFE_X,0,SAFE_WIDTH,CONST_NAV_BAR_HEIGHT))))

#define NAV_BAR_HEIGHT                         NAV_BAR_FRAME.size.height
#define NAV_ITEM_HEIGH                         NAV_BAR_HEIGHT
#define NAV_IMAGE_ITEM_WIDTH_WITH_HEIGHT_RATIO (0.8)

#define TAB_BAR_HEIGHT                         (TAB_BAR_FRAME.size.height)
#define SAFE_TAB_BAR_HEIGHT                    (TAB_BAR_HEIGHT - SAFE_BOTTOM)

#define STATUS_NAV_BAR_HEIGHT                  (STATUS_BAR_HEIGHT + NAV_BAR_HEIGHT)
#define STATUS_NAV_TAB_BAR_HEIGHT              (STATUS_NAV_BAR_HEIGHT + TAB_BAR_HEIGHT)
#define VIEW_VISIBLE_HEIGHT                    (SCREEN_HEIGHT - STATUS_NAV_TAB_BAR_HEIGHT)

//颜色
#undef RGB
#define RGBA_F(R,G,B,A)                         [UIColor colorWithRed:R green:G blue:B alpha:A]
#define RGB(R,G,B)                              RGBA_F((R)/255.f,(G)/255.f,(B)/255.f,1.0)
#define RGBA(R,G,B,A)                           RGBA_F((R)/255.f,(G)/255.f,(B)/255.f,(A)/255.f)

#define RGB_WITH_INT_WITH_NO_ALPHA(C_INT)       RGB(TYPE_AND(TYPE_RS(C_INT,16),255),TYPE_AND(TYPE_RS(C_INT,8),255),TYPE_AND(C_INT,255))
#define RGB_WITH_STR_WITH_NO_ALPHA(C_STR)       RGB_WITH_INT_WITH_NO_ALPHA([(C_STR) integerValue])

#define RGB_WITH_INT_WITH_ALPHA(C_INT)          RGBA(TYPE_AND(TYPE_RS(C_INT,24),255),TYPE_AND(TYPE_RS(C_INT,16),255),TYPE_AND(TYPE_RS(C_INT,8),255),TYPE_AND(C_INT,255))
#define RGB_WITH_STR_WITH_ALPHA(C_STR)          RGB_WITH_INT_WITH_ALPHA([(C_STR) integerValue])

#define RAND_COLOR                              RGB(TYPE_AND(arc4random(),255),TYPE_AND(arc4random(),255),TYPE_AND(arc4random(),255))

#define CLEAR_COLOR                             [UIColor clearColor]
#define WHITE_COLOR                             [UIColor whiteColor]
#define BLACK_COLOR                             [UIColor blackColor]
#define BLUE_COLOR                              [UIColor blueColor]
#define RED_COLOR                               [UIColor redColor]
#define GRAY_COLOR                              [UIColor grayColor]
#define LIGHT_GRAY_COLOR                        [UIColor lightGrayColor]
#define PURPLE_COLOR                            [UIColor purpleColor]
#define YELLOW_COLOR                            [UIColor yellowColor]
#define GREEN_COLOR                             [UIColor greenColor]
#define ORANGE_COLOR                            [UIColor orangeColor]
#define BROWN_COLOR                             [UIColor brownColor]
#define GROUP_TABLEVIEW_BG_COLOR                [UIColor groupTableViewBackgroundColor]

#define RED_FROM_RGB_COLOR(COLOR)               ({ \
                                                    CGFloat _R_COLOR_ = 0; \
                                                    CGFloat _G_COLOR_ = 0; \
                                                    CGFloat _B_COLOR_ = 0; \
                                                    CGFloat _ALPHA_ = 0; \
                                                    [COLOR getRed:&_R_COLOR_ green:&_G_COLOR_ blue:&_B_COLOR_ alpha:&_ALPHA_]; \
                                                    _R_COLOR_; \
                                                })

#define GREEN_FROM_RGB_COLOR(COLOR)             ({ \
                                                    CGFloat _R_COLOR_ = 0; \
                                                    CGFloat _G_COLOR_ = 0; \
                                                    CGFloat _B_COLOR_ = 0; \
                                                    CGFloat _ALPHA_ = 0; \
                                                    [COLOR getRed:&_R_COLOR_ green:&_G_COLOR_ blue:&_B_COLOR_ alpha:&_ALPHA_]; \
                                                    _G_COLOR_; \
                                                })

#define BLUE_FROM_RGB_COLOR(COLOR)              ({ \
                                                    CGFloat _R_COLOR_ = 0; \
                                                    CGFloat _G_COLOR_ = 0; \
                                                    CGFloat _B_COLOR_ = 0; \
                                                    CGFloat _ALPHA_ = 0; \
                                                    [COLOR getRed:&_R_COLOR_ green:&_G_COLOR_ blue:&_B_COLOR_ alpha:&_ALPHA_]; \
                                                    _B_COLOR_; \
                                                })

#define ALPHA_FROM_RGB_COLOR(COLOR)             ({ \
                                                    CGFloat _R_COLOR_ = 0; \
                                                    CGFloat _G_COLOR_ = 0; \
                                                    CGFloat _B_COLOR_ = 0; \
                                                    CGFloat _ALPHA_ = 0; \
                                                    [COLOR getRed:&_R_COLOR_ green:&_G_COLOR_ blue:&_B_COLOR_ alpha:&_ALPHA_]; \
                                                    _ALPHA_; \
                                                })

#define NSOBJECT_FORMAT                         @"%@"
#define INTEGER_FORMAT                          @"%ld"
#define LLONG_INTEGER_FORMAT                    @"%lld"
#define INTEGER_WITH_SPACE_FORMAT               @"%ld "
#define INTEGER_WITH_SPACE_ANOTHER_FORMAT       @"%ld %@"
#define FLOAT_2D_NSOBJECT_FORMAT                @"%.2f %@"
//NSString的一些常用用定义
#define NEW_STRING(STRING)                      ((STRING != nil) ? [[NSString alloc] initWithString:STRING] : (nil))
#define NEW_NORMAL_FORMAT_STRING(OBJ)           ((OBJ) ? [[NSString alloc] initWithFormat:NSOBJECT_FORMAT,OBJ] : (nil))
#define NEW_DATA(DATA)                          ((DATA) ? [[NSData alloc] initWithData:DATA] : (nil))
#define STRING_FORMAT(FORMAT,...)               [NSString stringWithFormat:FORMAT,##__VA_ARGS__]
#define NEW_STRING_WITH_FORMAT(FORMAT,...)      [[NSString alloc] initWithFormat:FORMAT,##__VA_ARGS__]

//判断可用的NSOBject对象
#define IS_AVAILABLE_NSSTRNG(STRING)            (STRING != nil && STRING.length > 0)
#define IS_AVAILABLE_NSSET_OBJ(NSSET_OBJ)       (NSSET_OBJ != nil && NSSET_OBJ.count > 0)
#define IS_AVAILABLE_NSOBJECT_NOT_NULL(OBJ)     ((OBJ) != nil &&  (OBJ) != [NSNull null])
#define IS_AVAILABLE_CGSIZE(SIZE)               ((SIZE.width >0) && (SIZE.height > 0))
#define IS_AVAILABLE_DATA(DATA)                 (DATA != nil && DATA.length > 0)
#define IS_AVAILABLE_ATTRIBUTEDSTRING(ATTR_STR) (ATTR_STR != nil && ATTR_STR.length > 0)


//返回的一些安全操作
#define NSSTRING_SAFE_GET_NONULL_VAL(VAL)       (VAL) ? (VAL) : @""
#define NSSTRING_SAFE_RET_NONULL_VAL(VAL)       return ((VAL) ? (VAL) : @"")

#define NSARRAY_SAFE_GET_NONULL_VAL(VAL)        (VAL) ? (VAL) : (@[])
#define NSARRAY_SAFE_RET_NONULL_VAL(VAL)        return ((VAL) ? (VAL) : (@[]))

#define NSDICTIONARY_SAFE_GET_NONULL_VAL(VAL)   (VAL) ? (VAL) : (@{})
#define NSDICTIONARY_SAFE_RET_NONULL_VAL(VAL)   return ((VAL) ? (VAL) : (@{}))

#define IS_IN_ARRAY_FOR_INDEX(ARRAY,INDEX)      (IS_AVAILABLE_NSSET_OBJ(ARRAY) ? (INDEX >= 0 && INDEX < ARRAY.count) : NO)

//获取class的string的互转
#define NSSTRING_FROM_CLASS(CLASS_NAME)         NSStringFromClass([CLASS_NAME class])
#define NSCLASS_FROM_STRING(CLASS_STRING)       NSClassFromString(CLASS_STRING)
#define CLASS_NAME_STRING_FOR_NSOBJ(NSOBJ)      NSStringFromClass([NSOBJ class])
#define NSOBJ_TYPE_IS_CLASS(NSOBJ,CLASS_NAME)   [CLASS_NAME_STRING_FOR_NSOBJ(NSOBJ) isEqualToString:NSSTRING_FROM_CLASS(CLASS_NAME)]

#define CLASS_FROM_CLASSNAME(CLASS_NAME)        [CLASS_NAME class]

#define IS_SYSTEM_CLASS(CLASS)                  ([NSBundle bundleForClass:CLASS] != [NSBundle mainBundle])
#define IS_SYSTEM_CLASS_FROM_STRING(CLASS_NAME) IS_SYSTEM_CLASS(NSClassFromString(CLASS_NAME))

//selector和string的互转
#define NSSELECTOR_FROM_STRING(STRING)          NSSelectorFromString(STRING)
#define NSSTRING_FROM_SELECTOR(SELECTOR)        NSStringFromSelector(SELECTOR)

//NSURL
#define NSURL_FROM_STRING(STRING_URL)           [NSURL URLWithString:STRING_URL]
#define NSURL_FROM_FILE_PATH(FILE_PATH)         [NSURL fileURLWithPath:FILE_PATH]

//字体
#define FONT(F_S)                               [UIFont systemFontOfSize:(F_S)]
#define BOLD_FONT(F_S)                          [UIFont boldSystemFontOfSize:(F_S)]

//弱引用
#define WEAK_NSOBJ(NSOBJ,WEAK_NAME)             __weak __typeof(&*NSOBJ) WEAK_NAME = NSOBJ
#define WEAK_SELF(WEAK_NAME)                    __weak __typeof(&*self) WEAK_NAME = self

//本地化的操作
#define NSLOCAL_STRING(TEXT)                    NSLocalizedString(TEXT, nil)

//获取系统的版本号
#define SYSTEMVERSION_NUMBER                    [[UIDevice currentDevice].systemVersion floatValue]

#define ON_IOS_VERSION(V)                       (SYSTEMVERSION_NUMBER == V)
#define LATER_IOS_VERSION(V)                    (SYSTEMVERSION_NUMBER > V)
#define BEFORE_IOS_VERSION(V)                   (SYSTEMVERSION_NUMBER <  V)
#define ON_LATER_IOS_VERSION(V)                 (SYSTEMVERSION_NUMBER >= V)
#define ON_BEFORE_IOS_VERSION(V)                (SYSTEMVERSION_NUMBER <= V)


#define IS_RANGE_LENGTH_ZERO(RANGE)             ((RANGE.length == 0) ? (1) : (0))
#define NSRANGE_ZERO                            ({const NSRange NSRangeZero={.location=0,.length=0}; NSRangeZero;})

#define IMPLEMENTATION_FOR_CLASS(CLASS)         @implementation CLASS @end


//以下宏定义可能会与业务需求相关
//字节单位
#define KB_VALUE                                (1024)
#define MB_VALUE                                (1048576)
#define GB_VALUE                                (1073741824)
#define KB_NAME_STR                             @"KB"
#define MB_NAME_STR                             @"MB"
#define GB_NAME_STR                             @"GB"

//时间单位
#define MSEC_PER_SEC                            (1000)
#define SEC_PER_MIN                             (60)
#define SEC_PER_HOUR                            (3600)


#define TIME_SEC_TEXT                           NSLOCAL_STRING(@"秒")
#define TIME_MIN_TEXT                           NSLOCAL_STRING(@"分")
#define TIME_HOUR_TEXT                          NSLOCAL_STRING(@"小时")

//计数单位
#define TEN_THOUSAND                            (10000)
#define TEN_THOUSAN_NAME                        NSLOCAL_STRING(@"万") //(@"万")

#define THOUSAND                                (1000)
#define THOUSAN_NAME                            NSLOCAL_STRING(@"千") //(@"万")

#define MILLION                                 (1000000)
#define MILLION_NAME                            NSLOCAL_STRING(@"百万")

//已GB,MB为单位,如50GB20MB
#define GB_MB_UNIT_STR(SIZE)                    (((SIZE) > (GB_VALUE)) ? STRING_FORMAT(FLOAT_2D_NSOBJECT_FORMAT,(SIZE) * 1.0/(GB_VALUE),GB_NAME_STR) : STRING_FORMAT(FLOAT_2D_NSOBJECT_FORMAT,(SIZE) * 1.0/(MB_VALUE),MB_NAME_STR))

//已MB，KB为单位，如2000MB500KB
#define MB_KB_UNIT_STR(SIZE)                    (((SIZE) > (MB_VALUE)) ? STRING_FORMAT(FLOAT_2D_NSOBJECT_FORMAT,(SIZE) * 1.0/(MB_VALUE),MB_NAME_STR) : STRING_FORMAT(FLOAT_2D_NSOBJECT_FORMAT,(SIZE)*1.0/(KB_VALUE),KB_NAME_STR))

//以GB，MB或者KB为单位，
//1、如20GB200MB，
//2、如500MB
//3、如20KB
#define MB_UNIT_STR(SIZE)                       (((SIZE) > (MB_VALUE)) ? GB_MB_UNIT_STR(SIZE) : STRING_FORMAT(FLOAT_2D_NSOBJECT_FORMAT,(SIZE)*1.0/(KB_VALUE),KB_NAME_STR))


#define FILE_SIZE_DESCRIPTION(FILE_SIZE)        [NSString stringWithFormat:@"%@%@",FILE_SIZE_TEXT,MB_UNIT_STR(FILE_SIZE)]

//计数
//以万为单位
#define TEN_THOUSAND_UNIT_STR(CNT)              (((CNT) > (TEN_THOUSAND)) ? STRING_FORMAT(FLOAT_2D_NSOBJECT_FORMAT, (CNT)*1.0/TEN_THOUSAND,TEN_THOUSAN_NAME) : STRING_FORMAT(INTEGER_WITH_SPACE_FORMAT,CNT))


//以千为单位
#define THOUSAND_UNIT_STR(CNT)                  (((CNT) > THOUSAND) ? ( ((CNT) > MILLION) ? STRING_FORMAT(FLOAT_2D_NSOBJECT_FORMAT, (CGFloat)(CNT)*1.0/MILLION,MILLION_NAME) : STRING_FORMAT(INTEGER_WITH_SPACE_ANOTHER_FORMAT, (CNT)/THOUSAND, THOUSAN_NAME)) : (STRING_FORMAT(INTEGER_WITH_SPACE_FORMAT,CNT)))


//00(分钟):00(秒)
#define TIME_SECOND_UNIT_STR(SEC)               (((SEC) >= 6000) ? STRING_FORMAT(@"%03d:%02d",(int)(SEC)/SEC_PER_MIN,(int)(SEC)%SEC_PER_MIN) : STRING_FORMAT(@"%02d:%02d",(int)(SEC)/SEC_PER_MIN,(int)(SEC)%SEC_PER_MIN))

//xx小时xx分xx秒 格式
#define TIME_TEXT_FORMAT_HMS(SEC)               ((((int)SEC) >= SEC_PER_MIN) ? ((((int)SEC) >= SEC_PER_HOUR) ? STRING_FORMAT(@"%d%@%d%@%d%@",((int)SEC)/SEC_PER_HOUR,TIME_HOUR_TEXT, (((int)SEC)%SEC_PER_HOUR)/SEC_PER_MIN,TIME_MIN_TEXT, ((int)SEC)%SEC_PER_MIN,TIME_SEC_TEXT) : STRING_FORMAT(@"%d%@%d%@",((int)SEC)/SEC_PER_MIN,TIME_MIN_TEXT, (((int)SEC)%SEC_PER_MIN),TIME_SEC_TEXT)) : STRING_FORMAT(@"%d%@",(int)SEC,TIME_SEC_TEXT))

//00:00:00格式
#define TIME_TEXT_FORMAT_COLON(SEC)             ((((int)SEC) >= SEC_PER_MIN) ? ((((int)SEC) >= SEC_PER_HOUR) ? STRING_FORMAT(@"%02d:%02d:%02d",(((int)SEC)/SEC_PER_HOUR), ((((int)SEC)%SEC_PER_HOUR)/SEC_PER_MIN), (((int)SEC)%SEC_PER_MIN)) : STRING_FORMAT(@"00:%02d:%02d",(((int)SEC)/SEC_PER_MIN), (((int)SEC)%SEC_PER_MIN))) : STRING_FORMAT(@"00:00:%02d",(int)SEC))

#define TIME_TEXT_FORMAT_COLON_WITH_MSEC(MSEC)      TIME_TEXT_FORMAT_COLON((unsigned int)(MSEC)/MSEC_PER_SEC)
#define TIME_MSECOND_UNIT_STR(MSEC)                 TIME_SECOND_UNIT_STR((NSInteger)(MSEC)/MSEC_PER_SEC)

#define USEC_FROM_DATE_SINCE1970(DATE)              ((uint64_t)([DATE timeIntervalSince1970] * USEC_PER_SEC))
#define DATE_FROM_USEC_SINCE1970(TIME)              ([NSDate dateWithTimeIntervalSince1970:TIME * 1.0/USEC_PER_SEC])

#define MSEC_FROM_DATE_SINCE1970(DATE)              ((uint64_t)([DATE timeIntervalSince1970] * MSEC_PER_SEC))
#define DATE_FROM_MSEC_SINCE1970(TIME)              ([NSDate dateWithTimeIntervalSince1970:TIME * 1.0/MSEC_PER_SEC])

#define USEC_FROM_DATE_SINCE1970_NOW                USEC_FROM_DATE_SINCE1970([NSDate date])
#define MSEC_FROM_DATE_SINCE1970_NOW                MSEC_FROM_DATE_SINCE1970([NSDate date])

//-------数据模型请求下来的，比较特殊的宏定义
#define IS_OBJ_CLASS(OBJ,CLS)                       [OBJ isKindOfClass:[CLS class]]
#define IS_NULL_OBJ(OBJ)                            IS_OBJ_CLASS(OBJ,NSNull)
#define IS_NONNULL_OBJ(OBJ)                         (!IS_NULL_OBJ(OBJ))

#define NSOBJECT_VALUE(DICT,NAME)                   DICT[TYPE_STR(NAME)]

#define IS_NULL_VALUE(DICT,NAME)                    IS_OBJ_CLASS(NSOBJECT_VALUE(DICT,NAME), NSNull)
#define IS_NONNULL_VALUE(DICT,NAME)                 (!IS_NULL_VALUE(DICT,NAME))
#define BOOL_VALUE(DICT,NAME)                       (IS_NULL_VALUE(DICT,NAME) ? NO : [NSOBJECT_VALUE(DICT, NAME) boolValue])
#define FLOAT_VALUE(DICT,NAME)                      (IS_NULL_VALUE(DICT,NAME) ? 0 : [NSOBJECT_VALUE(DICT, NAME) floatValue])
#define INTEGER_VALUE(DICT,NAME)                    (IS_NULL_VALUE(DICT,NAME) ? 0 : [NSOBJECT_VALUE(DICT, NAME) integerValue])
#define INT_VALUE(DICT,NAME)                        (IS_NULL_VALUE(DICT,NAME) ? 0 : [NSOBJECT_VALUE(DICT, NAME) intValue])
#define STRING_VALUE(DICT,NAME)                     (IS_NULL_VALUE(DICT,NAME) ? nil : NEW_NORMAL_FORMAT_STRING(DICT[TYPE_STR(NAME)]))
#define NUMBER_VALUE(DICT,NAME)                     (IS_OBJ_CLASS(NSOBJECT_VALUE(DICT,NAME), NSNumber) ? NSOBJECT_VALUE(DICT,NAME) : nil)
//-------数据模型请求下来的，比较特殊的宏定义，end
//n倍向上取整
#define CEIL_TIMES(VAL,D)                           ((VAL) == 0 ? (VAL) : ( (VAL) > 0 ? ((((VAL)-1)/D + 1) * D) : ((((VAL)+1)/D+1)*D)))

#define RADIANS_TO_DEGREES(radians)                 ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle)                   ((angle) / 180.0 * M_PI)

//cgsize
#define CGSizeLessThanToSize(SIZE1,SIZE2)           ((SIZE1.width < SIZE2.width) && (SIZE1.height < SIZE2.height))
#define CGSizeLessEqualToSize(SIZE1,SIZE2)          ((SIZE1.width <= SIZE2.width) && (SIZE1.height <= SIZE2.height))
#define CGSizeGreaterThanToSize(SIZE1,SIZE2)        ((SIZE1.width > SIZE2.width) && (SIZE1.height > SIZE2.height))
#define CGSizeGreaterEqualToSize(SIZE1,SIZE2)       ((SIZE1.width >= SIZE2.width) && (SIZE1.height >= SIZE2.height))

#define CGPointGeneralEqualToPoint(PT1,PT2)         ((((NSInteger)PT1.x) == ((NSInteger)PT2.x)) && (((NSInteger)PT1.y) == ((NSInteger)PT2.y)))


#define _UI_D_WIDTH                                 (1334.0)
#define _UI_D_HEIGHT                                (750.0)
#define _UI_D_RATIO                                 (2.0)
/*定义相对参考物时的长度
 *REF_L为参考物的长度
 *CUR_REL_L当前相对参考物的长度
 *REA_L实际参考物的长度
 */
#define REF_LENGTH(REF_L, CUR_REL_L, REA_L)         ((REA_L <= 0) ? 0 : ((CUR_REL_L) * (REA_L) * 1.0 / (REF_L)))
#define UI_WIDTH(W)                                 REF_LENGTH(_UI_D_WIDTH, W, SCREEN_WIDTH)
#define UI_HEIGHT(H)                                REF_LENGTH(_UI_D_HEIGHT, H, SCREEN_HEIGHT)
#define UI_SIZE(SIZE)                               CGSizeMake(UI_WIDTH(SIZE.width),UI_HEIGHT(SIZE.height))
#define UI_RECT(RECT)                               CGRectMake(UI_WIDTH(RECT.origin.x),UI_HEIGHT(RECT.origin.y),UI_WIDTH(RECT.size.width),UI_HEIGHT(RECT.size.height))


#define SINGLE_LINE_WIDTH                           (1 / SCREEN_SCALE)
#define SINGLE_LINE_ADJUST_OFFSET                   ((1 / SCREEN_SCALE) / 2)
#define SINGLE_LINE_COLOR                           RGB_WITH_INT_WITH_NO_ALPHA(0xdddddd)

#define PROJ_MAIN_COLOR


#endif /* Macro_h */


