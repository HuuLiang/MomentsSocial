//
//  MSNearCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSNearCell.h"
#import "MSGreetView.h"

NSString *const kMSRobotSexMaleKeyName    = @"男";
NSString *const kMSRobotSexFemaleKeyName  = @"女";

@interface MSNearCell ()
@property (nonatomic) UIImageView *mainImgV;
@property (nonatomic) UILabel     *nickLabel;
@property (nonatomic) UILabel     *ageLabel;
@property (nonatomic) UIImageView *sexImgV;
@property (nonatomic) UIImageView *locationImgV;
@property (nonatomic) UILabel     *locationLabel;
@property (nonatomic) MSGreetView *greetView;
@end

@implementation MSNearCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.mainImgV = [[UIImageView alloc] init];
        [self.contentView addSubview:_mainImgV];
        
        self.nickLabel = [[UILabel alloc] init];
        _nickLabel.textColor = kColor(@"#333333");
        _nickLabel.font = kFont(13);
        [self.contentView addSubview:_nickLabel];
        
        self.ageLabel = [[UILabel alloc] init];
        _ageLabel.textColor = kColor(@"#999999");
        _ageLabel.font = kFont(13);
        [self.contentView addSubview:_ageLabel];
        
        self.sexImgV = [[UIImageView alloc] init];
        [self.contentView addSubview:_sexImgV];
        
        self.locationImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"near_location"]];
        [self.contentView addSubview:_locationImgV];
        
        self.locationLabel = [[UILabel alloc] init];
        _locationLabel.textColor = kColor(@"#999999");
        _locationLabel.font = kFont(11);
        [self.contentView addSubview:_locationLabel];
        
        self.greetView = [[MSGreetView alloc] init];
        [self.contentView addSubview:_greetView];
        
        @weakify(self);
        [_greetView bk_whenTapped:^{
            @strongify(self);
            if (self.greetAction) {
                self.greetAction();
            }
        }];
        
        {
            [_mainImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self.contentView);
                make.height.mas_equalTo(frame.size.width);
            }];
            
            [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(kWidth(20));
                make.top.equalTo(_mainImgV.mas_bottom).offset(kWidth(8));
                make.height.mas_equalTo(_nickLabel.font.lineHeight);
            }];
            
            [_ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(_nickLabel.mas_bottom);
                make.left.equalTo(_nickLabel.mas_right).offset(kWidth(18));
                make.height.mas_equalTo(_ageLabel.font.lineHeight);
            }];
            
            [_sexImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_nickLabel);
                make.left.equalTo(_ageLabel.mas_right).offset(kWidth(6));
                make.size.mas_equalTo(CGSizeMake(kWidth(24), kWidth(24)));
            }];
            
            [_locationImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-kWidth(12));
                make.left.equalTo(self.contentView).offset(kWidth(28));
                make.size.mas_equalTo(CGSizeMake(kWidth(18), kWidth(24)));
            }];
            
            [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_locationImgV);
                make.left.equalTo(_locationImgV.mas_right).offset(kWidth(18));
                make.height.mas_equalTo(_locationLabel.font.lineHeight);
            }];
            
            [_greetView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-kWidth(14));
                make.right.equalTo(self.contentView.mas_right).offset(-kWidth(6));
                make.size.mas_equalTo(CGSizeMake(kWidth(90), kWidth(60)));
            }];
        }
        
    }
    return self;
}

- (void)setImgUrl:(NSString *)imgUrl {
    _imgUrl = imgUrl;
    [_mainImgV sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
}

- (void)setNickName:(NSString *)nickName {
    _nickName = nickName;
    _nickLabel.text = nickName;
}

- (void)setAge:(NSInteger)age {
    _age = age;
    _ageLabel.text = [NSString stringWithFormat:@"%ld岁",(long)age];
}

- (void)setSex:(NSString *)sex {
    _sex = sex;
    if (sex == kMSRobotSexMaleKeyName) {
        _sexImgV.image = [UIImage imageNamed:@"near_male"];
    } else if (sex == kMSRobotSexFemaleKeyName) {
        _sexImgV.image = [UIImage imageNamed:@"near_female"];
    }
}

- (void)setLocation:(NSString *)location {
    _location = location;
    _locationLabel.text = location;
}

- (void)setIsGreeted:(BOOL)isGreeted {
    _greetView.isGreeted = isGreeted;
}

@end
