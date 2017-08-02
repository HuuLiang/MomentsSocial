//
//  MSDetailInfoViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDetailInfoViewController.h"
#import "MSDetailInfoCell.h"
#import "MSDetailInfoHeaderView.h"

typedef NS_ENUM(NSInteger, MSUserInfoSection) {
    MSUserInfoSectionBase = 0,
    MSUserInfoSectionContact,
    MSUserInfoSectionDetail,
    MSUserInfoSectionCount
};

typedef NS_ENUM(NSInteger, MSBaseInfoRow) {
    MSBaseInfoRowNick = 0,
    MSBaseInfoRowSex,
    MSBaseInfoRowAge,
    MSBaseInfoRowCity,
    MSBaseInfoRowIncome,
    MSBaseInfoRowMarriage,
    MSBaseInfoRowCount
};

typedef NS_ENUM(NSInteger, MSContactInfoRow) {
    MSContactInfoRowQQ = 0,
    MSContactInfoRowPhone,
    MSContactInfoRowWX,
    MSContactInfoRowCount
};

typedef NS_ENUM(NSInteger, MSDetailInfoRow) {
    MSDetailInfoRowEducation = 0,
    MSDetailInfoRowJob,
    MSDetailInfoRowBirth,
    MSDetailInfoRowWeight,
    MSDetailInfoRowHeight,
    MSDetailInfoRowConstellation,
    MSDetailInfoRowCount
};

static NSString *const kMSDetailInfoCellReusableIdentifier = @"kMSDetailInfoCellReusableIdentifier";

@interface MSDetailInfoViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@end

@implementation MSDetailInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kColor(@"#f0f0f0");
    [_tableView registerClass:[MSDetailInfoCell class] forCellReuseIdentifier:kMSDetailInfoCellReusableIdentifier];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MSUserInfoSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == MSUserInfoSectionBase) {
        return MSBaseInfoRowCount;
    } else if (section == MSUserInfoSectionContact) {
        return MSContactInfoRowCount;
    } else if (section == MSUserInfoSectionDetail) {
        return MSDetailInfoRowCount;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MSDetailInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSDetailInfoCellReusableIdentifier forIndexPath:indexPath];
    if (indexPath.section == MSUserInfoSectionBase) {
        if (indexPath.row == MSBaseInfoRowNick) {
            cell.title = @"昵称";
            cell.content = @"Dior女孩";
        } else if (indexPath.row == MSBaseInfoRowSex) {
            cell.title = @"性别";
            cell.content = @"女";
        } else if (indexPath.row == MSBaseInfoRowAge) {
            cell.title = @"年龄";
            cell.content = @"24岁";
        } else if (indexPath.row == MSBaseInfoRowCity) {
            cell.title = @"居住地";
            cell.content = @"杭州市";
        } else if (indexPath.row == MSBaseInfoRowIncome) {
            cell.title = @"月收入";
            cell.content = @"5000-10000";
        } else if (indexPath.row == MSBaseInfoRowMarriage) {
            cell.title = @"婚姻状况";
            cell.content = @"未婚";
        }
    } else if (indexPath.section == MSUserInfoSectionContact) {
        if (indexPath.row == MSContactInfoRowQQ) {
            cell.title = @"QQ";
            cell.content = @"67934056";
        } else if (indexPath.row == MSContactInfoRowPhone) {
            cell.title = @"手机号";
            cell.content = @"15866667439";
        } else if (indexPath.row == MSContactInfoRowWX) {
            cell.title = @"微信";
            cell.content = @"89345601";
        }
    } else if (indexPath.section == MSUserInfoSectionDetail) {
        if (indexPath.row == MSDetailInfoRowEducation) {
            cell.title = @"学历";
            cell.content = @"本科";
        } else if (indexPath.row == MSDetailInfoRowJob) {
            cell.title = @"职业";
            cell.content = @"未填写";
        } else if (indexPath.row == MSDetailInfoRowBirth) {
            cell.title = @"生日";
            cell.content = @"1992-05-24";
        } else if (indexPath.row == MSDetailInfoRowWeight) {
            cell.title = @"体重";
            cell.content = @"50-55kg";
        } else if (indexPath.row == MSDetailInfoRowHeight) {
            cell.title = @"身高";
            cell.content = @"159cm";
        } else if (indexPath.row == MSDetailInfoRowConstellation) {
            cell.title = @"星座";
            cell.content = @"白羊座";
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kWidth(88);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MSDetailInfoHeaderView *headerView = [[MSDetailInfoHeaderView alloc] init];
    headerView.backgroundColor = kColor(@"#ffffff");
    if (section == MSUserInfoSectionBase) {
        headerView.title = @"基本资料";
    } else if (section == MSUserInfoSectionContact) {
        headerView.title = @"联系方式";
    } else if (section == MSUserInfoSectionDetail) {
        headerView.title = @"详细资料";
    }
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = kColor(@"#f0f0f0");
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kWidth(88);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kWidth(20);
}

@end
