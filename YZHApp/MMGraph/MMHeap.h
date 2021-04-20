//
//  MMGraph.h
//  YZHApp
//
//  Created by yuan on 2021/4/3.
//  Copyright © 2021 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

//读取VM的regin
void readVMRegin(void);

//开始准备读取HeapZone
void prepareReadHeapZone(void);

//开始读取HeapZone
void readHeapZone(void);

void MMGraphTest(void);
