//
//  MSSendMomentsVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/2.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSSendMomentsVC.h"

@interface MSSendMomentsVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@end

@implementation MSSendMomentsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    [self configTableHeaderView];
    [self configTableFooterView];
    [self configBarButtonItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configBarButtonItems {
    @weakify(self);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"取消" style:UIBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"发帖" style:UIBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        [self sendMoments];
    }];
}

- (void)sendMoments {
    [[MSHudManager manager] showHudWithText:@"发布成功 审核中"];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configTableFooterView {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = kColor(@"#f0f0f0");
    self.tableView.tableFooterView = footerView;
}

- (void)configTableHeaderView {
    
}

@end
