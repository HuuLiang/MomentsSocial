//
//  MSHomeCategoryCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSHomeCategoryCell.h"

@interface MSHomeCategoryCell ()
@property (nonatomic) UIImageView *mainImgV;
@property (nonatomic) UILabel     *titleLabel;
@property (nonatomic) UIImageView *vipImgV;
@property (nonatomic) UILabel     *descLabel;
@property (nonatomic) UIButton    *joinButton;
@end

@implementation MSHomeCategoryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.mainImgV = [[UIImageView alloc] init];
        _mainImgV.layer.cornerRadius = kWidth(56);
        _mainImgV.layer.borderColor = kColor(@"#F0F0F0").CGColor;
        _mainImgV.layer.borderWidth = kWidth(4);
        _mainImgV.layer.masksToBounds = YES;
        [self.contentView addSubview:_mainImgV];

        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#333333");
        _titleLabel.font = kFont(16);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
        
        self.vipImgV = [[UIImageView alloc] init];
        [self addSubview:_vipImgV];
        
        self.descLabel = [[UILabel alloc] init];
        _descLabel.textColor = kColor(@"#999999");
        _descLabel.font = kFont(12);
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.numberOfLines = 0;
        [self.contentView addSubview:_descLabel];
        
        self.joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_joinButton setTitle:@"加入" forState:UIControlStateNormal];
        [_joinButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _joinButton.titleLabel.font = kFont(12);
        _joinButton.layer.cornerRadius = kWidth(24);
        _joinButton.layer.masksToBounds = YES;
        [self.contentView addSubview:_joinButton];
        
        @weakify(self);
        [_joinButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.joinAction) {
                self.joinAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            [_mainImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.contentView);
                make.top.equalTo(self.contentView).offset(kWidth(34));
                make.size.mas_equalTo(CGSizeMake(kWidth(112), kWidth(112)));
            }];
            
            [_vipImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView.mas_centerX).offset(kWidth(24));
                make.top.equalTo(_mainImgV.mas_top).offset(2);
                make.size.mas_equalTo(CGSizeMake(kWidth(64), kWidth(28)));
            }];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.contentView);
                make.top.equalTo(_mainImgV.mas_bottom).offset(kWidth(20));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.contentView);
                make.top.equalTo(_titleLabel.mas_bottom).offset(kWidth(20));
                make.width.mas_equalTo(kWidth(220));
            }];
            
            [_joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.contentView);
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-kWidth(22));
                make.size.mas_equalTo(CGSizeMake(kWidth(120), kWidth(48)));
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
    
    UIImage *backgroundImg = [_joinButton setGradientWithSize:_joinButton.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
    [_joinButton setBackgroundImage:backgroundImg forState:UIControlStateNormal];
}

@end
