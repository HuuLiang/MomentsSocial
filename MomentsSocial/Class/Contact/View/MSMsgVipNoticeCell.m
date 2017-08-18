//
//  MSMsgVipNoticeCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/18.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSMsgVipNoticeCell.h"

@interface MSMsgVipNoticeCell ()
@property (nonatomic) UILabel *label;
@property (nonatomic) UILabel *payLabel;
@end

@implementation MSMsgVipNoticeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        NSString *allStr = @"您不是vip，当前用户无法接受到您的信息哦，点此开通。";
        NSString *subStr = @"点此开通。";
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:allStr
                                                                                     attributes:@{NSForegroundColorAttributeName:kColor(@"#999999"),NSFontAttributeName:kFont(13)}];
        [attriStr addAttributes:@{NSForegroundColorAttributeName:kColor(@"#5AC8FA"),NSFontAttributeName:kFont(13)} range:[allStr rangeOfString:subStr]];
        self.label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.attributedText = attriStr;
        _label.userInteractionEnabled = YES;
        [self.contentView addSubview:_label];
        
        {
            [_label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.contentView);
                make.height.mas_equalTo(kFont(13).lineHeight);
            }];
        }
        
        @weakify(self);
        [_label bk_whenTapped:^{
            @strongify(self);
            if (self.noticeAction) {
                self.noticeAction();
            }
        }];
    }
    return self;
}


@end
