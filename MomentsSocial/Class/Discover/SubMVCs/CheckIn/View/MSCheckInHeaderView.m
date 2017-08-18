//
//  MSCheckInHeaderView.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/3.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSCheckInHeaderView.h"

@interface MSCheckInHeaderView ()
@property (nonatomic) UIImageView *imgV;
@property (nonatomic) UILabel     *titleLabel;
@property (nonatomic) UILabel     *subLabel;
@property (nonatomic) UIButton    *registerBtn;
@property (nonatomic) UILabel     *descLabel;

@property (nonatomic) UILabel         *label;
@property (nonatomic) UIImageView     *leftLine;
@property (nonatomic) UIImageView     *rightLine;
@end

@implementation MSCheckInHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = kColor(@"#f0f0f0");
        backView.layer.cornerRadius = kWidth(56);
        backView.layer.masksToBounds = YES;
        [self addSubview:backView];
        
        self.imgV = [[UIImageView alloc] init];
        _imgV.layer.cornerRadius = kWidth(52);
        _imgV.layer.masksToBounds = YES;
        [backView addSubview:_imgV];
        
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = kColor(@"#333333");
        _titleLabel.font = kFont(15);
        _titleLabel.text = @"今夜开房";
        [self addSubview:_titleLabel];
        
        self.subLabel = [[UILabel alloc] init];
        _subLabel.textColor = kColor(@"#666666");
        _subLabel.font = kFont(12);
        _subLabel.text = @"每日20点截止当天报名";
        [self addSubview:_subLabel];
        
        self.registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerBtn setTitle:@"点击报名" forState:UIControlStateNormal];
        [_registerBtn setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _registerBtn.titleLabel.font = kFont(14);
        _registerBtn.layer.cornerRadius = kWidth(30);
        _registerBtn.layer.masksToBounds = YES;
        [self addSubview:_registerBtn];
        
        @weakify(self);
        [_registerBtn bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.registerAction) {
                self.registerAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        self.descLabel = [[UILabel alloc] init];
        _descLabel.textColor = kColor(@"#666666");
        _descLabel.font = kFont(13);
        _descLabel.numberOfLines = 0;
        _descLabel.text = @"如果，你今晚想开房爱爱，点击上方“点击报名”即可，每日同城限报30人，早上8点开始报名，晚上20点结束报名。报名结束后即可开启开房攻略。零点清除上一日报名数据。报名后不参加开放活动，24小时内无法再次报名。";
        [self addSubview:_descLabel];
        
        self.label = [[UILabel alloc] init];
        _label.textColor = kColor(@"#333333");
        _label.font = kFont(16);
        [self addSubview:_label];
        
        self.leftLine = [[UIImageView alloc] init];
        _leftLine.backgroundColor = kColor(@"#DCDCDC");
        [self addSubview:_leftLine];
        
        self.rightLine = [[UIImageView alloc] init];
        _rightLine.backgroundColor = kColor(@"#DCDCDC");
        [self addSubview:_rightLine];
        
        
        {
            [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(kWidth(20));
                make.top.equalTo(self).offset(kWidth(22));
                make.size.mas_equalTo(CGSizeMake(kWidth(112), kWidth(112)));
            }];
            
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(backView);
                make.size.mas_equalTo(CGSizeMake(kWidth(104), kWidth(104)));
            }];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imgV.mas_right).offset(kWidth(12));
                make.top.equalTo(self).offset(kWidth(36));
                make.height.mas_equalTo(_titleLabel.font.lineHeight);
            }];
            
            [_subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_titleLabel);
                make.top.equalTo(_titleLabel.mas_bottom).offset(kWidth(12));
                make.height.mas_equalTo(_subLabel.font.lineHeight);
            }];
            
            [_registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_imgV);
                make.right.equalTo(self.mas_right).offset(-kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(180), kWidth(60)));
            }];
            
            [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_imgV.mas_bottom).offset(kWidth(28));
                make.centerX.equalTo(self);
                make.width.mas_equalTo(kWidth(690));
            }];
            
            [_label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.bottom.equalTo(self);
                make.height.mas_equalTo(_label.font.lineHeight);
            }];
            
            [_leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_label);
                make.right.equalTo(_label.mas_left).offset(-kWidth(24));
                make.left.equalTo(self).offset(kWidth(20));
                make.height.mas_equalTo(1);
            }];
            
            [_rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_label);
                make.left.equalTo(_label.mas_right).offset(kWidth(24));
                make.right.equalTo(self.mas_right).offset(-kWidth(20));
                make.height.mas_equalTo(1);
            }];
        }
    }
    return self;
}

- (void)setImgUrl:(NSString *)imgUrl {
    [_imgV sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
}

- (void)setCanCheckIn:(BOOL)canCheckIn {
    if (canCheckIn) {
        _label.text = @"已经报名";
    } else {
        _label.text = @"现在是啪啪时间 请在8到20点报名";
    }
    _leftLine.hidden = !canCheckIn;
    _rightLine.hidden = !canCheckIn;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIImage *backgroundImg = [_registerBtn setGradientWithSize:_registerBtn.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
    [_registerBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
}

@end
