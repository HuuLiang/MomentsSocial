//
//  MSComentsListVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSComentsListVC.h"
#import "MSReqManager.h"
#import "MSMomentsListCell.h"

static NSString *const kMSMomentsListCellReusableIdentifier = @"kMSMomentsListCellReusableIdentifier";

@interface MSComentsListVC () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@end

@implementation MSComentsListVC

- (instancetype)initWithMomentInfo:(NSString *)info {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        [self fetchAllMomentsWithCategoryId:@""];
    }];
    
    [_tableView QB_triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fetchAllMomentsWithCategoryId:(NSString *)categoryId {
    [self.tableView QB_endPullToRefresh];
}


#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSMomentsListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSMomentsListCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.row < 10) {
        cell.imgUrl = @"";
        cell.title = @"房事羞羞哒";
        cell.subTitle = @"默默的美美的发了一张照片【照片】";
        cell.count = 1111;
        cell.vipLevel = 0;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kWidth(144);
}

@end
