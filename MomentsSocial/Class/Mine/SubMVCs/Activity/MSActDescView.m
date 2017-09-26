//
//  MSActDescView.m
//  MomentsSocial
//
//  Created by Liang on 2017/9/26.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSActDescView.h"

@interface MSActDescView ()
@property (nonatomic) UILabel * titleLabel;
@property (nonatomic) UILabel * descTitleLabel;
@property (nonatomic) UILabel * descALabel;
@property (nonatomic) UILabel * descBLabel;
@property (nonatomic) UILabel * descCLabel;
@property (nonatomic) UILabel * descDLabel;
@end

@implementation MSActDescView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kFont(16);
        _titleLabel.textColor = kColor(@"#333333");
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        self.descTitleLabel = [[UILabel alloc] init];
        _descTitleLabel.font = kFont(16);
        _descTitleLabel.textColor = kColor(@"#333333");
        _descTitleLabel.text = @"活动规则：";
        [self addSubview:_descTitleLabel];
        
        self.descALabel = [[UILabel alloc] init];
        _descALabel.font = kFont(14);
        _descALabel.textColor = kColor(@"#666666");
        _descALabel.numberOfLines = 0;
        _descALabel.text = @"1.活动期间，首次充值100元成为VIP的用户，将得到100元的话费返还；";
        [self addSubview:_descALabel];
        
        self.descBLabel = [[UILabel alloc] init];
        _descBLabel.font = kFont(14);
        _descBLabel.textColor = kColor(@"#666666");
        _descBLabel.numberOfLines = 0;
        _descBLabel.text = @"2.100元话费将以每月返还10元的形式充值到您填写的手机号上，直至完全返还完；";
        [self addSubview:_descBLabel];
        
        self.descCLabel = [[UILabel alloc] init];
        _descCLabel.font = kFont(14);
        _descCLabel.textColor = kColor(@"#666666");
        _descCLabel.numberOfLines = 0;
        _descCLabel.text = @"3.首次成为黄金VIP的用户，请在活动相关的页面提交您的有效手机号，话费将充值在该手机号。";
        [self addSubview:_descCLabel];
        
        self.descDLabel = [[UILabel alloc] init];
        _descDLabel.font = kFont(14);
        _descDLabel.textColor = kColor(@"#666666");
        _descDLabel.numberOfLines = 0;
        _descDLabel.text = @"4.话费将在充值次月开始返回，请确保每个月内至少21天活动在线，否则该月将无返还。";
        [self addSubview:_descDLabel];
        
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(kWidth(56));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_descTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.mas_left).offset(kWidth(30));
                make.top.equalTo(_titleLabel.mas_bottom).offset(kWidth(98));
                make.height.mas_equalTo(_descTitleLabel.font.lineHeight);
            }];
            
            [_descALabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.width.mas_equalTo(kWidth(690));
                make.top.equalTo(_descTitleLabel.mas_bottom).offset(kWidth(40));
            }];
            
            [_descBLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.width.mas_equalTo(kWidth(690));
                make.top.equalTo(_descALabel.mas_bottom).offset(kWidth(16));
            }];
            
            [_descCLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.width.mas_equalTo(kWidth(690));
                make.top.equalTo(_descBLabel.mas_bottom).offset(kWidth(16));
            }];
            
            [_descDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.width.mas_equalTo(kWidth(690));
                make.top.equalTo(_descCLabel.mas_bottom).offset(kWidth(16));
            }];
        }
    }
    return self;
}

- (void)setIsGoldVipPaid:(BOOL)isGoldVipPaid {
    _descDLabel.hidden = !isGoldVipPaid;
    if (isGoldVipPaid) {
        _titleLabel.text = @"恭喜您成为尊贵的黄金VIP";
    } else {
        _titleLabel.text = @"您当前非黄金VIP用户";
    }
}

@end
