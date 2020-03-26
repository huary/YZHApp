//
//  YZHUtil.m
//  YZHApp
//
//  Created by yuan on 2019/1/1.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHUtil.h"
#import <CommonCrypto/CommonDigest.h>

#define APPLICATION_INFO_PATH                   @"APP_INFO"
#define SAVE_DATA_KEY                           @"APP_DATA"


@implementation YZHUtil

+ (BOOL)isValidateEmail:(NSString *)emailAddress
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailAddress];
}

+ (BOOL)isValidateIPAddress:(NSString*)IPAddress
{
    NSString *ipRegex = @"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)";
    NSPredicate *ipPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ipRegex];
    return [ipPredicate evaluateWithObject:IPAddress];
}

+ (BOOL)isValidatePhoneNumber:(NSString *)phoneNumber
{
//    NSString *mobileRegex = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[0678])\\d{8}$";
    NSString *mobileRegex = @"^(1)\\d{10}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    return [regextestmobile evaluateWithObject:phoneNumber];
}

+ (BOOL)isValidateHTMLString:(NSString*)HTMLString
{
    NSRegularExpression *regularExpretion=[NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n|&nbsq |\r|&mdash|&ldquo|&rdquo" options:0 error:nil];
    
    NSInteger number = [regularExpretion numberOfMatchesInString:HTMLString options:0 range:NSMakeRange(0, HTMLString.length)];
    
    return number > 0;
}

//+(void)alertInfoWithMessage:(NSString*)message delay:(NSTimeInterval)delay animated:(BOOL)animated
//{
//    YZHUIAlertView *alertView =[[YZHUIAlertView alloc] initWithTitle:@"提示" alertMessage:message alertViewStyle:YZHUIAlertViewStyleAlertInfo];
//    if (delay > 0) {
//        alertView.delayDismissInterval = delay;
//    }
//    else {
//        alertView.delayDismissInterval = 1.0;
//    }
//    [alertView alertShowInView:nil animated:animated];
//}
//
//+(void)alertInfoWithMessage:(NSString*)message animated:(BOOL)animated
//{
//    [Utils alertInfoWithMessage:message delay:0 animated:animated];
//}
//
//+(void)alertForceWithTitle:(NSString*)title message:(id)message
//{
//    YZHUIAlertView *alertView =[[YZHUIAlertView alloc] initWithTitle:title alertMessage:message alertViewStyle:YZHUIAlertViewStyleAlertForce];
//    [alertView addAlertActionWithTitle:@"确定" actionStyle:YZHUIAlertActionStyleConfirm actionBlock:nil];
//    [alertView alertShowInView:nil animated:NO];
//}

+(NSString *)applicationVersion
{
    return [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
}

+(NSString*)applicationShortVersion
{
    return [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+(BOOL)checkDirectory:(NSString*)directory
{
    if (!IS_AVAILABLE_NSSTRNG(directory)) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExists = [fileManager fileExistsAtPath:directory isDirectory:&isDir];
    if (isExists && isDir == YES) {
        return YES;
    }
    return NO;
}

+(BOOL)checkAndCreateDirectory:(NSString*)directory
{
    if (!IS_AVAILABLE_NSSTRNG(directory)) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExists = [fileManager fileExistsAtPath:directory isDirectory:&isDir];
    if ((isExists && isDir == NO) || isExists == NO) {
        if (isExists == YES) {
            [fileManager removeItemAtPath:directory error:nil];
        }
        [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return YES;
}

+(BOOL)checkFileExistsAtPath:(NSString*)filePath
{
    if (!IS_AVAILABLE_NSSTRNG(filePath)) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

+(void)removeFileItemAtPath:(NSString*)path
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:path error:NULL];
}

+(void)createFileItemAtPath:(NSString *)path
{
    if (!IS_AVAILABLE_NSSTRNG(path)) {
        return;
    }
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager createFileAtPath:path contents:nil attributes:nil];
}

+(uint64_t)fileSizeAtPath:(NSString *)path
{
    if (![[self class] checkFileExistsAtPath:path]) {
        return 0;
    }
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSDictionary *attr = [defaultManager attributesOfItemAtPath:path error:NULL];
    return [attr fileSize];
}

+(NSString *)applicationTmpDirectory:(NSString *)filename
{
    NSString *tmpDir = NSTemporaryDirectory();
    if (IS_AVAILABLE_NSSTRNG(filename)) {
        return [tmpDir stringByAppendingString:filename];
    }
    return tmpDir;
}

+ (NSString *)applicationCachesDirectory:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    if (IS_AVAILABLE_NSSTRNG(filename)) {
        return [basePath stringByAppendingPathComponent:filename];
    }
    return basePath;
}

+ (NSString *)applicationDocumentsDirectory:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    if (IS_AVAILABLE_NSSTRNG(filename)) {
        return [basePath stringByAppendingPathComponent:filename];
    }
    return basePath;
}

+(NSString *)applicationStoreInfoDirectory:(NSString*)fileName
{
    NSString *filePath = [[self class] applicationCachesDirectory:nil];
    
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *pathName = [[NSString alloc] initWithFormat:@"%@.%@",bundleId,APPLICATION_INFO_PATH];
    filePath = [filePath stringByAppendingPathComponent:pathName];
    
    NSString *directory = filePath;
    if (IS_AVAILABLE_NSSTRNG(fileName)) {
        filePath = [filePath stringByAppendingPathComponent:fileName];
        directory = [filePath stringByDeletingLastPathComponent];
    }
    [[self class] checkAndCreateDirectory:directory];
    return filePath;
}

+(uint64_t)getTotalFileSizeFromDirectory:(NSString*)directory
{
    if (![[self class] checkDirectory:directory]) {
        return 0;
    }
    uint64_t size = 0;
    NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:directory];
    for (NSString *fileName in dirEnumerator) {
        NSString *filePath = [directory stringByAppendingPathComponent:fileName];
        NSDictionary<NSString *, id> *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

+(NSData*)encodeObject:(id)object forKey:(NSString*)key
{
    if ([object conformsToProtocol:@protocol(NSCoding)] == NO) {
        return nil;
    }
    
    if (key != nil) {
        if (ON_LATER_IOS_VERSION(10.0)) {
            NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] init];
            [encoder encodeObject:object forKey:key];
            [encoder finishEncoding];
            
            return encoder.encodedData;
        }
        else {
            NSMutableData *mutData = [NSMutableData data];
            NSKeyedArchiver *keyArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mutData];
            
            [keyArchiver encodeObject:object forKey:key];
            [keyArchiver finishEncoding];
            
            return [mutData copy];
        }
    }
    else
    {
        if (object == nil) {
            return nil;
        }
        return [NSKeyedArchiver archivedDataWithRootObject:object];
    }
}

