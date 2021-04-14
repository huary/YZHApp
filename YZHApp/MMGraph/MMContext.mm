//
//  MMContext.m
//  YZHApp
//
//  Created by yuan on 2021/4/7.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "MMContext.h"
#import <malloc/malloc.h>
#import <assert.h>
#import <iostream>

struct MMDictEnumeratorCtx {
    BOOL stop;
    MMCtxDictEnumeratorBlock block;
};

typedef struct {
    Class isa;
}MMObjc_t;

#define SYSTEM_CLASS(CLS)     ([NSBundle bundleForClass:CLS] != [NSBundle mainBundle])
#define SYSTEM_CLASS_FOR_NAME(CLS_NAME)     SYSTEM_CLASS(objc_getClass(CLS_NAME))

//#define MM_ZonesKey     @"zones"
//#define MM_RangesKey    @"ranges"
#define MM_AddrKey      @"addr"
#define MM_SizeKey      @"size"
#define MM_NameKey      @"name"
#define MM_TypeKey      @"type"
#define MM_SubsKey      @"subs"

#define MM_OBJC_STR(cstr) [NSString stringWithUTF8String:cstr]
#define MM_VALUE_PTR(ptr) [NSValue valueWithPointer:(void *)ptr]
#define MM_VALUE_OBJ(obj) [NSValue valueWithPointer:(__bridge void *)obj]

#define USE_CF_RUNTIME_CLASS    1
#if USE_CF_RUNTIME_CLASS
typedef struct {
    CFIndex version;
    const char *className;
}MM_CFRunTimeClass;
extern "C" const MM_CFRunTimeClass * _CFRuntimeGetClassWithTypeID(CFTypeID typeID);
#endif

malloc_zone_t *MMContextZone() {
    static malloc_zone_t *MMCtxZone = NULL;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
    if (MMCtxZone == NULL) {
        MMCtxZone = malloc_create_zone(8 * 1024 * 1024, 0);
        malloc_set_zone_name(MMCtxZone, "MMGraphCtxZone");        
    }
//    });
    return MMCtxZone;
}

CFMutableDictionaryRef createMMCtxDictionary(CFIndex capacity) {
    return CFDictionaryCreateMutableCopy(MMContextAllocator(), capacity, NULL);
}

void MMCtxDictionarySetValueForKey(CFMutableDictionaryRef dict, uintptr_t key, uintptr_t value) {
    CFDictionarySetValue(dict, (const void *)key, (const void *)value);
}

void MMCtxDictionaryRemoveKey(CFMutableDictionaryRef dict, uintptr_t key) {
    CFDictionaryRemoveValue(dict, (const void *)key);
}

void MMCtxDictionaryRemoveAllValues(CFMutableDictionaryRef dict) {
    CFDictionaryRemoveAllValues(dict);
}

void _dictionaryApplierFunction(const void *key, const void *value, void *context)
{
    struct MMDictEnumeratorCtx *ctx = (struct MMDictEnumeratorCtx*)context;
    if (!ctx->stop) {
        ctx->block((uintptr_t)key,(uintptr_t)key, &ctx->stop);
    }
}

void enumeratorMMCtxDictionry(CFMutableDictionaryRef dict, MMCtxDictEnumeratorBlock block) {
    if (dict == NULL || block == nil) {
        return;
    }
    struct MMDictEnumeratorCtx ctx;
    ctx.block = block;
    ctx.stop = NO;
    CFDictionaryApplyFunction(dict, _dictionaryApplierFunction, (void*)&ctx);
}

CFMutableArrayRef createMMCtxArray(CFIndex capacity) {
    return CFArrayCreateMutable(MMContextAllocator(), capacity, NULL);
}

void MMCtxArrayAppendValue(CFMutableArrayRef array, uintptr_t value) {
    CFArrayAppendValue(array, (const void *)value);
}

void MMCtxArrayInsertValueAtIndex(CFMutableArrayRef array, CFIndex idx, uintptr_t value) {
    CFArrayInsertValueAtIndex(array, idx, (const void *)value);
}

void MMCtxArrayRemoveValueAtIndex(CFMutableArrayRef array, uintptr_t value) {
    CFArrayRemoveValueAtIndex(array, value);
}

