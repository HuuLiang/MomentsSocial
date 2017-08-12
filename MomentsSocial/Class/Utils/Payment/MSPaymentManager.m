//
//  MSPaymentManager.m
//  MomentsSocial
//
//  Created by Liang on 2017/8/8.
//  Copyright © 2017年 Liang. All rights reserved.
//

#import "MSPaymentManager.h"
#import <WXApi.h>
#import <WXApiObject.h>
#import <QBPaymentManager.h>
#import <QBPaymentConfiguration.h>

@interface MSPaymentManager () <WXApiDelegate>
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

- (void)setup {
//    [WXApi registerApp:YFB_WEXIN_APP_ID];
    [[QBPaymentManager sharedManager] registerPaymentWithSettings:@{kQBPaymentSettingAppId:MS_REST_APPID,
                                                                    kQBPaymentSettingPv:@(MS_REST_PV.integerValue),
                                                                    kQBPaymentSettingChannelNo:MS_CHANNEL_NO,
                                                                    kQBPaymentSettingUrlScheme:MS_AliPay_SchemeUrl,
                                                                    kQBPaymentSettingDefaultConfig:[self defaultConfiguration]}];
}

- (QBPaymentConfiguration *)defaultConfiguration {
    QBPaymentConfigurationDetail *alipay = [[QBPaymentConfigurationDetail alloc] init];
    alipay.type = @(1001);
    alipay.config = @{@"appId":@"2015121000955429",
                      @"privateKey":@"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKxJu4mHp7puorftVMcIhUU4qdQRalHFyp7/yXOKYJ2dv6+9xtZWJVAedQfoWwfjBfGb7r9sOVjG8otwi/1+pwu4u9BpdQxfV5VkFclf/wjSLbe4191udy9UuFO2gXNGmN2GC7/28MeY8LGH9kcIEsTJI5iB1yz42grnnk+rYysvAgMBAAECgYBzgHrZmLg5pDIyXEmZpXyzC2nPYl2EtLVCIvlLHFnpUPhROUk0KEybic+rnXppryks8Pz+F+/aNIYmNS2kpGQXuZa9yLDyTzy38iqqHGtOUVBMDuHyvNM4qBepn065uhQqhA3O5IndSBUXNRMMovab7qdJdqLLMuPWAFBTAk6vAQJBAPrRQhC2+BsSbaZe1Tqv6PQK7uN4hK23zPVhy5xQ6YaeTtIIIkGK4j/1vnObiVqCE1HPryEUlhljaG6TJ2q9h/sCQQCv2RRo4Mne8Eb6e67uLj8GavUHEuQ6GAK/01oZ3H0FEmWK2kyuWuJyOxfwH3BbsYPw4FtQGCkcuAciHp9Jlj9dAkEApW8+7z1wGpMmJdVpOYNr2QQZG4qToO2Zz8RIg3tO/M8QWDKrPaX4o41YqHJPv5YKXizpa51jf6105XJEToBi3wJAM+KARCW3SqFov/WIetyIWhNq8shfMMju3ry0xBariLiR33Nj1roYQI4xFPehxlxNSuBX8Pz//GpMKIQSibrcPQJAaTHHXGWr5Qh5dgOjs9CspivZYeSlLDbHePFsRLzXeRbsQD/Xsh4a9n0n0tOnIUSn71HjYlX9bEF+3RwvDZlcPw==",
                      @"productInfo":@"atlas",
                      @"seller":@"wuyp@iqu8.cn",
                      @"notifyUrl":@"http://phas.rdgongcheng.cn/pd-has/notifyByAlipayNew.json",
                      @"partner":@""};
    
    QBPaymentConfigurationDetail *weixin = [[QBPaymentConfigurationDetail alloc] init];
    weixin.type = @(1008);
    weixin.config = @{@"appId":@"wx633c4131be881cb1",
                      @"signKey":@"201hdaldie999900djw01dl458575580",
                      @"mchId":@"1319692301",
                      @"notifyUrl":@"http://phas.rdgongcheng.cn/pd-has/notifyWx.json"};
    
    QBPaymentConfiguration *configuration = [[QBPaymentConfiguration alloc] init];
    configuration.weixin = weixin;
    configuration.alipay = alipay;
    return configuration;
}

- (void)startPayForVipLevel:(MSLevel)vipLevel type:(MSPayType)payType  price:(NSInteger)price handler:(PayResult)handler {
    _payResult = handler;
    _targetLevel = vipLevel;
    
#ifdef DEBUG
    price = 1;
#endif
    
    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    
    QBOrderInfo *orderInfo = [[QBOrderInfo alloc] init];
    orderInfo.orderId = MS_PAYMENT_ORDERID;
    orderInfo.orderPrice = price;
    orderInfo.orderDescription = [NSString stringWithFormat:@"%@增值服务", appName];
    orderInfo.payType = payType + 1;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    orderInfo.createTime = [dateFormatter stringFromDate:[NSDate date]];
    orderInfo.userId = [NSString stringWithFormat:@"%ld",(long)[MSUtil currentUserId]];
    orderInfo.currentPayPointType = [MSUtil currentVipLevel];
    orderInfo.targetPayPointType = vipLevel;
    orderInfo.reservedData = MS_PAYMENT_RESERVE_DATA;
    
    
    [[QBPaymentManager sharedManager] payWithOrderInfo:orderInfo contentInfo:nil completionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
        NSDictionary *payResults = @{@(QBPayResultSuccess):@(MSPayResultSuccess),
                                     @(QBPayResultFailure):@(MSPayResultFailed),
                                     @(QBPayResultCancelled):@(MSPayResultCancle),
                                     @(QBPayResultUnknown):@(MSPayResultUnknow)};
        
        
        [self commitPayResult:[payResults[@(payResult)] integerValue] handler:handler];
    }];
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

- (void)handleOpenURL:(NSURL *)url {
    [[QBPaymentManager sharedManager] handleOpenUrl:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[QBPaymentManager sharedManager] applicationWillEnterForeground:application];
}

@end
