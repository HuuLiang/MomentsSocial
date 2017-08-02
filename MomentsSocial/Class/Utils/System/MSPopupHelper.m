//
//  MSPopupHelper.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/1.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSPopupHelper.h"

@interface MSPopupHelper ()
@property (nonatomic) MSPopupView *popView;
@end

@implementation MSPopupHelper

+ (instancetype)helper {
    static MSPopupHelper *_helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [[MSPopupHelper alloc] init];
    });
    return _helper;
}

- (void)showPopupViewWithType:(MSPopupType)type disCount:(BOOL)disCount cancleAction:(CancleAction)cancleAction confirmAction:(ConfirmAction)confirmAction {
    NSString *contentMsg = @"";
    NSString *enterMsg = @"";
    
    switch (type) {
        case MSPopupTypePhoto:
            contentMsg = @"该用户设置：此照片不对用户展示";
            enterMsg = @"升级VIP";
            break;
            
        case MSPopupTypePostMsg:
            contentMsg = @"很抱歉，游客无法使用发帖功能";
            enterMsg = @"升级VIP";
            break;
            
        default:
            break;
    }
    
    [self showPopupViewWithMessage:contentMsg disCount:disCount cancleMsg:@"再看看" cancleAction:cancleAction confirmMsg:enterMsg confirmAction:confirmAction];
}

- (void)showPopupViewWithMessage:(NSString *)msg
                        disCount:(BOOL)disCount
                       cancleMsg:(NSString *)cancleMsg cancleAction:(CancleAction)cancleAction
                      confirmMsg:(NSString *)confirmMsg confirmAction:(ConfirmAction)confirmAction
{
    @weakify(self);
    self.popView = [[MSPopupView alloc] initWithMsg:msg dicCount:disCount cancleMsg:cancleMsg cancleAction:cancleAction confirmMsg:confirmMsg confirmAction:confirmAction hideAction:^{
        @strongify(self);
        [self.popView removeFromSuperview];
        self.popView = nil;
    }];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.popView];
    
    {
        [_popView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo([UIApplication sharedApplication].keyWindow.rootViewController.view);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth, kScreenHeight));
        }];
    }
}
@end


@interface MSPopupView ()
@property (nonatomic) UIView *backView;
@property (nonatomic) UILabel *msgLabel;
@property (nonatomic) UIImageView *disImgV;
@property (nonatomic) UIButton *cancleBtn;
@property (nonatomic) UIButton *confirmBtn;
@end

@implementation MSPopupView

- (instancetype)initWithMsg:(NSString *)msg
                   dicCount:(BOOL)disCount
                  cancleMsg:(NSString *)cancleMsg
               cancleAction:(CancleAction)cancleAction
                 confirmMsg:(NSString *)confirmMsg
              confirmAction:(ConfirmAction)confirmAction hideAction:(void (^)(void))hideAction

{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [kColor(@"#000000") colorWithAlphaComponent:0.6];
        
        self.backView = [[UIView alloc] init];
        _backView.backgroundColor = kColor(@"#ffffff");
        _backView.layer.cornerRadius = 5;
        _backView.layer.masksToBounds = YES;
        [self addSubview:_backView];
        
        self.msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = kColor(@"#333333");
        _msgLabel.font = kFont(15);
        _msgLabel.numberOfLines = 0;
        _msgLabel.text = msg;
        [_backView addSubview:_msgLabel];
        
        self.cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancleBtn setTitle:cancleMsg forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:kColor(@"#cccccc") forState:UIControlStateNormal];
        _cancleBtn.titleLabel.font = kFont(15);
        _cancleBtn.layer.borderWidth = 1;
        _cancleBtn.layer.borderColor = kColor(@"#e6e6e6").CGColor;
        [_backView addSubview:_cancleBtn];
        
        self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBtn setTitle:confirmMsg forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:kColor(@"#3584E0") forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = kFont(15);
        _confirmBtn.layer.borderWidth = 1;
        _confirmBtn.layer.borderColor = kColor(@"#e6e6e6").CGColor;
        [_backView addSubview:_confirmBtn];
        
        if (disCount) {
            self.disImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"discount"]];
            [_backView addSubview:_disImgV];
        }
        
        [_cancleBtn bk_addEventHandler:^(id sender) {
            if (hideAction) {
                hideAction();
            }
            if (cancleAction) {
                cancleAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        [_confirmBtn bk_addEventHandler:^(id sender) {
            if (hideAction) {
                hideAction();
            }
            if (confirmAction) {
                confirmAction();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        {
            [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
                make.size.mas_equalTo(CGSizeMake(kWidth(490), kWidth(274)));
            }];
            
            [_msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_backView).offset(kWidth(50));
                make.centerX.equalTo(_backView);
                make.width.mas_equalTo(kWidth(400));
            }];
            
            [_cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.equalTo(_backView);
                make.size.mas_equalTo(CGSizeMake(kWidth(245), kWidth(80)));
            }];
            
            [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.bottom.equalTo(_backView);
                make.size.mas_equalTo(CGSizeMake(kWidth(245), kWidth(80)));
            }];
            
            if (disCount) {
                [_disImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(_backView.mas_right).offset(-kWidth(50));
                    make.bottom.equalTo(_backView.mas_bottom).offset(-kWidth(70));
                    make.size.mas_equalTo(CGSizeMake(kWidth(100), kWidth(50)));
                }];
            }
        }
    }
    return self;
}


@end

