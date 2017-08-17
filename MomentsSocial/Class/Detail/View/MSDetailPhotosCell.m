//
//  MSDetailPhotosCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDetailPhotosCell.h"

@interface MSDetailPhotosCell ()
@property (nonatomic) UIImageView *imgVA;
@property (nonatomic) UIImageView *imgVB;
@property (nonatomic) UIImageView *imgVC;
@end

@implementation MSDetailPhotosCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.imgVA = [[UIImageView alloc] init];
//        _imgVA.backgroundColor = [UIColor blueColor];
        [self.contentView addSubview:_imgVA];
        
        self.imgVB = [[UIImageView alloc] init];
//        _imgVB.backgroundColor = [UIColor yellowColor];
        [self.contentView addSubview:_imgVB];
        
        self.imgVC = [[UIImageView alloc] init];
//        _imgVC.backgroundColor = [UIColor brownColor];
        [self.contentView addSubview:_imgVC];
        
        
        {
            [_imgVA mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView);
                make.left.equalTo(self.contentView).offset(kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kDetailPhotoWidth, kDetailPhotoWidth));
            }];
            
            [_imgVB mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView);
                make.left.equalTo(_imgVA.mas_right).offset(kWidth(10));
                make.size.mas_equalTo(CGSizeMake(kDetailPhotoWidth, kDetailPhotoWidth));
            }];
            
            [_imgVC mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView);
                make.left.equalTo(_imgVB.mas_right).offset(kWidth(10));
                make.size.mas_equalTo(CGSizeMake(kDetailPhotoWidth, kDetailPhotoWidth));
            }];
        }
        
    }
    return self;
}

- (void)setImgUrlA:(NSString *)imgUrlA {
    [_imgVA sd_setImageWithURL:[NSURL URLWithString:imgUrlA]];
}

- (void)setImgUrlB:(NSString *)imgUrlB {
    [_imgVB sd_setImageWithURL:[NSURL URLWithString:imgUrlB]];
}

- (void)setImgUrlC:(NSString *)imgUrlC {
    [_imgVC sd_setImageWithURL:[NSURL URLWithString:imgUrlC]];
}

@end
