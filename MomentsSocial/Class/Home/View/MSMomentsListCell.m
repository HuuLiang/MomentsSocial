//
//  MSMomentsListCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMomentsListCell.h"

@interface MSMomentsListCell ()
@property (nonatomic) UIImageView   *mainImgV;
@property (nonatomic) UILabel       *titleLabel;
@property (nonatomic) UILabel       *descLabel;
@property (nonatomic) UIImageView   *typeImgV;
@property (nonatomic) UILabel       *onlineLabel;
@property (nonatomic) UIImageView   *hotImgV;
@end

@implementation MSMomentsListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = kColor(@"#f0f0f0");
        backView.layer.cornerRadius = kWidth(56);
        backView.layer.masksToBounds = YES;
        [self.contentView addSubview:backView];
        
        self.mainImgV = [[UIImageView alloc] init];
        _mainImgV.layer.cornerRadius = kWidth(52);
        _mainImgV.layer.masksToBounds = YES;
        [backView addSubview:_mainImgV];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#333333");
        _titleLabel.font = kFont(15);
        [self.contentView addSubview:_titleLabel];
        
        self.typeImgV = [[UIImageView alloc] init];
        [self addSubview:_typeImgV];
        
        self.descLabel = [[UILabel alloc] init];
        _descLabel.textColor = kColor(@"#999999");
        _descLabel.font = kFont(12);
        [self.contentView addSubview:_descLabel];
        
        self.onlineLabel = [[UILabel alloc] init];
        _onlineLabel.textColor = kColor(@"#5AC8FA");
        _onlineLabel.font = kFont(12);
        _onlineLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_onlineLabel];
        
        self.hotImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_hot"]];
        [self.contentView addSubview:_hotImgV];
        
        {
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(self.contentView).offset(kWidth(26));
                make.size.mas_equalTo(CGSizeMake(kWidth(112), kWidth(112)));
            }];
            
            [_mainImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(backView);
                make.size.mas_equalTo(CGSizeMake(kWidth(104), kWidth(104)));
            }];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_mainImgV.mas_right).offset(kWidth(30));
                make.bottom.equalTo(self.contentView.mas_centerY).offset(-kWidth(10));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_onlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_titleLabel);
                make.left.equalTo(_titleLabel.mas_right).offset(kWidth(16));
                make.height.mas_equalTo(_onlineLabel.font.lineHeight);
            }];
            
            [_typeImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_titleLabel);
                make.left.equalTo(_onlineLabel.mas_right).offset(kWidth(24));
                make.size.mas_equalTo(CGSizeMake(kWidth(66), kWidth(28)));
            }];
            
            [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel);
                make.top.equalTo(self.contentView.mas_centerY).offset(kWidth(8));
                make.height.mas_equalTo(_descLabel.font.lineHeight);
            }];
            
            
            [_hotImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.right.equalTo(self.contentView.mas_right).offset(-kWidth(42));
                make.size.mas_equalTo(CGSizeMake(kWidth(32), kWidth(36)));
            }];
        }

    }
    return self;
}

- (void)setImgUrl:(NSString *)imgUrl {
    [_mainImgV sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setSubTitle:(NSString *)subTitle {
    _descLabel.text = subTitle;
}

- (void)setVipLevel:(MSLevel)vipLevel {
    if (vipLevel == MSLevelVip0) {
        _typeImgV.image = [UIImage imageNamed:@"level_vip_0"];
    } else if (vipLevel == MSLevelVip1) {
        _typeImgV.image = [UIImage imageNamed:@"level_vip_1"];
    } else if (vipLevel == MSLevelVip2) {
        _typeImgV.image = [UIImage imageNamed:@"level_vip_2"];
    } else {
        _typeImgV.image = nil;
    }
}

- (void)setCount:(NSInteger)count {
    _onlineLabel.text = [NSString stringWithFormat:@"%ld在线",(long)count];
    _hotImgV.hidden = count <= 1000;
}

@end
