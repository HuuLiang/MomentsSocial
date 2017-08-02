//
//  MSDetailViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDetailViewController.h"
#import "MSDetailHeaderView.h"
#import "MSDetailFooterView.h"
#import "MSDetailPhotosCell.h"
#import "MSDetailSectionHeaderView.h"
#import "MSDetailModel.h"

#import "MSDetailPhotosVC.h"
#import "MSDetailInfoViewController.h"

static NSString *const kMSDetailPhotosCellReusableIdentifier = @"kMSDetailPhotosCellReusableIdentifier";

typedef NS_ENUM(NSInteger,MSDetailSection) {
    MSDetailSectionPhotos = 0,
    MSDetailSectionInfo,
    MSDetailSectionCount
};

@interface MSDetailViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) MSDetailHeaderView *headerView;
@property (nonatomic) MSDetailFooterView *footerView;
@property (nonatomic) MSDetailModel *response;
@end

@implementation MSDetailViewController
QBDefineLazyPropertyInitialization(MSDetailModel, response)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kColor(@"#f0f0f0");
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[MSDetailPhotosCell class] forCellReuseIdentifier:kMSDetailPhotosCellReusableIdentifier];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.backgroundColor = kColor(@"#f0f0f0");
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    @weakify(self);
    [_tableView QB_addPullToRefreshWithHandler:^{
        @strongify(self);
        [self fetchUserDetailInfo];
    }];
    
    [_tableView QB_triggerPullToRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)alwaysHideNavigationBar {
    return YES;
}

- (void)fetchUserDetailInfo {
    [self.tableView QB_endPullToRefresh];
    [self configHeaderView];
    [self configFooterView];
    [self.tableView reloadData];
}

- (void)configHeaderView {
    if (!_headerView) {
        self.headerView = [[MSDetailHeaderView alloc] init];
        _headerView.size = CGSizeMake(kScreenWidth, kWidth(448));
        self.tableView.tableHeaderView = _headerView;
    }
    _headerView.imgUrl = @"";
    _headerView.nickName = @"匿名传说";
    _headerView.location = @"蒋村街道办事处";
    _headerView.vipLevel = MSLevelVip2;
}

- (void)configFooterView {
    if (!_footerView) {
        self.footerView = [[MSDetailFooterView alloc] init];
        _footerView.size = CGSizeMake(kScreenWidth, kWidth(448));
        self.tableView.tableFooterView = _footerView;
    }
    
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MSDetailSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == MSDetailSectionPhotos) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MSDetailSectionPhotos) {
        MSDetailPhotosCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSDetailPhotosCellReusableIdentifier forIndexPath:indexPath];
        cell.imgUrlA = @"";
        cell.imgUrlB = @"";
        cell.imgUrlC = @"";
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MSDetailSectionPhotos) {
        return kDetailPhotoWidth + kWidth(20);
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MSDetailSectionHeaderView *headerView = [[MSDetailSectionHeaderView alloc] init];
    if (section == MSDetailSectionPhotos) {
        headerView.title = @"相册";
        headerView.buttonTitle = @"更多";
    } else if (section == MSDetailSectionInfo) {
        headerView.title = @"个人资料";
        headerView.buttonTitle = @"全部";
    }
    @weakify(self);
    headerView.intoAction = ^{
        @strongify(self);
        if (section == MSDetailSectionPhotos) {
            [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypePhoto disCount:YES cancleAction:nil confirmAction:^{
                MSDetailPhotosVC *photosVC = [[MSDetailPhotosVC alloc] initWithTitle:@"相册"];
                [self.navigationController pushViewController:photosVC animated:YES];
            }];
        } else if (section == MSDetailSectionInfo) {
            MSDetailInfoViewController *infoVC = [[MSDetailInfoViewController alloc] initWithTitle:@"个人资料"];
            [self.navigationController pushViewController:infoVC animated:YES];
        }
    };
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == MSDetailSectionPhotos) {
        UIView *footerView = [[UIView alloc] init];
        footerView.backgroundColor = kColor(@"#f0f0f0");
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == MSDetailSectionPhotos || section == MSDetailSectionInfo) {
        return kWidth(88);
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == MSDetailSectionPhotos) {
        return kWidth(20);
    }
    return 0;
}

@end
