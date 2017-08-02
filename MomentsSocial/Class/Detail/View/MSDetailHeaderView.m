//
//  MSDetailHeaderView.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDetailHeaderView.h"

@interface MSDetailHeaderView ()
@property (nonatomic) UIImageView *backImgV;
@property (nonatomic) UIImageView *userImgV;
@property (nonatomic) UILabel     *nickLabel;
@property (nonatomic) UILabel     *onlineLabel;
@property (nonatomic) UIButton    *locationButton;
@property (nonatomic) UIImageView *vipImgV;
@end

@implementation MSDetailHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backImgV = [[UIImageView alloc] init];
        [self addSubview:_backImgV];
        
        self.userImgV = [[UIImageView alloc] init];
        _userImgV.layer.cornerRadius = kWidth(56);
        _userImgV.layer.borderColor = kColor(@"#f0f0f0").CGColor;
        _userImgV.layer.borderWidth = 2.0f;
        _userImgV.layer.masksToBounds = YES;
        [self addSubview:_userImgV];
        
        self.nickLabel = [[UILabel alloc] init];
        _nickLabel.textColor = kColor(@"#ffffff");
        _nickLabel.font = kFont(16);
        [self addSubview:_nickLabel];
        
        self.onlineLabel = [[UILabel alloc] init];
        _onlineLabel.textColor = kColor(@"#ED465C");
        _onlineLabel.font = kFont(11);
        _onlineLabel.text = @"在线";
        _onlineLabel.backgroundColor = kColor(@"#ffffff");
        [self addSubview:_onlineLabel];
        
        self.locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_locationButton setImage:[UIImage imageNamed:@"near_location"] forState:UIControlStateNormal];
        [_locationButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _locationButton.titleLabel.font = kFont(11);
        [self addSubview:_locationButton];
        
        self.vipImgV = [[UIImageView alloc] init];
        [self addSubview:_vipImgV];
        
        {
            [_backImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            
            [_userImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(kWidth(104));
                make.size.mas_equalTo(CGSizeMake(kWidth(112), kWidth(112)));
            }];
            
            [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_userImgV.mas_bottom).offset(kWidth(28));
                make.centerX.equalTo(self);
                make.height.mas_equalTo(_nickLabel.font.lineHeight);
            }];
            
            [_onlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_nickLabel);
                make.left.equalTo(_nickLabel.mas_right).offset(kWidth(18));
                make.height.mas_equalTo(_onlineLabel.font.lineHeight);
            }];
            
            [_locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_nickLabel.mas_bottom).offset(kWidth(18));
                make.centerX.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kWidth(300), kWidth(26)));
            }];
            
            [_vipImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_locationButton.mas_bottom).offset(kWidth(22));
                make.size.mas_equalTo(CGSizeMake(kWidth(66), kWidth(28)));
            }];
        }
        
    }
    return self;
}

- (void)setImgUrl:(NSString *)imgUrl {
    [_userImgV sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
}

- (void)setNickName:(NSString *)nickName {
    _nickLabel.text = nickName;
}

- (void)setLocation:(NSString *)location {
    [_locationButton setTitle:location forState:UIControlStateNormal];
}

- (void)setVipLevel:(MSLevel)vipLevel {
    if (vipLevel == MSLevelVip0) {
        _vipImgV.image = [UIImage imageNamed:@"level_vip_0"];
    } else if (vipLevel == MSLevelVip1) {
        _vipImgV.image = [UIImage imageNamed:@"level_vip_1"];
    } else if (vipLevel == MSLevelVip2) {
        _vipImgV.image = [UIImage imageNamed:@"level_vip_2"];
    } else {
        _vipImgV.image = nil;
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [_locationButton  setIconInLeftWithSpacing:5];
}

@end
