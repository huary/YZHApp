//
//  TestMemoryGraphViewController.m
//  YZHApp
//
//  Created by yuan on 2021/4/3.
//  Copyright © 2021 yuan. All rights reserved.
//

#import "TestMemoryGraphViewController.h"
#import "MMGraph.h"


@interface TestMemoryGraphViewController ()

@end

@implementation TestMemoryGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    readVMRegin();
    
    MMGraphTest();
}



@end
