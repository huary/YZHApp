//
//  AppDelegate.m
//  YZHApp
//
//  Created by yuan on 2018/12/27.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "AppDelegate.h"
#import "YZHKit.h"
#import "ViewController.h"
#import "YZHQueue.h"

#import "IHRT_First_ViewController.h"
#import "IHRT_Second_ViewController.h"
#import "IHRT_Third_ViewController.h"
#import "IHRT_Fourth_ViewController.h"
#import "IHRT_Fifth_ViewController.h"

#import "CAT_First_ViewController.h"
#import "CAT_Second_ViewController.h"
#import "CAT_Third_ViewController.h"
#import "CAT_Fourth_ViewController.h"
#import "CAT_Fifth_ViewController.h"

#import "YZHNavigationTypes.h"
#import "UIViewController+YZHNavigation.h"
#import "UINavigationController+YZHNavigation.h"

#import "UITabBarController+YZHTabBarView.h"
#import "UIViewController+YZHNavigationRootVCInitSetup.h"
#import "UISideSlipViewController.h"

#if 0
#define YZH_PROPERTY_R_BLOCK(M, T, V, PT) \
@property (nonatomic, M, readonly) T V; \
@property (nonatomic, copy) T(^CONCAT(V,Block))(PT sender); \

#define YZH_PROPERTY_R_BLOCK_IMP(T, v, V, PT, N) \
- (void)CONCAT(pri_update,V):(T)v { CONCAT(_,v)=v;} \
- (void)CONCAT(set,CONCAT(V,Block)):(T (^)(PT sender))block { \
    CONCAT(_,CONCAT(v,Block)) = ^(PT sender) {\
        T r = block(sender); \
        [sender CONCAT(pri_update,V):r]; \
        return r;\
    };\
}

#define YZH_PROPERTY_V(M, Type, Value, CLS)                       \
@property (nonatomic, assign, readonly) BOOL CONCAT(CONCAT(is,Value),set);    \
@property (nonatomic, M, readonly) Type Value;                    \
@property (nonatomic, copy) Type(^CONCAT(Value,Block))(CLS *sender);  \

#define YZH_PROPERTY_IMP(Type, Value, SFX, CLS)                     \
- (void)CONCAT(pri_update,SFX):(Type)Value {CONCAT(_,Value)=Value; CONCAT(_,CONCAT(CONCAT(is,Value),set))=YES;}  \
- (void)CONCAT(set,CONCAT(SFX,Block)):(Type (^)(CLS *sender))block { \
    CONCAT(_,CONCAT(Value,Block)) = ^(CLS *sender) { \
        Type ret = block(sender); \
        [sender CONCAT(pri_update,SFX):ret]; \
        return ret;\
    };\
} \
@synthesize Value = CONCAT(_,Value);                               \
- (Type)Value { if (CONCAT(_,CONCAT(CONCAT(is,Value),set))) return CONCAT(_,Value); return CONCAT(_,CONCAT(Value,Block))(self);}
#endif


#define TYPE_C_STR(VAR)                     #VAR
#define IS_LOWER_LETTER(C)                  ((C) >= 97 && (C) <= 122)

#define STR_FISRT_LETTER_TO_UPPER(STR)      if (IS_LOWER_LETTER(STR[0])) STR[0] = STR[0] - 32;
#define FIRST_TO_UPPER(VAR)                 ({char TMP[]=TYPE_C_STR(VAR);STR_FISRT_LETTER_TO_UPPER(TMP);TMP;})


#define YZH_OW_PROPERTY_V(M, Type, Var, CLS)                       \
@property (nonatomic, assign, readonly) BOOL CONCAT(CONCAT(is,Var),set);    \
@property (nonatomic, M, readonly) Type Var;                                \
@property (nonatomic, copy) Type(^CONCAT(Var,Block))(CLS *sender);

#define YZH_OW_PROPERTY_IMP(Type, Var, SFX, CLS)                     \
- (void)CONCAT(pri_update,SFX):(Type)Var {CONCAT(_,Var)=Var; CONCAT(_,CONCAT(CONCAT(is,Var),set))=YES;}  \
- (void)CONCAT(set,CONCAT(Var,Block)):(Type (^)(CLS *sender))block { \
    CONCAT(_,CONCAT(Var,Block)) = ^(CLS *sender) { \
        Type ret = block(sender); \
        [sender CONCAT(pri_update,SFX):ret]; \
        return ret;\
    };\
} \
@synthesize Var = CONCAT(_,Var);                               \
- (Type)Var { if (CONCAT(_,CONCAT(CONCAT(is,Var),set))) return CONCAT(_,Var); return CONCAT(_,CONCAT(Var,Block))(self);}



