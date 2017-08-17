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
#import "MSCheckInVC.h"
#import "MSVipVC.h"

#import "MSDiscoverModel.h"
#import "MSReqManager.h"
#import "MSSystemConfigModel.h"

static NSString *const kMSDiscverCellReusableIdentifier = @"kMSDiscverCellReusableIdentifier";

@interface MSDiscoverViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSMutableArray *dataSource;
@end

@implementation MSDiscoverViewController
QBDefineLazyPropertyInitialization(NSMutableArray, dataSource)

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
    
    [self configTableHeaderView];
    
    [_tableView QB_triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configTableHeaderView {
    UIImageView *headerImgV = [[UIImageView alloc] init];
    headerImgV.userInteractionEnabled = YES;
    headerImgV.size = CGSizeMake(kScreenWidth, kWidth(300));
    [headerImgV sd_setImageWithURL:[NSURL URLWithString:[MSSystemConfigModel defaultConfig].config.SPREAD_IMG]];
    _tableView.tableHeaderView = headerImgV;
    @weakify(self);
    [headerImgV bk_whenTapped:^{
        @strongify(self);
        [MSVipVC showVipViewControllerInCurrentVC:self];
    }];
}

- (void)fetchDiscoverFunctionsInfo {
    @weakify(self);
    [[MSReqManager manager] fetchDiscoverInfoClass:[MSDiscoverModel class] completionHandler:^(BOOL success, MSDiscoverModel * obj) {
        @strongify(self);
        [self.tableView QB_endPullToRefresh];
        if (success) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:obj.finds];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSDiscoverCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSDiscverCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.dataSource.count) {
        MSFindInfo *info = self.dataSource[indexPath.row];
        cell.imgUrl = info.findImg;
        cell.title = info.name;
        cell.subTitle = info.findDesc;
        cell.descTitle = info.findSubtitle;
        @weakify(self);
        cell.joinAction = ^{
            @strongify(self);
            if (info.funType == 1) {
                MSNearViewController *nearVC = [[MSNearViewController alloc] initWithTitle:@"附近的人"];
                [self.navigationController pushViewController:nearVC animated:YES];
            } else if (info.funType == 2) {
                MSShakeVC *shakeVC = [[MSShakeVC alloc] initWithTitle:@"摇一摇"];
                [self.navigationController pushViewController:shakeVC animated:YES];
            } else if (info.funType == 3) {
                if ([MSUtil currentVipLevel] == MSLevelVip0) {
                    [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeRegisterVip0 disCount:NO cancleAction:nil confirmAction:^{
                        [MSVipVC showVipViewControllerInCurrentVC:self];
                    }];
                    return ;
                }
                MSCheckInVC *checkInVC = [[MSCheckInVC alloc] initWithTitle:@"今日开房"];
                [self.navigationController pushViewController:checkInVC animated:YES];
            }
        };
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kWidth(180);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.count) {
        MSFindInfo *info = self.dataSource[indexPath.row];
        if (info.funType == 1) {
            MSNearViewController *nearVC = [[MSNearViewController alloc] initWithTitle:@"附近的人"];
            [self.navigationController pushViewController:nearVC animated:YES];
        } else if (info.funType == 2) {
            MSShakeVC *shakeVC = [[MSShakeVC alloc] initWithTitle:@"摇一摇"];
            [self.navigationController pushViewController:shakeVC animated:YES];
        } else if (info.funType == 3) {
            if ([MSUtil currentVipLevel] == MSLevelVip0) {
                [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeRegisterVip0 disCount:NO cancleAction:nil confirmAction:^{
                    [MSVipVC showVipViewControllerInCurrentVC:self];
                }];
                return ;
            }
            MSCheckInVC *checkInVC = [[MSCheckInVC alloc] initWithTitle:@"今日开房"];
            [self.navigationController pushViewController:checkInVC animated:YES];
        }
    }
}

@end
