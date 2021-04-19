//
//  MMContext.m
//  YZHApp
//
//  Created by yuan on 2021/4/7.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "MMContext.h"
#import <malloc/malloc.h>
#import <mach/thread_act.h>
#import <assert.h>
#import <iostream>
#import "MMStack.h"
#import "MMTypes.h"
#import <dlfcn.h>

struct MMDictEnumeratorCtx {
    BOOL stop;
    MMCtxDictEnumeratorBlock block;
};

struct MMSetEnumeratorCtx {
    BOOL stop;
    MMCtxSetEnumeratorBlock block;
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

#define MM_DictKey      @"key"
#define MM_DictValue    @"value"

#define MM_THRD_IdKey            @"thrdid"
#define MM_THRD_NameKey          @"thrdname"
#define MM_THRD_SizeKey          @"stksize"
#define MM_THRD_AddrKey          @"stkaddr"
#define MM_THRD_DepthKey         @"stkdepth"
#define MM_THRD_FramesKey        @"frames"
#define MM_THRD_FrameSNameKey    @"sname"
#define MM_THRD_FrameFNameKey    @"fname"
#define MM_THRD_FrameFPKey       @"fp"
#define MM_THRD_FrameSPKey       @"sp"
#define MM_THRD_FrameHeapKey     @"heap"

#define MM_OBJC_STR(cstr) [NSString stringWithUTF8String:cstr]
#define MM_VALUE_PTR(ptr) @((uintptr_t)ptr)//[NSValue valueWithPointer:(void *)ptr]
#define MM_VALUE_OBJ(obj) @((uintptr_t)obj)//[NSValue valueWithPointer:(__bridge void *)obj]

#define MM_ARRAY_FOREACH_READ(IN)   \
{ \
    NSMutableDictionary *sub = [NSMutableDictionary dictionary]; \
    [sub setObject:NSStringFromClass(object_getClass(obj)) forKey:MM_TypeKey]; \
    [sub setObject:@(idx) forKey:MM_NameKey]; \
    [sub setObject:MM_VALUE_OBJ(obj) forKey:MM_AddrKey]; \
    [IN addObject:sub]; \
}

#define MM_DICT_FOREACH_READ(IN)    \
{ \
    NSMutableDictionary *objSub = [NSMutableDictionary dictionary]; \
    NSDictionary *typeValue = @{MM_DictKey:NSStringFromClass(object_getClass(key)), \
                                MM_DictValue:NSStringFromClass(object_getClass(obj))}; \
    NSDictionary *addrValue = @{MM_DictKey:MM_VALUE_OBJ(key), \
                                MM_DictValue:MM_VALUE_OBJ(obj)}; \
    [objSub setObject:typeValue forKey:MM_TypeKey]; \
    [objSub setObject:addrValue forKey:MM_AddrKey]; \
    [IN addObject:objSub]; \
}

#define MM_SET_FOREACH_READ(IN) \
{ \
    NSMutableDictionary *sub = [NSMutableDictionary dictionary]; \
    [sub setObject:NSStringFromClass(object_getClass(obj)) forKey:MM_TypeKey]; \
    [sub setObject:MM_VALUE_OBJ(obj) forKey:MM_AddrKey]; \
    [subs addObject:sub];\
}

#define MM_ADDR_FOREACH_READ(ADDR, SIZE, ...) \
if (SIZE > MMContext::pointerSize) { \
    uint8_t *ptr = (uint8_t*)ADDR; \
    uint8_t *endPtr = ptr + SIZE; \
    while (ptr + MMContext::pointerSize < endPtr) { \
        vm_address_t *addrPtr = (vm_address_t*)ptr; \
        ptr += MMContext::pointerSize; \
        vm_address_t addrVal = *addrPtr; \
        __VA_ARGS__;\
    }\
}

#define LR_TRIP_MASK            0x0000000fffffffff
#define MM_NORMALISE_LR(LR)     (LR & LR_TRIP_MASK)


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

void enumerateMMCtxDictionry(CFDictionaryRef dict, MMCtxDictEnumeratorBlock block) {
    if (dict == NULL || block == nil) {
        return;
    }
    //现在本身内存紧张，不通过获取所有的keys的方式来遍历
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

void enumerateMMCtxArray(CFArrayRef array, CFRange range, MMCtxArrayEnumeratorBlock block) {
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

void _setApplierFunction(const void *value, void *context)
{
    struct MMSetEnumeratorCtx *ctx = (struct MMSetEnumeratorCtx*)context;
    if (!ctx->stop) {
        ctx->block((uintptr_t)value, &ctx->stop);
    }
}

void enumerateMMCtxSet(CFSetRef set, MMCtxSetEnumeratorBlock block) {
    if (set == NULL || block == nil) {
        return;
    }
    
    struct MMSetEnumeratorCtx ctx;
    ctx.block = block;
    ctx.stop = NO;
    CFSetApplyFunction(set, _setApplierFunction, &ctx);
}

void enumerateMMCtxBag(CFBagRef bag, MMCtxSetEnumeratorBlock block) {
    if (bag == NULL || block == nil) {
        return;
    }
    
    struct MMSetEnumeratorCtx ctx;
    ctx.block = block;
    ctx.stop = NO;
    
    CFBagApplyFunction(bag, _setApplierFunction, &ctx);
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

NSDictionary *pri_frameInfoFrom(vm_address_t fp, vm_address_t sp, vm_address_t lr) {
    Dl_info info = {NULL,NULL};
    NSMutableDictionary *frameInfo = [NSMutableDictionary dictionary];
    dladdr((const void *)MM_NORMALISE_LR(lr), &info);
    if (info.dli_sname) {
        [frameInfo setObject:MM_OBJC_STR(info.dli_sname) forKey:MM_THRD_FrameSNameKey];
    }
    if (info.dli_fname) {
        [frameInfo setObject:MM_OBJC_STR(info.dli_fname) forKey:MM_THRD_FrameFNameKey];
    }
    [frameInfo setObject:@(fp) forKey:MM_THRD_FrameFPKey];
    [frameInfo setObject:@(sp) forKey:MM_THRD_FrameSPKey];
    
    vm_size_t size = fp - sp;
    NSMutableArray *heapAddrList = [NSMutableArray array];
    MM_ADDR_FOREACH_READ(sp, size, {
        //这里是否需要判断addrValue是否在堆上？？？
        if (addrVal) {
            [heapAddrList addObject:@(addrVal)];
        }
    });
    if (heapAddrList.count > 0) {
        [frameInfo setObject:heapAddrList forKey:MM_THRD_FrameHeapKey];
    }
    
    return frameInfo;
}

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
        
        shareContext.suspendThreadList = NULL;
        shareContext.suspendThreadCnt = 0;
        shareContext.heapList = nil;
        shareContext.stackList = nil;
        shareInstancePtr = &shareContext;
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


void MMContext::readHeap() {
    CFIndex cnt = CFArrayGetCount(zoneList);
    CFRange r = CFRangeMake(0, cnt);
    
    NSMutableArray *zoneArray = [NSMutableArray array];
    enumerateMMCtxArray(zoneList, r, ^(uintptr_t value, CFIndex idx, BOOL * _Nonnull stop) {
        MMCtxZone_T *ctxZone = (MMCtxZone_T *)value;
        NSMutableArray *rangeArray = [NSMutableArray array];
        CFIndex rangeCnt = CFArrayGetCount(ctxZone->rangeList);
        enumerateMMCtxArray(ctxZone->rangeList, CFRangeMake(0, rangeCnt), ^(uintptr_t value, CFIndex idx, BOOL * _Nonnull stop) {
            
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
                void *mainPtr = (void*)ctxRange->range.address;
                id mainObj = (__bridge id)mainPtr;
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
                            void *ptrTmp = (__bridge void *)object_getIvar((__bridge id)mainPtr, ivar);
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
                        NSArray *array = (NSArray*)mainObj;
                        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) MM_ARRAY_FOREACH_READ(subs)];
                    }
                    else if ([mainObj isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dict = (NSDictionary*)mainObj;
                        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) MM_DICT_FOREACH_READ(subs)];
                    }
                    else if ([mainObj isKindOfClass:[NSSet class]]) {
                        NSSet *set = (NSSet*)mainObj;
                        [set enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) MM_SET_FOREACH_READ(subs)];
                    }
                    else if ([mainObj isKindOfClass:[NSHashTable class]]) {
                        NSHashTable *ht = (NSHashTable*)mainObj;
                        [ht hz_enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) MM_ARRAY_FOREACH_READ(subs)];
                    }
                    else if ([mainObj isKindOfClass:[NSMapTable class]]) {
                        NSMapTable *mt = (NSMapTable*)mainObj;
                        [mt hz_enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) MM_DICT_FOREACH_READ(subs)];
                    }
                    else {
                        CFTypeID typeId = CFGetTypeID(mainPtr);
                        if (typeId == CFDictionaryGetTypeID()) {
                            CFDictionaryRef dict = (CFDictionaryRef)mainPtr;
                            enumerateMMCtxDictionry(dict, ^(uintptr_t pKey, uintptr_t pValue, BOOL * _Nonnull stop) {
                                id key = (__bridge id)((void*)pKey);
                                id obj = (__bridge id)((void*)pValue);
                                MM_DICT_FOREACH_READ(subs);
                            });
                        }
                        else if (typeId == CFArrayGetTypeID()) {
                            CFArrayRef array = (CFArrayRef)mainPtr;
                            CFRange r = CFRangeMake(0, CFArrayGetCount(array));
                            enumerateMMCtxArray(array, r, ^(uintptr_t value, CFIndex idx, BOOL * _Nonnull stop) {
                                id obj = (__bridge id)((void*)value);
                                MM_ARRAY_FOREACH_READ(subs);
                            });
                        }
                        else if (typeId == CFSetGetTypeID()) {
                            CFSetRef set = (CFSetRef)mainPtr;
                            enumerateMMCtxSet(set, ^(uintptr_t value, BOOL * _Nonnull stop) {
                                id obj = (__bridge id)(void*)value;
                                MM_SET_FOREACH_READ(subs);
                            });
                        }
                        else if (typeId == CFBagGetTypeID()) {
                            CFBagRef bag = (CFBagRef)mainPtr;
                            enumerateMMCtxBag(bag, ^(uintptr_t value, BOOL * _Nonnull stop) {
                                id obj = (__bridge id)(void*)value;
                                MM_SET_FOREACH_READ(subs);
                            });
                        }
                        else {
                            //其他系统类不进行遍历
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
                MM_ADDR_FOREACH_READ(r.address, r.size, {
                    if (addrVal) {
                        NSMutableDictionary *sub = [NSMutableDictionary dictionary];
                        [sub setObject:@(addrVal) forKey:MM_AddrKey];
                        [subs addObject:sub];
                    }
                });
                [rangeDict setObject:subs forKey:MM_SubsKey];
            }
            [rangeArray addObject:rangeDict];
        });
        [zoneArray addObject:rangeArray];
    });
    this->heapList = [zoneArray copy];
}


