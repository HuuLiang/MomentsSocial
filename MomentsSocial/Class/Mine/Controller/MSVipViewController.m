//
//  MSVipViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSVipViewController.h"
#import "MSPayInfoCell.h"
#import "MSPayTypeCell.h"
#import "MSPayDescCell.h"
#import "MSPaymentManager.h"
#import "MSSystemConfigModel.h"

static NSString *const kMSPayInfoCellReusableIdentifier = @"kMSPayInfoCellReusableIdentifier";
static NSString *const kMSPayTypeCellReusableIdentifier = @"kMSPayTypeCellReusableIdentifier";
static NSString *const kMSPayDescCellReusableIdentifier = @"kMSPayDescCellReusableIdentifier";

@interface MSVipViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) MSLevel targetLevel;
@property (nonatomic) NSInteger price;
@end

@implementation MSVipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kColor(@"#efefef");
    
    self.title = @"支付订单";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kColor(@"#ffffff");
//    [_tableView setSeparatorColor:kColor(@"#ffffff")];
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    [_tableView registerClass:[MSPayTypeCell class] forCellReuseIdentifier:kMSPayTypeCellReusableIdentifier];
    [_tableView registerClass:[MSPayInfoCell class] forCellReuseIdentifier:kMSPayInfoCellReusableIdentifier];
    [_tableView registerClass:[MSPayDescCell class] forCellReuseIdentifier:kMSPayDescCellReusableIdentifier];
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    self.targetLevel = [MSUtil currentVipLevel] + 1;
    if (self.targetLevel == MSLevelVip1) {
        self.price = [MSSystemConfigModel defaultConfig].config.PAY_AMOUNT_1;
    } else if (self.targetLevel == MSLevelVip2) {
        self.price = [MSSystemConfigModel defaultConfig].config.PAY_AMOUNT_2;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//qq客服
- (void)contactCustomerService {
    NSString *contactScheme = [MSSystemConfigModel defaultConfig].config.CONTACT_SCHEME;
    NSString *contactName = [MSSystemConfigModel defaultConfig].config.CONTACT_NAME;
    
    if (contactScheme.length == 0) {
        return ;
    }
    
    [UIAlertView bk_showAlertViewWithTitle:nil
                                   message:[NSString stringWithFormat:@"是否联系客服%@？", contactName ?: @""]
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@[@"确认"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex)
     {
         if (buttonIndex == 1) {
             if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:contactScheme]]) {
                 
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contactScheme]];
             }
         }
     }];
}

- (void)startPayWithType:(MSPayType)type {
    [[MSPaymentManager manager] startPayForVipLevel:self.targetLevel type:type price:self.price handler:^(BOOL success) {
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MSOpenVipSuccessNotification object:nil];
        }
    }];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MSPayInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSPayInfoCellReusableIdentifier forIndexPath:indexPath];
        cell.payForLevel = self.targetLevel;
        return cell;
    } else if (indexPath.section == 1) {
        MSPayTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSPayTypeCellReusableIdentifier forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.payType = MSPayTypeAliPay;
        } else if (indexPath.row == 1) {
            cell.payType = MSPayTypeWeiXin;
        }
        return cell;
    } else if (indexPath.section == 2) {
        MSPayDescCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSPayDescCellReusableIdentifier forIndexPath:indexPath];
        @weakify(self);
        cell.payAction = ^{
            @strongify(self);
            [self contactCustomerService];
        };
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self startPayWithType:MSPayTypeAliPay];
        } else if (indexPath.row == 1) {
            [self startPayWithType:MSPayTypeWeiXin];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return kWidth(60);
    } else if (indexPath.section == 1) {
        return kWidth(160);
    } else if (indexPath.section == 2) {
        return kWidth(300);
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = kColor(@"#efefef");
    if (section == 1 || section == 2) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = kColor(@"#666666");
        label.font = kFont(15);
        if (section == 1) {
            label.text = @"选择支付方式";
        } else if (section == 2) {
            label.text = @"充值疑难答疑";
        }
        
        [headerView addSubview:label];
        
        {
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(headerView);
                make.left.equalTo(headerView).offset(kWidth(30));
                make.height.mas_equalTo(label.font.lineHeight);
            }];
        }
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return kWidth(30);
    } else if (section == 1) {
        return kWidth(64);
    } else if (section == 2) {
        return kWidth(64);
    }
    return 0;
}

@end
