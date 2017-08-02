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
        [self addSubview:_titleLabel];
        
        self.vip1 = [[MSVipDescView alloc] initWithImgName:@"mine_moments" desc:@"进入所有\nVIP圈子"];
        [self addSubview:_vip1];
        
        self.vip2 = [[MSVipDescView alloc] initWithImgName:@"mine_info" desc:@"用户私密\n（照片、联系）"];
        [self addSubview:_vip2];
        
        self.vip3 = [[MSVipDescView alloc] initWithImgName:@"mine_msg" desc:@"在圈子里\n发布自己信息"];
        [self addSubview:_vip3];
        
        self.vip4 = [[MSVipDescView alloc] initWithImgName:@"mine_social" desc:@"无限\n摇一摇"];
        [self addSubview:_vip4];
        
        self.vip5 = [[MSVipDescView alloc] initWithImgName:@"mine_receive" desc:@"发送消息\n用户优先收到"];
        [self addSubview:_vip5];
        
        self.vip6 = [[MSVipDescView alloc] initWithImgName:@"mine_tonight" desc:@"可参加\n《今夜开房》"];
        [self addSubview:_vip6];
        
        self.vip7 = [[MSVipDescView alloc] initWithImgName:@"mine_chat" desc:@"可参加\n《全名lo聊》"];
        [self addSubview:_vip7];
        
        self.openVipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openVipButton setTitle:@"开通VIP" forState:UIControlStateNormal];
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
        
        
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(kWidth(36));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_vip1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self);
                make.top.equalTo(_titleLabel.mas_bottom).offset(kWidth(34));
                make.size.mas_equalTo(CGSizeMake(kWidth(173), kWidth(172)));
            }];
            
            [_vip2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_vip1);
                make.left.equalTo(_vip1.mas_right);
                make.size.mas_equalTo(CGSizeMake(kWidth(173), kWidth(172)));
            }];
            
            [_vip3 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_vip2);
                make.left.equalTo(_vip2.mas_right);
                make.size.mas_equalTo(CGSizeMake(kWidth(173), kWidth(172)));
            }];
            
            [_vip4 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_vip3);
                make.left.equalTo(_vip3.mas_right);
                make.size.mas_equalTo(CGSizeMake(kWidth(173), kWidth(172)));
            }];
            
            [_vip6 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_vip1.mas_bottom).offset(kWidth(56));
                make.size.mas_equalTo(CGSizeMake(kWidth(173), kWidth(172)));
            }];
            
            [_vip5 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_vip6);
                make.right.equalTo(_vip6.mas_left);
                make.size.mas_equalTo(CGSizeMake(kWidth(173), kWidth(172)));
            }];
            
            [_vip7 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_vip6);
                make.left.equalTo(_vip6.mas_right);
                make.size.mas_equalTo(CGSizeMake(kWidth(173), kWidth(172)));
            }];
            
            [_openVipButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.mas_bottom).offset(-kWidth(42));
                make.centerX.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kWidth(398), kWidth(64)));
            }];
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
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = kColor(@"#000000").CGColor;
        
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
                make.size.mas_equalTo(CGSizeMake(kWidth(172), kFont(12).lineHeight *2));
            }];
        }
        
    }
    return self;
}

@end
