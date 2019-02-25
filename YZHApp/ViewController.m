//
//  ViewController.m
//  YZHApp
//
//  Created by yuan on 2018/12/27.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "ViewController.h"
#import "YZHUtil.h"


@interface Test : NSObject <NSCoding>

/* <#name#> */
@property (nonatomic, assign) NSInteger a;

/* <#注释#> */
@property (nonatomic, strong) NSString *b;

@end

@implementation Test

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.a = [aDecoder decodeIntegerForKey:@"a"];
        self.b = [aDecoder decodeObjectForKey:@"b"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.a forKey:@"a"];
    [aCoder encodeObject:self.b forKey:@"b"];
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"_a=%ld,\n_b=%@",self.a,self.b];
}

@end



@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self _test];
}


-(void)_test
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:@"1" forKey:@"1"];
    
    NSArray *list = @[@"2",@"3",@"4",@"5"];
    [dict setObject:list forKey:@"list"];
    
    Test *t = [[Test alloc] init];
    t.a = 100;
    t.b = @"name";
    
    [dict setObject:t forKey:@"t"];
    
    
    NSString *path = [YZHUtil applicationCachesDirectory:@"1.dt"];
    
    BOOL ok = [dict writeToFile:path atomically:YES];
    NSLog(@"ok=%@",@(ok));
    
    NSDictionary *cp = [NSDictionary dictionaryWithContentsOfFile:path];
    NSLog(@"cp=%@",cp);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
