//
//  NSObject+YZHAdd.h
//  YZHApp
//
//  Created by yuan on 2018/12/28.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (YZHAdd)

//addfor Identity
@property (nonatomic, assign) NSInteger hz_identity;

@property (nonatomic, strong) NSString *hz_identityString;

//weak reference object
//single
@property (nonatomic, weak) id hz_weakReferenceObject;

//multi,不要对外开放
//@property (nonatomic, strong) NSMapTable *hz_weakReferenceObjectsTable;
//@property (nonatomic, strong) NSMutableDictionary *hz_strongReferenceObjectsTable;

+ (BOOL)hz_exchangeInstanceMethod:(SEL)orgSelector with:(SEL)newSelector;
+ (BOOL)hz_exchangeClassMethod:(SEL)orgSelector with:(SEL)newSelector;

-(id)hz_respondsAndPerformSelector:(SEL)selector;
-(id)hz_respondsAndPerformSelector:(SEL)selector withObject:(id)object;

+(id)hz_respondsToSelector:(SEL)selector forClass:(Class)cls;
+(id)hz_respondsToSelector:(SEL)selector forClass:(Class)cls withObject:(id)object;

-(void)hz_addWeakReferenceObject:(id)object forKey:(id)key;
-(void)hz_removeWeakReferenceObjectForKey:(id)key;
-(id)hz_weakReferenceObjectForKey:(id)key;

-(void)hz_addStrongReferenceObject:(id)object forKey:(id)key;
-(void)hz_removeStrongReferenceObjectForKey:(id)key;
-(id)hz_strongReferenceObjectForKey:(id)key;

@end
