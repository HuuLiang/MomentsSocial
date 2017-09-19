//
//  MSNearCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSNearCell.h"

//NSString *const kMSRobotSexMaleKeyName    = @"男";
//NSString *const kMSRobotSexFemaleKeyName  = @"女";

@interface MSNearCell ()
@property (nonatomic) UIImageView *mainImgV;
@property (nonatomic) UILabel     *nickLabel;
@property (nonatomic) UILabel     *ageLabel;
@property (nonatomic) UIImageView *locationImgV;
@property (nonatomic) UILabel     *locationLabel;
@property (nonatomic) UIButton    *greetButton;
@end

@implementation MSNearCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.mainImgV = [[UIImageView alloc] init];
        _mainImgV.layer.cornerRadius = 5.0;
        _mainImgV.layer.masksToBounds = YES;
        [self.contentView addSubview:_mainImgV];
        
        self.nickLabel = [[UILabel alloc] init];
        _nickLabel.textColor = kColor(@"#333333");
        _nickLabel.font = kFont(16);
        [self.contentView addSubview:_nickLabel];
        
        self.ageLabel = [[UILabel alloc] init];
        _ageLabel.textColor = kColor(@"#999999");
        _ageLabel.font = kFont(14);
        [self.contentView addSubview:_ageLabel];
        
        self.locationImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"near_location"]];
        [self.contentView addSubview:_locationImgV];
        
        self.locationLabel = [[UILabel alloc] init];
        _locationLabel.textColor = kColor(@"#999999");
        _locationLabel.font = kFont(14);
        [self.contentView addSubview:_locationLabel];
        
        self.greetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _greetButton.layer.cornerRadius = kWidth(30);
        _greetButton.layer.masksToBounds = YES;
        _greetButton.titleLabel.font = kFont(13);
        [self.contentView addSubview:_greetButton];
        
        @weakify(self);
        [_greetButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.greetAction) {
                self.greetAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            [_mainImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(self.contentView).offset(kWidth(30));
                make.size.mas_equalTo(CGSizeMake(kWidth(140), kWidth(140)));
            }];
            
            [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_mainImgV.mas_right).offset(kWidth(20));
                make.top.equalTo(_mainImgV.mas_top).offset(kWidth(20));
                make.height.mas_equalTo(_nickLabel.font.lineHeight);
            }];
            
            [_ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_nickLabel.mas_centerY);
                make.left.equalTo(_nickLabel.mas_right).offset(kWidth(14));
                make.height.mas_equalTo(_ageLabel.font.lineHeight);
            }];
            
            [_locationImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(_mainImgV.mas_bottom).offset(-kWidth(20));
                make.left.equalTo(_mainImgV.mas_right).offset(kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(22), kWidth(28)));
            }];
            
            [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_locationImgV);
                make.left.equalTo(_locationImgV.mas_right).offset(kWidth(6));
                make.height.mas_equalTo(_locationLabel.font.lineHeight);
            }];
            
            [_greetButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.right.equalTo(self.contentView.mas_right).offset(-kWidth(26));
                make.size.mas_equalTo(CGSizeMake(kWidth(144), kWidth(60)));
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

- (void)setLocation:(NSString *)location {
    _location = location;
    _locationLabel.text = location;
}

- (void)setIsGreeted:(BOOL)isGreeted {
    [_greetButton setTitle:isGreeted ? @"已打招呼" : @"打招呼" forState:UIControlStateNormal];
    [_greetButton setTitleColor:isGreeted ? kColor(@"#666666") : kColor(@"#ffffff") forState:UIControlStateNormal];
    UIImage *image = [_greetButton setGradientWithSize:CGSizeMake(kWidth(144), kWidth(60)) Colors:isGreeted ? @[kColor(@"#EAEAEA"),kColor(@"#DCDCDC")] : @[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
    [_greetButton setBackgroundImage:image forState:UIControlStateNormal];
}

@end