@interface AppDelegate ()

//@property (nonatomic, assign, readonly) CGFloat f;
//@property (nonatomic, copy) CGFloat(^fblock)(AppDelegate *delegate);
//YZH_PROPERTY_R_BLOCK(assign, CGFloat, f, AppDelegate*)
//YZH_PROPERTY_R_BLOCK(strong, UIFont *, font, AppDelegate*)

YZH_OW_PROPERTY_V(assign, CGFloat, width, AppDelegate)
YZH_OW_PROPERTY_V(strong, UIFont*, font, AppDelegate)
YZH_OW_PROPERTY_V(strong, UIColor*, color, AppDelegate)


@property (nonatomic, copy)  dispatch_block_t testBlock;

@property (nonatomic, strong) YZHTabBarController *tabBarController;

@end

@implementation AppDelegate


YZH_OW_PROPERTY_IMP(CGFloat, width, Width, AppDelegate)
YZH_OW_PROPERTY_IMP(UIFont *, font, Font, AppDelegate)
YZH_OW_PROPERTY_IMP(UIColor *, color, Color, AppDelegate)

- (void)pri_test {
    self.widthBlock = ^CGFloat(AppDelegate *sender) {
        return 10;
    };
    self.fontBlock = ^UIFont *(AppDelegate *sender) {
        return SYS_FONT(18);
    };
    
    self.colorBlock = ^UIColor *(AppDelegate *sender) {
        return RED_COLOR;
    };
    
    self.testBlock = ^{
        NSLog(@"hello");
    };
    
//    self.widthBlock(self);
    
//    NSLog(@"%s",TYPE_C_STR(hello));
    char a[] = TYPE_C_STR(hello);
    NSLog(@"a=%s",a);
//    NSLog(@"%s",STR_FISRT_LETTER_TO_UPPER(a);
//    STR_FISRT_LETTER_TO_UPPER(a);
    
//    char *b = STR_FISRT_LETTER_TO_UPPER(a);
//    char *b = STR_FISRT_LETTER_TO_UPPER(a);
    NSLog(@"b=%s",FIRST_TO_UPPER(hello));
    
//    NSLog(@"%s",TYPE_C_STR(CONCAT(set, hello)));
    
    
//    NSLog(@"a=%s", STR_FISRT_LETTER_TO_UPPER(a));
    
    NSLog(@"self.width=%@,font=%@,color=%@",@(self.width),self.font,self.color);
}

- (void)pri_setupNavBarAppearance {
    [self pri_test];
    /*这是barButton的字体色/背景色/font，
     *[UIBarButtonItem appearance]的titleTextAttributesForState没有设置时，取[UINavigationBar appearance]的
     *[UIBarButtonItem appearance].tintColor = [UIColor blackColor];同[UIBarButtonItem appearance]中的NSForegroundColorAttributeName
     */
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:BLACK_COLOR,
                                                           NSBackgroundColorAttributeName:BLUE_COLOR,
    } forState:UIControlStateNormal];
    
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSFontAttributeName:NAVIGATION_ITEM_TITLE_FONT,
                                                         NSForegroundColorAttributeName:RED_COLOR,
                                                         NSBackgroundColorAttributeName:YELLOW_COLOR,
    };
}

- (void)pri_setupWindow {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
}

