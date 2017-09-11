//
//  MSPopupHelper.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/1.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSPopupHelper.h"
#import "MSMessageViewController.h"

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
        case MSPopupTypeChangeUserInfo:
            contentMsg = @"很抱歉，游客无法编辑个人资料";
            enterMsg = @"升级VIP";
            break;
            
        case MSPopupTypeSendMessage:
            contentMsg = @"很抱歉，该用户设置了防骚扰，只接受VIP信息";
            enterMsg = @"升级VIP";
            break;
            
        case MSPopupTypeUserDetailInfo:
            contentMsg = @"很抱歉，游客无法查看用户详细资料，成为VIP即可查案所有用户资料。";
            enterMsg = @"升级VIP";
            break;
            
        case MSPopupTypeRegisterVip0:
            contentMsg = @"很抱歉,为保证活动真实有效，游客身份无法报名。";
            enterMsg = @"升级VIP";
            break;
        
        case MSPopupTypeRegisterVip1:
            contentMsg = @"为提高开放质量，今日开房服务仅针对钻石VIP用户";
            enterMsg = @"钻石VIP";
            break;
            
        case MSPopupTypeShakeTime:
            contentMsg = @"游客每日只可摇一摇三次，升级VIP可无限摇";
            enterMsg = @"升级VIP";
            break;
            
        case MSPopupTypeCircleVip1:
            contentMsg = @"很抱歉，游客无法游览此区域。";
            enterMsg = @"升级VIP";
            break;
            
        case MSPopupTypeCircleVip2:
            contentMsg = @"此分类仅支持钻石VIP进入";
            enterMsg = @"钻石VIP";
            break;
        
        case MSPopupTypePostMoment:
            contentMsg = @"很抱歉，游客无法使用发帖功能";
            enterMsg = @"升级VIP";
            break;
        case MSPopupTypePhotoVip1:
            contentMsg = @"该用户设置，此照片不对游客展示。";
            enterMsg = @"升级VIP";
            break;
        case MSPopupTypePhotoVip2:
            contentMsg = @"该用户设置，此照片仅供钻石VIP观看。";
            enterMsg = @"升级VIP";
            break;
        case MSPopupTypeVideoVip1:
            contentMsg = @"该用户设置，此视频不对游客展示。";
            enterMsg = @"升级VIP";
            break;
        case MSPopupTypeVideoVip2:
            contentMsg = @"该用户设置，此视频仅供钻石VIP观看。";
            enterMsg = @"升级VIP";
            break;

        case MSPopupTypeFaceTime:
            contentMsg = @"很抱歉，游客无法视频聊天";
            enterMsg = @"升级VIP";
            break;
        
        case MSPopupTypeFaceTimeVip1:
            contentMsg = @"钻石VIP可发起视频聊天";
            enterMsg = @"钻石VIP";
            break;
        
        case MSPopupTypeMoreMoments:
            contentMsg = @"升级VIP,查看更多动态！";
            enterMsg = @"升级VIP";
            break;
            
        case MSPopupTypeSendComment:
            contentMsg = @"很抱歉,游客无法发表评论";
            enterMsg = @"升级VIP";
            break;

        case MSPopupTypeBookLuoVip1:
            contentMsg = @"很抱歉，游客无法游览此区域";
            enterMsg = @"升级VIP";
            break;
            
        case MSPopupTypeBookLuoVip2:
            contentMsg = @"功能升级中，正在招募，预计月底上线，敬请期待";
            enterMsg = @"期待ing";
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
    if (self.popView) {
        [self.popView removeFromSuperview];
        self.popView = nil;
    }
    
    self.popView = [[MSPopupView alloc] initWithMsg:msg dicCount:disCount cancleMsg:cancleMsg cancleAction:cancleAction confirmMsg:confirmMsg confirmAction:confirmAction hideAction:^{
        @strongify(self);
        [self.popView removeFromSuperview];
        self.popView = nil;
    }];
    
    UIViewController *baseViewController = [MSUtil rootViewControlelr];
    UIViewController *messageViewController = [MSUtil currentViewController];
    if ([messageViewController isKindOfClass:[MSMessageViewController class]]) {
        baseViewController = messageViewController;
    }
    [baseViewController.view addSubview:self.popView];
    [baseViewController.view bringSubviewToFront:self.popView];
    
    {
        [_popView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(baseViewController.view);
            make.size.mas_equalTo(CGSizeMake(kScreenWidth, kScreenHeight));
        }];
    }
}
@end


