//
//  MSDetailSectionHeaderView.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDetailSectionHeaderView.h"

@interface MSDetailSectionHeaderView ()
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UIButton *intoButton;
@end

@implementation MSDetailSectionHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#333333");
        _titleLabel.font = kFont(15);
        [self addSubview:_titleLabel];
        
        self.intoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_intoButton setTitleColor:kColor(@"#999999") forState:UIControlStateNormal];
        _intoButton.titleLabel.font = kFont(14);
        [_intoButton setImage:[UIImage imageNamed:@"mine_into"] forState:UIControlStateNormal];
        [self addSubview:_intoButton];
        
        @weakify(self);
        [_intoButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.intoAction) {
                self.intoAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        [self bk_whenTapped:^{
            @strongify(self);
            if (self.intoAction) {
                self.intoAction();
            }
        }];
        
        
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).offset(kWidth(20));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_intoButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.right.equalTo(self.mas_right).offset(-kWidth(22));
                make.size.mas_equalTo(CGSizeMake(kWidth(80), kWidth(30)));
            }];
        }
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    [_intoButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [_intoButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:kWidth(8)];
}

@end
