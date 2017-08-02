//
//  MSDetailInfoHeaderView.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/31.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDetailInfoHeaderView.h"

@interface MSDetailInfoHeaderView ()
@property (nonatomic) UILabel *titleLabel;
@end

@implementation MSDetailInfoHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#999999");
        _titleLabel.font = kFont(15);
        [self addSubview:_titleLabel];
        
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).offset(kWidth(30));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
        }
        
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

@end