@interface MSPopupView ()
@property (nonatomic) UIImageView *backImgV;
@property (nonatomic) UIView *backView;
@property (nonatomic) UIView *shapeView;
@property (nonatomic) CAShapeLayer *shapeLayer;
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
        
        self.backImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pop_vip1"]];
        [self addSubview:_backImgV];
        
        self.backView = [[UIView alloc] init];
        _backView.backgroundColor = kColor(@"#ffffff");
        [self addSubview:_backView];
        
        self.shapeView = [[UIView alloc] init];
        _shapeView.backgroundColor = kColor(@"#ffffff");
        [_backView addSubview:_shapeView];
        
        self.msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = kColor(@"#ffffff");
        _msgLabel.font = kFont(15);
        _msgLabel.numberOfLines = 0;
        _msgLabel.text = msg;
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        [_backView addSubview:_msgLabel];

        self.cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancleBtn setTitle:cancleMsg forState:UIControlStateNormal];
        [_cancleBtn setTitleColor:kColor(@"#999999") forState:UIControlStateNormal];
        _cancleBtn.titleLabel.font = kFont(15);
        _cancleBtn.layer.borderWidth = 1;
        _cancleBtn.layer.borderColor = kColor(@"#dcdcdc").CGColor;
        [_backView addSubview:_cancleBtn];

        self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmBtn setTitle:confirmMsg forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:kColor(@"#ffffff") forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = kFont(15);
        _confirmBtn.backgroundColor = kColor(@"#7FB2ED");
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
            [_backImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).offset(kScreenHeight * 0.2);
                make.size.mas_equalTo(CGSizeMake(kWidth(340), kWidth(242)));
            }];
            
            [_backView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_backImgV.mas_bottom).offset(-kWidth(20));
                make.size.mas_equalTo(CGSizeMake(kWidth(560), kWidth(280)));
            }];
            
            [_shapeView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.right.equalTo(_backView);
                make.height.mas_equalTo(kWidth(110));
            }];
            
            [_msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(_backView);
                make.top.equalTo(_backView).offset(kWidth(15));
                make.width.mas_equalTo(kWidth(520));
//                make.bottom.equalTo(_shapeView.mas_bottom);
//                make.edges.mas_equalTo(UIEdgeInsetsMake(kWidth(10), kWidth(10), kWidth(30), kWidth(10)));
            }];

            [_cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_backView).offset(kWidth(20));
                make.bottom.equalTo(_backView.mas_bottom).offset(-kWidth(40));
                make.size.mas_equalTo(CGSizeMake(kWidth(256), kWidth(76)));
            }];
            
            [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_backView.mas_right).offset(-kWidth(20));
                make.centerY.equalTo(_cancleBtn);
                make.size.mas_equalTo(CGSizeMake(kWidth(256), kWidth(76)));
            }];
            
            if (disCount) {
                [_disImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(_confirmBtn.mas_top).offset(0);
                    make.left.equalTo(_confirmBtn.mas_centerX).offset(0);
                    make.size.mas_equalTo(CGSizeMake(kWidth(100), kWidth(50)));
                }];
            }
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGFloat width = ceilf(_shapeView.frame.size.width);
    CGFloat height = kWidth(104);
    CGFloat amplitude = 2.0f;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 2;
    [path moveToPoint:CGPointMake(width, 0)];
    [path addLineToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(0, height)];
    
    CGFloat y = height;
    CGFloat ω = 70*M_PI/width;
    for (float x = 0.0f; x <= width; x++) {
        y = amplitude * sinf(ω * x) + height;
        [path addLineToPoint:CGPointMake(x, y)];
    }
    [path addLineToPoint:CGPointMake(width, 0)];
    [path closePath];
    
    UIImage *img = [self setGradientWithSize:CGSizeMake(width, kWidth(104)) Colors:@[kColor(@"#EF6FB0"),kColor(@"#ED465C")] direction:leftToRight];
    
    self.shapeLayer = [CAShapeLayer layer];
    _shapeLayer.borderWidth = 2;
    _shapeLayer.fillColor = [UIColor colorWithPatternImage:img].CGColor;
    _shapeLayer.path = path.CGPath;
    [_shapeView.layer addSublayer:_shapeLayer];
    
    [self bringSubviewToFront:_msgLabel];
}

@end

