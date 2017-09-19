//
//  MSMineInfoView.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMineInfoView.h"

@interface MSMineInfoView ()
@property (nonatomic) UIImageView *userImgV;
@property (nonatomic) UILabel     *nickLabel;
@property (nonatomic) UIImageView *vipImgV;
@property (nonatomic) UILabel     *idLabel;
@property (nonatomic) UIImageView *intoImgV;
@end

@implementation MSMineInfoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        self.layer.shadowColor = kColor(@"#000000").CGColor;
        self.layer.shadowOpacity = 0.15;
        self.layer.shadowRadius = kWidth(4);
        self.layer.shadowOffset = CGSizeMake(-5, 5);
        
        
        self.userImgV = [[UIImageView alloc] init];
        _userImgV.layer.cornerRadius = 5;
        _userImgV.layer.masksToBounds = YES;
        _userImgV.userInteractionEnabled = YES;
        [self addSubview:_userImgV];
        
        self.nickLabel = [[UILabel alloc] init];
        _nickLabel.textColor = kColor(@"#333333");
        _nickLabel.font = kFont(15);
        _nickLabel.userInteractionEnabled = YES;
        [self addSubview:_nickLabel];
        
        @weakify(self);
        [_userImgV bk_whenTapped:^{
            @strongify(self);
            if (self.changeImgAction) {
                self.changeImgAction();
            }
        }];
        
        [_nickLabel bk_whenTapped:^{
            @strongify(self);
            if (self.changeNickAction) {
                self.changeNickAction();
            }
        }];
        
        self.vipImgV = [[UIImageView alloc] init];
        [self addSubview:_vipImgV];
        
        self.idLabel = [[UILabel alloc] init];
        _idLabel.textColor = kColor(@"#333333");
        _idLabel.font = kFont(15);
        [self addSubview:_idLabel];
        
        self.intoImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_into"]];
        [self addSubview:_intoImgV];
        
        {
            [_userImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).offset(kWidth(30));
                make.size.mas_equalTo(CGSizeMake(kWidth(140), kWidth(140)));
            }];
            
            [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_userImgV.mas_right).offset(kWidth(20));
                make.bottom.equalTo(self.mas_centerY).offset(-kWidth(10));
                make.height.mas_equalTo(_nickLabel.font.lineHeight);
            }];
            
            [_vipImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_nickLabel);
                make.left.equalTo(_nickLabel.mas_right).offset(kWidth(16));
                make.size.mas_equalTo(CGSizeMake(kWidth(64), kWidth(28)));
            }];
            
            [_idLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.mas_centerY).offset(kWidth(10));
                make.left.equalTo(_nickLabel);
                make.height.mas_equalTo(_idLabel.font.lineHeight);
            }];
            
            [_intoImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.right.equalTo(self.mas_right).offset(-kWidth(30));
                make.size.mas_equalTo(CGSizeMake(kWidth(14), kWidth(26)));
            }];
        }
    }
    return self;
}

- (void)setImgUrl:(NSString *)imgUrl {
    [_userImgV sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"mine_portrait"]];
}

- (void)setNickName:(NSString *)nickName {
    _nickLabel.text = nickName;
}

- (void)setUserId:(NSInteger)userId {
    _idLabel.text = [NSString stringWithFormat:@"ID：%ld",(long)userId];
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


@end
