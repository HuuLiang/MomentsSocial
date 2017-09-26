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
#import "MSSystemConfigModel.h"
#import <QBPaymentInfo.h>

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
                                                                    kQBPaymentSettingPv:@(MS_PAYMENT_PV.integerValue),
                                                                    kQBPaymentSettingChannelNo:MS_CHANNEL_NO,
                                                                    kQBPaymentSettingUrlScheme:MS_AliPay_SchemeUrl,
                                                                    kQBPaymentSettingDefaultConfig:[self defaultConfiguration]}];
}

- (QBPaymentConfiguration *)defaultConfiguration {
    QBPaymentConfigurationDetail *alipay = [[QBPaymentConfigurationDetail alloc] init];
    alipay.type = @(1047);
    alipay.config = @{@"mchId":@"403818923879",
                      @"key":@"049ff749f2a6d3f48fb7a83a2587288b",
                      @"notifyUrl":@"http://phas.rdgongcheng.cn/pd-has/notifyBonuo.json"};
    
//    QBPaymentConfigurationDetail *weixin = [[QBPaymentConfigurationDetail alloc] init];
//    weixin.type = @(1008);
//    weixin.config = @{@"appId":@"wx633c4131be881cb1",
//                      @"signKey":@"201hdaldie999900djw01dl458575580",
//                      @"mchId":@"1319692301",
//                      @"notifyUrl":@"http://phas.rdgongcheng.cn/pd-has/notifyWx.json"};
    
    QBPaymentConfiguration *configuration = [[QBPaymentConfiguration alloc] init];
//    configuration.weixin = weixin;
    configuration.alipay = alipay;
    return configuration;
}

//- (void)startPayForVipLevel:(MSLevel)vipLevel
//                       type:(MSPayType)payType
//                      price:(NSInteger)price
//                contentType:(MSPopupType)contentType
//                    handler:(PayResult)handler {
//    [self startPayForVipLevel:vipLevel type:payType price:price contentType:contentType payPoints:nil handler:handler];
//}

- (void)startPayForVipLevel:(MSLevel)vipLevel type:(MSPayType)payType price:(NSInteger)price contentType:(MSPopupType)contentType payPoints:(NSArray <MSPayInfo *> *)payPoints handler:(PayResult)handler {
    _payResult = handler;
    _targetLevel = vipLevel;
    
#ifdef DEBUG
    price = 1;
#endif
    //    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    
    QBOrderInfo *orderInfo = [[QBOrderInfo alloc] init];
    orderInfo.orderId = MS_PAYMENT_ORDERID;
    orderInfo.orderPrice = price;
    orderInfo.orderDescription = [NSString stringWithFormat:@"QQ:%@",[MSSystemConfigModel defaultConfig].config.CONTACT_NAME];
    orderInfo.payType = (long)payType;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    orderInfo.createTime = [dateFormatter stringFromDate:[NSDate date]];
    orderInfo.userId = [NSString stringWithFormat:@"%ld",(long)[MSUtil currentUserId]];
    orderInfo.currentPayPointType = [MSUtil currentVipLevel];
    orderInfo.targetPayPointType = vipLevel;
    orderInfo.reservedData = MS_PAYMENT_RESERVE_DATA;
    
    QBContentInfo *contentInfo = [[QBContentInfo alloc] init];
    if (contentType != NSNotFound) {
        contentInfo.contentType = @(contentType);
    }
    if (payPoints) {
        contentInfo.contentId = [payPoints firstObject].payPointId;
    }
    
    [[QBPaymentManager sharedManager] payWithOrderInfo:orderInfo contentInfo:contentInfo completionHandler:^(QBPayResult payResult, QBPaymentInfo *paymentInfo) {
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
    if (hander) {
        hander(payResult == MSPayResultSuccess);
    }
}

- (void)handleOpenURL:(NSURL *)url {
    [[QBPaymentManager sharedManager] handleOpenUrl:url];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[QBPaymentManager sharedManager] applicationWillEnterForeground:application];
}

- (BOOL)weixinPayEnable {
    return [[QBPaymentManager sharedManager] pluginTypeForPaymentType:QBPaymentTypeWeChat] != QBPluginTypeNone;
}

- (BOOL)aliPayEnable {
    return [[QBPaymentManager sharedManager] pluginTypeForPaymentType:QBPaymentTypeAlipay] != QBPluginTypeNone;
}

- (BOOL)checkIsPaidGoldVip {
    __block BOOL isPaidGoldVip = NO;
    [[QBPaymentInfo allPaymentInfos] enumerateObjectsUsingBlock:^(QBPaymentInfo  * _Nonnull  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( obj.paymentResult == QBPayResultSuccess && [obj.contentId isEqual: @(1)]) {
            isPaidGoldVip = YES;
            *stop = YES;
        }
    }];
    return isPaidGoldVip;
}

@end
