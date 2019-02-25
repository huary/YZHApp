//
//  YZHUtil.h
//  YZHApp
//
//  Created by yuan on 2019/1/1.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHKitType.h"

typedef NS_ENUM(NSInteger, NSNumberType)
{
    //可以浮点数，也可以是整数
    NSNumberTypeNumber   = 0,
    //整数
    NSNumberTypeInteger  = 1,
    //浮点数
    NSNumberTypeFloat    = 2,
};

typedef NS_ENUM(NSInteger,NSFloatPointType)
{
    //可以是[+-].xxx，[+-]xxx.xxx，[+-]xxx.
    NSFloatPointTypeDefault = 0,
    //[+-].xxx这种类型的
    NSFloatPointTypeFirst   = (1 << 0),
    //[+-]xxx.xxx这种类型的
    NSFloatPointTypeMid     = (1 << 1),
    //[+-]xxx.这种类型的
    NSFloatPointTypeLast    = (1 << 2),
};


@interface YZHUtil : NSObject

+ (BOOL)isValidateEmail:(NSString *)emailAddress;
+ (BOOL)isValidateIPAddress:(NSString*)IPAddress;
+ (BOOL)isValidatePhoneNumber:(NSString *)phoneNumber;
+ (BOOL)isValidateHTMLString:(NSString*)HTMLString;

//+(void)alertInfoWithMessage:(NSString*)message delay:(NSTimeInterval)delay animated:(BOOL)animated;
//+(void)alertInfoWithMessage:(NSString*)message animated:(BOOL)animated;
//+(void)alertForceWithTitle:(NSString*)title message:(id)message;

+(NSString *)applicationVersion;
+(NSString *)applicationShortVersion;

+(BOOL)checkDirectory:(NSString*)directory;
+(BOOL)checkAndCreateDirectory:(NSString*)directory;
+(BOOL)checkFileExistsAtPath:(NSString*)filePath;
+(void)removeFileItemAtPath:(NSString*)path;
+(void)createFileItemAtPath:(NSString *)path;
+(uint64_t)fileSizeAtPath:(NSString *)path;

+(NSString *)applicationTmpDirectory:(NSString *)filename;
+(NSString *)applicationCachesDirectory:(NSString *)filename;
+(NSString *)applicationDocumentsDirectory:(NSString *)filename;

+(NSString *)applicationStoreInfoDirectory:(NSString*)fileName;
+(uint64_t )getTotalFileSizeFromDirectory:(NSString*)directory;

+(NSData*)encodeObject:(id)object forKey:(NSString*)key;
+(id)decodeObjectForData:(NSData*)data forKey:(NSString*)key;

+(NSData*)saveObject:(id<NSCoding>)ObjectToSave to:(NSString *)filename;
+(id<NSCoding>)loadObjectFrom:(NSString *)filename;
+(void)removeObjectFrom:(NSString *)filename;

+(id)jsonObjectFromString:(NSString *)string;
+(NSString*)stringFromJsonObject:(id)jsonObject;

+(NSData*)UIImageToDataRepresentation:(UIImage*)image;
+(NSData*)UIImageToDataRepresentation:(UIImage*)image PNG:(BOOL)PNG;

+(void)saveImage:(UIImage*)image toFilePath:(NSString*)filePath;
+(UIImage*)loadImageFromFilePath:(NSString*)filePath;

+(NSString*)imageToBase64EncodedString:(UIImage*)image;
+(NSString*)imageDataToBase64EncodedString:(NSData*)imageData;
+(UIImage*)imageFromBase64EncodedString:(NSString*)base64EncodedString;

//前面可以包含正负号，和浮点数,如05这样的数字也可可以
+(BOOL)isNumberForString:(NSString*)text;
//如05这样的数字可以通过firstCanBeZero来确定，0.5这样的数字返回YES
+(BOOL)isNumberForString:(NSString *)text numberType:(NSNumberType)numberType;
+(BOOL)isNumberForString:(NSString *)text firstDigitCanBeZero:(BOOL)firstCanBeZero;

//浮点数
+(BOOL)isFloatNumberForString:(NSString*)text;
+(BOOL)isFloatNumberForString:(NSString *)text floatPointType:(NSFloatPointType)floatPointType;
+(CGFloat)floatNumberForString:(NSString*)text;
//整数
+(BOOL)isIntegerNumberForString:(NSString*)text;
//如05，这样的数字
+(BOOL)isIntegerNumberForString:(NSString *)text firstDigitCanBeZero:(BOOL)firstCanBeZero;
+(NSInteger)integerNumberForString:(NSString*)text;

+(BOOL)isHexIntegerNumberForString:(NSString*)text;
+(NSNumber*)hexIntegerNumberForString:(NSString *)text;

+(NSString*)getIntegerValueString:(NSInteger)value;
/*
 *将text中的数字进行+changeValue(可正可负)
 *text中支持有一段数字：123，XX123，XX123XX
 */
+(NSString*)changeIntegerStringForText:(NSString*)text changeValue:(NSInteger)changeValue;
+(BOOL)isAvailableIntegerStringForText:(NSString *)text;
//返回第一段数字
+(NSInteger)integerValueForText:(NSString*)text;

//这里的参数macText是带分隔符的MAC地址
+(BOOL)isMacStringForText:(NSString*)macText separator:(NSString*)separator;
//这里返回的是带分割符号的mac地址
+(NSString*)getMacStringForText:(NSString*)macText separator:(NSString*)separator;
+(NSString*)getPartMacStringForText:(NSString*)macText separator:(NSString*)separator range:(NSRange)range;
//默认按“:”来进行分割
+(BOOL)isMacStringForText:(NSString*)macText;
//返回带分割符号“:”的mac地址
+(NSString*)getMacStringForText:(NSString*)macText;
//将一段字符的range用*来替换
+(NSString*)replaceTextWithAsterisk:(NSString*)text inRange:(NSRange)range;

+(BOOL)isPasswordForText:(NSString *)text;
+(BOOL)isRegisterNameForText:(NSString *)text;

+(void)printData:(NSData*)data;

+(NSString*)MD5ForText:(NSString*)text lowercase:(BOOL)lowercase;

@end
