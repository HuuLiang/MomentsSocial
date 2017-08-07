//
//  MSAutoActivateVC.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSAutoActivateVC.h"

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
        [self activateInfo];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)activateInfo {
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIImage *backgroundImg = [_activateButton setGradientWithSize:_activateButton.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
    [_activateButton setBackgroundImage:backgroundImg forState:UIControlStateNormal];
}

@end
