//
//  YZHDiskCache.m
//  YZHURLSessionTaskOperation
//
//  Created by yuan on 2019/1/5.
//  Copyright © 2019年 yuan. All rights reserved.
//

#import "YZHDiskCache.h"
#import "YZHUtil.h"
#import "NSData+YZHCoding.h"
#import "UIImage+YZHCoding.h"

#define OBJECT_ARCHIVE_TO_DATA_KEY                  @"com.yzhDiskCache.archiveToData"

static const void *const dispatchIOQueueSpecificKey =&dispatchIOQueueSpecificKey;
static const void *const dispatchCompletionQueueSpecificKey = &dispatchCompletionQueueSpecificKey;


typedef NS_ENUM(NSInteger, YZHDiskObjectType)
{
    //对象本身就是NSdata类型，
    YZHDiskObjectTypeData           = 0,
    //比如不用进行code的，直接进行存储的,NSString,
    YZHDiskObjectTypeNoneCode       = 1,
    //比如支持NSCoding协议的
    YZHDiskObjectTypeCodingToData   = 2,
    //自定义存储、加载成的对象，有可能是sqlite存储的
    YZHDiskObjectTypeCustom         = 3,
};


/****************************************************
 *YZHDiskObject
 ****************************************************/
@interface YZHDiskObject : NSObject

@property (nonatomic, strong) id data;

@property (nonatomic, assign) YZHDiskObjectType type;

-(instancetype)initWithData:(id)data type:(YZHDiskObjectType)type;

-(NSDictionary*)encode;

-(void)decode:(NSDictionary*)dict;
@end


@implementation YZHDiskObject

-(instancetype)initWithData:(id)data type:(YZHDiskObjectType)type
{
    if (self = [super init]) {
        self.data = data;
        self.type = type;
    }
    return self;
}


-(NSDictionary*)encode
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.data) {
        [dict setObject:self.data forKey:TYPE_STR(data)];
    }
    [dict setObject:@(self.type) forKey:TYPE_STR(type)];
    return dict;
}

-(void)decode:(NSDictionary*)dict
{
    self.type = [[dict objectForKey:TYPE_STR(type)] integerValue];
    self.data = [dict objectForKey:TYPE_STR(data)];
}


@end






/****************************************************
 *YZHDiskCache
 ****************************************************/
@interface YZHDiskCache ()
/* <#注释#> */
@property (nonatomic, strong) NSString *cacheDirectory;

/* <#注释#> */
@property (nonatomic, strong) NSString *fullPath;

/* <#注释#> */
@property (nonatomic, strong) dispatch_queue_t IOQueue;

/* <#注释#> */
@property (nonatomic, strong) dispatch_queue_t completionQueue;

@end

@implementation YZHDiskCache

-(instancetype)init
{
    return [self initWithName:nil directory:nil];
}

-(instancetype)initWithName:(NSString*)name
{
    return [self initWithName:name directory:nil];
}

-(instancetype)initWithName:(NSString *)name directory:(NSString*)directory
{
    self = [super init];
    if (self) {
        if (!IS_AVAILABLE_NSSTRNG(name)) {
            name = @"com.YZHDiskCache";
        }
        if (!IS_AVAILABLE_NSSTRNG(directory)) {
            directory = [YZHUtil applicationCachesDirectory:nil];
        }
        _name = name;
        self.cacheDirectory = [directory stringByStandardizingPath];
        [self _setupDefault];
    }
    return self;
}

-(NSString*)_fullCachePath
{
    return [[self.cacheDirectory stringByAppendingPathComponent:self.name] stringByStandardizingPath];
}

-(void)_setupDefault
{
    self.fullPath = [self _fullCachePath];
    self.completionQueue = dispatch_get_main_queue();
}

