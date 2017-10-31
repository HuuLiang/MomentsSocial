//
//  MSContactView.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/9.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSContactView.h"
#import "MSAutoReplyMessageManager.h"
#import "MSMessageViewController.h"
#import "MSContactViewController.h"

@interface MSContactView ()
@property (nonatomic) UIView *contentView;
@property (nonatomic) UIImageView *userImageV;
@property (nonatomic) UILabel *nickLabel;
@property (nonatomic) UILabel *contentLabel;
@property (nonatomic) UIButton *replyButton;
@end

@implementation MSContactView

+ (void)showWithReplyMsgInfo:(MSAutoReplyMsg *)replyMsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *baseViewController = [MSUtil rootViewControlelr];
        UIViewController *contactVC = [MSUtil currentViewController];
        if ([contactVC isKindOfClass:[MSContactViewController class]]) {
            return ;
        }
        MSContactView *contactView = [[MSContactView alloc] initWithReplyMsgInfo:replyMsg handler:^{
            [MSMessageViewController presentMessageWithUserId:replyMsg.userId nickName:replyMsg.nickName portraitUrl:replyMsg.portraitUrl inViewController:baseViewController];
        }];
        contactView.frame = CGRectMake(0, -kWidth(300), kScreenWidth, kWidth(300));
        [baseViewController.view addSubview:contactView];
        [baseViewController.view bringSubviewToFront:contactView];
    });
}

- (instancetype)initWithReplyMsgInfo:(MSAutoReplyMsg *)replyMsg handler:(MSAction)handler {
    self = [super init];
    if (self) {
        
        self.backgroundColor = [kColor(@"#000000") colorWithAlphaComponent:0.89];
        
        self.contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
        
        self.userImageV = [[UIImageView alloc] init];
        [_userImageV sd_setImageWithURL:[NSURL URLWithString:replyMsg.portraitUrl] placeholderImage:[UIImage imageNamed:@"default_Img"]];
        _userImageV.layer.cornerRadius = kWidth(45);
        _userImageV.layer.masksToBounds = YES;
        [_contentView addSubview:_userImageV];
        
        self.nickLabel = [[UILabel alloc] init];
        _nickLabel.text = replyMsg.nickName;
        _nickLabel.font = kFont(14);
        _nickLabel.textColor = kColor(@"#ffffff");
        [_contentView addSubview:_nickLabel];

        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = kColor(@"#ffffff");
        _contentLabel.font = kFont(13);
        _contentLabel.numberOfLines = 0;
        if (replyMsg.msgType == MSMessageTypeText) {
            _contentLabel.text = replyMsg.msgContent;
        } else if (replyMsg.msgType == MSMessageTypePhoto) {
            _contentLabel.text = @"【图片】";
        } else if (replyMsg.msgType == MSMessageTypeVoice) {
            _contentLabel.text = @"【语音】";
        } else if (replyMsg.msgType == MSMessageTypeVideo) {
            _contentLabel.text = @"【视频】";
        }
        [_contentView addSubview:_contentLabel];
        
        self.replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_replyButton setTitle:@"查看" forState:UIControlStateNormal];
        [_replyButton setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _replyButton.titleLabel.font = kFont(14);
        _replyButton.backgroundColor = kColor(@"#FF7474");
        _replyButton.layer.cornerRadius = 5;
        _replyButton.layer.masksToBounds = YES;
        [_contentView addSubview:_replyButton];
        
        [_replyButton bk_addEventHandler:^(id sender) {
            handler();
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.equalTo(self);
                make.height.mas_equalTo(kWidth(160));
            }];
            
            [_userImageV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(_contentView.mas_bottom).offset(-kWidth(34));
                make.left.equalTo(_contentView).offset(kWidth(30));
                make.size.mas_equalTo(CGSizeMake(kWidth(90), kWidth(90)));
            }];
            
            [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_userImageV.mas_right).offset(kWidth(22));
                make.top.equalTo(_userImageV.mas_top).offset(kWidth(10));
                make.height.mas_equalTo(kWidth(28));
            }];
            
            [_replyButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(_contentView.mas_bottom).offset(-kWidth(50));
                make.right.equalTo(_contentView.mas_right).offset(-kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(120), kWidth(60)));
            }];
            
            [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_userImageV.mas_right).offset(kWidth(22));
                make.top.equalTo(_nickLabel.mas_bottom).offset(kWidth(16));
                make.right.equalTo(_replyButton.mas_left).offset(-kWidth(20));
                make.height.mas_equalTo(kWidth(60));
            }];
        }
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(moveUpAnimation)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
        [self addGestureRecognizer:recognizer];
        
        
        [self downAnimation];
        
        [self performSelector:@selector(moveUpAnimation) withObject:nil afterDelay:4];

    }
    return self;
}

- (void)moveUpAnimation {
    if (self.superview) {
        [self upAnimation];
        
        [self performSelector:@selector(removeContactView) withObject:nil afterDelay:2];
    }
}

- (void)removeContactView {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)dealloc {
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIImage *img = [_replyButton setGradientWithSize:_replyButton.size Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
    [_replyButton setBackgroundImage:img forState:UIControlStateNormal];
}

@end
