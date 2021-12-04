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

#import "UITabBarController+UITabBarView.h"
#import "UIViewController+YZHNavigationRootVCInitSetup.h"

@interface AppDelegate ()

@property (nonatomic, strong) YZHTabBarController *tabBarController;

@end

@implementation AppDelegate

- (void)pri_setupNavBarAppearance {
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
}

- (void)resetRootVC {
    [self pri_setupRootVC];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self pri_setupNavBarAppearance];
    
    [self pri_setupRootVC];
    
    [self.window makeKeyAndVisible];
    
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


@end
