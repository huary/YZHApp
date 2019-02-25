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
@property (nonatomic, assign) NSInteger identity;

@property (nonatomic, strong) NSString *identityString;

//weak reference object
//single
@property (nonatomic, weak) id weakReferenceObject;

//multi,不要对外开放
//@property (nonatomic, strong) NSMapTable *weakReferenceObjectsTable;
//@property (nonatomic, strong) NSMapTable *strongReferenceObjectsTable;


-(id)respondsAndPerformSelector:(SEL)selector;
-(id)respondsAndPerformSelector:(SEL)selector withObject:(id)object;

+(id)respondsToSelector:(SEL)selector forClass:(Class)cls;
+(id)respondsToSelector:(SEL)selector forClass:(Class)cls withObject:(id)object;


-(void)addWeakReferenceObject:(id)object forKey:(id)key;
-(id)weakReferenceObjectForKey:(id)key;

-(void)addStrongReferenceObject:(id)object forKey:(id)key;
-(id)strongReferenceObjectForKey:(id)key;

-(BOOL)exchangeInstanceMethodFrom:(SEL)from to:(SEL)to;
-(BOOL)exchangeClassMethodFrom:(SEL)from to:(SEL)to;

@end
