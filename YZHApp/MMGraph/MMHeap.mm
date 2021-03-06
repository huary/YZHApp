//
//  MMGraph.m
//  YZHApp
//
//  Created by yuan on 2021/4/3.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "MMHeap.h"
#import <mach/mach.h>
//有user_tag的标识
#import <mach/vm_statistics.h>
#import <malloc/malloc.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>
#import "MMContext.h"
#import "MMTypes.h"
#include <iostream>


extern "C" int proc_regionfilename(int pid, uint64_t address, void * buffer, uint32_t buffersize);

static void dyld_add_image_callback(const struct mach_header *mh, intptr_t slide);
static void vm_range_recorder(task_t task, void *ctx, unsigned type, vm_range_t *ranges, unsigned cnt);

static void register_dyld_add_callback() {
    _dyld_register_func_for_add_image(dyld_add_image_callback);
}

static uint64_t read_uleb128(const uint8_t *&p, const uint8_t* end)
{
    uint64_t result = 0;
    int         bit = 0;
    do {
        if ( p == end ) {
            break;
        }
        uint64_t slice = *p & 0x7f;

        if ( bit > 63 ) {
            break;
        }
        else {
            result |= (slice << bit);
            bit += 7;
        }
    }
    while (*p++ & 0x80);
    return result;
}

static int64_t read_sleb128(const uint8_t*&p, const uint8_t* end)
{
    int64_t  result = 0;
    int      bit = 0;
    uint8_t  byte = 0;
    do {
        if ( p == end ) {
            break;
        }
        byte = *p++;
        result |= (((int64_t)(byte & 0x7f)) << bit);
        bit += 7;
    } while (byte & 0x80);
    if ( ((byte & 0x40) != 0) && (bit < 64) )
        result |= (~0ULL) << bit;
    return result;
}

