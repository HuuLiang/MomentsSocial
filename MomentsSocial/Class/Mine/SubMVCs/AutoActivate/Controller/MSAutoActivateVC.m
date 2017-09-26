//
//  MSAutoActivateVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSAutoActivateVC.h"
#import <QBPaymentManager.h>
#import <QBPaymentInfo.h>
#import "MSPaymentManager.h"

@interface MSAutoActivateVC () <UITextFieldDelegate>
@property (nonatomic) UITextField *textField;
@property (nonatomic) UIButton *activateButton;
@end

@implementation MSAutoActivateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textField = [[UITextField alloc] init];
    _textField.backgroundColor = kColor(@"#D8D8D8");
    _textField.delegate = self;
    _textField.placeholder = @"请输入你的订单号";
    [_textField setValue:kColor(@"#999999") forKeyPath:@"_placeholderLabel.textColor"];
    [_textField setValue:kFont(14) forKeyPath:@"_placeholderLabel.font"];
    [self.view addSubview:_textField];
    
    self.activateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_activateButton setTitle:@"自助激活" forState:UIControlStateNormal];
    [_activateButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
    _activateButton.titleLabel.font = kFont(15);
    _activateButton.layer.cornerRadius = 3;
    _activateButton.layer.masksToBounds = YES;
    [self.view addSubview:_activateButton];
    
    @weakify(self);
    [_activateButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self doActivation];
    } forControlEvents:UIControlEventTouchUpInside];
    
    {
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(self.view).offset(kWidth(64));
            make.size.mas_equalTo(CGSizeMake(kWidth(630), kWidth(88)));
        }];
        
        [_activateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(_textField.mas_bottom).offset(kWidth(64));
            make.size.mas_equalTo(CGSizeMake(kWidth(630), kWidth(80)));
        }];
    }
    
    [self.navigationController.navigationBar bk_whenTouches:1 tapped:5 handler:^{
        NSString *baseURLString = [MS_BASE_URL stringByReplacingCharactersInRange:NSMakeRange(0, MS_BASE_URL.length-6) withString:@"******"];
        [[MSHudManager manager] showHudWithText:[NSString stringWithFormat:@"Server:%@\nChannelNo:%@\nPackageCertificate:%@\npV:%@\nBundleId:%@\nVersion:%@\nUserID:%ld\nVIPLEVEL:%ld\n当月成为黄金VIP登录天数:%ld", baseURLString, MS_CHANNEL_NO, MS_PACKAGE_CERTIFICATE, MS_REST_PV,MS_BUNDLE_IDENTIFIER,MS_REST_APP_VERSION, (long)[MSUtil currentUserId],(long)[MSUtil currentVipLevel],[MSUtil loginDays]]];
    }];
}

- (void)doActivation {
    if ([MSUtil currentVipLevel] == MSLevelVip2) {
        [UIAlertView bk_showAlertViewWithTitle:@"您已经购买了全部VIP，无需再激活！" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
        return ;
    }
    
    NSArray<QBPaymentInfo *> *paymentInfos = [QBPaymentInfo allPaymentInfos];
    paymentInfos = [paymentInfos bk_select:^BOOL(QBPaymentInfo *paymentInfo) {
        return paymentInfo.targetPayPointType >= MSLevelVip2;
    }];
    
    
    [[UIApplication sharedApplication].keyWindow beginLoading];
    [[QBPaymentManager sharedManager] activatePaymentInfos:paymentInfos withCompletionHandler:^(BOOL success, QBPaymentInfo * obj) {
        [[UIApplication sharedApplication].keyWindow endLoading];
        if (success) {
            [self registerVipWithTargetVip:obj.targetPayPointType];
        } else {
            [self activationWithCode];
        }
    }];
}

- (void)activationWithCode {
    NSString *orderId = _textField.text;
    
    if (orderId.length != 12) {
        [[MSHudManager manager] showHudWithText:@"无效的订单号"];
        return;
    }
    
    NSString *currentString = [MSUtil currentTimeStringWithFormat:@"ddHH"];
    NSMutableString *dataString = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < currentString.length; i++) {
        NSInteger ascii = [currentString characterAtIndex:i];
        [dataString appendString:[NSString stringWithFormat:@"%ld",(long)ascii]];
    }
    
    if ([[orderId substringToIndex:8] isEqualToString:dataString]) {
        if ([[orderId substringFromIndex:8] isEqualToString:@"5641"]) {
            [self registerVipWithTargetVip:MSLevelVip1];
        } else if ([[orderId substringFromIndex:8] isEqualToString:@"5642"]) {
            [self registerVipWithTargetVip:MSLevelVip2];
        } else {
            [[MSHudManager manager] showHudWithText:@"无效的订单号"];
        }
    } else {
        [[MSHudManager manager] showHudWithText:@"无效的订单号"];
    }
}

- (void)registerVipWithTargetVip:(MSLevel)targetVipLevel {
    [MSUtil setVipLevel:targetVipLevel];
    [[NSNotificationCenter defaultCenter] postNotificationName:MSOpenVipSuccessNotification object:nil];
    [UIAlertView bk_showAlertViewWithTitle:@"激活成功" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIImage *backgroundImg = [_activateButton setGradientWithSize:_activateButton.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
    [_activateButton setBackgroundImage:backgroundImg forState:UIControlStateNormal];
}

@end
