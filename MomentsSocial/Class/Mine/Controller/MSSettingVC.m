//
//  MSSettingVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSSettingVC.h"
#import "MSAboutUsVC.h"
#import "MSAutoActivateVC.h"

static NSString *const kMSSettingCellReusableIdentifier = @"kMSSettingCellReusableIdentifier";

typedef NS_ENUM(NSInteger,MSSettingRow) {
    MSSettingRowAutoActivate = 0,
    MSSettingRowAboutUs,
    MSSettingRowCount
};

@interface MSSettingVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@end

@implementation MSSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMSSettingCellReusableIdentifier];
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MSSettingRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSSettingCellReusableIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row < MSSettingRowCount) {
        if (indexPath.row == MSSettingRowAutoActivate) {
            cell.textLabel.text = @"自助激活";
        } else if (indexPath.row == MSSettingRowAboutUs) {
            cell.textLabel.text = @"关于我们";
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kWidth(88);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == MSSettingRowAutoActivate) {
        MSAutoActivateVC *activateVC = [[MSAutoActivateVC alloc] initWithTitle:@"自助激活"];
        [self.navigationController pushViewController:activateVC animated:YES];
    } else if (indexPath.row == MSSettingRowAboutUs) {
        MSAboutUsVC *aboutUsVC = [[MSAboutUsVC alloc] initWithTitle:@"关于我们"];
        [self.navigationController pushViewController:aboutUsVC animated:YES];
    }
}

@end
