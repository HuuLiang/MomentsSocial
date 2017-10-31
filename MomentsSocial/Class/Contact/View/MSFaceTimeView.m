//
//  MSFaceTimeView.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/9.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSFaceTimeView.h"
#import "MSAutoReplyMessageManager.h"
#import "QBVoiceManager.h"
#import "MSBaseViewController.h"
#import "MSVipVC.h"

@interface MSFaceTimeView ()

@property (nonatomic) UIImageView *backImgV;
@property (nonatomic) UIView *shadowView;

@property (nonatomic) UIImageView *userImgV;
@property (nonatomic) UILabel *nickLabel;
@property (nonatomic) UILabel *descLabel;
@property (nonatomic) UIButton *refuseButton;
@property (nonatomic) UIButton *confirmButton;
@end

@implementation MSFaceTimeView

+ (void)showWithReplyMsgInfo:(MSAutoReplyMsg *)replyMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *baseViewController = [MSUtil rootViewControlelr];
        
       __block MSFaceTimeView *faceTimeView = [[MSFaceTimeView alloc] initWithReplyMsgInfo:replyMsg
                                                                       refuseAction:^{
                                                                           [faceTimeView cancelFaceTimeView];
                                                                       } confirmAction:^{
                                                                           [faceTimeView popVipView];
                                                                       }];
        faceTimeView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        [baseViewController.view addSubview:faceTimeView];
        [baseViewController.view bringSubviewToFront:faceTimeView];
    });
}

- (void)cancelFaceTimeView {
    [self removeFromSuperview];
}

- (void)popVipView {
    if ([MSUtil currentVipLevel] == MSLevelVip0) {
        [[MSPopupHelper helper] showPopupViewWithType:MSPopupTypeFaceTime disCount:YES cancleAction:^{
            [self cancelFaceTimeView];
        } confirmAction:^{
            [self cancelFaceTimeView];
            [MSVipVC showVipViewControllerInCurrentVC:[MSUtil rootViewControlelr] contentType:MSPopupTypeFaceTime];
        }];
    } else {
        [self cancelFaceTimeView];
        [[MSHudManager manager] showHudWithText:@"对方已挂断"];
    }
}

- (instancetype)initWithReplyMsgInfo:(MSAutoReplyMsg *)replyMsg refuseAction:(MSAction)refuseAction confirmAction:(MSAction)confirmAction {
    self = [super init];
    if (self) {
        
        self.backImgV = [[UIImageView alloc] init];
        _backImgV.userInteractionEnabled = YES;
        [_backImgV sd_setImageWithURL:[NSURL URLWithString:replyMsg.msgContent]];
        [self addSubview:_backImgV];
        
        self.shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor = [kColor(@"#1D1F26") colorWithAlphaComponent:0.88];
        [self addSubview:_shadowView];
        
        self.userImgV = [[UIImageView alloc] init];
        [_userImgV sd_setImageWithURL:[NSURL URLWithString:replyMsg.portraitUrl] placeholderImage:[UIImage imageNamed:@"default_Img"]];
        _userImgV.layer.cornerRadius = 5;
        _userImgV.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_userImgV];
        
        self.nickLabel = [[UILabel alloc] init];
        _nickLabel.text = replyMsg.nickName;
        _nickLabel.font = kFont(25);
        _nickLabel.textColor = kColor(@"#ffffff");
        [self addSubview:_nickLabel];
        
        self.descLabel = [[UILabel alloc] init];
        _descLabel.text = @"邀请你视频聊天";
        _descLabel.font = kFont(14);
        _descLabel.textColor = kColor(@"#ffffff");
        [self addSubview:_descLabel];
        
        self.refuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refuseButton setTitle:@"拒 绝" forState:UIControlStateNormal];
        [_refuseButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _refuseButton.titleLabel.font = kFont(12);
        [_refuseButton setImage:[UIImage imageNamed:@"facetime_refuse"] forState:UIControlStateNormal];
        [self addSubview:_refuseButton];
        
        [_refuseButton bk_addEventHandler:^(id sender) {
            [self stopPlayVoice];
            refuseAction();
        } forControlEvents:UIControlEventTouchUpInside];
        
        self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:@"接 听" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = kFont(12);
        [_confirmButton setImage:[UIImage imageNamed:@"facetime_answer"] forState:UIControlStateNormal];
        [self addSubview:_confirmButton];
        
        [_confirmButton bk_addEventHandler:^(id sender) {
            [self stopPlayVoice];
            confirmAction();
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            [_backImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            
            [_shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            
            [_userImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset(kWidth(76));
                make.left.equalTo(self).offset(30);
                make.size.mas_equalTo(CGSizeMake(kWidth(120), kWidth(120)));
            }];
            
            [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_userImgV);
                make.left.equalTo(_userImgV.mas_right).offset(kWidth(16));
                make.height.mas_equalTo(_nickLabel.font.lineHeight);
            }];
            
            [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_nickLabel);
                make.top.equalTo(_nickLabel.mas_bottom).offset(kWidth(12));
                make.height.mas_equalTo(_descLabel.font.lineHeight);
            }];
            
            [_refuseButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self).offset(kWidth(60));
                make.bottom.equalTo(self.mas_bottom).offset(-kWidth(40));
                make.size.mas_equalTo(CGSizeMake(kWidth(120), kWidth(250)));
            }];
            
            [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.mas_right).offset(-kWidth(60));
                make.bottom.equalTo(self.mas_bottom).offset(-kWidth(40));
                make.size.mas_equalTo(CGSizeMake(kWidth(120), kWidth(250)));
            }];
        }

        [self performSelector:@selector(startPlayVoice) withObject:nil afterDelay:1.];//延时1秒后开启声音
    }
    return self;
}

- (void)startPlayVoice {
    [[QBVoiceManager manager] playFaceTimeVoice];
}

- (void)stopPlayVoice {
    [[QBVoiceManager manager] endFaceTimeVoice];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [_refuseButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:kWidth(30)];
    [_confirmButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:kWidth(30)];
}

@end