- (void)pri_setupRootVC{
    [self pri_setupWindow];
    
    YZHTabBarController *tabBarVC = [[YZHTabBarController alloc] init];
    
    tabBarVC.tabBarAttributes = @{YZHTabBarItemTitleTextFontKey:SYS_FONT(12),
                                  YZHTabBarItemTitleNormalColorKey:RGB_WITH_INT_WITH_NO_ALPHA(0X808080),
                                  YZHTabBarItemTitleSelectedColorKey:RED_COLOR,
                                  YZHTabBarItemSelectedBackgroundColorKey:ORANGE_COLOR,
                                  YZHTabBarItemHighlightedBackgroundColorKey:RED_COLOR
    };
    BOOL useSystemNavigation = YES;
#if 0
    [tabBarVC setupChildViewController:[IHRT_First_ViewController new]
                                 title:@"default"
                                 image:nil
                         selectedImage:nil
                   useSystemNavigation:useSystemNavigation
             navigationBarAndItemStyle:YZHNavigationBarAndItemStyleDefault];
    
    [tabBarVC setupChildViewController:[IHRT_Second_ViewController new]
                                 title:@"GBarDefItem"
                                 image:nil
                         selectedImage:nil
                   useSystemNavigation:useSystemNavigation
             navigationBarAndItemStyle:YZHNavigationBarAndItemStyleGlobalBarDefaultItem];
    
    [tabBarVC setupChildViewController:[IHRT_Third_ViewController new]
                                 title:@"GBarItem"
                                 image:nil
                         selectedImage:nil
                   useSystemNavigation:useSystemNavigation
             navigationBarAndItemStyle:YZHNavigationBarAndItemStyleGlobalBarItem];
    
    [tabBarVC setupChildViewController:[IHRT_Fourth_ViewController new]
                                 title:@"VCBarItem"
                                 image:nil
                         selectedImage:nil
                   useSystemNavigation:useSystemNavigation
             navigationBarAndItemStyle:YZHNavigationBarAndItemStyleVCBarItem];

    [tabBarVC setupChildViewController:[IHRT_Fifth_ViewController new]
                                 title:@"GBarDefItem"
                                 image:nil
                         selectedImage:nil
                   useSystemNavigation:useSystemNavigation
             navigationBarAndItemStyle:YZHNavigationBarAndItemStyleVCBarDefaultItem];
#else
//    UIViewController *vc = [CAT_First_ViewController new];
//    vc.hz_navigationEnableForRootVCInitSetToNavigation = YES;
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
        
    CAT_First_ViewController *first = [CAT_First_ViewController new];
    first.hz_navigationEnable = YES;
    [tabBarVC setupChildViewController:first
                                 title:@"default"
                                 image:nil
                         selectedImage:nil
                   useSystemNavigation:useSystemNavigation
             navigationBarAndItemStyle:YZHNavigationBarAndItemStyleDefault];
    
    CAT_Second_ViewController *second = [CAT_Second_ViewController new];
    second.hz_navigationEnable = YES;
    [tabBarVC setupChildViewController:second
                                 title:@"GBarDefItem"
                                 image:nil
                         selectedImage:nil
                   useSystemNavigation:useSystemNavigation
             navigationBarAndItemStyle:YZHNavigationBarAndItemStyleGlobalBarDefaultItem];
    
    CAT_Third_ViewController *third = [CAT_Third_ViewController new];
    third.hz_navigationEnable = YES;
    [tabBarVC setupChildViewController:third
                                 title:@"GBarItem"
                                 image:nil
                         selectedImage:nil
                   useSystemNavigation:useSystemNavigation
             navigationBarAndItemStyle:YZHNavigationBarAndItemStyleGlobalBarItem];
    
    CAT_Fourth_ViewController *fourth = [CAT_Fourth_ViewController new];
    fourth.hz_navigationEnable = YES;
    [tabBarVC setupChildViewController:fourth
                                 title:@"VCBarItem"
                                 image:nil
                         selectedImage:nil
                   useSystemNavigation:useSystemNavigation
             navigationBarAndItemStyle:YZHNavigationBarAndItemStyleVCBarItem];

    CAT_Fifth_ViewController *fifth = [CAT_Fifth_ViewController new];
    fifth.hz_navigationEnable = YES;
    [tabBarVC setupChildViewController:fifth
                                 title:@"GBarDefItem"
                                 image:nil
                         selectedImage:nil
                   useSystemNavigation:useSystemNavigation
             navigationBarAndItemStyle:YZHNavigationBarAndItemStyleVCBarDefaultItem];
#endif
    self.window.rootViewController = tabBarVC;
    self.tabBarController = tabBarVC;
    
//    UISideSlipViewController *sideSlipVC = [[UISideSlipViewController alloc] initWithContentViewController:tabBarVC leftViewController:[ViewController new] rightViewController:NULL];
//
//    self.window.rootViewController = sideSlipVC;
}

- (void)resetRootVC {
    [self pri_setupRootVC];
}

- (void)pri_testRemove {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tabBarController removeChildViewControllerAtIndex:2];        
    });
}


- (void)pri_testBezierPath {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(10, 20, 30, 40)];
    
    NSLog(@"bounds=%@",NSStringFromCGRect([path bounds]));
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSArray *f = [UIFont fontNamesForFamilyName:@"Helvetica Neue"];
    NSLog(@"f=%@",f);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    NSLog(@"font=%@",font);
    
    f = [UIFont fontNamesForFamilyName:@"PingFangSC-Regular"];
    NSLog(@"f=%@",f);
    UIFont *pf = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    NSLog(@"pf=%@",pf);
    
    
    [self pri_setupNavBarAppearance];
    
    [self pri_setupRootVC];
    
    [self.window makeKeyAndVisible];
    
//    [self pri_testBezierPath];
    
//    [self pri_testRemove];
    
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
    
/*
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
    */
    
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

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return self.window.rootViewController.supportedInterfaceOrientations;
}


@end
