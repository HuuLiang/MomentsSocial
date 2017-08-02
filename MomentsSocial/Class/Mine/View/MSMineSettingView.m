//
//  MSMineSettingView.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMineSettingView.h"

@interface MSMineSettingView ()
@property (nonatomic) UIImageView *mainImgV;
@property (nonatomic) UILabel     *titleLabel;
@property (nonatomic) UIImageView *intoView;
@end

@implementation MSMineSettingView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        
        self.mainImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_setting"]];
        [self addSubview:_mainImgV];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#666666");
        _titleLabel.font = kFont(14);
        _titleLabel.text = @"设置";
        [self addSubview:_titleLabel];
        
        self.intoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_into"]];
        [self addSubview:_intoView];
        
        @weakify(self);
        [self bk_whenTapped:^{
            @strongify(self);
            if (self.settingAction) {
                self.settingAction();
            }
        }];
        
        {
            [_mainImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).offset(kWidth(30));
                make.size.mas_equalTo(CGSizeMake(kWidth(56), kWidth(56)));
            }];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(_mainImgV.mas_right).offset(kWidth(20));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_intoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.right.equalTo(self.mas_right).offset(-kWidth(30));
                make.size.mas_equalTo(CGSizeMake(kWidth(14), kWidth(26)));
            }];
        }
    }
    return self;
}

@end
