//
//  MSMineViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/25.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMineViewController.h"
#import "MSMineInfoView.h"
#import "MSMineSettingView.h"
#import "MSMineVipDescView.h"
#import "MSSettingVC.h"
#import "MSVipVC.h"
#import "MSSettingCell.h"
#import "MSMyInfoViewController.h"

static NSString *kMineSettingCellReusableIdentifier = @"kMineSettingCellReusableIdentifier";

typedef NS_ENUM(NSUInteger,MSMineSectionRow) {
    MSMineSectionSetting = 0,
//    MSMineSectionInfo,
    MSMineSectionCount
};

@interface MSMineViewController () <UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UIImageView    *gradientView;
@property (nonatomic) MSMineInfoView *infoView;
@property (nonatomic) MSMineSettingView *settingView;
@property (nonatomic) MSMineVipDescView *vipView;
@property (nonatomic) UITableView *tableView;
@end

@implementation MSMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kColor(@"#f0f0f0");
    self.navigationController.navigationBar.barStyle = UIBaselineAdjustmentNone;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = kColor(@"#f0f0f0");
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    [_tableView registerClass:[MSSettingCell class] forCellReuseIdentifier:kMineSettingCellReusableIdentifier];
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(kWidth(230));
            make.width.mas_equalTo(kWidth(690));
        }];
    }
    [self configGradientView];
    [self configUserInfoView];
    [self configVipView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:MSOpenVipSuccessNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _infoView.imgUrl = [MSUtil currentProtraitUrl];
    _infoView.nickName = [MSUtil currentNickName];
}

- (void)refreshView {
    [self configUserInfoView];
    [self configVipView];
}

- (void)configGradientView {
    if (!_gradientView) {
        self.gradientView = [[UIImageView alloc] init];
        UIImage *gradientImg = [self.gradientView setGradientWithSize:CGSizeMake(kScreenWidth, 100) Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED455C")] direction:leftToRight];
        _gradientView.image = gradientImg;
        [self.view addSubview:_gradientView];
        
        {
            [_gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.equalTo(self.view);
                make.height.mas_equalTo(kWidth(100));
            }];
        }
    }
}

- (void)configUserInfoView {
    if (!_infoView) {
        self.infoView = [[MSMineInfoView alloc] init];
        [self.view addSubview:_infoView];
        _infoView.userId = [MSUtil currentUserId];
        
        
        @weakify(self);        
        [_infoView bk_whenTapped:^{
            @strongify(self);
            MSMyInfoViewController *infoVC = [[MSMyInfoViewController alloc] initWithTitle:@"个人资料"];
            [self.navigationController pushViewController:infoVC animated:YES];
        }];

        
        {
            [_infoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.top.equalTo(self.view);
                make.size.mas_equalTo(CGSizeMake(kWidth(690), kWidth(200)));
            }];
        }
    }
    _infoView.imgUrl = [MSUtil currentProtraitUrl];
    _infoView.nickName = [MSUtil currentNickName];
    _infoView.vipLevel = [MSUtil currentVipLevel];
    
}

- (void)configVipView {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = kColor(@"#f0f0f0");
    footerView.size = CGSizeMake(kScreenWidth, kWidth(750));
    
    self.vipView = [[MSMineVipDescView alloc] init];
    [footerView addSubview:_vipView];
    
    @weakify(self);
    _vipView.openVipAction = ^{
        @strongify(self);
        if ([MSUtil currentVipLevel] == MSLevelVip2) {
            [[MSHudManager manager] showHudWithText:@"您已经是最高级的VIP啦"];
            return ;
        }
        [MSVipVC showVipViewControllerInCurrentVC:self contentType:MSPopupTypeMineVC];
    };
    
    {
        [_vipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(footerView);
            make.top.equalTo(footerView).offset(kWidth(28));
            make.size.mas_equalTo(CGSizeMake(kWidth(690), kWidth(674)));
        }];
    }
    self.tableView.tableFooterView = footerView;
}


#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MSMineSectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kMineSettingCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.row == MSMineSectionSetting) {
        cell.imgName = @"mine_setting";
        cell.title = @"设置";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kWidth(88);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == MSMineSectionSetting) {
        MSSettingVC *settingVC = [[MSSettingVC alloc] initWithTitle:@"设置"];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
//    else if (indexPath.row == MSMineSectionInfo) {
//        
//    }
}


@end
