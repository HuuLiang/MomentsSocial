//
//  MSVipPayPointCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/14.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSVipPayPointCell.h"
#import "MSSystemConfigModel.h"

@interface MSVipPayPointCell ()
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *priceLabel;
@property (nonatomic) UILabel *unitPriceLabel;
@property (nonatomic) UILabel *subTitleLabel;
@property (nonatomic) UILabel *descLabel;
@property (nonatomic) UIButton *selectedBtn;
@end

@implementation MSVipPayPointCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kFont(16);
        _titleLabel.textColor = kColor(@"#333333");
        [self.contentView addSubview:_titleLabel];
        
        self.priceLabel = [[UILabel alloc] init];
        _priceLabel.textColor = kColor(@"#FF3366");
        _priceLabel.font = kFont(16);
        [self.contentView addSubview:_priceLabel];
        
        self.unitPriceLabel = [[UILabel alloc] init];
        _unitPriceLabel.textColor = kColor(@"#ED455C");
        _unitPriceLabel.font = kFont(11);
        _unitPriceLabel.backgroundColor = kColor(@"#f0f0f0");
        [self.contentView addSubview:_unitPriceLabel];
        
        self.subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.font = kFont(12);
        _subTitleLabel.textColor = kColor(@"#666666");
        [self.contentView addSubview:_subTitleLabel];
        
        self.descLabel = [[UILabel alloc] init];
        _descLabel.textColor = kColor(@"#CD8B1E");
        _descLabel.font = kFont(11);
        [self.contentView addSubview:_descLabel];
        
        self.selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedBtn setImage:[UIImage imageNamed:@"pay_normal"] forState:UIControlStateNormal];
        [self.contentView addSubview:_selectedBtn];
        
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(kWidth(40));
                make.top.equalTo(self.contentView).offset(kWidth(26));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_titleLabel);
                make.left.equalTo(_titleLabel.mas_right).offset(kWidth(84));
                make.height.mas_equalTo(_priceLabel.font.lineHeight);
            }];
            
            [_unitPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_priceLabel);
                make.left.equalTo(_priceLabel.mas_right).offset(kWidth(20));
                make.height.mas_equalTo(_unitPriceLabel.font.lineHeight + 3);
            }];
            
            [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_titleLabel.mas_bottom).offset(kWidth(18));
                make.left.equalTo(_titleLabel);
                make.height.mas_equalTo(_subTitleLabel.font.lineHeight);
            }];
            
            [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel);
                make.top.equalTo(_subTitleLabel.mas_bottom).offset(kWidth(8));
                make.height.mas_equalTo(_descLabel.font.lineHeight);
            }];
            
            [_selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView).offset(kWidth(50));
                make.right.equalTo(self.contentView.mas_right).offset(-kWidth(40));
                make.size.mas_equalTo(CGSizeMake(kWidth(40), kWidth(40)));
            }];
        }
    }
    return self;
}

- (void)setPayPoint:(MSPayInfo *)payPoint {
    _payPoint = payPoint;
}

- (void)setPayPointLevel:(NSInteger)payPointLevel {
    MSPayInfo *info = nil;
    if (payPointLevel == 0) {
        if ([MSUtil currentVipLevel] == MSLevelVip0) {
            info = [MSSystemConfigModel defaultConfig].PAY_VIP_1_1;
        } else if ([MSUtil currentVipLevel] == MSLevelVip1) {
            info = [MSSystemConfigModel defaultConfig].PAY_VIP_2_1;
        }
    } else {
        if ([MSUtil currentVipLevel] == MSLevelVip0) {
            info = [MSSystemConfigModel defaultConfig].PAY_VIP_1_2;
        } else if ([MSUtil currentVipLevel] == MSLevelVip1) {
            info = [MSSystemConfigModel defaultConfig].PAY_VIP_2_2;
        }
    }
    if (_payPoint) {
        info = _payPoint;
    }
    if (info) {
        _price = info.price;
        _titleLabel.text = info.title;
        _priceLabel.text = [NSString stringWithFormat:@"¥%ld",(long)info.price/100];
        _unitPriceLabel.text = [NSString stringWithFormat:@"%.1f元/天",(float)info.price/100/info.days];
        _subTitleLabel.text = info.subTitle;
        _descLabel.text = info.desc;
    }
    if (_descLabel.text.length > 0) {
        [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(kWidth(6));
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [_selectedBtn setImage:[UIImage imageNamed:selected ? @"pay_selected" : @"pay_normal"] forState:UIControlStateNormal];
}

@end
