//
//  MMStack.h
//  YZHApp
//
//  Created by yuan on 2021/4/14.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach_types.h>
#import <mach/vm_map.h>
#import <mach/mach_init.h>
#import <mach/task.h>
#import <mach/mach_port.h>

typedef struct MMStackFrame {
    //栈上的栈帧
    struct MMStackFrame *prev;
    //这个是在fp寄存器上的连接寄存器
    uintptr_t lr;
}MMStackFrame_S;

typedef struct MMStackCtx {
    MMStackFrame frame;
    //读取到线程栈数据、寄存器数据
    _STRUCT_MCONTEXT ctx;
}MMStackCtx_S;

//返回true/false表示是否继续往下执行（进行遍历）
typedef bool(^MM_foreach_task_thread_before_block)(thread_act_array_t thread_array, mach_msg_type_number_t cnt);

//进行遍历
typedef void(^MM_foreach_task_thread_block)(thread_t thread, mach_msg_type_number_t idx, bool *stop);

//返回true/false表示是否继续往下执行（释放资源）
typedef bool(^MM_foreach_task_thread_after_block)(thread_act_array_t thread_array, mach_msg_type_number_t cnt);

/// 获取线程的栈帧
/// @param thread 线程端口
/// @param fp 返回的栈帧(栈底)的基地址
bool thread_stack_fp(thread_t thread, vm_address_t *fp);


/// 获取线程的栈帧
/// @param thread 线程端口
/// @param sp 返回栈帧（栈顶）
bool thread_stack_sp(thread_t thread, vm_address_t *sp);


/// 获取线程的栈上下文
/// @param thread 线程端口
/// @param ctx 返回的栈帧、寄存器数据
bool thread_stack_ctx(thread_t thread, struct MMStackCtx *ctx);

bool suspend_task_threads(void);

void resume_task_threads(void);

void foreach_task_threads(MM_foreach_task_thread_before_block before_block,
                          MM_foreach_task_thread_block block,
                          MM_foreach_task_thread_after_block after_block);

void foreach_task_threads_simple(MM_foreach_task_thread_block block);