void enumeratorMMCtxArray(CFMutableArrayRef array, CFRange range, MMCtxArrayEnumeratorBlock block) {
    if (array == NULL || block == nil) {
        return;
    }
    
    CFIndex cnt = CFArrayGetCount(array);
    if (range.location < 0 || range.location >= cnt) {
        return;
    }
    
    for (CFIndex i = 0; i < range.length; ++i) {
        CFIndex idx = range.location + i;
        if (idx >= cnt) {
            break;
        }
        
        const void *item = CFArrayGetValueAtIndex(array, idx);
        BOOL stop = NO;
        block((uintptr_t)item, idx, &stop);
        if (stop) {
            break;
        }
    }
}


void *MMCtxMalloc(size_t size) {
    return malloc_zone_malloc(MMContextZone(), size);
}

void *MMCtxCalloc(size_t num_items, size_t size) {
    return malloc_zone_calloc(MMContextZone(), num_items, size);
}

void *MMCtxRealloc(void *ptr, size_t size) {
    return malloc_zone_realloc(MMContextZone(), ptr, size);
}

void MMCtxFree(void *ptr) {
    return malloc_zone_free(MMContextZone(), ptr);
}


const char *getObjcClassNameForAddress(vm_range_t range) {
    if (range.size < sizeof(void*)) {
        return nullptr;
    }
    void *ptr = (void*)range.address;
    MMObjc_t *objc = (MMObjc_t*)ptr;
    Class objcClass = NULL;
#ifdef __arm64__
    extern const uintptr_t objc_debug_isa_class_mask;
    objcClass = (__bridge Class)((void*)((uintptr_t)objc->isa & objc_debug_isa_class_mask));
#else
    objcClass = objc->isa;
#endif
    CFArrayRef list =MMContext::shareContext()->getObjcClassList();
    CFIndex cnt = CFArrayGetCount(list);
    if (CFArrayContainsValue(list, CFRangeMake(0, cnt), (__bridge const void *)objcClass)) {
        const char *clsName = class_getName(objcClass);
        if (strcmp(clsName, "__NSCFType") == 0) {
            CFTypeID typeId = CFGetTypeID(objc);
#if USE_CF_RUNTIME_CLASS
            const MM_CFRunTimeClass *runtimeCls = _CFRuntimeGetClassWithTypeID(typeId);
            clsName = runtimeCls->className;
#else
            CFStringRef name = CFCopyTypeIDDescription(typeId);
            clsName = CFStringGetCStringPtr(name,kCFStringEncodingASCII);
            CFRelease(name);
#endif
        }
        return clsName;
    }
    return nullptr;
}

const char *getCxxTypeInfoNameForAddress(vm_range_t range) {
    if (range.size < sizeof(void*)) {
        return nullptr;
    }
    void *ptr = (void*)range.address;
    
    MMContext *share = MMContext::shareContext();
    CFMutableArrayRef cxxTypeInfoList = share->getCxxTypeInfoList();
    
    uint64_t ptrValue = (*((uintptr_t*)ptr) - 8);
    uint64_t start = share->machODataConstOff;
    uint64_t end = share->machODataConstOff + share->machODataConstSize;
    if (ptrValue >= start && ptrValue < end) {
        //取ptrValue作为指针里面的值就是type_info的地址
        void *typeInfoPtr = (void*)(*((uintptr_t*)ptrValue));
        CFIndex cnt = CFArrayGetCount(cxxTypeInfoList);
        if (CFArrayContainsValue(cxxTypeInfoList, CFRangeMake(0, cnt), (const void *)typeInfoPtr)) {
            std::type_info *typeInfo = (std::type_info *)typeInfoPtr;
            return typeInfo->name();
        }
    }
    return nullptr;
}

//bool isSystemClassForName(const char *name) {
//    Class cls = objc_getClass(name);
//    if ([NSBundle bundleForClass:cls] == [NSBundle mainBundle]) {
//        return NO;
//    }
//    return YES;
//}

#define CHECK_MMCTX  assert(this == MMContext::shareContext())

MMContext* MMContext::shareContext() {
    static MMContext *shareInstancePtr = nullptr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        static MMContext shareContext;
        shareContext.objcClassList = NULL;
        shareContext.cxxTypeInfoList = NULL;
        shareContext.objcInstanceList = createMMCtxArray(32);
        shareContext.zoneList = NULL;
        shareContext.rangeInfo = createMMCtxDictionary(32);
        shareContext.machODataConstOff = 0;
        shareContext.machODataConstSize = 0;
        shareInstancePtr = &shareContext;
        MMContext::pointerSize = sizeof(void*);
    });
    return shareInstancePtr;
}

