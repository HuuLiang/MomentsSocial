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
#import "MSReqManager.h"
#import "QBLocationManager.h"
#import "MSOnlineManager.h"

#import "MSDetailPhotosVC.h"
#import "MSDetailInfoViewController.h"
#import "MSVipVC.h"
#import "MSMessageViewController.h"

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
@property (nonatomic) NSString *userId;
@property (nonatomic) MSUserModel *user;
@end

@implementation MSDetailViewController
QBDefineLazyPropertyInitialization(MSDetailModel, response)

- (instancetype)initWithUserId:(NSString *)userId {
    self = [super init];
    if (self) {
        _userId = userId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.view.backgroundColor = kColor(@"#f0f0f0");
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[MSDetailPhotosCell class] forCellReuseIdentifier:kMSDetailPhotosCellReusableIdentifier];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.backgroundColor = kColor(@"#f0f0f0");
    [self.view addSubview:_tableView];
    self.tableView.contentInset = [MSUtil deviceType] == MSDeviceType_iPhoneX ? UIEdgeInsetsMake(-44, 0, 0, 0) : UIEdgeInsetsMake(-20, 0, 0, 0);
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOnline:) name:kMSPostOnlineInfoNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMSPostOnlineInfoNotification object:nil];
}

- (void)changeOnline:(NSNotification *)notification {
    MSOnlineInfo *onlineInfo = [notification object];
    if (onlineInfo.userId == [self.userId integerValue]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headerView.online = onlineInfo.online;
        });
    }
}

- (void)fetchUserDetailInfo {
    @weakify(self);
    [[MSReqManager manager] fetchDetailInfoWithUserId:self.userId Class:[MSDetailModel class] completionHandler:^(BOOL success, MSDetailModel * obj) {
        @strongify(self);
        [self.tableView QB_endPullToRefresh];
        if (success) {
            self.user = obj.user;
            [self configHeaderView];
            [self configFooterView];
            [self.tableView reloadData];
        }
    }];
}

- (void)configHeaderView {
    if (!_headerView) {
        self.headerView = [[MSDetailHeaderView alloc] init];
        _headerView.size = CGSizeMake(kScreenWidth, kWidth(448));
        self.tableView.tableHeaderView = _headerView;
        @weakify(self);
        _headerView.backAction = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    _headerView.imgUrl = self.user.portraitUrl;
    _headerView.nickName = self.user.nickName;
//    @weakify(self);
//    [[QBLocationManager manager] getUserLacationNameWithUserId:self.userId locationName:^(BOOL success, NSString *locationName) {
//        @strongify(self);
//        self.headerView.location = self.user.city;
//
//    }];
    _headerView.online = [[MSOnlineManager manager] onlineWithUserId:[self.userId integerValue]];
    _headerView.vipLevel = self.user.vipLv;
}

- (void)configFooterView {
    if (!_footerView) {
        self.footerView = [[MSDetailFooterView alloc] init];
        _footerView.size = CGSizeMake(kScreenWidth, kWidth(448));
        self.tableView.tableFooterView = _footerView;
        
        @weakify(self);
        _footerView.sendMsgAction = ^{
            @strongify(self);
            [MSMessageViewController showMessageWithUserId:self.user.userId nickName:self.user.nickName portraitUrl:self.user.portraitUrl inViewController:self];
        };
        
        _footerView.faceAction = ^{
            @strongify(self);
            if ([MSUtil currentVipLevel] == MSLevelVip0) {
                [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeFaceTime disCount:NO cancleAction:nil confirmAction:^{
                    [MSVipVC showVipViewControllerInCurrentVC:self contentType:MSPopupTypeFaceTime];
                }];
            } else if ([MSUtil currentVipLevel] == MSLevelVip1) {
                [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeFaceTimeVip1 disCount:YES cancleAction:nil confirmAction:^{
                    [MSVipVC showVipViewControllerInCurrentVC:self contentType:MSPopupTypeFaceTimeVip1];
                }];
            } else {
                [MSMessageViewController showMessageWithUserId:self.user.userId nickName:self.user.nickName portraitUrl:self.user.portraitUrl inViewController:self];
            }
        };
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
        [self.user.userPhoto enumerateObjectsUsingBlock:^(NSString *  _Nonnull imgUrl, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                cell.imgUrlA = imgUrl;
            } else if (idx == 1) {
                cell.imgUrlB = imgUrl;
            } else if (idx == 2) {
                cell.imgUrlC = imgUrl;
            }
        }];
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MSDetailSectionPhotos) {
        if ([MSUtil currentVipLevel] == MSLevelVip0) {
            [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeUserDetailInfo disCount:NO cancleAction:nil confirmAction:^{
                [MSVipVC showVipViewControllerInCurrentVC:self contentType:MSPopupTypeUserDetailInfo];
            }];
            return ;
        }
        MSDetailPhotosVC *photosVC = [[MSDetailPhotosVC alloc] initWithPhotos:self.user.userPhoto];
        [self.navigationController pushViewController:photosVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MSDetailSectionPhotos) {
        if (self.user.userPhoto.count > 0) {
            return kDetailPhotoWidth + kWidth(20);
        } else {
            return 0;
        }
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
        if ([MSUtil currentVipLevel] == MSLevelVip0) {
            [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeUserDetailInfo disCount:NO cancleAction:nil confirmAction:^{
                [MSVipVC showVipViewControllerInCurrentVC:self contentType:MSPopupTypeUserDetailInfo];
            }];
            return ;
        }
        if (section == MSDetailSectionPhotos) {
            MSDetailPhotosVC *photosVC = [[MSDetailPhotosVC alloc] initWithPhotos:self.user.userPhoto];
            [self.navigationController pushViewController:photosVC animated:YES];
        } else if (section == MSDetailSectionInfo) {
            MSDetailInfoViewController *infoVC = [[MSDetailInfoViewController alloc] initWithUserInfo:self.user];
            
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
