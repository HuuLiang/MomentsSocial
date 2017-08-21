//
//  MSHomeMomentsCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSHomeMomentsCell.h"

@interface MSHomeMomentsCell ()
@property (nonatomic) UIImageView   *mainImgV;
@property (nonatomic) UILabel       *titleLabel;
@property (nonatomic) UILabel       *descLabel;
@property (nonatomic) UIImageView   *vipImgV;
@property (nonatomic) UILabel       *onlineLabel;
@property (nonatomic) UIImageView   *lineV;
@end

@implementation MSHomeMomentsCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
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
        
        self.vipImgV = [[UIImageView alloc] init];
        [self.contentView addSubview:_vipImgV];
        
        self.descLabel = [[UILabel alloc] init];
        _descLabel.textColor = kColor(@"#999999");
        _descLabel.font = kFont(12);
        [self.contentView addSubview:_descLabel];
        
        self.onlineLabel = [[UILabel alloc] init];
        _onlineLabel.textColor = kColor(@"#5AC8FA");
        _onlineLabel.font = kFont(12);
        _onlineLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_onlineLabel];
        
        self.lineV = [[UIImageView alloc] init];
        _lineV.backgroundColor = kColor(@"#f0f0f0");
        [self.contentView addSubview:_lineV];
        
        {
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(self.contentView).offset(kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(112), kWidth(112)));
            }];
            
            [_mainImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(backView);
                make.size.mas_equalTo(CGSizeMake(kWidth(104), kWidth(104)));
            }];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_mainImgV.mas_right).offset(kWidth(20));
                make.bottom.equalTo(self.contentView.mas_centerY).offset(-kWidth(10));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_vipImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_titleLabel);
                make.left.equalTo(_titleLabel.mas_right).offset(kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(66), kWidth(28)));
            }];
            
            [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel);
                make.top.equalTo(self.contentView.mas_centerY).offset(kWidth(8));
                make.height.mas_equalTo(_descLabel.font.lineHeight);
            }];
            
            [_onlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.right.equalTo(self.contentView.mas_right).offset(-kWidth(20));
                make.height.mas_equalTo(_onlineLabel.font.lineHeight);
            }];
            
            [_lineV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.centerX.equalTo(self.contentView);
                make.size.mas_equalTo(CGSizeMake(frame.size.width, 1));
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
    _vipLevel = vipLevel;
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

- (void)setCount:(NSInteger)count {
    _onlineLabel.text = [NSString stringWithFormat:@"%ld在线",(long)count];
}


@end