void MMContext::allRegisteredObjCClassList(){
    CHECK_MMCTX;
    
    if (objcClassList) {
        CFRelease(objcClassList);
    }
    
    int cnt = objc_getClassList(nullptr, 0);
    objcClassList = createMMCtxArray(cnt);

    Class *classList = (Class*)MMCtxCalloc(cnt, sizeof(Class));
    objc_getClassList(classList, cnt);

    for (unsigned int i = 0; i < cnt; ++i) {
        Class cls = classList[i];
        CFArrayAppendValue(objcClassList, (__bridge const void *)cls);
    }
    
    if (classList) {
        MMCtxFree(classList);
    }
}

void MMContext::addCxxTypeInfo(uintptr_t typeInfo) {
    CHECK_MMCTX;
    
    if (!cxxTypeInfoList) {
        cxxTypeInfoList = createMMCtxArray(32);
    }
    MMCtxArrayAppendValue(cxxTypeInfoList, typeInfo);
}

MMCtxZone_T *MMContext::addCtxZone(malloc_zone_t *zone, uint32_t type, uint32_t range_cnt) {
    
    CHECK_MMCTX;
    
    if (!zoneList) {
        zoneList = createMMCtxArray(8);
    }
    
    MMCtxZone_T *ctxZone = (MMCtxZone_T*)MMCtxCalloc(1, sizeof(MMCtxZone_T));
    ctxZone->zone_name = zone->zone_name;
    ctxZone->zone_type = type;
    ctxZone->rangeList = createMMCtxArray(range_cnt);
    CFArrayAppendValue(zoneList, ctxZone);
    return ctxZone;
}

MMCtxRange_T *MMContext::addRangeIntoCtxZone(MMCtxZone_T *zone, vm_range_t range) {
    MMCtxRange_T *r = (MMCtxRange_T*)MMCtxCalloc(1, sizeof(MMCtxRange_T));
    r->range = range;
    if (const char *clsname = getObjcClassNameForAddress(range)) {
        r->name = clsname;
        r->type = MMCtxRNGTypeObjc;
//        NSLog(@"zone.name=%s,range=(0x%0lx,%ld),objc_clsname=%s",zone->zone_name,range.address,range.size,clsname);
    }
    else if (const char *cxxname = getCxxTypeInfoNameForAddress(range)) {
        r->name = cxxname;
        r->type = MMCtxRNGTypeCXX;
//        NSLog(@"zone.name=%s,range=(0x%0lx,%ld),cxx_clsname=%s",zone->zone_name,range.address,range.size,cxxname);
    }
    else {
        r->type = MMCtxRNGTypeRaw;
//        NSLog(@"zone.name=%s,range=(0x%0lx,%ld), raw buffer",zone->zone_name,range.address,range.size);
    }
    CFArrayAppendValue(zone->rangeList, r);
    CFDictionarySetValue(rangeInfo, (const void *)range.address, r);
    return r;
}


