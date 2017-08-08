//
//  MSCommentCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/7.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSCommentCell.h"

@interface MSCommentCell ()
@property (nonatomic) UILabel *nickLabel;
@property (nonatomic) UILabel *contentLabel;
@end

@implementation MSCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.nickLabel = [[UILabel alloc] init];
        _nickLabel.textColor = kColor(@"#999999");
        _nickLabel.font = kFont(14);
        [self.contentView addSubview:_nickLabel];
        
        self.contentLabel = [[UILabel alloc] init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = kColor(@"#333333");
        _contentLabel.font = kFont(15);
        [self.contentView addSubview:_contentLabel];
        
        {
            [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(kWidth(30));
                make.top.equalTo(self.contentView).offset(kWidth(30));
                make.height.mas_equalTo(_nickLabel.font.lineHeight);
            }];
            
            [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(kWidth(30));
                make.top.equalTo(_nickLabel.mas_bottom).offset(kWidth(20));
                make.right.equalTo(self.contentView.mas_right).offset(-kWidth(30));
            }];
        }
    }
    return self;
}

- (void)setNickName:(NSString *)nickName {
    _nickLabel.text = nickName;
}

- (void)setContent:(NSString *)content {
    _contentLabel.text = content;
}


@end
