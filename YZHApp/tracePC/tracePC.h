//
//  tracePC.h
//  BitSort
//
//  Created by yuan on 2021/3/26.
//

#import <Foundation/Foundation.h>

NSArray *getAllFuncList(BOOL writeOrderFile);
void getStartSymbolList(BOOL writeOrderFile, void(^completionBlock)(NSArray<NSString*>*symbolList));
