//
//  MSShakeUserView.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/7.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSShakeUserView.h"

@interface MSShakeUserView ()
@property (nonatomic) UIImageView *imgV;
@property (nonatomic) UILabel *ageLabel;
@property (nonatomic) UIButton *hateBtn;
@property (nonatomic) UIButton *loveBtn;
@end

@implementation MSShakeUserView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        self.backgroundColor = kColor(@"#ffffff");
        self.backgroundColor = [UIColor clearColor];
        
        self.imgV = [[UIImageView alloc] init];
        _imgV.layer.cornerRadius = kWidth(64);
        _imgV.layer.borderWidth = kWidth(2);
        _imgV.layer.borderColor = kColor(@"#f0f0f0").CGColor;
        _imgV.layer.masksToBounds = YES;
        [self addSubview:_imgV];
        
        self.ageLabel = [[UILabel alloc] init];
        _ageLabel.textColor = kColor(@"#ffffff");
        _ageLabel.font = kFont(15);
        _ageLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_ageLabel];
        
        self.hateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hateBtn setTitle:@"没感觉" forState:UIControlStateNormal];
        [_hateBtn setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _hateBtn.titleLabel.font = kFont(15);
        [_hateBtn setImage:[UIImage imageNamed:@"moment_noatt"] forState:UIControlStateNormal];
        [self addSubview:_hateBtn];
        
        self.loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loveBtn setTitle:@"有感觉" forState:UIControlStateNormal];
        [_loveBtn setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _loveBtn.titleLabel.font = kFont(15);
        [_loveBtn setImage:[UIImage imageNamed:@"moment_att"] forState:UIControlStateNormal];
        [self addSubview:_loveBtn];

        @weakify(self);
        [_hateBtn bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.hateAction) {
                self.hateAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        [_loveBtn bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.loveAction) {
                self.loveAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(kWidth(10));
                make.size.mas_equalTo(CGSizeMake(kWidth(128), kWidth(128)));
            }];
            
            [_ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_imgV.mas_bottom).offset(kWidth(20));
                make.height.mas_equalTo(_ageLabel.font.lineHeight);
            }];
            
            [_hateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_centerX).offset(-kWidth(40));
                make.bottom.equalTo(self.mas_bottom);
                make.size.mas_equalTo(CGSizeMake(kWidth(140), kWidth(160)));
            }];
            
            [_loveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.mas_centerX).offset(kWidth(40));
                make.centerY.equalTo(_hateBtn);
                make.size.mas_equalTo(CGSizeMake(kWidth(140), kWidth(160)));
            }];
            
        }
    }
    return self;
}

- (void)setImgUrl:(NSString *)imgUrl {
    [_imgV sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
}

- (void)setAge:(NSInteger)age {
    _ageLabel.text = [NSString stringWithFormat:@"年龄：%ld",(long)age];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [_hateBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:kWidth(24)];
    [_loveBtn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:kWidth(24)];
}

@end
