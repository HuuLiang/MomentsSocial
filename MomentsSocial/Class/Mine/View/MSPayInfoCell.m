//
//  MSPayInfoCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/9.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSPayInfoCell.h"
#import "MSSystemConfigModel.h"

@interface MSPayInfoCell ()
@property (nonatomic) UILabel *titleLabel;;
@property (nonatomic) UILabel *infoLabel;
@end

@implementation MSPayInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#666666");
        _titleLabel.font = kFont(15);
        _titleLabel.text = @"订单信息：";
        [self.contentView addSubview:_titleLabel];
        
        self.infoLabel = [[UILabel alloc] init];
        _infoLabel.textColor = kColor(@"#666666");
        _infoLabel.font = kFont(15);
        [self.contentView addSubview:_infoLabel];
        
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(self.contentView).offset(kWidth(30));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(_titleLabel.mas_right).offset(kWidth(10));
                make.height.mas_equalTo(_infoLabel.font.lineHeight);
            }];
        }
    }
    return self;
}

- (void)setPayForLevel:(MSLevel)payForLevel {
    if (payForLevel == MSLevelVip1) {
        _infoLabel.text = [NSString stringWithFormat:@"升级到VIP1，价格：%ld元",(long)[MSSystemConfigModel defaultConfig].config.PAY_AMOUNT_1/100];
    } else if (payForLevel == MSLevelVip2) {
        _infoLabel.text = [NSString stringWithFormat:@"升级到VIP2，价格：%ld元",(long)[MSSystemConfigModel defaultConfig].config.PAY_AMOUNT_2/100];
    }
}

@end
