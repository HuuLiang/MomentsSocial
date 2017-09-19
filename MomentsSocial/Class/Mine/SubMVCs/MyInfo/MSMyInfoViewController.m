//
//  MSMyInfoViewController.m
//  MomentsSocial
//
//  Created by Liang on 2017/9/16.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMyInfoViewController.h"
#import "MSDetailInfoCell.h"
#import "MSMyPortraitCell.h"
#import "MSDetailInfoHeaderView.h"
#import "QBPhotoManager.h"
#import "QBUploadManager.h"
#import "ActionSheetPicker.h"

typedef NS_ENUM(NSInteger, MSMyInfoSection) {
    MSMyInfoSectionPortrait = 0,
    MSMyInfoSectionBase,
    MSMyInfoSectionContact,
    MSMyInfoSectionDetail,
    MSMyInfoSectionCount
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

static NSString *kMSMineInfoCellReusableIdentifier      = @"kMSMineInfoCellReusableIdentifier";
static NSString *kMSMinePortraitCellReusableIdentifier  = @"kMSMinePortraitCellReusableIdentifier";

@interface MSMyInfoViewController () <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic) MSUserModel *myInfo;
@end

@implementation MSMyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人资料";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = kColor(@"#f0f0f0");
    [_tableView registerClass:[MSDetailInfoCell class] forCellReuseIdentifier:kMSMineInfoCellReusableIdentifier];
    [_tableView registerClass:[MSMyPortraitCell class] forCellReuseIdentifier:kMSMinePortraitCellReusableIdentifier];
    [self.view addSubview:_tableView];
    
    {
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self loadInfoCache];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadInfoCache {
    self.myInfo = [MSUtil currentUser];
    [self.tableView reloadData];
}

- (void)changeUserInfoAlert:(NSString *)title msg:(NSString *)message handler:(void(^)(id content))handler {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"修改", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    @weakify(alertView);
    [alertView bk_setHandler:^{
        @strongify(alertView);
        handler([alertView textFieldAtIndex:0].text);
    } forButtonAtIndex:1];
    [alertView show];
}

- (void)changeUserInfoWithSheetPicker:(NSString *)title dataSource:(NSArray *)dataSource defaultIndex:(NSInteger)selectedIndex handler:(void(^)(id content))handler {
    [ActionSheetStringPicker showPickerWithTitle:title
                                            rows:dataSource
                                initialSelection:selectedIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        handler(selectedValue);
    } cancelBlock:nil origin:self.view];
}