-(dispatch_queue_t)IOQueue
{
    if (_IOQueue == nil) {
        _IOQueue = dispatch_queue_create("com.YZHDiskCache.ioQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_IOQueue, dispatchIOQueueSpecificKey, (__bridge void *)self, NULL);
    }
    return _IOQueue;
}

-(NSString*)fullCacheDirectory
{
    return self.fullPath;
}

-(void)createCacheDirectory
{
    NSString *path = self.fullPath;
    dispatch_async(self.IOQueue, ^{
        [YZHUtil checkAndCreateDirectory:path];
    });
}

-(void)_writeData:(YZHDiskObject*)diskObject toPath:(NSString*)path
{
    if (!diskObject) {
        return;
    }
    NSAssert(dispatch_get_specific(dispatchIOQueueSpecificKey) == (__bridge void *)self, @"must is IOQueue");
    NSString *directory = [path stringByDeletingLastPathComponent];
    [YZHUtil checkAndCreateDirectory:directory];
    [[diskObject encode] writeToFile:path atomically:NO];
}

-(NSString*)_saveFileNameForFileName:(NSString*)fileName
{
    NSString *key = fileName;
    if (fileName.length >= 256) {
        NSString *ext = [fileName pathExtension];
        key = [[YZHUtil MD5ForText:fileName lowercase:YES] stringByAppendingPathExtension:ext];
    }
    return key;
}


-(void)saveObject:(id)object forFileName:(NSString*)fileName completion:(YZHDiskCacheSaveCompletionBlock)completion
{
    [self saveObject:object data:nil forFileName:fileName completion:completion];
}

-(void)saveObject:(id)object data:(NSData*)data forFileName:(NSString*)fileName completion:(YZHDiskCacheSaveCompletionBlock)completion
{
    NSString *key = [self _saveFileNameForFileName:fileName];
    NSString *path = [self.fullPath stringByAppendingPathComponent:key];
    
    dispatch_async(self.IOQueue, ^{
        NSData *encodeData = data;
        YZHDiskObject *cacheObject = [[YZHDiskObject alloc] init];
        if (encodeData == nil) {
            //encode
            if ([object conformsToProtocol:@protocol(YZHDiskCacheObjectCodingProtocol)]) {
                id<YZHDiskCacheObjectCodingProtocol> tmp = object;
                if (tmp.encodeBlock) {
                    encodeData = tmp.encodeBlock(self, tmp, path, fileName);
                }
                cacheObject.type = YZHDiskObjectTypeCustom;
            }
            else if ([object conformsToProtocol:@protocol(NSCoding)]) {
                encodeData = [YZHUtil encodeObject:object forKey:OBJECT_ARCHIVE_TO_DATA_KEY];
                cacheObject.type = YZHDiskObjectTypeCodingToData;
            }
        }
        else {
            cacheObject.type = YZHDiskObjectTypeData;
        }
        cacheObject.data = encodeData;
        
        [self _writeData:cacheObject toPath:path];
        
        if (self.syncDoCompletion) {
            if (completion) {
                completion(self,object, path, fileName);
            }
        }
        else {
            dispatch_async(self.completionQueue, ^{
                if (completion) {
                    completion(self,object, path, fileName);
                }
            });
        }
    });
}

-(void)moveItemAtPath:(NSString*)path toPath:(NSString*)toPath
{
    dispatch_async(self.IOQueue, ^{
        [[NSFileManager defaultManager] moveItemAtURL:NSURL_FROM_FILE_PATH(path) toURL:NSURL_FROM_FILE_PATH(toPath) error:NULL];
    });
}

-(NSOperation*)addExecuteBlock:(id(^)(YZHDiskCache *cache))block completion:(void(^)(YZHDiskCache *cache, id retObj))completion
{
    return [self addExecuteBlock:block syncCompletion:NO completion:completion];
}

-(NSOperation*)addExecuteBlock:(id(^)(YZHDiskCache *cache))block syncCompletion:(BOOL)sync completion:(void(^)(YZHDiskCache *cache, id retObj))completion
{
    NSOperation *operation = [NSOperation new];
    dispatch_async(self.IOQueue, ^{
        
        if (operation.isCancelled) {
            return ;
        }
        
        id retObj = nil;
        if (block) {
            retObj = block(self);
        }
        
        if (sync) {
            if (completion) {
                completion(self, retObj);
            }
        }
        else {
            dispatch_async(self.completionQueue, ^{
                if (completion) {
                    completion(self, retObj);
                }
            });
        }
    });
    return operation;
}

//可以cancel
-(NSOperation*)loadObjectForFileName:(NSString*)fileName decode:(YZHDiskCacheDecodeBlock)decode completion:(YZHDiskCacheLoadCompletionBlock)completion
{
    NSString *key = [self _saveFileNameForFileName:fileName];
    NSString *path = [self.fullPath stringByAppendingPathComponent:key];

    NSOperation *operation = [NSOperation new];
    dispatch_async(self.IOQueue, ^{
        if (operation.isCancelled) {
            return ;
        }
        id object = nil;
        
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        YZHDiskObject *diskObject = [[YZHDiskObject alloc] init];
        [diskObject decode:dict];
        if (diskObject.type == YZHDiskObjectTypeData || diskObject.type == YZHDiskObjectTypeNoneCode) {
            object = diskObject.data;
        }
        else if (diskObject.type == YZHDiskObjectTypeCustom) {
            if (decode) {
                object = decode(self, diskObject.data, path, fileName);
            }
        }
        else if (diskObject.type == YZHDiskObjectTypeCodingToData) {
            object = [YZHUtil decodeObjectForData:diskObject.data forKey:OBJECT_ARCHIVE_TO_DATA_KEY];
        }
        
        id data = diskObject.data;
        if (self.syncDoCompletion) {
            if (completion) {
                completion(self, data, object, path, fileName);
            }
        }
        else {
            dispatch_async(self.completionQueue, ^{
                if (operation.isCancelled) {
                    return;
                }
                if (completion) {
                    completion(self, data, object, path, fileName);
                }
            });
        }
    });
    
    return operation;
}

-(NSOperation*)removeObjectForFileName:(NSString*)fileName completion:(YZHDiskCacheRemoveCompletionBlock)completion
{
    NSString *key = [self _saveFileNameForFileName:fileName];
    NSString *path = [self.fullPath stringByAppendingPathComponent:key];
    
    NSOperation *operation = [NSOperation new];
    dispatch_async(self.IOQueue, ^{
        if (operation.isCancelled) {
            return ;
        }
        if ([YZHUtil checkFileExistsAtPath:path]) {
            [YZHUtil removeFileItemAtPath:path];
        }
        if (self.syncDoCompletion) {
            if (completion) {
                completion(self, path);
            }
        }
        else {
            dispatch_async(self.completionQueue, ^{
                if (completion) {
                    completion(self, path);
                }
            });
        }
    });
    return operation;
}

@end
