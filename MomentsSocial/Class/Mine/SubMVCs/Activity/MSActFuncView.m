//
//  MSActFuncView.m
//  MomentsSocial
//
//  Created by Liang on 2017/9/26.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSActFuncView.h"
#import "MSTextField.h"

@interface MSActFuncView()
@property (nonatomic) UIButton *joinButton;
@property (nonatomic) MSTextField *phoneTextField;
@property (nonatomic) UIButton *upButton;
@property (nonatomic) UILabel *bindingLabel;
@end

@implementation MSActFuncView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        
        self.joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinButton setTitle:@"参与活动" forState:UIControlStateNormal];
        [_joinButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _joinButton.titleLabel.font = kFont(15);
        _joinButton.layer.cornerRadius = 3;
        _joinButton.layer.masksToBounds = YES;
        [self addSubview:_joinButton];
        
        @weakify(self);
        [_joinButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.joinAction) {
                self.joinAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        self.phoneTextField = [[MSTextField alloc] init];
        _phoneTextField.placeholder = @"请输入您的手机号码";
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.backgroundColor = kColor(@"#EBEBEB");
        [self addSubview:_phoneTextField];
        
        self.upButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_upButton setTitle:@"确认提交" forState:UIControlStateNormal];
        [_upButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _upButton.titleLabel.font = kFont(15);
        _upButton.layer.cornerRadius = 3;
        _upButton.layer.masksToBounds = YES;
        [self addSubview:_upButton];
        
        [_upButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            [MSUtil registerBindPhoneNumber:_phoneTextField.text];
            self.funcType = MSActFuncTypeBinding;
        } forControlEvents:UIControlEventTouchUpInside];
        
        self.bindingLabel = [[UILabel alloc] init];
        _bindingLabel.textColor = kColor(@"#333333");
        _bindingLabel.font = kFont(18);
        _bindingLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_bindingLabel];
        
        {
            [_joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kWidth(630), kWidth(80)));
            }];
            
            [_phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(self.mas_centerY).offset(-kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(630), kWidth(88)));
            }];
            
            [_upButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self.mas_centerY).offset(kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(630), kWidth(80)));
            }];
            
            [_bindingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.height.mas_equalTo(_bindingLabel.font.lineHeight);
            }];
        }
    }
    return self;
}

- (void)resignResponder {
    [_phoneTextField resignFirstResponder];
}

- (void)setFuncType:(MSActFuncType)funcType {
    _joinButton.hidden = funcType != MSActFuncTypeJoin;
    _phoneTextField.hidden = funcType != MSActFuncTypeInput;
    _upButton.hidden = funcType != MSActFuncTypeInput;
    _bindingLabel.hidden = funcType != MSActFuncTypeBinding;
    if (!_bindingLabel.hidden) {
        _bindingLabel.text = [NSString stringWithFormat:@"已提交手机:%@",[MSUtil getbindingPhoneNumber]];
    }
}

- (void)drawRect:(CGRect)rect {
    [_joinButton setBackgroundImage:[self.joinButton setGradientWithSize:self.joinButton.frame.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED455C")] direction:leftToRight] forState:UIControlStateNormal];
    [_upButton setBackgroundImage:[self.upButton setGradientWithSize:self.upButton.frame.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED455C")] direction:leftToRight] forState:UIControlStateNormal];

}

@end
