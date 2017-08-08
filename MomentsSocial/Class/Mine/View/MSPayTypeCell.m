//
//  MSPayTypeCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSPayTypeCell.h"

@interface MSPayTypeCell ()
@property (nonatomic) UIImageView *imgV;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *subLabel;
@end

@implementation MSPayTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.imgV = [[UIImageView alloc] init];
        _imgV.layer.cornerRadius = 8;
        _imgV.clipsToBounds = YES;
        [self.contentView addSubview:_imgV];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#333333");
        _titleLabel.font = kFont(17);
        [self.contentView addSubview:_titleLabel];
        
        self.subLabel = [[UILabel alloc] init];
        _subLabel.font = kFont(15);
        _subLabel.textColor = kColor(@"#999999");
        [self.contentView addSubview:_subLabel];
        
        {
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(kWidth(30));
                make.centerY.equalTo(self.contentView);
                make.size.mas_equalTo(CGSizeMake(kWidth(120), kWidth(120)));
            }];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imgV.mas_right).offset(kWidth(20));
                make.top.equalTo(self.contentView).offset(kWidth(32));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];

            [_subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel);
                make.top.equalTo(_titleLabel.mas_bottom).offset(kWidth(20));
                make.height.mas_equalTo(_subLabel.font.lineHeight);
            }];
        }
        
    }
    return self;
}

- (void)setPayType:(MSPayType)payType {
    _payType = payType;
    if (payType == MSPayTypeWeiXin) {
        _imgV.image = [UIImage imageNamed:@"mine_pay_ali"];
        _titleLabel.text = @"微信支付";
        _subLabel.text = @"推荐开通微信支付功能的用户使用";
    } else if (payType == MSPayTypeAliPay) {
        _imgV.image = [UIImage imageNamed:@"mine_pay_wx"];
        _titleLabel.text = @"支付宝";
        _subLabel.text = @"推荐支付宝用户使用";
    }
}


@end