//stack,休眠当前进程中所有的线程
void MMContext::suspendTaskThread() {
    __block bool OK = true;
    foreach_task_threads(^bool(thread_act_array_t thread_array, mach_msg_type_number_t cnt) {
        this->suspendThreadCnt = cnt;
        this->suspendThreadList = thread_array;
        return true;
    }, ^(thread_t thread, mach_msg_type_number_t idx, bool *stop) {
        if (thread == mach_thread_self()) {
            return;
        }
        
        if (KERN_SUCCESS != thread_suspend(thread)) {
            for (mach_msg_type_number_t i = 0; i < idx; ++i) {
                thread_t th = this->suspendThreadList[i];
                thread_resume(th);
            }
            OK = false;
            *stop = true;
        }
    }, ^bool(thread_act_array_t thread_array, mach_msg_type_number_t cnt) {
        if (!OK) {
            this->suspendThreadCnt = 0;
            this->suspendThreadList = nullptr;
            return true;
        }
        return false;
    });
}

//stack,读取休眠的线程栈
void MMContext::readStack() {
    struct MMStackCtx ctx;
    char thread_name[512] = {0};
    size_t size = sizeof(thread_name)/sizeof(char);
    NSMutableArray *threadList = [NSMutableArray array];
    for (mach_msg_type_number_t i = 0; i < this->suspendThreadCnt; ++i) {
        thread_t thread = this->suspendThreadList[i];
        pthread_t pthread = pthread_from_mach_thread_np(thread);
        vm_size_t stackSize = pthread_get_stacksize_np(pthread);
        //栈的起始地址，在高位
        void *stackaddr = pthread_get_stackaddr_np(pthread);
        if (stackaddr && stackSize >= MMContext::pointerSize) {
            thread_stack_ctx(thread, &ctx);
            NSMutableDictionary *threadInfo = [NSMutableDictionary dictionary];
            uint64_t tid = 0;
            pthread_threadid_np(pthread, &tid);
            [threadInfo setObject:@(tid) forKey:MM_THRD_IdKey];
            
            thread_name[0] = 0;
            if (pthread_getname_np(pthread, thread_name, size) == 0 && thread_name[0]!=0) {
                [threadInfo setObject:MM_OBJC_STR(thread_name) forKey:MM_THRD_NameKey];
            }
            
            [threadInfo setObject:@(stackSize) forKey:MM_THRD_SizeKey];
            [threadInfo setObject:@((uintptr_t)stackaddr) forKey:MM_THRD_AddrKey];
            
            vm_size_t depth = (vm_address_t)stackaddr - (vm_address_t)ctx.ctx.MM_SS.MM_SP;
            [threadInfo setObject:@(depth) forKey:MM_THRD_DepthKey];
            
            NSMutableArray *frameList = [NSMutableArray array];
            
            vm_address_t fp = ctx.ctx.MM_SS.MM_FP;
            vm_address_t sp = ctx.ctx.MM_SS.MM_SP;
            vm_address_t pc = ctx.ctx.MM_SS.MM_PC;
            NSDictionary *frameInfo = pri_frameInfoFrom(fp, sp, pc);
            [frameList addObject:frameInfo];
            
            sp = ctx.ctx.MM_SS.MM_FP;
            struct MMStackFrame *frame = &ctx.frame;
            while (frame && frame->prev && frame->lr) {
                fp = (vm_address_t)frame->prev;
                NSDictionary *frameInfo = pri_frameInfoFrom(fp, sp, frame->lr);
                [frameList addObject:frameInfo];
                sp = fp;
            }
            [threadInfo setObject:frameList forKey:MM_THRD_FramesKey];
            [threadList addObject:threadInfo];
        }
    }
    this->stackList = [threadList copy];
}

//stack,恢复当前进程中所有的线程
void MMContext::resumeTaskThread() {
    for (mach_msg_type_number_t i = 0; i < suspendThreadCnt; ++i) {
        thread_t thread = suspendThreadList[i];
        if (KERN_SUCCESS != thread_resume(thread)) {
            NSLog(@"resume thread:%u failed", thread);
        }
    }
    
    for (mach_msg_type_number_t i = 0; i < suspendThreadCnt; ++i) {
        mach_port_deallocate(mach_task_self(), suspendThreadList[i]);
    }
    vm_deallocate(mach_task_self(), (vm_address_t)&suspendThreadList, suspendThreadCnt * sizeof(thread_t));
    
}
