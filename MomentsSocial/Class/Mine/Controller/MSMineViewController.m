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

@interface MSMineViewController ()
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configVipView) name:MSOpenVipSuccessNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)configGradientView {
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

- (void)configUserInfoView {
    if (!_infoView) {
        self.infoView = [[MSMineInfoView alloc] init];
        [self.view addSubview:_infoView];
        
        {
            [_infoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.top.equalTo(self.view);
                make.size.mas_equalTo(CGSizeMake(kWidth(690), kWidth(200)));
            }];
        }
    }
    _infoView.imgUrl = @"";
    _infoView.nickName = @"洒脱";
    _infoView.vipLevel = MSLevelVip0;
    _infoView.userId = @"204840";
}

- (void)configSettingView {
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

- (void)configVipView {
    self.vipView = [[MSMineVipDescView alloc] init];
    [self.view addSubview:_vipView];
    
    @weakify(self);
    _vipView.openVipAction = ^{
        @strongify(self);
        
    };
    
    {
        [_vipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(_settingView.mas_bottom).offset(kWidth(28));
            make.size.mas_equalTo(CGSizeMake(kWidth(690), kWidth(674)));
        }];
    }
}

@end
