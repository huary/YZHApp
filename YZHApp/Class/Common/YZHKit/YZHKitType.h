//
//  YZHKitType.h
//  YZHApp
//
//  Created by yuan on 2018/12/29.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#import "YZHKitMacro.h"

#define UPDATE_VIEW_FRAME(VIEW, FIELD, VAL)   {CGRect F = VIEW.frame; F.FIELD = VAL; VIEW.frame = F;}
#define UPDATE_VIEW_CENTER(VIEW, FIELD, VAL)  {CGPoint C = VIEW.center; C.FIELD = VAL; VIEW.center = C;}

#define SET_VIEW_top(VIEW,TOP)        UPDATE_VIEW_FRAME(VIEW, origin.y, TOP)
#define SET_VIEW_left(VIEW,LEFT)      UPDATE_VIEW_FRAME(VIEW, origin.x, LEFT)
#define SET_VIEW_right(VIEW,RIGHT)    UPDATE_VIEW_FRAME(VIEW, origin.x, RIGHT - F.size.width)
#define SET_VIEW_bottom(VIEW,BOTTOM)  UPDATE_VIEW_FRAME(VIEW, origin.y, BOTTOM - F.size.height)
#define SET_VIEW_width(VIEW,WIDTH)    UPDATE_VIEW_FRAME(VIEW, size.width, WIDTH)
#define SET_VIEW_height(VIEW,HEIGHT)  UPDATE_VIEW_FRAME(VIEW, size.height, HEIGHT)
#define SET_VIEW_centerX(VIEW,CX)     UPDATE_VIEW_CENTER(VIEW, x, CX)
#define SET_VIEW_centerY(VIEW,CY)     UPDATE_VIEW_CENTER(VIEW, y, CY)
#define SET_VIEW_origin(VIEW,ORG)     UPDATE_VIEW_FRAME(VIEW, origin, ORG)
#define SET_VIEW_size(VIEW, SIZE)     UPDATE_VIEW_FRAME(VIEW, size, SIZE)


#define GET_VIEW_top(VIEW)            (VIEW.frame.origin.y)
#define GET_VIEW_left(VIEW)           (VIEW.frame.origin.x)
#define GET_VIEW_right(VIEW)          (VIEW.frame.origin.x + VIEW.frame.size.width)
#define GET_VIEW_bottom(VIEW)         (VIEW.frame.origin.y + VIEW.frame.size.height)
#define GET_VIEW_width(VIEW)          (VIEW.frame.size.width)
#define GET_VIEW_height(VIEW)         (VIEW.frame.size.height)
#define GET_VIEW_centerX(VIEW)        (VIEW.center.x)
#define GET_VIEW_centerY(VIEW)        (VIEW.center.y)
#define GET_VIEW_origin(VIEW)         (VIEW.frame.origin)
#define GET_VIEW_size(VIEW)           (VIEW.frame.size)


#define SET_VIEW_TOP(VIEW,TOP)        SET_VIEW_top(VIEW,TOP)
#define SET_VIEW_LEFT(VIEW,LEFT)      SET_VIEW_left(VIEW,LEFT)
#define SET_VIEW_RIGHT(VIEW,RIGHT)    SET_VIEW_right(VIEW,RIGHT)
#define SET_VIEW_BOTTOM(VIEW,BOTTOM)  SET_VIEW_bottom(VIEW,BOTTOM)
#define SET_VIEW_WIDTH(VIEW,WIDTH)    SET_VIEW_width(VIEW,WIDTH)
#define SET_VIEW_HEIGHT(VIEW,HEIGHT)  SET_VIEW_height(VIEW,HEIGHT)
#define SET_VIEW_CENTER_X(VIEW,CX)    SET_VIEW_centerX(VIEW,CX)
#define SET_VIEW_CENTER_Y(VIEW,CY)    SET_VIEW_centerY(VIEW,CY)
#define SET_VIEW_ORIGIN(VIEW,ORG)     SET_VIEW_origin(VIEW,ORG)
#define SET_VIEW_SIZE(VIEW, SIZE)     SET_VIEW_size(VIEW, SIZE)

#define GET_VIEW_TOP(VIEW)            GET_VIEW_top(VIEW)
#define GET_VIEW_LEFT(VIEW)           GET_VIEW_left(VIEW)
#define GET_VIEW_RIGHT(VIEW)          GET_VIEW_right(VIEW)
#define GET_VIEW_BOTTOM(VIEW)         GET_VIEW_bottom(VIEW)
#define GET_VIEW_WIDTH(VIEW)          GET_VIEW_width(VIEW)
#define GET_VIEW_HEIGHT(VIEW)         GET_VIEW_height(VIEW)
#define GET_VIEW_CENTER_X(VIEW)       GET_VIEW_centerX(VIEW)
#define GET_VIEW_CENTER_Y(VIEW)       GET_VIEW_centerY(VIEW)
#define GET_VIEW_ORIGIN(VIEW)         GET_VIEW_origin(VIEW)
#define GET_VIEW_SIZE(VIEW)           GET_VIEW_size(VIEW)

#define GET_PROPERTY(TYPE,PROPERTY,F_NAME)     \
    -(TYPE)F_NAME                              \
    {                                          \
        return GET_VIEW_##PROPERTY(self);      \
    }

#define SET_PROPERTY(TYPE,PROPERTY,F_NAME)        \
    -(void)set##F_NAME:(TYPE)PROPERTY             \
    {                                             \
        SET_VIEW_##PROPERTY(self,PROPERTY);       \
    }

#define GET_SET_PROPERTY(TYPE,PROPERTY,GF_NAME,SF_NAME)    \
    GET_PROPERTY(TYPE, PROPERTY, GF_NAME)                  \
    SET_PROPERTY(TYPE, PROPERTY, SF_NAME)                  \



static inline void dispatch_async_in_main_queue(void (^block)(void)) {
    dispatch_async(dispatch_get_main_queue(), block);
}

static inline void dispatch_in_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static inline void dispatch_after_in_main_queue(NSTimeInterval after ,void (^block)(void)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), block);
}

static inline void sync_lock(dispatch_semaphore_t lock, void (^block)(void)) {
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    if (block) {
        block();
    }
    dispatch_semaphore_signal(lock);
}

typedef void(^YZH_cleanupBlock_t)(void);
static inline void YZH_executeCleanupBlock (YZH_cleanupBlock_t *block) {
    (*block)();
}