static void dyld_add_image_callback(const struct mach_header *mh, intptr_t slide) {
    if (mh->filetype != MH_EXECUTE) {
        return;
    }
    
    segment_command_t *cur_cmd = NULL;
    
    size_t headerSize = sizeof(mach_header_t);
    uintptr_t cmdPtr = (intptr_t)mh + headerSize;
    
    uint64_t dataConstOff = 0;
    uint64_t dataConstSize = 0;
    
    uint64_t segmentOffset = 0;
    const uint32_t  ptrSize = mh->magic == MH_MAGIC_64 ? 8 : 4;
    const char *cxxSymbolNamePrefix = "__ZTVN10__cxxabi";
    const int cxxSymbolNamePrefixLen = 16;
    
    NSMutableArray *segOffList = [NSMutableArray array];

    for (uint32_t i = 0; i < mh->ncmds; ++i) {
        cur_cmd = (segment_command_t *)cmdPtr;
        [segOffList addObject:@(cur_cmd->fileoff)];
        if (cur_cmd->cmd == LC_SEGMENT_ARCH) {
            if (strcmp(cur_cmd->segname, SEG_DATA) == 0) {
                section_t *sec = (section_t*)(cur_cmd + 1);
                for (uint32_t j = 0; j < cur_cmd->nsects; ++j) {
                    if (strcmp(sec[j].sectname, "__const") == 0) {
                        dataConstOff = (uintptr_t)mh + sec[j].offset;
                        dataConstSize = sec[j].size;
                    }
                }
            }
        }
        else if (cur_cmd->cmd == LC_DYLD_INFO ||
                 cur_cmd->cmd == LC_DYLD_INFO_ONLY) {
            struct dyld_info_command *dyldInfoCmd = (struct dyld_info_command*)cur_cmd;
            
            uintptr_t bindOff = (uintptr_t)mh + dyldInfoCmd->bind_off;
            uintptr_t bindEndOff = bindOff + dyldInfoCmd->bind_size;
            
//            bool stop = false;
            const uint8_t *p = (const uint8_t *)bindOff;
            const uint8_t *end = (const uint8_t *)bindEndOff;
            const char*symbolName = NULL;

            while (/*!stop &&*/ p < end) {
                uint8_t immediate = *p & BIND_IMMEDIATE_MASK;
                uint8_t opcode = *p & BIND_OPCODE_MASK;
                ++p;
                switch (opcode) {
                    case BIND_OPCODE_DONE:
//                        stop = true;
                        break;
                    case BIND_OPCODE_SET_DYLIB_ORDINAL_IMM:
                        break;
                    case BIND_OPCODE_SET_DYLIB_ORDINAL_ULEB:
                        read_uleb128(p, end);
                        break;
                    case BIND_OPCODE_SET_DYLIB_SPECIAL_IMM:
                        break;
                    case BIND_OPCODE_SET_SYMBOL_TRAILING_FLAGS_IMM: {
                        symbolName = (char*)p;
                        while (*p != '\0')
                            ++p;
                        ++p;
                    }
                        break;
                    case BIND_OPCODE_SET_TYPE_IMM:
                        break;
                    case BIND_OPCODE_SET_ADDEND_SLEB:
                        read_sleb128(p, end);
                        break;
                    case BIND_OPCODE_SET_SEGMENT_AND_OFFSET_ULEB: {
                        int32_t segIdx = immediate;
                        uint64_t uleb = read_uleb128(p, end);
                        segmentOffset += uleb;
                        if (segIdx >= 0 && segIdx < segOffList.count) {
                            segmentOffset += [segOffList[segIdx] longLongValue];
                        }
                    }
                        break;
                    case BIND_OPCODE_ADD_ADDR_ULEB:
                        segmentOffset += read_uleb128(p, end);
                        break;
                    case BIND_OPCODE_DO_BIND: {
                        if (strlen(symbolName) > cxxSymbolNamePrefixLen && strncmp(symbolName, cxxSymbolNamePrefix, cxxSymbolNamePrefixLen) == 0)
                        {
                            std::type_info *typeInfo = (std::type_info*)((uintptr_t)mh + (uintptr_t)segmentOffset);
//                            NSLog(@"typeInfo.name=%s,typeInfo:%p",typeInfo->name(), typeInfo);
                            MMContext::shareContext()->addCxxTypeInfo((uintptr_t)typeInfo);
                        }
                        segmentOffset += ptrSize;
                    }
                        break;
                    case BIND_OPCODE_DO_BIND_ADD_ADDR_ULEB:
                        segmentOffset += read_uleb128(p, end) + ptrSize;
                        break;
                    case BIND_OPCODE_DO_BIND_ADD_ADDR_IMM_SCALED:{
                        if (strlen(symbolName) > cxxSymbolNamePrefixLen && strncmp(symbolName, cxxSymbolNamePrefix, cxxSymbolNamePrefixLen) == 0)
                        {
                            std::type_info *typeInfo = (std::type_info*)((uintptr_t)mh + (uintptr_t)segmentOffset);
//                            NSLog(@"typeInfo.name=%s,typeInfo:%p",typeInfo->name(), typeInfo);
                            MMContext::shareContext()->addCxxTypeInfo((uintptr_t)typeInfo);
                        }
                        segmentOffset += immediate * ptrSize + ptrSize;
                    }
                        break;
                    case BIND_OPCODE_DO_BIND_ULEB_TIMES_SKIPPING_ULEB: {
                        uint64_t cnt = read_uleb128(p, end);
                        uint64_t skip = read_uleb128(p, end);
                        for (uint64_t k= 0; k < cnt; ++k) {
                            segmentOffset += skip + ptrSize;
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
        }
        cmdPtr += cur_cmd->cmdsize;
    }
    MMContext::shareContext()->machODataConstOff = dataConstOff;
    MMContext::shareContext()->machODataConstSize = dataConstSize;
}

void readVMRegin() {
    kern_return_t kret = KERN_SUCCESS;
    vm_address_t addr = 0;
    vm_size_t size = 0;
    uint32_t depth = 1;
    pid_t pid = getpid();
    char buf[PATH_MAX + 1] = {0};
    while (1) {
        struct vm_region_submap_info_64 info;
        mach_msg_type_number_t cnt = VM_REGION_SUBMAP_INFO_COUNT_64;
        kret = vm_region_recurse_64(mach_task_self(), &addr, &size, &depth, (vm_region_info_64_t)&info, &cnt);
        if (kret != KERN_SUCCESS) {
            break;
        }
        if (info.is_submap) {
            ++depth;
        }
        else {

            int len = proc_regionfilename(pid, addr, buf, sizeof(buf));
            if (len > 0) {
                buf[len] = 0;
            }
            NSLog(@"vmRegion:%@ size:%@, depth:%@,userTag:%@, name=%s", @(addr),@(size),@(depth), @(info.user_tag), buf);
            addr += size;
        }
    }
}

static kern_return_t memory_reader(task_t remote_task, vm_address_t remote_address, vm_size_t size, void **local_memory) {
    *local_memory = (void*)remote_address;
    return KERN_SUCCESS;
}

void prepareReadHeapZone(void) {
    register_dyld_add_callback();
}

void readHeapZone(void) {
    vm_address_t *zoneList = NULL;
    unsigned int cnt = 0;
    kern_return_t ret = malloc_get_all_zones(mach_task_self(), memory_reader, &zoneList, &cnt);
    if (ret != KERN_SUCCESS) {
        return;
    }
    
    MMContext::shareContext()->allRegisteredObjCClassList();
    for (unsigned int i = 0; i < cnt; ++i) {
        malloc_zone_t *zone = (malloc_zone_t*)zoneList[i];
        
        if (zone == MMContextZone()) {
            continue;
        }
        
        if (zone && zone->introspect && zone->introspect->enumerator) {
            zone->introspect->enumerator(mach_task_self(),
                                         zone,
                                         MALLOC_PTR_IN_USE_RANGE_TYPE,
                                         (vm_address_t)zone,
                                         memory_reader,
                                         vm_range_recorder);
        }
    }
}

static void vm_range_recorder(task_t task, void *ctx, unsigned type, vm_range_t *ranges, unsigned cnt) {
    malloc_zone_t *zone = (malloc_zone_t*)ctx;
    MMContext *shareCtx = MMContext::shareContext();
    MMCtxZone *ctxzone = shareCtx->addCtxZone(zone, type, cnt);
    for (uint32_t i = 0; i < cnt; ++i) {
        shareCtx->addRangeIntoCtxZone(ctxzone, ranges[i]);
    }
}


//class Person {
//private:
//    int age;
//
//public:
//    Person(int age):age(age){
//
//    }
//
//    int getAge() {
//        return age;
//    }
//
//    virtual ~Person() {
//
//    }
//
//    virtual void print() {
//        printf("Person:%d\n",age);
//    }
//};
//
//class Man : public Person {
//public:
//    Man(int age) : Person(age){
//
//    }
//};
//
//class Base {
//private:
//    int i;
//public:
//    Base(int i):i(i){
//
//    }
//
//    int getI() {
//        return i;
//    }
//};
//
//
//@interface MMGraphTestObjc : NSObject
//
//@end
//
//@implementation MMGraphTestObjc
//
//- (void)test {
//    NSLog(@"MMGraphTestObjc test");
//}
//
//@end



void MMGraphTest(void)
{
    
//    UIImage *image = [UIImage imageNamed:@"info"];
//    CFTypeID typeId = CFGetTypeID(image.CGImage);
//    CFStringRef clsName = CFCopyTypeIDDescription(typeId);
//    NSLog(@"clsName=%@",clsName);
//    CFRelease(clsName);
//
//    return;
    
//    MMGraphTestObjc *testObjc = [MMGraphTestObjc new];
//
//    [testObjc test];
    
//    Man *man = new Man(20);
//    man->print();
//
//    Person *p = new Person(50);
    
//    malloc_zone_t *zone = malloc_create_zone(1024,0);
//    malloc_set_zone_name(zone, "MMCtxZone");
//
//
//    CFMutableDictionaryRef dict = CFDictionaryCreateMutable((CFAllocatorRef)zone, 7, nullptr, nullptr);
//
//    CFTypeID typeId = CFGetTypeID(dict);
//    _CFRuntimeGetClassWithTypeID(typeId);
//    const MMCFRunTimeClass *runtimeClass = _CFRuntimeGetClassWithTypeID(typeId);
//    NSLog(@"runtimeClass.name=%s",runtimeClass->className);
    
//    CFStringRef name = CFCopyTypeIDDescription(typeId);
//    const char *clsName = CFStringGetCStringPtr(name,kCFStringEncodingASCII);
//    NSLog(@"clsName=%s",clsName);
    
//    NSLog(@"clsName2=%@",NSStringFromClass(objc_getClass("NSDictionary")));
//    CFRelease(name);
    
//    Class cls = object_getClass((__bridge id)man);
    
//    Class pcls = object_getClass((__bridge id)p);
    
//    NSLog(@"cls=%s",class_getName(cls));
//    NSLog(@"p.cls=%s",class_getName(pcls));
    
//    CFDictionarySetValue(dict, (const void *)1, (const void *)2);
//    
//    const void *ptr = CFDictionaryGetValue(dict, (const void *)1);
//    NSLog(@"1.val=%p,dict=%p",ptr,dict);
//    NSLog(@"typeId.name=%s",typeid(Man).name());
    
    
    

//    NSBundle *bv = [NSBundle bundleForClass:[UIViewController class]];
//    NSBundle *bt = [NSBundle bundleForClass:[MMGraphTestObjc class]];
//    //==[NSBundle mainBundle]属于自定义的类
//    NSLog(@"bundle.class=%@,system.class=%@",bv,@(bv == [NSBundle mainBundle]));
//    NSLog(@"bundle.test.class=%@,system.class=%@",bt,@(bt == [NSBundle mainBundle]));

//    Base *b = new Base(100);
//    uint64_t ptrValue = (*((uint64_t*)man) - 8);
//    std::type_info *typeInfo = (std::type_info*)(*((uintptr_t*)ptrValue));
//    NSLog(@"type.name=%s",typeInfo->name());
//
//
//    NSLog(@"man=%p",man);
    
    prepareReadHeapZone();
    
    readHeapZone();
}