NSDictionary *MMContext::parase() {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:8];
    
    CFIndex cnt = CFArrayGetCount(zoneList);
    CFRange r = CFRangeMake(0, cnt);
    
    NSMutableArray *zoneArray = [NSMutableArray array];
    enumeratorMMCtxArray(zoneList, r, ^(uintptr_t value, CFIndex idx, BOOL * _Nonnull stop) {
        MMCtxZone_T *ctxZone = (MMCtxZone_T *)value;
        NSMutableArray *rangeArray = [NSMutableArray array];
        CFIndex rangeCnt = CFArrayGetCount(ctxZone->rangeList);
        enumeratorMMCtxArray(ctxZone->rangeList, CFRangeMake(0, rangeCnt), ^(uintptr_t value, CFIndex idx, BOOL * _Nonnull stop) {
            
            NSMutableDictionary *rangeDict = [NSMutableDictionary dictionary];
            MMCtxRange *ctxRange = (MMCtxRange*)value;
            
            [rangeDict setObject:@(ctxRange->range.address) forKey:MM_AddrKey];
            [rangeDict setObject:@(ctxRange->range.size) forKey:MM_SizeKey];
            [rangeDict setObject:@(ctxRange->type) forKey:MM_TypeKey];
            if (ctxRange->type == MMCtxRNGTypeObjc) {
                //如果是非系统类，遍历ivarList
                if (ctxRange->name) {
                    [rangeDict setObject:MM_OBJC_STR(ctxRange->name) forKey:MM_NameKey];
                }
    
                NSMutableArray *subs = [NSMutableArray array];
                Class cls = objc_getClass(ctxRange->name);
                void *ptr = (void*)ctxRange->range.address;
                id mainObj = (__bridge id)ptr;
                if (!SYSTEM_CLASS(cls)) {
                    unsigned int cnt;
                    Ivar *ivars = class_copyIvarList(cls, &cnt);
                    for (unsigned int i = 0; i < cnt; ++i) {
                        Ivar ivar = ivars[i];
                        const char *type = ivar_getTypeEncoding(ivar);
                        if (type[0] == '@') {
                            id obj = object_getIvar(mainObj, ivar);
                            if (obj) {
                                const char *name = ivar_getName(ivar);
                                NSMutableDictionary *sub = [NSMutableDictionary dictionary];
                                [sub setObject:MM_OBJC_STR(name) forKey:MM_NameKey];
                                
                                [sub setObject:MM_OBJC_STR(type) forKey:MM_TypeKey];
                                
                                [sub setObject:MM_VALUE_OBJ(obj) forKey:MM_AddrKey];
                            
                                [subs addObject:sub];
                            }
                        }
                        //c/c++的指针,*是uint8_t/int8_t *的指针
                        else if (type[0] == '^' || type[0] == '*') {
                            void *ptrTmp = (__bridge void *)object_getIvar((__bridge id)ptr, ivar);
                            if (ptrTmp) {
                                NSMutableDictionary *sub = [NSMutableDictionary dictionary];
                                [sub setObject:MM_OBJC_STR(type) forKey:MM_TypeKey];
                                
                                [sub setObject:MM_VALUE_PTR(ptrTmp) forKey:MM_AddrKey];
                                
                                [subs addObject:sub];
                            }
                        }
                    }
                    if (ivars) {
                        free(ivars);
                    }
                }
                else {
                    //如果是系统类（集合类是否需要一一遍历？？？）
                    if ([mainObj isKindOfClass:[NSArray class]]) {

                    }
                    else if ([mainObj isKindOfClass:[NSDictionary class]]) {
                        
                    }
                    else if ([mainObj isKindOfClass:[NSSet class]]) {
                        
                    }
                    else if ([mainObj isKindOfClass:[NSHashTable class]]) {
                        
                    }
                    else if ([mainObj isKindOfClass:[NSMapTable class]]) {
                        
                    }
                    else {
                        CFTypeID typeId = CFGetTypeID(ptr);
                        if (typeId == CFDictionaryGetTypeID()) {
                            
                        }
                        else if (typeId == CFArrayGetTypeID()) {
                            
                        }
                        else if (typeId == CFSetGetTypeID()) {
                            
                        }
                        else if (typeId == CFBagGetTypeID()) {
                            
                        }

                    }
                }
                [rangeDict setObject:subs forKey:MM_SubsKey];
            }
            else {
                //MMCtxRNGTypeCXX,MMCtxRNGTypeRaw
                if (ctxRange->type == MMCtxRNGTypeCXX && ctxRange->name) {
                    [rangeDict setObject:MM_OBJC_STR(ctxRange->name) forKey:MM_NameKey];
                }
                
                //MMContext::以pointerSize为步长遍历
                NSMutableArray *subs = [NSMutableArray array];
                vm_range_t r = ctxRange->range;
                if (r.size > MMContext::pointerSize) {
                    uint8_t *ptr = (uint8_t*)r.address;
                    uint8_t *endPtr = ptr + r.size;
                    while (ptr + MMContext::pointerSize < endPtr) {
                        vm_address_t *addrPtr = (vm_address_t*)ptr;
                        ptr += MMContext::pointerSize;
                        
                        vm_address_t addrVal = *addrPtr;
                        if (addrVal) {
                            NSMutableDictionary *sub = [NSMutableDictionary dictionary];
                            [sub setObject:@(addrVal) forKey:MM_AddrKey];
                            [subs addObject:sub];
                        }
                    }
                }
                [rangeDict setObject:subs forKey:MM_SubsKey];
            }
            [rangeArray addObject:rangeDict];
        });
        [zoneArray addObject:rangeArray];
    });
    return [dict copy];
}



