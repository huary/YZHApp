//
//  tracePC.m
//  BitSort
//
//  Created by yuan on 2021/3/26.
//

#import "tracePC.h"
#import <dlfcn.h>
#import <libkern/OSAtomicQueue.h>

static int flag = 0;
static OSQueueHead funcQueue = OS_ATOMIC_QUEUE_INIT;

typedef struct funcNode {
    void *PC;
    struct funcNode *next;
}FuncNode_S;

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start, uint32_t *stop)
{
    static uint32_t n = 0;  // Counter for the guards.
    if (start == stop || *start) return;  // Initialize only once.
    for (uint32_t *x = start; x < stop; x++) {
        *x = ++n;  // Guards should start from 1.
    }
    NSLog(@"%s n=%d",__FUNCTION__,n);
}

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
//    if (!*guard) return;  // Duplicate the guard check.

    if (flag) {
        return;
    }
    void *PC = __builtin_return_address(0);
    
    FuncNode_S *fn = malloc(sizeof(FuncNode_S));
    fn->PC = PC;
    fn->next = NULL;
    OSAtomicEnqueue(&funcQueue, fn, offsetof(FuncNode_S, next));
}


NSArray *getAllFuncList(BOOL writeOrderFile)
{
    flag = 1;
    NSMutableArray *list = [NSMutableArray array];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    while (1) {
        FuncNode_S *fn = OSAtomicDequeue(&funcQueue, offsetof(FuncNode_S, next));
        if (!fn) {
            break;
        }
        
        Dl_info info;
        dladdr(fn->PC, &info);
        
        NSString *name = [NSString stringWithUTF8String:info.dli_sname];
        if (![dict objectForKey:name]) {
            [dict setObject:@(1) forKey:name];
            BOOL isObjc = [name hasPrefix:@"-["] || [name hasPrefix:@"+["];
            if (!isObjc) {
                name = [@"_" stringByAppendingString:name];
            }
            
//            NSLog(@"name=%@",name);
            [list addObject:name];
        }
        free(fn);
    }
    
    NSArray *funcList = [[list reverseObjectEnumerator] allObjects];

    if (writeOrderFile) {
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ld.order"];
        
        NSString *content = [funcList componentsJoinedByString:@"\n"];
        NSData *fileData = [content dataUsingEncoding:NSUTF8StringEncoding];
        
        BOOL r = [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileData attributes:nil];
        if (!r) {
            NSLog(@"写入文件失败");
        }
    }
    return funcList;
}

void getStartSymbolList(BOOL writeOrderFile, void(^completionBlock)(NSArray<NSString*>*symbolList)) {
    CFRunLoopRef mainRunLoop = [[NSRunLoop mainRunLoop] getCFRunLoop];
    
    CFRunLoopPerformBlock(mainRunLoop, kCFRunLoopDefaultMode, ^{
        NSLog(@"runloop perform block end:%@",@([[NSDate date] timeIntervalSince1970]));
//        NSArray *symbolList = getAllFuncList(YES);
//        if (completionBlock) {
//            completionBlock(symbolList);
//        }
    });
    
    
    CFRunLoopActivity activities = kCFRunLoopAllActivities;
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(NULL, activities, NO, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (activity == kCFRunLoopBeforeTimers) {
            NSLog(@"runloop before timers end:%@",@([[NSDate date] timeIntervalSince1970]));
            CFRunLoopRemoveObserver(mainRunLoop, observer, kCFRunLoopCommonModes);
            
            NSArray *symbolList = getAllFuncList(YES);
            if (completionBlock) {
                completionBlock(symbolList);
            }
        }
    });
    CFRunLoopAddObserver(mainRunLoop, observer, kCFRunLoopCommonModes);
}
