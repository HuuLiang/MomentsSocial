//
//  MSCheckInUserCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/4.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSCheckInUserCell.h"

@interface MSCheckInUserCell ()
@property (nonatomic) UIImageView *imgV;
//@property (nonatomic) UILabel *distanceLabel;
@property (nonatomic) UILabel *nickLabel;
@property (nonatomic) UILabel *ageLabel;
@property (nonatomic) UIImageView *sexImgV;
@end

@implementation MSCheckInUserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.imgV = [[UIImageView alloc] init];
        [self.contentView addSubview:_imgV];
        
//        self.distanceLabel = [[UILabel alloc] init];
//        _distanceLabel.textColor = kColor(@"#ffffff");
//        _distanceLabel.font = kFont(12);
//        _distanceLabel.textAlignment = NSTextAlignmentRight;
//        [self.contentView addSubview:_distanceLabel];
        
        self.nickLabel = [[UILabel alloc] init];
        _nickLabel.textColor = kColor(@"#333333");
        _nickLabel.font = kFont(12);
        [self.contentView addSubview:_nickLabel];
        
        self.ageLabel = [[UILabel alloc] init];
        _ageLabel.textColor = kColor(@"#999999");
        _ageLabel.font = kFont(12);
        [self.contentView addSubview:_ageLabel];
        
        self.sexImgV = [[UIImageView alloc] init];
        [self.contentView addSubview:_sexImgV];
        
        {
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.top.equalTo(self.contentView);
                make.height.mas_equalTo(frame.size.width);
            }];
            
//            [_distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.right.equalTo(_imgV.mas_right);
//                make.bottom.equalTo(_imgV.mas_bottom);
//                make.height.mas_equalTo(_distanceLabel.font.lineHeight);
//            }];
            
            [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView.mas_bottom);
                make.left.equalTo(self.contentView);
                make.height.mas_equalTo(_nickLabel.font.lineHeight);
                make.right.mas_lessThanOrEqualTo(self.mas_right).offset(-frame.size.width*0.4);
            }];
            
            [_ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_nickLabel);
                make.left.equalTo(_nickLabel.mas_right).offset(kWidth(12));
                make.height.mas_equalTo(_ageLabel.font.lineHeight);
            }];
            
            [_sexImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_ageLabel);
                make.left.equalTo(_ageLabel.mas_right).offset(kWidth(12));
                make.size.mas_equalTo(CGSizeMake(kWidth(24), kWidth(24)));
            }];
        }
    }
    return self;
}

- (void)setImgUrl:(NSString *)imgUrl {
    [_imgV sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
}

//- (void)setDistance:(NSInteger)distance {
//    _distanceLabel.text = [NSString stringWithFormat:@"%ldkm内",(long)distance];
//}

- (void)setNickName:(NSString *)nickName {
    _nickLabel.text = nickName;
}

- (void)setAge:(NSInteger)age {
    _ageLabel.text = [NSString stringWithFormat:@"%ld岁",(long)age];
}

- (void)setSex:(NSString *)sex {
    if ([sex isEqualToString:@"男"]) {
        _sexImgV.image = [UIImage imageNamed:@"near_male"];
    } else if ([sex isEqualToString:@"女"]) {
        _sexImgV.image = [UIImage imageNamed:@"near_female"];
    }
}


@end
