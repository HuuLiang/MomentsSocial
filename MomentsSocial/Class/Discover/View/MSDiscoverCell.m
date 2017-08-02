//
//  MSDiscoverCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDiscoverCell.h"

@interface MSDiscoverCell ()
@property (nonatomic) UIImageView *mainImgV;
@property (nonatomic) UILabel     *titleLabel;
@property (nonatomic) UILabel     *subTitleLabel;
@property (nonatomic) UILabel     *descLabel;
@property (nonatomic) UIButton    *joinButton;
@end

@implementation MSDiscoverCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.mainImgV = [[UIImageView alloc] init];
        _mainImgV.layer.cornerRadius = kWidth(12);
        _mainImgV.layer.masksToBounds = YES;
        [self.contentView addSubview:_mainImgV];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#333333");
        _titleLabel.font = kFont(16);
        [self.contentView addSubview:_titleLabel];
        
        self.subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.textColor = kColor(@"#999999");
        _subTitleLabel.font = kFont(12);
        [self.contentView addSubview:_subTitleLabel];
        
        self.descLabel = [[UILabel alloc] init];
        _descLabel.textColor = kColor(@"#999999");
        _descLabel.font = kFont(12);
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
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(self.contentView).offset(kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(140), kWidth(140)));
            }];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_mainImgV.mas_right).offset(kWidth(20));
                make.top.equalTo(self.contentView).offset(kWidth(30));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel);
                make.top.equalTo(_titleLabel.mas_bottom).offset(kWidth(20));
                make.height.mas_equalTo(_subTitleLabel.font.lineHeight);
            }];
            
            [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_subTitleLabel);
                make.top.equalTo(_subTitleLabel.mas_bottom).offset(kWidth(18));
                make.height.mas_equalTo(_descLabel.font.lineHeight);
            }];
            
            [_joinButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.right.equalTo(self.contentView.mas_right).offset(-kWidth(20));
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
    _subTitleLabel.text = subTitle;
}

- (void)setDescTitle:(NSString *)descTitle {
    _descLabel.text = descTitle;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIImage *backgroundImg = [_joinButton setGradientWithSize:_joinButton.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
    [_joinButton setBackgroundImage:backgroundImg forState:UIControlStateNormal];
}


@end
