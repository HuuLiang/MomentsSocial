//
//  MSPaymentManager.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSPaymentManager.h"
#import "AlipayManager.h"
#import "WeChatPayManager.h"

@interface MSPaymentManager ()
@property (nonatomic) MSLevel targetLevel;
@property (nonatomic) PayResult payResult;
@end

@implementation MSPaymentManager

+ (instancetype)manager {
    static MSPaymentManager *_paymentManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _paymentManager = [[MSPaymentManager alloc] init];
    });
    return _paymentManager;
}

- (void)startPayForVipLevel:(MSLevel)vipLevel type:(MSPayType)payType  price:(NSInteger)price handler:(PayResult)handler {
    _payResult = handler;
    _targetLevel = vipLevel;
    
#ifdef DEBUG
    price = 1;
#endif
    
    if (payType == MSPayTypeWeiXin) {
        [[WeChatPayManager sharedInstance] startWeChatPayWithOrderNo:MS_PAYMENT_ORDERID
                                                               price:price
                                                   completionHandler:^(MSPayResult result)
         {
             [self commitPayResult:result handler:handler];
         }];
    } else if (payType == MSPayTypeAliPay) {
        [[AlipayManager shareInstance] startAlipay:MS_PAYMENT_ORDERID
                                             price:price
                                        withResult:^(MSPayResult result, Order *order)
         {
             [self commitPayResult:result handler:handler];
         }];
    }
}

- (void)commitPayResult:(MSPayResult)payResult handler:(PayResult)hander {
    if (payResult == MSPayResultSuccess) {
        [MSUtil setVipLevel:self.targetLevel];
        [[MSHudManager manager] showHudWithText:@"支付成功"];
    } else if (payResult == MSPayResultFailed) {
        [[MSHudManager manager] showHudWithText:@"支付失败"];
    } else if (payResult == MSPayResultCancle) {
        [[MSHudManager manager] showHudWithText:@"支付取消"];
    }
    hander(payResult == MSPayResultSuccess);
}

@end
