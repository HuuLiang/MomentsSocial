//
//  MSGreetView.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/27.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSGreetView.h"

@interface MSGreetView ()
@property (nonatomic) UIImageView *imgV;
@property (nonatomic) UILabel     *label;
@end

@implementation MSGreetView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        
        self.imgV = [[UIImageView alloc] init];
        [self addSubview:_imgV];
        
        self.label = [[UILabel alloc] init];
        _label.textColor = kColor(@"#999999");
        _label.font = kFont(11);
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        {
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kWidth(32), kWidth(30)));
            }];
            
            [_label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(self.mas_bottom);
                make.height.mas_equalTo(_label.font.lineHeight);
            }];
        }
    }
    return self;
}

- (void)setIsGreeted:(BOOL)isGreeted {
    _isGreeted = isGreeted;
    _imgV.image = [UIImage imageNamed:isGreeted ? @"near_greeted" : @"near_greet"];
    _label.text = isGreeted ? @"已打招呼" : @"打招呼";
}

@end