+(id)decodeObjectForData:(NSData*)data forKey:(NSString*)key
{
    if (data == nil) {
        return nil;
    }
    NSKeyedUnarchiver *decoder = nil;
    id value = nil;
    if (key != nil) {
        decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        value = [decoder decodeObjectForKey:key];
        [decoder finishDecoding];
    }
    else
    {
        value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return value;
}

+(NSData*)saveObject:(id<NSCoding>)ObjectToSave to:(NSString *)filename
{
    NSData *data = [[self class] encodeObject:ObjectToSave forKey:SAVE_DATA_KEY];
    if (data) {
        NSString *filePath = [[self class] applicationStoreInfoDirectory:filename];
        [data writeToFile:filePath atomically:YES];
    }
    return data;
}

+(id<NSCoding>)loadObjectFrom:(NSString *)filename
{
    NSString *filePath  = [[[self class] applicationStoreInfoDirectory:nil] stringByAppendingPathComponent:filename];
    if ([[self class] checkFileExistsAtPath:filePath]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        id<NSCoding> result = [[self class] decodeObjectForData:data forKey:SAVE_DATA_KEY];
        return result;
    }
    return nil;
}

+(void)removeObjectFrom:(NSString *)filename
{
    NSString *filePath  = [[[self class] applicationStoreInfoDirectory:nil] stringByAppendingPathComponent:filename];
    [[self class] removeFileItemAtPath:filePath];
}


+(id)jsonObjectFromString:(NSString *)string
{
    if (!IS_AVAILABLE_NSSTRNG(string)) {
        return nil;
    }
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    return obj;
}

+(NSString*)stringFromJsonObject:(id)jsonObject
{
    if (jsonObject == nil) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}


+(NSData*)UIImageToDataRepresentation:(UIImage*)image
{
    NSData *data = UIImagePNGRepresentation(image);
    if (data == nil) {
        data = UIImageJPEGRepresentation(image, 1.0);
    }
    return data;
}

+(NSData*)UIImageToDataRepresentation:(UIImage*)image PNG:(BOOL)PNG
{
    NSData *data = nil;
    if (PNG) {
        data = UIImagePNGRepresentation(image);
    }
    else {
        data = UIImageJPEGRepresentation(image, 1.0);
    }
    return data;
}

+(void)saveImage:(UIImage*)image toFilePath:(NSString*)filePath
{
    if (image == nil || !IS_AVAILABLE_NSSTRNG(filePath)) {
        return;
    }
    NSData *data = [[self class] UIImageToDataRepresentation:image];
    NSString *dir = [filePath stringByDeletingLastPathComponent];
    [[self class] checkAndCreateDirectory:dir];
    [data writeToFile:filePath atomically:YES];
}

+(UIImage*)loadImageFromFilePath:(NSString*)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

+(NSString*)imageToBase64EncodedString:(UIImage*)image
{
    if (!image) {
        return nil;
    }
    NSData *imageData = [[self class] UIImageToDataRepresentation:image PNG:YES];
    
    return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+(NSString*)imageDataToBase64EncodedString:(NSData*)imageData
{
    if (!imageData) {
        return nil;
    }
    return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+(UIImage*)imageFromBase64EncodedString:(NSString*)base64EncodedString
{
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64EncodedString options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}

+(NSString*)_integerRegularExpressionPattern:(BOOL)firstCanBeZero
{
    if (firstCanBeZero) {
        return @"[+-]?\\d+";
    }
    return @"([+-]?[0-9]$)|([+-]?[1-9][0-9]*$)";
}

+(NSString*)_floatRegularExpressionPattern:(NSFloatPointType)floatPointType
{
    NSString *regular = @"";
    if (floatPointType == NSFloatPointTypeDefault) {
        return @"(([+-]?)(\\d+)(\\.\\d{0,}))|(([+-]?)(\\d{0,})(\\.\\d+))";
    }
    else{
        if (TYPE_AND(floatPointType, NSFloatPointTypeFirst)) {
            if (IS_AVAILABLE_NSSTRNG(regular)) {
                regular = NEW_STRING_WITH_FORMAT(@"%@|%@",regular,@"(([+-]?)(\\.\\d+))");
            }
            else{
                regular =@"(([+-]?)(\\.\\d+))";
            }
        }
        if (TYPE_AND(floatPointType, NSFloatPointTypeMid)) {
            if (IS_AVAILABLE_NSSTRNG(regular)) {
                regular = NEW_STRING_WITH_FORMAT(@"%@|%@",regular,@"(([+-]?)(\\d+)(\\.\\d+))");
            }
            else{
                regular = @"(([+-]?)(\\d+)(\\.\\d+))";
            }
        }
        if (TYPE_AND(floatPointType, NSFloatPointTypeLast)) {
            if (IS_AVAILABLE_NSSTRNG(regular)) {
                regular = NEW_STRING_WITH_FORMAT(@"%@|%@",regular,@"(([+-]?)(\\d+\\.))");
            }
            else{
                regular = @"(([+-]?)(\\d+\\.))";
            }
        }
    }
    return regular;
}

+(BOOL)evaluateText:(NSString*)text withRegularExpressionPattern:(NSString*)pattern
{
    if (!IS_AVAILABLE_NSSTRNG(text)) {
        return NO;
    }
    if (pattern == nil) {
        return NO;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    return [predicate evaluateWithObject:text];
}

+(BOOL)isNumberForString:(NSString*)text
{
    return ([[self class] isFloatNumberForString:text] || [[self class] isIntegerNumberForString:text]);
}

+(BOOL)isNumberForString:(NSString *)text numberType:(NSNumberType)numberType
{
    if (numberType == NSNumberTypeNumber) {
        return [[self class] isNumberForString:text];
    }
    else if (numberType == NSNumberTypeInteger){
        return [[self class] isIntegerNumberForString:text];
    }
    else if (numberType == NSNumberTypeFloat){
        return [[self class] isFloatNumberForString:text];
    }
    return NO;
}

+(BOOL)isNumberForString:(NSString *)text firstDigitCanBeZero:(BOOL)firstCanBeZero
{
    if (firstCanBeZero) {
        return [[self class] isNumberForString:text];
    }
    
    return ([[self class] isFloatNumberForString:text] || [[self class] isIntegerNumberForString:text firstDigitCanBeZero:NO]);
}

+(BOOL)isFloatNumberForString:(NSString*)text
{
    if (!IS_AVAILABLE_NSSTRNG(text)) {
        return NO;
    }
    return [[self class] evaluateText:text withRegularExpressionPattern:[[self class] _floatRegularExpressionPattern:NSFloatPointTypeDefault]];
}

+(BOOL)isFloatNumberForString:(NSString *)text floatPointType:(NSFloatPointType)floatPointType
{
    if (!IS_AVAILABLE_NSSTRNG(text)) {
        return NO;
    }
    return [[self class] evaluateText:text withRegularExpressionPattern:[[self class] _floatRegularExpressionPattern:floatPointType]];
}

+(CGFloat)floatNumberForString:(NSString*)text
{
    BOOL isFloatNumber = [[self class] isNumberForString:text];
    if (isFloatNumber) {
        return [text floatValue];
    }
    return 0;
}

+(BOOL)isIntegerNumberForString:(NSString*)text
{
    if (!IS_AVAILABLE_NSSTRNG(text)) {
        return NO;
    }
    return [[self class] evaluateText:text withRegularExpressionPattern:[[self class] _integerRegularExpressionPattern:YES]];
}


//如05，这样的数字
+(BOOL)isIntegerNumberForString:(NSString *)text firstDigitCanBeZero:(BOOL)firstCanBeZero
{
    if (!IS_AVAILABLE_NSSTRNG(text)) {
        return NO;
    }
    return [[self class] evaluateText:text withRegularExpressionPattern:[[self class] _integerRegularExpressionPattern:firstCanBeZero]];
}

+(NSInteger)integerNumberForString:(NSString*)text
{
    BOOL isInteget = [[self class] isIntegerNumberForString:text];
    if (isInteget) {
        return [text integerValue];
    }
    return 0;
}

+(BOOL)isHexIntegerNumberForString:(NSString *)text
{
    NSNumber *result = [[self class] hexIntegerNumberForString:text];
    return result != nil;
}

+(NSNumber*)hexIntegerNumberForString:(NSString *)text
{
    if (!IS_AVAILABLE_NSSTRNG(text)) {
        return nil;
    }
    
    for (NSInteger i = 0; i < text.length; ++i) {
        unichar c = [text characterAtIndex:i];
        if (![[self class] _isHexChar:c]) {
            return nil;
        }
    }
    
    NSScanner *scaner = [[NSScanner alloc] initWithString:text];
    unsigned long long result = 0;
    BOOL OK = [scaner scanHexLongLong:&result];
    if (OK) {
        return @(result);
    }
    return nil;
}

+(BOOL)_isHexChar:(unichar)c
{
    if ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f')) {
        return YES;
    }
    return NO;
}

+(NSString*)getIntegerValueString:(NSInteger)value
{
    return NEW_STRING_WITH_FORMAT(@"%ld",(long)value);
}

+(NSString*)changeIntegerStringForText:(NSString*)text changeValue:(NSInteger)changeValue
{
    if (changeValue == 0) {
        return text;
    }
    NSScanner *scanner = [NSScanner scannerWithString:text];
    NSString *skipString = nil;
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&skipString];
    NSInteger integer = 0;
    BOOL haveNumber = [scanner scanInteger:&integer];
    if (haveNumber == NO) {
        return text;
    }
    NSInteger numberEndLocation = scanner.scanLocation;
    if ([scanner isAtEnd] == NO) {
        NSString *skipStringTmp = nil;
        NSInteger integetTmp = 0;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&skipStringTmp];
        haveNumber = [scanner scanInteger:&integetTmp];
        if (haveNumber) {
            return text;
        }
    }
    integer = integer + changeValue;
    NSString *newNumberText = [[NSString alloc] initWithFormat:@"%ld",integer];
    NSInteger startLocation = 0;
    if (skipString) {
        startLocation = skipString.length;
    }
    text = [text stringByReplacingCharactersInRange:NSMakeRange(startLocation, numberEndLocation-startLocation) withString:newNumberText];
    return text;
}

+(BOOL)isAvailableIntegerStringForText:(NSString *)text
{
    NSString *new = [[self class] changeIntegerStringForText:text changeValue:1];
    if ([new isEqualToString:text]) {
        return NO;
    }
    return YES;
}

+(NSInteger)integerValueForText:(NSString*)text
{
    NSScanner *scanner = [NSScanner scannerWithString:text];
    NSString *skipString = nil;
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&skipString];
    NSInteger integer = 0;
    BOOL haveNumber = [scanner scanInteger:&integer];
    if (haveNumber == NO) {
        return -1;
    }
    return integer;
}

