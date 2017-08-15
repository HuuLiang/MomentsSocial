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
#import "QBPhotoManager.h"
#import "QBUploadManager.h"
#import "MSVipVC.h"

@interface MSMineViewController () <UIAlertViewDelegate>
@property (nonatomic) UIImageView    *gradientView;
@property (nonatomic) MSMineInfoView *infoView;
@property (nonatomic) MSMineSettingView *settingView;
@property (nonatomic) MSMineVipDescView *vipView;
@end

@implementation MSMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kColor(@"#f0f0f0");
    self.navigationController.navigationBar.barStyle = UIBaselineAdjustmentNone;
        
    [self configGradientView];
    [self configUserInfoView];
    [self configSettingView];
    [self configVipView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:MSOpenVipSuccessNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
        _infoView.changeImgAction = ^{
            @strongify(self);
            if ([MSUtil currentVipLevel] == MSLevelVip0) {
                [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeChangeUserInfo disCount:NO cancleAction:nil confirmAction:^{
                    [MSVipVC showVipViewControllerInCurrentVC:self];
                }];
                return ;
            }
            [[QBPhotoManager manager] getImageInCurrentViewController:self handler:^(UIImage *pickerImage, NSString *keyName) {
                NSString *name = [NSString stringWithFormat:@"%@_avatar.jpg", [[NSDate date] stringWithFormat:KDateFormatLong]];
               [QBUploadManager uploadWithFile:pickerImage fileName:name completionHandler:^(BOOL success, id obj) {
                   @strongify(self);
                   if (success) {
                       [[MSHudManager manager] showHudWithText:@"修改头像成功"];
                       self.infoView.imgUrl = obj;
                       [MSUtil registerPortraitUrl:obj];
                   }
               }];
            }];
        };
        
        _infoView.changeNickAction = ^{
            @strongify(self);
            if ([MSUtil currentVipLevel] == MSLevelVip0) {
                [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeChangeUserInfo disCount:NO cancleAction:nil confirmAction:^{
                    [MSVipVC showVipViewControllerInCurrentVC:self];
                }];
                return ;
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改昵称" message:@"请输入您的新昵称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView show];
        };
        
        
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

- (void)configSettingView {
    if (!_settingView) {
        self.settingView = [[MSMineSettingView alloc] init];
        [self.view addSubview:_settingView];
        
        @weakify(self);
        _settingView.settingAction = ^{
            @strongify(self);
            MSSettingVC *settingVC = [[MSSettingVC alloc] initWithTitle:@"设置"];
            [self.navigationController pushViewController:settingVC animated:YES];
        };
        
        {
            [_settingView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.top.equalTo(_infoView.mas_bottom).offset(kWidth(30));
                make.size.mas_equalTo(CGSizeMake(kWidth(690), kWidth(88)));
            }];
        }
    }
}

- (void)configVipView {
    self.vipView = [[MSMineVipDescView alloc] init];
    [self.view addSubview:_vipView];
    
    @weakify(self);
    _vipView.openVipAction = ^{
        @strongify(self);
        if ([MSUtil currentVipLevel] == MSLevelVip2) {
            [[MSHudManager manager] showHudWithText:@"您已经是最高级的VIP啦"];
            return ;
        }
        [MSVipVC showVipViewControllerInCurrentVC:self];
    };
    
    {
        [_vipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(_settingView.mas_bottom).offset(kWidth(28));
            make.size.mas_equalTo(CGSizeMake(kWidth(690), kWidth(674)));
        }];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        
    } else if (buttonIndex == 1) {
        self.infoView.nickName = [alertView textFieldAtIndex:0].text;
        [MSUtil registerNickName:[alertView textFieldAtIndex:0].text];
        [[MSHudManager manager] showHudWithText:@"修改昵称成功"];
    }
}

@end
