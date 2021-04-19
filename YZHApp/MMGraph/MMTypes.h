//
//  MMType.h
//  YZHApp
//
//  Created by yuan on 2021/4/14.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_types.h>

#ifdef __LP64__
typedef struct mach_header_64 mach_header_t;
typedef struct segment_command_64 segment_command_t;
typedef struct section_64 section_t;
typedef struct nlist_64 nlist_t;
#define LC_SEGMENT_ARCH LC_SEGMENT_64
#else
typedef struct mach_header mach_header_t;
typedef struct segment_command segment_command_t;
typedef struct section section_t;
typedef struct nlist nlist_t;
#define LC_SEGMENT_ARCH LC_SEGMENT
#endif

#if defined(__arm__)
#define MM_THREAD_STATE        ARM_THREAD_STATE
#define MM_THREAD_STATE_CNT    ARM_THREAD_STATE_COUNT
#define MM_EXCEPTION_STATE     ARM_EXCEPTION_STATE
#define MM_EXCEPTION_STATE_CNT ARM_EXCEPTION_STATE_COUNT

#define MM_SS                   __ss
#define MM_ES                   __es

#define MM_LR                   __lr
#define MM_FP                   __r[7]
#define MM_SP                   __sp
#define MM_PC                   __pc
#define MM_EXCEPTION            __exception

#elif defined(__arm64__)
#define MM_THREAD_STATE        ARM_THREAD_STATE64
#define MM_THREAD_STATE_CNT    ARM_THREAD_STATE64_COUNT
#define MM_EXCEPTION_STATE     ARM_EXCEPTION_STATE64
#define MM_EXCEPTION_STATE_CNT ARM_EXCEPTION_STATE64_COUNT

#define MM_SS                   __ss
#define MM_ES                   __es

#define MM_LR                   __lr
#define MM_FP                   __fp
#define MM_SP                   __sp
#define MM_PC                   __pc
#define MM_EXCEPTION            __exception


#elif defined(__i386__)
#define MM_THREAD_STATE        x86_THREAD_STATE32
#define MM_THREAD_STATE_CNT    x86_THREAD_STATE32_COUNT
#define MM_EXCEPTION_STATE     x86_EXCEPTION_STATE32
#define MM_EXCEPTION_STATE_CNT x86_EXCEPTION_STATE32_COUNT

#define MM_SS                   __ss
#define MM_ES                   __es

//i386没有lr寄存器，就用eip表示同样的效果
#define MM_LR                   __eip
#define MM_PC                   MM_LR
#define MM_FP                   __ebp
#define MM_SP                   __esp
#define MM_EXCEPTION            __err


#elif defined(__x86_64__)
#define MM_THREAD_STATE        x86_THREAD_STATE64
#define MM_THREAD_STATE_CNT    x86_THREAD_STATE64_COUNT
#define MM_EXCEPTION_STATE     x86_EXCEPTION_STATE64
#define MM_EXCEPTION_STATE_CNT x86_EXCEPTION_STATE64_COUNT

#define MM_SS                   __ss
#define MM_ES                   __es

//i386没有lr寄存器，就用rip表示同样的效果
#define MM_LR                   __rip
#define MM_PC                   MM_LR
#define MM_FP                   __rbp
#define MM_SP                   __rsp
#define MM_EXCEPTION            __err

#endif


#define _THREAD_GET_STATE(th, flavor, pattern, old_state, err_ret) \
{ \
mach_msg_type_number_t state_cnt = pattern; \
kern_return_t ret = thread_get_state(th, flavor, (thread_state_t)&old_state, &state_cnt); \
if (ret != KERN_SUCCESS) return err_ret; \
}

#define THREAD_GET_STATE(th, flavor, old_state, err_ret) _THREAD_GET_STATE(th, flavor, flavor ## _CNT, old_state, err_ret)

#define VM_READ_OVERWRITE(ph, addr, size, odata, osize, err_ret) \
{\
kern_return_t ret = vm_read_overwrite(ph, (vm_address_t)addr, size, (vm_address_t)odata, (vm_size_t*)&osize); \
if (ret != KERN_SUCCESS) return err_ret; \
}

