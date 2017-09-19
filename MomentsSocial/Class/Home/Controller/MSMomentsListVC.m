//
//  MSMomentsListVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMomentsListVC.h"
#import "MSReqManager.h"
#import "MSMomentsListCell.h"
#import "MSCircleModel.h"
#import "MSReqManager.h"
#import "MSMomentsVC.h"
#import "MSVipVC.h"

static NSString *const kMSMomentsListCellReusableIdentifier = @"kMSMomentsListCellReusableIdentifier";

@interface MSMomentsListVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) MSCircleInfo *circleInfo;
@property (nonatomic) MSCircleModel *response;
@end

@implementation MSMomentsListVC
QBDefineLazyPropertyInitialization(MSCircleModel, response)

- (instancetype)initWithCircleInfo:(MSCircleInfo *)info {
    self = [super init];
    if (self) {
        _circleInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.circleInfo.name;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kColor(@"#f0f0f0");
    [_tableView registerClass:[MSMomentsListCell class] forCellReuseIdentifier:kMSMomentsListCellReusableIdentifier];
    [_tableView setSeparatorColor:kColor(@"#f0f0f0")];
    [_tableView setSeparatorInset:UIEdgeInsetsMake(0, kWidth(20), 0, kWidth(20))];
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_tableView QB_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self fetchCircleListInfo];
    }];
    
    [_tableView QB_triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fetchAllMomentsWithCategoryId:(NSString *)categoryId {
    [self.tableView QB_endPullToRefresh];
}

- (void)fetchCircleListInfo {
    @weakify(self);
    [[MSReqManager manager] fetchCircleInfoWithCircleId:self.circleInfo.circleId Class:[MSCircleModel class] completionHandler:^(BOOL success, MSCircleModel * obj) {
        @strongify(self);
        [self.tableView QB_endPullToRefresh];
        if (success) {
            self.response = obj;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.response.circle.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSMomentsListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSMomentsListCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.response.circle.count) {
        MSCircleInfo *info = self.response.circle[indexPath.row];
        cell.imgUrl = info.circleImg;
        cell.title = info.name;
        cell.subTitle = info.circleDesc;
        cell.count = [info numberWithCircleId:info.circleId];
        cell.vipLevel = info.vipLv;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.response.circle.count) {
        MSCircleInfo *info = self.response.circle[indexPath.row];
        if (info.vipLv > [MSUtil currentVipLevel]) {
            MSPopupType type;
            if (info.vipLv == MSLevelVip1) {
                type = MSPopupTypeCircleVip1;
            } else {
                type = MSPopupTypeCircleVip2;
            }
            
            [[MSPopupHelper helper] showPopupViewWithType:type disCount:type == MSPopupTypeCircleVip2 cancleAction:nil confirmAction:^{
                [MSVipVC showVipViewControllerInCurrentVC:self contentType:type];
            }];
            return;
        }
        MSMomentsVC *momentsVC = [[MSMomentsVC alloc] initWithCircleInfo:info];
        [self.navigationController pushViewController:momentsVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kWidth(144);
}

@end
