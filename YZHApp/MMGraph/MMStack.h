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

//返回true/false表示是否继续往下执行（进行遍历）
typedef bool(^MM_foreach_task_thread_before_block)(thread_act_array_t thread_array, mach_msg_type_number_t cnt);

//进行遍历
typedef void(^MM_foreach_task_thread_block)(thread_t thread, mach_msg_type_number_t idx, bool *stop);

//返回true/false表示是否继续往下执行（释放资源）
typedef bool(^MM_foreach_task_thread_after_block)(thread_act_array_t thread_array, mach_msg_type_number_t cnt);

/// 获取线程的栈帧
/// @param thread 线程端口
/// @param fp 返回的栈帧(栈底)的基地址
/// @param backtrace_cnt 回溯的栈帧数
bool thread_stack_fp(thread_t thread, vm_address_t *fp, int32_t backtrace_cnt);


/// 获取线程的栈帧
/// @param thread 线程端口
/// @param sp 返回栈帧（栈顶）
bool thread_stack_sp(thread_t thread, vm_address_t *sp);

bool suspend_task_threads(void);

void resume_task_threads(void);

void foreach_task_threads(MM_foreach_task_thread_before_block before_block,
                          MM_foreach_task_thread_block block,
                          MM_foreach_task_thread_after_block after_block);

void foreach_task_threads_simple(MM_foreach_task_thread_block block);
