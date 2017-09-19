//
//  MSDetailInfoCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDetailInfoCell.h"

@interface MSDetailInfoCell ()

@property (nonatomic) UILabel *titleLabel;

@property (nonatomic) UILabel *contentLabel;

@end

@implementation MSDetailInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.backgroundColor = kColor(@"#fffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#333333");
        _titleLabel.font = kFont(15);
        [self.contentView addSubview:_titleLabel];
        
        self.contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = kColor(@"#999999");
        _contentLabel.font = kFont(15);
        [self.contentView addSubview:_contentLabel];
        
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(self.contentView).offset(kWidth(30));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.right.equalTo(self.contentView.mas_right).offset(-kWidth(30));
                make.height.mas_equalTo(_contentLabel.font.lineHeight);
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setContent:(NSString *)content {
    if (content.length == 0 || !content) {
        _contentLabel.text = @"未填写";
    } else {
        _contentLabel.text = content;
    }
}

@end
