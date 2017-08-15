//
//  MSMineVipDescView.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMineVipDescView.h"

@interface MSMineVipDescView ()
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) MSVipDescView *vip1;
@property (nonatomic) MSVipDescView *vip2;
@property (nonatomic) MSVipDescView *vip3;
@property (nonatomic) MSVipDescView *vip4;
@property (nonatomic) MSVipDescView *vip5;
@property (nonatomic) MSVipDescView *vip6;
@property (nonatomic) MSVipDescView *vip7;
@property (nonatomic) UIButton *openVipButton;
@end

@implementation MSMineVipDescView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#333333");
        _titleLabel.font = kFont(17);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"升级权益";
        [self addSubview:_titleLabel];
        
        if ([MSUtil currentVipLevel] == MSLevelVip0) {
            self.vip1 = [[MSVipDescView alloc] initWithImgName:@"mine_vip0_moments" desc:@"进入所有\nVIP圈子"];
            [self addSubview:_vip1];
            
            self.vip2 = [[MSVipDescView alloc] initWithImgName:@"mine_vip0_info" desc:@"用户私密\n（照片、联系）"];
            [self addSubview:_vip2];
            
            self.vip3 = [[MSVipDescView alloc] initWithImgName:@"mine_vip0_msg" desc:@"在圈子里\n发布自己信息"];
            [self addSubview:_vip3];
            
            self.vip4 = [[MSVipDescView alloc] initWithImgName:@"mine_vip0_social" desc:@"无限\n摇一摇"];
            [self addSubview:_vip4];
            
            self.vip5 = [[MSVipDescView alloc] initWithImgName:@"mine_vip0_receive" desc:@"发送消息\n用户优先收到"];
            [self addSubview:_vip5];
            
            self.vip6 = [[MSVipDescView alloc] initWithImgName:@"mine_vip0_tonight" desc:@"可参加\n《今夜开房》"];
            [self addSubview:_vip6];
            
            self.vip7 = [[MSVipDescView alloc] initWithImgName:@"mine_vip0_chat" desc:@"可参加\n《全名lo聊》"];
            [self addSubview:_vip7];
        } else if ([MSUtil currentVipLevel] > MSLevelVip0) {
            self.vip1 = [[MSVipDescView alloc] initWithImgName:@"mine_vip1_server" desc:@"客服介绍\n交友对象"];
            [self addSubview:_vip1];
            
            self.vip2 = [[MSVipDescView alloc] initWithImgName:@"mine_vip1_chat" desc:@"lo聊天\n不被踢出"];
            [self addSubview:_vip2];
            
            self.vip3 = [[MSVipDescView alloc] initWithImgName:@"mine_vip1_diamond" desc:@"进入钻石\nVIP分类"];
            [self addSubview:_vip3];
            
            self.vip4 = [[MSVipDescView alloc] initWithImgName:@"mine_vip1_tonight" desc:@"可参加\n《今日开房》"];
            [self addSubview:_vip4];
            
            self.vip5 = [[MSVipDescView alloc] initWithImgName:@"mine_vip1_face" desc:@"视频邀请\n服务"];
            [self addSubview:_vip5];
        }

        
        if ([MSUtil currentVipLevel] <= MSLevelVip1) {
            self.openVipButton = [UIButton buttonWithType:UIButtonTypeCustom];
            if ([MSUtil currentVipLevel] == MSLevelVip0) {
                [_openVipButton setTitle:@"升级VIP" forState:UIControlStateNormal];
            } else if ([MSUtil currentVipLevel] > MSLevelVip0) {
                [_openVipButton setTitle:@"钻石VIP" forState:UIControlStateNormal];
            }
            [_openVipButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
            _openVipButton.titleLabel.font = kFont(14);
            _openVipButton.layer.cornerRadius = kWidth(32);
            _openVipButton.layer.masksToBounds = YES;
            [self addSubview:_openVipButton];
            
            @weakify(self);
            [_openVipButton bk_addEventHandler:^(id sender) {
                @strongify(self);
                if (self.openVipAction) {
                    self.openVipAction();
                }
            } forControlEvents:UIControlEventTouchUpInside];

        }
        
        
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(kWidth(36));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            if ([MSUtil currentVipLevel] == MSLevelVip0) {
                [_vip1 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self);
                    make.top.equalTo(_titleLabel.mas_bottom).offset(kWidth(34));
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
                
                [_vip2 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_vip1);
                    make.left.equalTo(_vip1.mas_right);
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
                
                [_vip3 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_vip2);
                    make.left.equalTo(_vip2.mas_right);
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
                
                [_vip4 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_vip3);
                    make.left.equalTo(_vip3.mas_right);
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
                
                [_vip6 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self);
                    make.top.equalTo(_vip1.mas_bottom).offset(kWidth(56));
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
                
                [_vip5 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_vip6);
                    make.right.equalTo(_vip6.mas_left);
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
                
                [_vip7 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_vip6);
                    make.left.equalTo(_vip6.mas_right);
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
            } else if ([MSUtil currentVipLevel] >= MSLevelVip0) {
                [_vip2 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_titleLabel.mas_bottom).offset(kWidth(34));
                    make.centerX.equalTo(self);
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
                
                [_vip1 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_vip2);
                    make.right.equalTo(_vip2.mas_left).offset(-kWidth(60));
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
                
                [_vip3 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_vip2);
                    make.left.equalTo(_vip2.mas_right).offset(kWidth(60));
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
                
                [_vip4 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(_vip2.mas_bottom).offset(kWidth(56));
                    make.right.equalTo(self.mas_centerX).offset(-kWidth(45));
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
                
                [_vip5 mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(_vip4);
                    make.left.equalTo(self.mas_centerX).offset(kWidth(45));
                    make.size.mas_equalTo(CGSizeMake(ceilf(kWidth(173)), ceilf(kWidth(173))));
                }];
            }
            
            
            if ([MSUtil currentVipLevel] <= MSLevelVip1) {
                [_openVipButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(self.mas_bottom).offset(-kWidth(42));
                    make.centerX.equalTo(self);
                    make.size.mas_equalTo(CGSizeMake(kWidth(398), kWidth(64)));
                }];
            }
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIImage *img = [_openVipButton setGradientWithSize:_openVipButton.frame.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
    [_openVipButton setBackgroundImage:img forState:UIControlStateNormal];
}

@end




@interface MSVipDescView ()
@property (nonatomic) UIImageView *imgV;
@property (nonatomic) UILabel     *label;
@end


@implementation MSVipDescView

- (instancetype)initWithImgName:(NSString *)imgName desc:(NSString *)desc
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        
        self.imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        [self addSubview:_imgV];
        
        self.label = [[UILabel alloc] init];
        _label.textColor = kColor(@"#666666");
        _label.font = kFont(12);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = desc;
        _label.numberOfLines = 2;
        [self addSubview:_label];
        
        {
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.top.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kWidth(100), kWidth(100)));
            }];
            
            [_label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_imgV.mas_bottom).offset(kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(172), ceilf(kFont(12).lineHeight *2)));
            }];
        }
        
    }
    return self;
}

@end
