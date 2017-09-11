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
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIImageView *userImgV;
@property (nonatomic) UIButton *nickOnlineButton;
//@property (nonatomic) UIButton    *locationButton;
@property (nonatomic) UIImageView *vipImgV;
@end

@implementation MSDetailHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backImgV = [[UIImageView alloc] init];
        [self addSubview:_backImgV];
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [self addSubview:_backButton];
        
        self.userImgV = [[UIImageView alloc] init];
        _userImgV.layer.cornerRadius = kWidth(56);
        _userImgV.layer.borderColor = kColor(@"#f0f0f0").CGColor;
        _userImgV.layer.borderWidth = 2.0f;
        _userImgV.layer.masksToBounds = YES;
        [self addSubview:_userImgV];
                
        self.nickOnlineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nickOnlineButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _nickOnlineButton.titleLabel.font = kFont(16);
        _nickOnlineButton.enabled = NO;
        [self addSubview:_nickOnlineButton];
        
//        self.locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_locationButton setImage:[UIImage imageNamed:@"near_location"] forState:UIControlStateNormal];
//        [_locationButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
//        _locationButton.titleLabel.font = kFont(11);
//        [self addSubview:_locationButton];
        
        self.vipImgV = [[UIImageView alloc] init];
        [self addSubview:_vipImgV];
        
        @weakify(self);
        [_backButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.backAction) {
                self.backAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            [_backImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            
            [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_backImgV).offset(kWidth(66));
                make.left.equalTo(_backImgV).offset(kWidth(26));
                make.size.mas_equalTo(CGSizeMake(kWidth(26), kWidth(66)));
            }];
            
            [_userImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(kWidth(104));
                make.size.mas_equalTo(CGSizeMake(kWidth(112), kWidth(112)));
            }];
            
            
            [_nickOnlineButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_userImgV.mas_bottom).offset(kWidth(28));
                make.centerX.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kWidth(260), kWidth(36)));
            }];
            
//            [_locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(_nickOnlineButton.mas_bottom).offset(kWidth(18));
//                make.centerX.equalTo(self);
//                make.size.mas_equalTo(CGSizeMake(kWidth(300), kWidth(26)));
//            }];
            
            [_vipImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_nickOnlineButton.mas_bottom).offset(kWidth(30));
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
    [_nickOnlineButton setTitle:nickName forState:UIControlStateNormal];
}

- (void)setOnline:(BOOL)online {
    [_nickOnlineButton setImage:[UIImage imageNamed:online ? @"moment_online" : @"moment_offline"] forState:UIControlStateNormal];
}

//- (void)setLocation:(NSString *)location {
//    [_locationButton setTitle:location forState:UIControlStateNormal];
//}

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
    
    [_nickOnlineButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:kWidth(14)];
    
//    [_locationButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleLeft imageTitleSpace:5];
    
    _backImgV.image = [self setGradientWithSize:_backImgV.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
}

@end
