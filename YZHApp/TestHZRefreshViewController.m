//
//  TestHZRefreshViewController.m
//  YZHApp
//
//  Created by yuan on 2020/12/5.
//  Copyright © 2020 yuan. All rights reserved.
//

#import "TestHZRefreshViewController.h"
#import "NSObject+YZHAdd.h"

@interface TestModel : NSObject

/** <#name#> */
//@property (nonatomic, assign) BOOL done;

/** */
@property (nonatomic, copy) NSString *text;

/** <#注释#> */
@property (nonatomic, copy) NSString *doneText;

@end

@implementation TestModel

@end


@interface TestCell : UITableViewCell<YZHRefreshViewProtocol>

/** <#注释#> */
@property (nonatomic, strong) UILabel *lab;

@end

@implementation TestCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self pri_setupChildView];
    }
    return self;
}

- (void)pri_setupChildView {
    self.lab = [UILabel new];
    self.lab.frame = CGRectMake(100, 0, 100, 60);
    self.lab.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.lab];
    
    self.lab.hz_refreshBlock = ^BOOL(UIResponder<YZHRefreshViewProtocol> *refreshView, id model) {
        UILabel *lab = refreshView;
//        TestModel *m = model;
//        lab.text = m.doneText;
        lab.text = model;
        lab.backgroundColor = [UIColor orangeColor];
        return YES;
    };
}

- (BOOL)hz_refreshViewWithModel:(id)model {
    
    TestModel *test = model;
    NSString *text = test.text;
    self.textLabel.text = text;
    if (test.doneText.length == 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *tmp = [text stringByAppendingFormat:@"----%@",text];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                if (self.hz_refreshModel == test) {
                test.doneText = tmp;
                self.lab.text = tmp;
//                    [self.lab hz_bindRefreshModel:tmp];
//                }
            });
        });
    }
    else {
        self.lab.text = test.doneText;
//        [test.doneText hz_refresh];
    }
    
    return NO;
}

@end


@interface TestHZRefreshViewController ()<UITableViewDelegate,UITableViewDataSource>

/** <#注释#> */
@property (nonatomic, strong) UITableView *tableView;

/** <#注释#> */
@property (nonatomic, strong) NSMutableArray<TestModel*> *modelList;

/** <#注释#> */
@property (nonatomic, strong) UILabel *label;

/** <#注释#> */
@property (nonatomic, strong) TestModel *a;

/** <#注释#> */
@property (nonatomic, strong) TestModel *b;

@end

@implementation TestHZRefreshViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self pri_setupData];
    
    [self pri_setupChildView];
}

- (NSMutableArray<TestModel *> *)modelList {
    if (_modelList == nil) {
        _modelList = [NSMutableArray array];
    }
    return _modelList;
}

- (void)pri_setupData {
    NSInteger cnt = 200;
    for (NSInteger i = 0; i < cnt; ++i) {
        TestModel *m = [[TestModel alloc] init];
        m.text = [NSString stringWithFormat:@"%@",@(i + 1)];
        m.doneText = arc4random() & 1 ? @"done" : nil;
        [self.modelList  addObject:m];
    }
}

- (void)pri_setupChildView {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    YZHRefreshBlock refreshBlock = ^BOOL(UIResponder<YZHRefreshViewProtocol> *refreshView, id model) {
//        UILabel *l = (UILabel*)refreshView;
//        TestModel *m = model;
//        l.text = m.text;
//        return YES;
//    };
//
//    UILabel *labA = [UILabel new];
//    labA.frame = CGRectMake(20, 100, 200, 60);
//    labA.backgroundColor = [UIColor orangeColor];
//    [self.view addSubview:labA];
//    labA.hz_refreshBlock = refreshBlock;
//    self.label = labA;
//
//    TestModel *a = [[TestModel alloc] init];
//    a.text = @"A.label";
//    [labA hz_bindRefreshModel:a];
//    self.a = a;
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[TestCell class] forCellReuseIdentifier:@"cellId"];
    [self.view addSubview:self.tableView];
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    if (!self.b) {
//        TestModel *b = [[TestModel alloc] init];
//        b.text = @"b.label";
//        [self.label hz_bindRefreshModel:b];
//        self.b = b;
//    }
//    else {
//        self.a.text = @"touchesBegan";
//        [self.a hz_refresh];
//
//    }
//}

#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    
    TestModel *model = [self.modelList objectAtIndex:indexPath.row];
    
    [cell hz_bindRefreshModel:model];
    
    return cell;
}

@end
