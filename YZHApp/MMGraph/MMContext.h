//
//  MMContext.h
//  YZHApp
//
//  Created by yuan on 2021/4/7.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <malloc/malloc.h>


NS_ASSUME_NONNULL_BEGIN

//typedef struct {
//    Class isa;
//}MMObjc_t;


typedef void(^MMCtxDictEnumeratorBlock)(uintptr_t key, uintptr_t value, BOOL *stop);

typedef void(^MMCtxArrayEnumeratorBlock)(uintptr_t value, CFIndex idx, BOOL *stop);

typedef void(^MMCtxSetEnumeratorBlock)(uintptr_t value, BOOL *stop);

malloc_zone_t *MMContextZone(void);

/*通过查看CoreFoundation源码中CFBase.c的代码实现，
 CFAllocatorRef的结构是malloc_zone_t的子类(struct __CFAllocator 包含了malloc_zone_t的所有信息，还额外多了alloctor和context的信息)，
 在传入malloc_zone_t（非objc对象时）作为CFAllocatorRef的参数调用时，
 直接调用malloc_zone_malloc(zone,size)申请内存空间
 */
inline CFAllocatorRef MMContextAllocator() {
    return (CFAllocatorRef)MMContextZone();
}

//这里创建的key/value是不不进行retain/release的，可以是整数/指针
CFMutableDictionaryRef createMMCtxDictionary(CFIndex capacity);

void MMCtxDictionarySetValueForKey(CFMutableDictionaryRef dict, uintptr_t key, uintptr_t value);
void MMCtxDictionaryRemoveKey(CFMutableDictionaryRef dict, uintptr_t key);
void MMCtxDictionaryRemoveAllValues(CFMutableDictionaryRef dict);
void enumerateMMCtxDictionry(CFDictionaryRef dict, MMCtxDictEnumeratorBlock block);

CFMutableArrayRef createMMCtxArray(CFIndex capacity);
void MMCtxArrayAppendValue(CFMutableArrayRef array, uintptr_t value);
void MMCtxArrayInsertValueAtIndex(CFMutableArrayRef array, CFIndex idx, uintptr_t value);
void MMCtxArrayRemoveValueAtIndex(CFMutableArrayRef array, uintptr_t value);
void enumerateMMCtxArray(CFArrayRef array, CFRange range, MMCtxArrayEnumeratorBlock block);

void *MMCtxMalloc(size_t size);

void *MMCtxCalloc(size_t num_items, size_t size);

void *MMCtxRealloc(void *ptr, size_t size);

void MMCtxFree(void *ptr);

/*有可能是CFxxx的class,因此可以通过objc_getClass(clsName)来获取Class，
 如果是CFxxx的class,得到的Class就是NULL;
 */
const char *getObjcClassNameForAddress(vm_range_t range);
const char *getCxxTypeInfoNameForAddress(vm_range_t range);

typedef enum {
    //objc对象
    MMCtxRNGTypeObjc    = 1,
    //c++对象
    MMCtxRNGTypeCXX     = 2,
    //raw buffer/struct/class
    MMCtxRNGTypeRaw     = 3,
}MMCtxRNGType_E;

//typedef struct MMRangeIvar {
//    vm_address_t address;
//    const char *varName;
//    const char *varType;
//}MMRangeIvar_T;

//存储堆区的申请的内存块
typedef struct MMCtxRange {
    //当前堆区的范围
    vm_range_t range;
    //类名，或者为NULL
    const char *name;
    //内存的类型
    MMCtxRNGType_E type;
    //存储其他的堆区的指针数组(MMCtxBLK)
    CFMutableArrayRef ivarList;
}MMCtxRange_T;

//存储zone的信息（包含若干个堆区的内存块）
typedef struct MMCtxZone {
    //zone的名字
    const char *zone_name;
    //zone的type
    uint32_t zone_type;
    //堆区内存块的数据(MMCtxRange)
    CFMutableArrayRef rangeList;
}MMCtxZone_T;

class MMContext {
private:
    CFMutableArrayRef objcClassList;
    CFMutableArrayRef cxxTypeInfoList;
    CFMutableArrayRef objcInstanceList;
    CFMutableArrayRef zoneList;
    CFMutableDictionaryRef rangeInfo;
    thread_act_array_t suspendThreadList;
    mach_msg_type_number_t suspendThreadCnt;
    
    NSArray *heapList;
    NSArray *stackList;
public:
    int64_t machODataConstOff;
    int64_t machODataConstSize;
    
    static const uint8_t pointerSize = sizeof(void*);
    static MMContext *shareContext();
    MMContext() {}
    ~MMContext() {}
    
    CFMutableArrayRef getObjcClassList() {
        return objcClassList;
    }
    CFMutableArrayRef getCxxTypeInfoList() {
        return cxxTypeInfoList;
    }
    CFMutableArrayRef getObjcInstanceList() {
        return objcInstanceList;
    }
    
    void allRegisteredObjCClassList();
    
    void addCxxTypeInfo(uintptr_t typeInfo);
    
    MMCtxZone_T *addCtxZone(malloc_zone_t *zone, uint32_t type, uint32_t range_cnt);
    
    MMCtxRange_T *addRangeIntoCtxZone(MMCtxZone_T *zone, vm_range_t range);
    
    //读取对重的数据
    void readHeap();
    
    //stack,休眠当前进程中所有的线程
    bool suspendTaskThread();
    
    //stack,读取休眠的线程栈
    void readStack();
    
    //stack,恢复当前进程中所有的线程(前面休眠的)
    void resumeTaskThread();

    //开始进行内存快照
    void start();
};

NS_ASSUME_NONNULL_END
