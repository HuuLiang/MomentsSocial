//
//  MSDetailFooterView.m
//  MomentsSocial
//
//  Created by Liang on 2017/7/28.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSDetailFooterView.h"

@interface MSDetailFooterView ()
@property (nonatomic) UIButton *sendMsgButton;
@property (nonatomic) UIButton *faceButton;
@end

@implementation MSDetailFooterView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor = kColor(@"#f0f0f0");
        
        self.sendMsgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendMsgButton setTitle:@"发消息" forState:UIControlStateNormal];
        [_sendMsgButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _sendMsgButton.titleLabel.font = kFont(14);
        _sendMsgButton.layer.cornerRadius = kWidth(6);
        _sendMsgButton.layer.masksToBounds = YES;
        [self addSubview:_sendMsgButton];
        
        self.faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_faceButton setTitle:@"视频聊天" forState:UIControlStateNormal];
        [_faceButton setTitleColor:kColor(@"#ED465D") forState:UIControlStateNormal];
        _faceButton.titleLabel.font = kFont(14);
        _faceButton.layer.cornerRadius = kWidth(6);
        _faceButton.layer.borderWidth = 1.0f;
        _faceButton.layer.borderColor = kColor(@"#ED465D").CGColor;
        _faceButton.layer.masksToBounds = YES;
        [self addSubview:_faceButton];
        
        @weakify(self);
        [_sendMsgButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.sendMsgAction) {
                self.sendMsgAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        [_faceButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            if (self.faceAction) {
                self.faceAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            [_sendMsgButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(kWidth(54));
                make.size.mas_equalTo(CGSizeMake(kWidth(580), kWidth(68)));
            }];
            
            [_faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_sendMsgButton.mas_bottom).offset(kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(580), kWidth(68)));
            }];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIImage *backgroundImg = [_sendMsgButton setGradientWithSize:_sendMsgButton.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
    [_sendMsgButton setBackgroundImage:backgroundImg forState:UIControlStateNormal];
}

@end
