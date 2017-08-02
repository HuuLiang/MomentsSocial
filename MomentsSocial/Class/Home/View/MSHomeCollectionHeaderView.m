//
//  MSHomeCollectionHeaderView.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSHomeCollectionHeaderView.h"

@interface MSHomeCollectionHeaderView ()
@property (nonatomic) UILabel *titleLabel;
@end

@implementation MSHomeCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kColor(@"#ffffff");
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#333333");
        _titleLabel.font = kFont(16);
        [self addSubview:_titleLabel];
        
        {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).offset(kWidth(20));
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