- (void)changeContentWithCellIndexPath:(NSIndexPath *)indexPath content:(NSString *)content {
    [MSUtil saveCurrentUserInfo:self.myInfo];
    MSDetailInfoCell *cell = (MSDetailInfoCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.content = content;
}

- (BOOL)isQQWithString:(NSString *)string {
    NSString *qq = @"[1-9][0-9]{4,10}";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", qq];
    return [regextestmobile evaluateWithObject:string];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MSMyInfoSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == MSMyInfoSectionPortrait) {
        return 1;
    } else if (section == MSMyInfoSectionBase) {
        return MSBaseInfoRowCount;
    } else if (section == MSMyInfoSectionContact) {
        return MSContactInfoRowCount;
    } else if (section == MSMyInfoSectionDetail) {
        return MSDetailInfoRowCount;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MSMyInfoSectionPortrait) {
        MSMyPortraitCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSMinePortraitCellReusableIdentifier forIndexPath:indexPath];
        cell.imgUrl = self.myInfo.portraitUrl;
        return cell;
    } else {
        MSDetailInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kMSMineInfoCellReusableIdentifier forIndexPath:indexPath];
        if (indexPath.section == MSMyInfoSectionBase) {
            if (indexPath.row == MSBaseInfoRowNick) {
                cell.title = @"昵称";
                cell.content = self.myInfo.nickName;
            } else if (indexPath.row == MSBaseInfoRowSex) {
                cell.title = @"性别";
                cell.content = self.myInfo.sex;
            } else if (indexPath.row == MSBaseInfoRowAge) {
                cell.title = @"年龄";
                if (self.myInfo.age > 0) {
                    cell.content = [NSString stringWithFormat:@"%ld岁",(long)self.myInfo.age];
                } else {
                    cell.content = @"未填写";
                }
            } else if (indexPath.row == MSBaseInfoRowCity) {
                cell.title = @"居住地";
                cell.content = self.myInfo.city;
            } else if (indexPath.row == MSBaseInfoRowIncome) {
                cell.title = @"月收入";
                cell.content = self.myInfo.income;
            } else if (indexPath.row == MSBaseInfoRowMarriage) {
                cell.title = @"婚姻状况";
                cell.content = self.myInfo.marital;
            }
        } else if (indexPath.section == MSMyInfoSectionContact) {
            if (indexPath.row == MSContactInfoRowQQ) {
                cell.title = @"QQ";
                if (self.myInfo.qq == 0) {
                    cell.content = @"未填写";
                } else {
                    cell.content = [NSString stringWithFormat:@"%ld",(long)self.myInfo.qq];
                }
            } else if (indexPath.row == MSContactInfoRowPhone) {
                cell.title = @"手机号";
                if (self.myInfo.qq == 0) {
                    cell.content = @"未填写";
                } else {
                    cell.content = [NSString stringWithFormat:@"%ld",(long)self.myInfo.phone];
                }
            } else if (indexPath.row == MSContactInfoRowWX) {
                cell.title = @"微信";
                cell.content = self.myInfo.weixin;
            }
        } else if (indexPath.section == MSMyInfoSectionDetail) {
            if (indexPath.row == MSDetailInfoRowEducation) {
                cell.title = @"学历";
                cell.content = self.myInfo.education;
            } else if (indexPath.row == MSDetailInfoRowJob) {
                cell.title = @"职业";
                cell.content = self.myInfo.vocation;
            } else if (indexPath.row == MSDetailInfoRowBirth) {
                cell.title = @"生日";
                cell.content = self.myInfo.birthday;
            } else if (indexPath.row == MSDetailInfoRowWeight) {
                cell.title = @"体重";
                cell.content = self.myInfo.weight;
            } else if (indexPath.row == MSDetailInfoRowHeight) {
                cell.title = @"身高";
                if (self.myInfo.height > 0) {
                    cell.content = [NSString stringWithFormat:@"%ldcm",(long)self.myInfo.height];
                } else {
                    cell.content = @"未填写";
                }
            } else if (indexPath.row == MSDetailInfoRowConstellation) {
                cell.title = @"星座";
                cell.content = self.myInfo.constellation;
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == MSMyInfoSectionPortrait) {
        return kWidth(194);
    }
    return kWidth(88);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MSDetailInfoHeaderView *headerView = [[MSDetailInfoHeaderView alloc] init];
    headerView.backgroundColor = kColor(@"#ffffff");
    if (section == MSMyInfoSectionPortrait) {
        headerView.backgroundColor = kColor(@"#f0f0f0");
        headerView.title = @"";
    } else if (section == MSMyInfoSectionBase) {
        headerView.title = @"基本资料";
    } else if (section == MSMyInfoSectionContact) {
        headerView.title = @"联系方式";
    } else if (section == MSMyInfoSectionDetail) {
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
    if (section == MSMyInfoSectionPortrait) {
        return kWidth(20);
    }
    return kWidth(88);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kWidth(20);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self);
    if (indexPath.section == MSMyInfoSectionPortrait) {
        [[QBPhotoManager manager] getImageInCurrentViewController:self handler:^(UIImage *pickerImage, NSString *keyName) {
            NSString *name = [NSString stringWithFormat:@"%@_avatar.jpg", [[NSDate date] stringWithFormat:KDateFormatLong]];
            [QBUploadManager uploadWithFile:pickerImage fileName:name completionHandler:^(BOOL success, id obj) {
                @strongify(self);
                if (success) {
                    [[MSHudManager manager] showHudWithText:@"修改头像成功"];
                    self.myInfo.portraitUrl = obj;
                    [MSUtil saveCurrentUserInfo:self.myInfo];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:MSMyInfoSectionPortrait] withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
        }];
    } else if (indexPath.section == MSMyInfoSectionBase) {
        if (indexPath.row == MSBaseInfoRowNick) {
            [self changeUserInfoAlert:@"昵称" msg:@"请输入新的昵称" handler:^(NSString *content) {
                self.myInfo.nickName = content;
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        } else if (indexPath.row == MSBaseInfoRowSex) {
            [self changeUserInfoWithSheetPicker:@"性别" dataSource:[MSUserModel allUserSex] defaultIndex:0 handler:^(id content) {
                self.myInfo.sex = content;
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        } else if (indexPath.row == MSBaseInfoRowAge) {
            [self changeUserInfoWithSheetPicker:@"年龄:岁" dataSource:[MSUserModel allUserAge] defaultIndex:0 handler:^(id content) {
                self.myInfo.age = [content integerValue];
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        } else if (indexPath.row == MSBaseInfoRowCity) {
            [self changeUserInfoAlert:@"居住地" msg:@"请输入您的居住地" handler:^(NSString *content) {
                self.myInfo.city = content;
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        } else if (indexPath.row == MSBaseInfoRowIncome) {
            [self changeUserInfoWithSheetPicker:@"月收入" dataSource:[MSUserModel allUserIncome] defaultIndex:0 handler:^(id content) {
                self.myInfo.income = content;
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        } else if (indexPath.row == MSBaseInfoRowMarriage) {
            [self changeUserInfoWithSheetPicker:@"婚姻状况" dataSource:[MSUserModel allUserMarr] defaultIndex:0 handler:^(id content) {
                self.myInfo.marital = content;
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        }
    } else if (indexPath.section == MSMyInfoSectionContact) {
        if (indexPath.row == MSContactInfoRowQQ) {
            [self changeUserInfoAlert:@"QQ" msg:@"请输入您的QQ号码" handler:^(NSString *content) {
                if ([self isQQWithString:content]) {
                    self.myInfo.qq = [content integerValue];
                } else {
                    [[MSHudManager manager] showHudWithText:@"QQ号码不正确"];
                    return ;
                }
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        } else if (indexPath.row == MSContactInfoRowPhone) {
            [self changeUserInfoAlert:@"手机号码" msg:@"请输入您的手机号码" handler:^(NSString *content) {
                self.myInfo.phone = content;
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        } else if (indexPath.row == MSContactInfoRowWX) {
            [self changeUserInfoAlert:@"微信号" msg:@"请输入您的微信号" handler:^(NSString *content) {
                self.myInfo.weixin = content;
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        }
    } else if (indexPath.section == MSMyInfoSectionDetail) {
        if (indexPath.row == MSDetailInfoRowEducation) {
            [self changeUserInfoWithSheetPicker:@"学历" dataSource:[MSUserModel allUserEdu] defaultIndex:0 handler:^(id content) {
                self.myInfo.education = content;
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        } else if (indexPath.row == MSDetailInfoRowJob) {
            [self changeUserInfoAlert:@"职业" msg:@"请输入您的职业" handler:^(id content) {
                self.myInfo.vocation = content;
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        } else if (indexPath.row == MSDetailInfoRowBirth) {
            [self changeUserInfoAlert:@"生日" msg:@"请输入您的生日" handler:^(NSString *content) {
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        } else if (indexPath.row == MSDetailInfoRowWeight) {
            [self changeUserInfoWithSheetPicker:@"体重:kg" dataSource:[MSUserModel allUserWeight] defaultIndex:0 handler:^(id content) {
                self.myInfo.weight = [NSString stringWithFormat:@"%ld",[content integerValue]];
                [self changeContentWithCellIndexPath:indexPath content:[NSString stringWithFormat:@"%@kg",self.myInfo.weight]];
            }];
        } else if (indexPath.row == MSDetailInfoRowHeight) {
            [self changeUserInfoWithSheetPicker:@"身高:cm" dataSource:[MSUserModel allUserHeight] defaultIndex:0 handler:^(id content) {
                self.myInfo.height = [content integerValue];
                [self changeContentWithCellIndexPath:indexPath content:[NSString stringWithFormat:@"%ldcm",(long)self.myInfo.height]];
            }];
        } else if (indexPath.row == MSDetailInfoRowConstellation) {
            [self changeUserInfoWithSheetPicker:@"星座" dataSource:[MSUserModel allUserStars] defaultIndex:0 handler:^(NSString *content) {
                self.myInfo.constellation = content;
                [self changeContentWithCellIndexPath:indexPath content:content];
            }];
        }
    }
}

@end
