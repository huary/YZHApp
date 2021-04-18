//
//  MMStack.m
//  YZHApp
//
//  Created by yuan on 2021/4/14.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "MMStack.h"
#import "MMTypes.h"
#import <mach/thread_act.h>
#import <mach/vm_map.h>
#import <mach/mach_init.h>
#import <mach/task.h>
#import <mach/mach_port.h>
#import "YZHKitMacro.h"
#import <dlfcn.h>

typedef struct MMStackFrame {
    struct MMStackFrame *prev;
    uintptr_t lr;
}MMStackFrame_S;

/// 获取线程的栈帧
/// @param thread 线程端口
/// @param fp 返回的栈帧(栈底)的基地址
/// @param backtrace_cnt 回溯的栈帧数
bool thread_stack_fp(thread_t thread, vm_address_t *fp, int32_t backtrace_cnt) {
    _STRUCT_MCONTEXT ctx;

    THREAD_GET_STATE(thread, MM_THREAD_STATE, ctx.MM_SS, false);
    
    THREAD_GET_STATE(thread, MM_EXCEPTION_STATE, ctx.MM_ES, false);
    
    vm_size_t len = sizeof(fp);
    
    if (ctx.MM_ES.MM_EXCEPTION != 0) {
        return false;
    }
    VM_READ_OVERWRITE(mach_task_self(), ctx.MM_SS.MM_FP, len, fp, len, false);
    
    
    VM_READ_OVERWRITE(mach_task_self(), *fp, len, fp, len, false);
    
    return true;
}

/// 获取线程的栈帧
/// @param thread 线程端口
/// @param sp 返回栈帧（栈顶）
bool thread_stack_sp(thread_t thread, vm_address_t *sp) {
    _STRUCT_MCONTEXT ctx;

    THREAD_GET_STATE(thread, MM_THREAD_STATE, ctx.MM_SS, false);
    
    THREAD_GET_STATE(thread, MM_EXCEPTION_STATE, ctx.MM_ES, false);
        
    if (ctx.MM_ES.MM_EXCEPTION != 0) {
        return false;
    }
    
    *sp = (vm_address_t)ctx.MM_SS.MM_SP;
    
//    struct MMStackFrame frame;
//    frame.prev = nullptr;
//    frame.lr = 0;
//
//    vm_address_t size = sizeof(frame);
//    vm_address_t osize = 0;
//    VM_READ_OVERWRITE(mach_task_self(), ctx.MM_SS.MM_FP, size, &frame, osize, false);
//    NSLog(@"frame=%lu",frame.prev);
    return true;
}

void foreach_task_threads(MM_foreach_task_thread_before_block before_block,
                          MM_foreach_task_thread_block block,
                          MM_foreach_task_thread_after_block after_block)
{
    thread_act_array_t thread_array;
    mach_msg_type_number_t thread_cnt;
    kern_return_t ret = task_threads(mach_task_self(), &thread_array, &thread_cnt);
    if (ret == KERN_SUCCESS) {
        
        if (before_block) {
            if (!before_block(thread_array, thread_cnt)) {
                return;
            }
        }

        bool stop = false;
        for (mach_msg_type_number_t i = 0; i < thread_cnt; ++i) {
            thread_t thread = thread_array[i];
            block(thread, i, &stop);
            if (stop) {
                break;
            }
        }
        
        if (after_block) {
            if (!after_block(thread_array, thread_cnt)) {
                return;
            }
        }

        for (mach_msg_type_number_t i = 0; i < thread_cnt; ++i) {
            mach_port_deallocate(mach_task_self(), thread_array[i]);
        }
        vm_deallocate(mach_task_self(), (vm_address_t)&thread_array, thread_cnt * sizeof(thread_t));
    }
}

void foreach_task_threads_simple(MM_foreach_task_thread_block block) {
    foreach_task_threads(nil, block, nil);
}


bool suspend_task_threads()
{
    __block mach_msg_type_number_t thread_cnt;
    __block thread_act_array_t suspend_thread_array;
    
    __block bool ret = true;
    foreach_task_threads(^bool(thread_act_array_t thread_array, mach_msg_type_number_t cnt) {
        thread_cnt = cnt;
        suspend_thread_array = thread_array;
        return true;
    }, ^(thread_t thread, mach_msg_type_number_t idx, bool *stop) {
        if (thread == mach_thread_self()) {
            return;
        }
        
        if (KERN_SUCCESS != thread_suspend(thread)) {
            for (mach_msg_type_number_t i = 0; i < idx; ++i) {
                thread_t th = suspend_thread_array[i];
                thread_resume(th);
            }
            ret = false;
            *stop = true;
        }
    }, nil);
    
    return ret;
}

void resume_task_threads() {
    foreach_task_threads_simple(^(thread_t thread, mach_msg_type_number_t idx, bool *stop) {
        if (thread == mach_thread_self()) {
            return;
        }
        if (KERN_SUCCESS != thread_resume(thread)) {
            NSLog(@"resume thread:%u failed", thread);
        }
    });
}