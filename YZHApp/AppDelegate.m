//
//  AppDelegate.m
//  YZHApp
//
//  Created by yuan on 2018/12/27.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "AppDelegate.h"
#import "YZHKit.h"

//#define CHECK_N(x, n, ...)          n
//#define CHECK(...)                  CHECK_N(__VA_ARGS__, 0,)
//#define PROBE(x)                    x, 1,
//
//#define IS_PAREN_PROBE(...)         PROBE(~)
//#define IS_PAREN(x)                 CHECK(IS_PAREN_PROBE x)
//
//
//#define NOT_0                       PROBE(~)
//#define NOT(x)                      CHECK(CONCAT(NOT_,x))
//
//#define IIF_0(t, ...)               __VA_ARGS__
//#define IIF_1(t, ...)               t
//#define IIF(c)                      CONCAT(IIF_, c)
//
//#define COMP_0                      1
//#define COMP_1                      0
//#define COMP(b)                     CONCAT(COMP_, b)
//
//#define BOOL(x)                     COMPL(NOT(x))
//#define IF(c)                       IIF(BOOL(c))
//
//#define EAT(...)
//#define EXPAND(...)                 __VA_ARGS__
//#define WHEN(c)                     IF(c)(EXPAND, EAT)


/* Auxiliary macros */
//#define M_CHECK_(a, b, ...)     b
//#define M_CHECK(...)            M_CHECK_(__VA_ARGS__)
//
//#define M_IS_PAREN_(...)        1, 1,
//#define M_IS_PAREN(x)           M_CHECK(M_IS_PAREN_ x, 0)
//
//#define M_CONCAT_(a, b)         a ## b
//#define M_CONCAT(a, b)          M_CONCAT_(a, b)
//
///* Conditional definition macros */
//#define DEF(x)                  M_IS_PAREN(x)
//
//#define DEF_IF_0(id, def)
//#define DEF_IF_1(id, def){id, def},
//
//#define COND_DEF(x, y)          M_CONCAT(DEF_IF_, DEF(x))(x, y)

/* Implementation */

#define ID_1 27,
#define ID_3 28
#define ID_4 (29)


//#define HAV_XXX_SDK
//
//#if __has_include("YZHKit.h")
//#define YZHKIT_SDK  (1)
//#endif
//
//#define IF_DONE_0(...)
//#define IF_DONE_1(...)              __VA_ARGS__
//#define YZH_KIT_DONE(...)           M_CONCAT(IF_DONE_,DEF(YZHKIT_SDK))(__VA_ARGS__)


#define COMPARE_foo(x)  x
#define COMPARE_bar(x)  x
#define PRIMITIVE_COMPARE(x,y)      IS_PAREN(COMPARE_ ## x(COMPARE_ ## y)(()))

//#define ABC   (1)
//
//#define _IS_PAREN(a,...)                         1, a
//#define IS_PAREN(x)                              M_CHECK(_IS_PAREN x, 0)
//
//
//#define YZH_KIT_DONE(...)                       CONCAT(DEF_IF_,IS_PAREN(ABC))(__VA_ARGS__)



struct A {
    int a;
    int b;
};


struct B {
    struct A a[0];
    int b;
    int c;
};



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    UIEdgeInsets insets = AVAILABLE_IOS_V_EXP(11.0, UIEdgeInsets insets = [[UIApplication sharedApplication].windows firstObject].safeAreaInsets; UIEdgeInsets insets = UIEdgeInsetsZero;);
    
    
//    YZH_KIT_DONE(NSLog(@"hello world start"));
//
//    YZH_KIT_DONE({
//        int a = 5;
//        int b = a * a;
//        NSLog(@"end.b=%d",b);
//    });
//
//    YZH_KIT_DONE({
//
//    })
    
    YZH_KIT_FUNC(
                 void (^block)(void) = ^(void){NSLog(@"yzhKit block");};
                 block();
                 );
    
//    block();
    
//    YZH_KIT_DONE({
//        int a = 11;
//        int b = a * a * a;
//        NSLog(@"b.done=%d",b);
//    });
    

    YZH_KIT_FUNC({
        
        onExit(
               NSLog(@"hello world");
               
               int c = 100;
               int d = 20;
               int e = c * d;
               NSLog(@"e=%d",e);
               )
        int a = 10;
        int b = a * a * a;
        NSLog(@"b=%d",b);
    });
    
    NSLog(@"abc");
    
    YZH_KIT_FUNC(
                 
                 onExit(
                        
                        NSLog(@"on exit");
                        
                        int a = 100;
                        int b = 200;
                        int c = a + b;
                        
                        NSLog(@"c=%d",c);
                        
                        
                        
                        )
                 
                 
                 
                 int a = 20;
                 int b = 90;
                 
                 int c = a * b;
                 NSLog(@"c2=%d",c);
                 
                 
                 )
    
    

    NSLog(@"finish");
    
    NSLog(@"a=%d,b=%d,c3=%d",a,b,c);
    
    
//    int a = CHECK(PROBE());
//    int b = CHECK(x+5);
//
//    int c = IS_PAREN(());
//    int d = IS_PAREN(xxxx);
//    int e = IS_PAREN(1);
//    int f = NOT(10);
//    NSLog(@"a=%d,b=%d,c=%d,d=%d,e=%d,f=%d",a,b,c,d,e,f);
//
//    int g = M_IS_PAREN(ID_1 8);
//    int h = M_IS_PAREN(());
//    int j = M_IS_PAREN(20);
//    int k = M_IS_PAREN(ID_3);
//    int l = M_IS_PAREN(ID_4);
////    int M_IS_PAREN_;
////    int i[2]={M_IS_PAREN_()};
////    int i = M_IS_PAREN_ ID_1;
//    NSLog(@"g=%d,h=%d,j=%d,k=%d,l=%d",g,h,j,k,l);
////    NSLog(@"i[0]=%d,i[1]=%d",i[0],i[1]);
//
////    int m = YZH_KIT_INC;
////    NSLog(@"m=%d",m);
//
//    int m = PRIMITIVE_COMPARE(foo, bar);
//    int n = PRIMITIVE_COMPARE(foo, foo);
//    int o = PRIMITIVE_COMPARE(foo, unfoo);
//    NSLog(@"m=%d,n=%d,o=%d",m,n,o);
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
