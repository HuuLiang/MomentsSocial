//
//  MSDiscoverViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDiscoverViewController.h"
#import "MSDiscoverCell.h"

#import "MSNearViewController.h"
#import "MSShakeVC.h"

static NSString *const kMSDiscverCellReusableIdentifier = @"kMSDiscverCellReusableIdentifier";

@interface MSDiscoverViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@end

@implementation MSDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = kColor(@"#f0f0f0");
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[MSDiscoverCell class] forCellReuseIdentifier:kMSDiscverCellReusableIdentifier];
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView setSeparatorColor:kColor(@"#f0f0f0")];
    [_tableView setSeparatorInset:UIEdgeInsetsMake(0, kWidth(20), 0, kWidth(20))];
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_tableView QB_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self fetchDiscoverFunctionsInfo];
    }];
    
    [_tableView QB_triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configTableHeaderView {
    UIImageView *headerImgV = [[UIImageView alloc] init];
    headerImgV.backgroundColor = [UIColor blueColor];
    headerImgV.size = CGSizeMake(kScreenWidth, kWidth(300));
    _tableView.tableHeaderView = headerImgV;
}

- (void)fetchDiscoverFunctionsInfo {
    [self configTableHeaderView];
    [self.tableView reloadData];
    [self.tableView QB_endPullToRefresh];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSDiscoverCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSDiscverCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.row < 4) {
        cell.imgUrl = @"";
        cell.title = @"附近的人";
        cell.subTitle = @"看一看谁在附近";
        cell.descTitle = @"您附近当前有89位异性在线";
        @weakify(self);
        cell.joinAction = ^{
            @strongify(self);
//            MSNearViewController *nearVC = [[MSNearViewController alloc] initWithTitle:@"附近的人"];
//            [self.navigationController pushViewController:nearVC animated:YES];
            MSShakeVC *shakeVC = [[MSShakeVC alloc] initWithTitle:@"摇一摇"];
            [self.navigationController pushViewController:shakeVC animated:YES];
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kWidth(180);
}

@end
