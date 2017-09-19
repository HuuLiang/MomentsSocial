//
//  MSMyPortraitCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/9/16.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMyPortraitCell.h"

@interface MSMyPortraitCell ()
@property (nonatomic) UIImageView *imgV;
@end

@implementation MSMyPortraitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.imgV = [[UIImageView alloc] init];
        _imgV.layer.cornerRadius = 5;
        _imgV.layer.masksToBounds = YES;
        _imgV.userInteractionEnabled = YES;
        [self.contentView addSubview:_imgV];
        
        {
            [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(self.contentView).offset(kWidth(30));
                make.size.mas_equalTo(CGSizeMake(kWidth(140), kWidth(140)));
            }];
        }
        
    }
    return self;
}

- (void)setImgUrl:(NSString *)imgUrl {
    [_imgV sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"mine_portrait"]];
}

@end
