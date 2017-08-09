//
//  MSPayDescCell.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/9.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSPayDescCell.h"

@interface MSPayDescCell ()
@property (nonatomic) UILabel *descLabel;
@property (nonatomic) UIButton *payButton;
@end

@implementation MSPayDescCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = kColor(@"#ffffff");
        self.contentView.backgroundColor = kColor(@"#ffffff");
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.descLabel = [[UILabel alloc] init];
        _descLabel.textColor = kColor(@"#666666");
        _descLabel.font = kFont(14);
        _descLabel.numberOfLines = 0;
        _descLabel.backgroundColor = kColor(@"#efefef");
        _descLabel.text = @"亲爱的用户，您的支付过程中，有任何疑惑或者疑难，欢迎在线咨询，客服妹妹会在第一时间回复并帮助解决您的问题。";
        [self.contentView addSubview:_descLabel];
        
        self.payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_payButton setTitle:@"QQ客服" forState:UIControlStateNormal];
        [_payButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _payButton.titleLabel.font = kFont(15);
        [self.contentView addSubview:_payButton];
        
        @weakify(self);
        [_payButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.payAction) {
                self.payAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            CGFloat height = [_descLabel.text sizeWithFont:kFont(14) maxWidth:kWidth(710)].height;
            
            [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.contentView);
                make.top.equalTo(self.contentView).offset(kWidth(26));
                make.width.mas_equalTo(kWidth(710));
                make.height.mas_equalTo(height+kWidth(20));
            }];
            
            [_payButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.contentView);
                make.top.equalTo(_descLabel.mas_bottom).offset(kWidth(32));
                make.size.mas_equalTo(CGSizeMake(kWidth(710), kWidth(80)));
            }];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIImage *img = [_payButton setGradientWithSize:_payButton.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
    [_payButton setBackgroundImage:img forState:UIControlStateNormal];
}

@end