+(BOOL)isMacStringForText:(NSString*)macText separator:(NSString*)separator
{
    if (!IS_AVAILABLE_NSSTRNG(macText)) {
        return NO;
    }
    NSArray *array = [macText componentsSeparatedByString:separator];
    if (array.count == 6) {
        for (NSString *sub in array) {
            if (![[self class] isHexIntegerNumberForString:sub]) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

+(NSString*)getMacStringForText:(NSString*)macText separator:(NSString*)separator
{
    if (!IS_AVAILABLE_NSSTRNG(macText)) {
        return @"";
    }
    if ([[self class] isMacStringForText:macText separator:separator]) {
        return macText;
    }
    NSMutableString *mutString = [NSMutableString stringWithString:macText];
    NSInteger length = macText.length;
    for (NSInteger i = length-2; i > 0; i = i - 2) {
        [mutString insertString:separator atIndex:i];
    }
    
    if ([[self class] isMacStringForText:mutString]) {
        return [mutString copy];
    }
    return @"";
}

+(NSString*)getPartMacStringForText:(NSString*)macText separator:(NSString*)separator range:(NSRange)range
{
    if (!IS_AVAILABLE_NSSTRNG(macText)) {
        return nil;
    }
    NSString *macTextTmp = [[self class] getMacStringForText:macText separator:separator];
    NSArray *array = [macTextTmp componentsSeparatedByString:separator];
    
    NSInteger index = range.location;
    NSInteger endIndex = range.location + range.length;
    if (!IS_IN_ARRAY_FOR_INDEX(array, index) || endIndex > array.count) {
        return nil;
    }
    
    NSArray *sub = [array subarrayWithRange:range];
    
    NSString *retText = [sub componentsJoinedByString:separator];
    return retText;
}

+(BOOL)isMacStringForText:(NSString*)macText
{
    return [[self class] isMacStringForText:macText separator:@":"];
}

+(NSString*)getMacStringForText:(NSString*)macText
{
    return [[self class] getMacStringForText:macText separator:@":"];
}

+(NSString*)replaceTextWithAsterisk:(NSString*)text inRange:(NSRange)range
{
    NSMutableString *mutString = [[NSMutableString alloc] init];
    while (mutString.length < range.length) {
        [mutString appendString:@"*"];
    }
    return [text stringByReplacingCharactersInRange:range withString:mutString];
}

+(BOOL)isPasswordForText:(NSString *)text {
    
    BOOL result = false;
    if ([text length] >= 6 && [text length] <= 16){
        
        NSString *regex = @"^[A-Za-z0-9]+$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        result = [pred evaluateWithObject:text];
    }
    return result;
}

+(BOOL)isRegisterNameForText:(NSString *)text {
    
    BOOL result = false;
    
    if (!text || [text length] == 0) {
        return result;
    }
    
    NSString *regex = @"^[a-zA-Z0-9_\u4e00-\u9fa5]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    result = [pred evaluateWithObject:text];
    
    return result;
}

//+(void)printData:(NSData*)data
//{
//    NSInteger offset = 0;
//    NSInteger step = 10000;
//    NSInteger i = 1;
//    while (1) {
//        NSInteger subL = data.length - offset;
//        if (subL > step) {
//            subL = step;
//        }
//        if (subL <= 0) {
//            break;
//        }
//        NSData *sub = [data subdataWithRange:NSMakeRange(offset, subL)];
//        NSLog(@"sub-%ld=%@,length=%ld",i, sub,sub.length);
//        offset += subL;
//        ++i;
//    }
//}

+(NSString*)MD5ForText:(NSString*)text lowercase:(BOOL)lowercase
{
    const char *str = text.UTF8String;
    if (!str) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *format = nil;
    if (lowercase) {
        format = @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x";
    }
    else {
        format = @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X";
    }
    
    NSString *mdf = [NSString stringWithFormat:format,r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],r[11], r[12], r[13], r[14], r[15]];
    return mdf;
}

+(NSString*)createUUID
{
    CFUUIDRef    uuidObj = CFUUIDCreate(NULL);
    NSString    *uuidString = (__bridge NSString *)CFUUIDCreateString(NULL, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}

//是否是纯中文
+(BOOL)isChineseForText:(NSString*)text
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:text];
}

+(BOOL)isContainsChinese:(NSString*)text
{
    for(int i=0; i< [text length];i++)
    {
        int a =[text characterAtIndex:i];
        if( a >0x4e00 && a <0x9fff){
            return YES;
        }
    }
    return NO;
}

@end
